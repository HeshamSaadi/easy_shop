import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.client,
    required this.onUpdated,
    required this.pickPicture,
  });

  final ClientEntity client;
  final VoidCallback onUpdated;
  final Future<String?> Function() pickPicture;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _picturePath;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _emailController = TextEditingController(text: widget.client.email);
    _phoneController = TextEditingController(text: widget.client.phone);
    _addressController = TextEditingController(text: widget.client.address);
    _latitude = widget.client.latitude;
    _longitude = widget.client.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    final path = await widget.pickPicture();
    if (path != null) {
      setState(() => _picturePath = path);
      if (mounted) {
        context.read<ProfileCubit>().clearFieldError('picture');
      }
    }
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final params = UpdateProfileParams(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      picturePath: _picturePath,
    );

    context.read<ProfileCubit>().updateProfile(params);
  }

  void _onStatusChanged(BuildContext context, ProfileState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case ProfileUpdateSuccess():
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        widget.onUpdated();
      case ProfileUpdateError(:final message):
        messenger.showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : ErrorMessages.unknown),
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: _onStatusChanged,
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;

        return Scaffold(
          appBar: const AppTopBar(title: 'Edit Profile', showBack: true),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: primary.withValues(alpha: 0.1),
                            backgroundImage: _picturePath != null
                                ? NetworkImage(_picturePath!)
                                : (widget.client.pictureUrl != null
                                      ? NetworkImage(widget.client.pictureUrl!)
                                      : null),
                            child:
                                (_picturePath == null &&
                                    widget.client.pictureUrl == null)
                                ? Icon(Icons.person, size: 50, color: primary)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: primary,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: isLoading ? null : _pickPicture,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Name Field
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      validator: (value) =>
                          Validators.notEmpty(value, fieldName: 'Name'),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) =>
                          context.read<ProfileCubit>().clearFieldError('name'),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Email Field
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) =>
                          context.read<ProfileCubit>().clearFieldError('email'),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Phone Field
                    AppTextField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      controller: _phoneController,
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) =>
                          context.read<ProfileCubit>().clearFieldError('phone'),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Address Field
                    AppTextField(
                      label: 'Delivery Address',
                      hint: 'Enter your delivery address (optional)',
                      controller: _addressController,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      maxLines: 3,
                      onChanged: (_) => context
                          .read<ProfileCubit>()
                          .clearFieldError('address'),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Location Picker Button (TODO)
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Implement location picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Location Picker - Coming Soon!',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(
                        _latitude != null && _longitude != null
                            ? 'Location Set'
                            : 'Pick Location on Map',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Save Button
                    AppButton(
                      text: 'Save Changes',
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
