import 'package:easy_shop/apps/admin/admin_route_names.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_screen.dart';
import 'package:easy_shop/core/location/picked_location.dart' as core;
import 'package:easy_shop/core/utils/media_picker.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _sl = GetIt.instance;

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static PickedLocation? _toRecord(core.PickedLocation? location) {
    if (location == null) return null;
    return (latitude: location.latitude, longitude: location.longitude);
  }

  static Future<PickedLocation?> _pickLocation(BuildContext context) async {
    final result = await LocationPickerScreen.open(
      context,
      createCubit: () => _sl<LocationPickerCubit>(param1: null),
    );
    return _toRecord(result);
  }

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AdminRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final picker = _sl<MediaPicker>();
    return BlocProvider(
      create: (_) => _sl<RegisterCubit>(),
      child: RegisterScreen(
        onRegistered: () => _backToLogin(context),
        onExit: () => _backToLogin(context),
        pickDocument: picker.pickDocument,
        pickPicture: picker.pickPicture,
        pickLocation: () => _pickLocation(context),
      ),
    );
  }
}