import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

import '../../../../../../../../../base/theme/app_color.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/models/telecom_model.dart';
import '../../cubit/telecom_cubit/telecom_cubit.dart';

void showUpdateTelecomDialog({
  required BuildContext context,
  required TelecomModel telecom,
  required TelecomCubit telecomCubit,
  required Future<List<CodeModel>> telecomTypesFuture,
  required Future<List<CodeModel>> telecomUseFuture,
}) {
  final valueController = TextEditingController(text: telecom.value);
  CodeModel? selectedType = telecom.type;
  CodeModel? selectedUse = telecom.use;

  showDialog(
    context: context,
    builder: (dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);
      return AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        surfaceTintColor: theme.dialogTheme.surfaceTintColor,
        content: FutureBuilder<List<List<CodeModel>>>(
          future: Future.wait([telecomTypesFuture, telecomUseFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: LoadingButton(isWhite: false)),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text('telecomPage.errorLoadingData'.tr(context)),
                ),
              );
            }

            final telecomTypes = snapshot.data![0];
            final telecomUses = snapshot.data![1];

            selectedType = telecomTypes.firstWhere(
              (type) => type.id == (telecom.type?.id ?? ''),
              orElse:
                  () =>
                      telecomTypes.isNotEmpty
                          ? telecomTypes.first
                          : null as CodeModel,
            );
            selectedUse = telecomUses.firstWhere(
              (use) => use.id == (telecom.use?.id ?? ''),
              orElse:
                  () =>
                      telecomUses.isNotEmpty
                          ? telecomUses.first
                          : null as CodeModel,
            );

            return StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'telecomPage.updateTelecom'.tr(context),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.cancel,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      TextField(
                        controller: valueController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'telecomPage.valueLabel'.tr(context),
                        ),
                      ),
                      const Gap(20),
                      DropdownButtonFormField<CodeModel>(
                        items:
                            telecomTypes
                                .map(
                                  (type) => DropdownMenuItem<CodeModel>(
                                    value: type,
                                    child: Text(type.display),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedType = value),
                        decoration: InputDecoration(
                          labelText: 'telecomPage.typeLabel'.tr(context),
                        ),
                        value: selectedType,
                      ),
                      const Gap(20),
                      DropdownButtonFormField<CodeModel>(
                        items:
                            telecomUses
                                .map(
                                  (use) => DropdownMenuItem<CodeModel>(
                                    value: use,
                                    child: Text(use.display),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedUse = value),
                        decoration: InputDecoration(
                          labelText: 'telecomPage.useLabel'.tr(context),
                        ),
                        value: selectedUse,
                      ),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'telecomPage.cancel'.tr(context),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const Gap(30),
                          ElevatedButton(
                            onPressed: () {
                              if (valueController.text.isNotEmpty &&
                                  selectedType != null &&
                                  selectedUse != null) {
                                final updatedTelecom = TelecomModel(
                                  id: telecom.id,
                                  value: valueController.text,

                                  startDate: telecom.startDate,
                                  endDate: telecom.endDate,
                                  type: selectedType,
                                  use: selectedUse,
                                  useId: selectedUse!.id,
                                  typeId: selectedType!.id,
                                  rank: '',
                                );
                                telecomCubit.updateTelecom(
                                  context: context,
                                  id: telecom.id!,
                                  telecomModel: updatedTelecom,
                                );
                                Navigator.pop(context);
                              } else {
                                ShowToast.showToastError(
                                  message: 'telecomPage.allFieldsRequired'.tr(
                                    context,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor
                                  .withOpacity(0.7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              'telecomPage.update'.tr(context),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

void showCreateTelecomDialog({
  required BuildContext context,
  required TelecomCubit telecomCubit,
  required Future<List<CodeModel>> telecomTypesFuture,
  required Future<List<CodeModel>> telecomUseFuture,
}) {
  final valueController = TextEditingController();
  final ValueNotifier<CodeModel?> selectedTypeNotifier = ValueNotifier(null);
  final ValueNotifier<CodeModel?> selectedUseNotifier = ValueNotifier(null);

  showDialog(
    context: context,
    builder: (dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);

      return AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        surfaceTintColor: theme.dialogTheme.surfaceTintColor,

        contentPadding: const EdgeInsets.all(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: FutureBuilder<List<List<CodeModel>>>(
          future: Future.wait([telecomTypesFuture, telecomUseFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 180,
                child: Center(child: LoadingButton(isWhite: false)),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text('telecomPage.errorLoadingData'.tr(context)),
                ),
              );
            }

            final telecomTypes = snapshot.data![0];
            final telecomUses = snapshot.data![1];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'telecomPage.createNewTelecom'.tr(context),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.secondaryColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const Gap(30),
                  TextField(
                    controller: valueController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'telecomPage.valueLabel'.tr(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const Gap(30),
                  ValueListenableBuilder<CodeModel?>(
                    valueListenable: selectedTypeNotifier,
                    builder: (context, selectedType, child) {
                      return DropdownButtonFormField<CodeModel>(
                        items:
                            telecomTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type.display,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          selectedTypeNotifier.value = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'telecomPage.typeLabel'.tr(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        value: selectedType,
                        hint: Text('telecomPage.selectType'.tr(context)),
                      );
                    },
                  ),
                  const Gap(30),
                  ValueListenableBuilder<CodeModel?>(
                    valueListenable: selectedUseNotifier,
                    builder: (context, selectedUse, child) {
                      return DropdownButtonFormField<CodeModel>(
                        items:
                            telecomUses
                                .map(
                                  (use) => DropdownMenuItem(
                                    value: use,
                                    child: Text(
                                      use.display,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          selectedUseNotifier.value = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'telecomPage.useLabel'.tr(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        value: selectedUse,
                        hint: Text('telecomPage.selectUse'.tr(context)),
                      );
                    },
                  ),
                  const Gap(40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'telecomPage.cancel'.tr(context),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(20),
                      ElevatedButton(
                        onPressed: () {
                          if (valueController.text.isNotEmpty &&
                              selectedTypeNotifier.value != null &&
                              selectedUseNotifier.value != null) {
                            final newTelecom = TelecomModel(
                              id: '',
                              value: valueController.text,

                              startDate: null,
                              endDate: null,
                              type: selectedTypeNotifier.value!,
                              use: selectedUseNotifier.value!,
                              typeId: selectedTypeNotifier.value!.id,
                              useId: selectedUseNotifier.value!.id,
                              rank: '',
                            );
                            telecomCubit.createTelecom(
                              context: context,
                              telecomModel: newTelecom,
                            );
                            Navigator.pop(context);
                          } else {
                            ShowToast.showToastError(
                              message: 'telecomPage.allFieldsRequired'.tr(
                                context,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'telecomPage.create'.tr(context),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void showUpdateDeleteTelecomDialog({
  required BuildContext context,
  required TelecomModel telecom,
  required TelecomCubit telecomCubit,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);

      return AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        surfaceTintColor: theme.dialogTheme.surfaceTintColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'telecomPage.manageTelecom'.tr(context),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.dangerous_outlined,
                color: AppColors.secondaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${'telecomPage.value'.tr(context)}: ${telecom.value ?? 'telecomPage.notAvailable'.tr(context)}",
              style: const TextStyle(fontSize: 18),
            ),
            const Gap(13),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext);

                showUpdateTelecomDialog(
                  context: context,
                  telecom: telecom,
                  telecomCubit: telecomCubit,
                  telecomTypesFuture: Future.value([]),
                  telecomUseFuture: Future.value([]),
                );
              },
              child: Container(
                width: context.width / 2,
                decoration: BoxDecoration(
                  color: AppColors.update,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                child: Text(
                  'telecomPage.update'.tr(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                telecomCubit.deleteTelecom(id: telecom.id!,context: context);
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                width: context.width / 2,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'telecomPage.delete'.tr(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
