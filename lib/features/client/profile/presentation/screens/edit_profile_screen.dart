import 'dart:io';

import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/picker_field.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/presentation/constants/profile_strings.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Expects an [EditProfileCubit] above it (the router provides it).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.client,
    required this.onUpdated,
    required this.pickPicture,
    required this.onPickLocation,
  });

  final ClientEntity client;
  final VoidCallback onUpdated;
  final Future<String?> Function() pickPicture;
  final Future<PickedLocation?> Function() onPickLocation;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _coordinateDigits = 5;
  static const double _badgeSize = 32;
  static const double _badgeIconSize = 18;
  static const double _avatarTintAlpha = 0.1;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _picturePath;
  double? _latitude;
  double? _longitude;
  String? _pickedAddress;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _nameController = TextEditingController(text: client.name);
    _emailController = TextEditingController(text: client.email);
    _phoneController = TextEditingController(text: client.phone);
    _addressController = TextEditingController(text: client.address);
    _latitude = client.latitude;
    _longitude = client.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? get _locationSummary {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return null;

    final address = _pickedAddress;
    if (address != null && address.isNotEmpty) return address;

    final latText = lat.toStringAsFixed(_coordinateDigits);
    final lngText = lng.toStringAsFixed(_coordinateDigits);
    return '$latText, $lngText';
  }

  Future<void> _pickPicture() async {
    final path = await widget.pickPicture();
    if (path == null || !mounted) return;
    setState(() => _picturePath = path);
  }

  Future<void> _pickLocation() async {
    final picked = await widget.onPickLocation();
    if (picked == null || !mounted) return;

    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
      _pickedAddress = picked.address;
    });

    // Fill the address only if the user did not type one.
    final resolved = picked.address;
    if (resolved != null && _addressController.text.trim().isEmpty) {
      _addressController.text = resolved;
    }
  }

  /// The server error for [field], read from the cubit so it is never stale.
  String? _serverError(String field) {
    return context.read<EditProfileCubit>().state.fieldError(field);
  }

  FormFieldValidator<String> _withServerError(
    String field,
    FormFieldValidator<String> base,
  ) {
    return (value) => base(value) ?? _serverError(field);
  }

  void _clearError(String field) {
    context.read<EditProfileCubit>().clearFieldError(field);
  }

  void _submit() {
    final cubit = context.read<EditProfileCubit>();
    cubit.clearFieldErrors();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    cubit.save(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      latitude: _latitude,
      longitude: _longitude,
      picturePath: _picturePath,
    );
  }

  void _onStatusChanged(BuildContext context, EditProfileState state) {
    final messenger = ScaffoldMessenger.of(context);

    switch (state.status) {
      case EditProfileStatus.success:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(ProfileStrings.profileUpdated)),
          );
        widget.onUpdated();

      case EditProfileStatus.error:
        if (state.fieldErrors.isEmpty) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? ErrorMessages.unknown),
              ),
            );
        } else {
          // Runs the validators again, so server errors show under the fields.
          _formKey.currentState?.validate();
        }

      case EditProfileStatus.initial:
      case EditProfileStatus.saving:
        break;
    }
  }

  Widget _buildAvatar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = colors.primary.withValues(alpha: _avatarTintAlpha);

    final path = _picturePath;

    // AppAvatar loads network images only, so a picked file needs FileImage.
    if (path == null) {
      return AppAvatar(
        imageUrl: widget.client.pictureUrl,
        size: AppSizes.avatarLg,
        backgroundColor: background,
        iconColor: colors.primary,
      );
    }

    return CircleAvatar(
      radius: AppSizes.avatarLg / 2,
      backgroundColor: background,
      foregroundImage: FileImage(File(path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      builder: (context, state) {
        final isLoading = state.isSaving;

        return Scaffold(
          appBar: const AppTopBar(
            title: ProfileStrings.editProfileTitle,
            showBack: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          _buildAvatar(context),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: isLoading ? null : _pickPicture,
                              child: Container(
                                width: _badgeSize,
                                height: _badgeSize,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: _badgeIconSize,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppTextField(
                      label: ProfileStrings.fullName,
                      hint: ProfileStrings.enterFullName,
                      controller: _nameController,
                      validator: _withServerError(
                        'name',
                        (value) => Validators.notEmpty(
                          value,
                          fieldName: ProfileStrings.name,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('name'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: ProfileStrings.email,
                      hint: ProfileStrings.enterEmail,
                      controller: _emailController,
                      validator: _withServerError('email', Validators.email),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('email'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: ProfileStrings.phoneNumber,
                      hint: ProfileStrings.enterPhoneNumber,
                      controller: _phoneController,
                      validator: _withServerError(
                        'phone',
                        Validators.egyptianPhone,
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('phone'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: ProfileStrings.deliveryAddressLabel,
                      hint: ProfileStrings.enterAddress,
                      controller: _addressController,
                      validator: (_) => _serverError('address'),
                      isOptional: true,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('address'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PickerField(
                      label: ProfileStrings.locationLabel,
                      placeholder: ProfileStrings.pickLocationOnMap,
                      icon: Icons.location_on_outlined,
                      value: _locationSummary,
                      isOptional: true,
                      onTap: isLoading ? null : _pickLocation,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppButton(
                      text: ProfileStrings.saveChanges,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
