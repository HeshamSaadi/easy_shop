import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/picker_field.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_fields.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_step_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessStep extends StatefulWidget {
  const BusinessStep({
    super.key,
    required this.pickDocument,
    required this.pickLocation,
  });

  final PickFile pickDocument;
  final PickLocation pickLocation;

  @override
  State<BusinessStep> createState() => _BusinessStepState();
}

class _BusinessStepState extends State<BusinessStep>
    with ServerFieldErrors<BusinessStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessName;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterCubit>().state.draft;
    _businessName = TextEditingController(text: draft.businessName);
    _address = TextEditingController(text: draft.address);
  }

  @override
  void dispose() {
    _businessName.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final cubit = context.read<RegisterCubit>();
    final location = await widget.pickLocation();
    if (location == null || !mounted) return;
    cubit.setLocation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  Future<void> _pickCommercialRegister() async {
    final cubit = context.read<RegisterCubit>();
    final path = await widget.pickDocument();
    if (path == null || !mounted) return;
    cubit.setCommercialRegister(path);
  }

  Future<void> _pickTaxCard() async {
    final cubit = context.read<RegisterCubit>();
    final path = await widget.pickDocument();
    if (path == null || !mounted) return;
    cubit.setTaxCard(path);
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RegisterCubit>().saveBusiness(
      businessName: _businessName.text,
      address: _address.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft ||
          previous.fieldErrors != current.fieldErrors,
      builder: (context, state) {
        final draft = state.draft;
        return RegisterStepForm(
          formKey: _formKey,
          children: [
            Text(
              AuthStrings.headingBusiness,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppTextField(
              label: AuthStrings.businessName,
              hint: AuthStrings.businessNameHint,
              controller: _businessName,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.notEmpty(
                    value,
                    fieldName: AuthStrings.businessName,
                  ) ??
                  serverError(RegisterFields.businessName),
              onChanged: (_) => clearServerError(RegisterFields.businessName),
            ),
            AppTextField(
              label: AuthStrings.businessAddress,
              hint: AuthStrings.businessAddressHint,
              controller: _address,
              isOptional: true,
              textInputAction: TextInputAction.done,
              validator: (_) => serverError(RegisterFields.address),
              onChanged: (_) => clearServerError(RegisterFields.address),
            ),
            PickerField(
              label: AuthStrings.storeLocation,
              placeholder: AuthStrings.tapToSetLocation,
              icon: Icons.location_on_outlined,
              isOptional: true,
              value: draft.hasLocation ? AuthStrings.locationSet : null,
              errorText:
                  state.fieldError(RegisterFields.latitude) ??
                  state.fieldError(RegisterFields.longitude),
              onTap: _pickLocation,
            ),
            PickerField.file(
              label: AuthStrings.commercialRegister,
              placeholder: AuthStrings.uploadCommercialRegister,
              isOptional: true,
              filePath: draft.commercialRegisterPath,
              errorText: state.fieldError(RegisterFields.commercialRegister),
              onTap: _pickCommercialRegister,
            ),
            PickerField.file(
              label: AuthStrings.taxCard,
              placeholder: AuthStrings.uploadTaxCard,
              isOptional: true,
              filePath: draft.taxCardPath,
              errorText: state.fieldError(RegisterFields.taxCard),
              onTap: _pickTaxCard,
            ),
            AppButton(text: AuthStrings.continueLabel, onPressed: _continue),
          ],
        );
      },
    );
  }
}
