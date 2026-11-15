import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/client/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';

/// Records the calls the profile makes, and answers with [response].
class _RecordingProfileApi extends FakeApiConsumer {
  dynamic response;

  final List<String> getPaths = [];
  final List<({String path, Object? data})> putCalls = [];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    getPaths.add(path);
    return response;
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    putCalls.add((path: path, data: data));
    return response;
  }
}

Map<String, dynamic> _profileResponse() => {
  'data': {
    'id': 68,
    'name': 'Ahmed',
    'email': 'ahmed@example.com',
    'phone': '+201013114901',
    'address': null,
    'latitude': null,
    'longitude': null,
    'picture_url': 'https://host/assets/images/default.png',
  },
  'message': 'ok',
};

void main() {
  late _RecordingProfileApi api;
  late ProfileRemoteDataSourceImpl dataSource;
  Directory? tempDir;

  setUp(() {
    api = _RecordingProfileApi()..response = _profileResponse();
    dataSource = ProfileRemoteDataSourceImpl(api);
  });

  tearDown(() async {
    await tempDir?.delete(recursive: true);
    tempDir = null;
  });

  Future<FormData> update({
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    await dataSource.updateProfile(
      name: 'Ahmed',
      email: 'ahmed@example.com',
      phone: '+201013114901',
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    );
    expect(api.putCalls.single.path, EndPoints.clientProfileUpdate);
    return api.putCalls.single.data as FormData;
  }

  group('getProfile', () {
    test('gets the profile endpoint and parses the client', () async {
      final client = await dataSource.getProfile();

      expect(api.getPaths, [EndPoints.clientProfile]);
      expect(client.id, 68);
      expect(client.name, 'Ahmed');
      expect(client.address, isNull);
    });
  });

  group('updateProfile', () {
    test('sends the required fields as form-data', () async {
      final form = await update();

      expect(Map.fromEntries(form.fields), {
        'name': 'Ahmed',
        'email': 'ahmed@example.com',
        'phone': '+201013114901',
      });
      expect(form.files, isEmpty);
    });

    test('leaves out the optional fields that are null', () async {
      final form = await update();

      final keys = form.fields.map((e) => e.key);
      expect(keys, isNot(contains('address')));
      expect(keys, isNot(contains('latitude')));
      expect(keys, isNot(contains('longitude')));
    });

    test('sends the address and the coordinates when given', () async {
      final form = await update(
        address: '123 Tahrir Square',
        latitude: 30.0444,
        longitude: 31.2357,
      );

      final fields = Map.fromEntries(form.fields);
      expect(fields['address'], '123 Tahrir Square');
      expect(fields['latitude'], '30.0444');
      expect(fields['longitude'], '31.2357');
    });

    test('sends the picture only when a path is given', () async {
      tempDir = await Directory.systemTemp.createTemp('profile_test');
      final file = File('${tempDir!.path}/photo.jpg');
      await file.writeAsBytes([1, 2, 3]);

      final form = await update(picturePath: file.path);

      expect(form.files.map((e) => e.key), ['picture']);
    });

    test('parses the response into a client', () async {
      final client = await dataSource.updateProfile(
        name: 'Ahmed',
        email: 'ahmed@example.com',
        phone: '+201013114901',
      );

      expect(client.id, 68);
      expect(client.pictureUrl, endsWith('default.png'));
    });
  });
}
