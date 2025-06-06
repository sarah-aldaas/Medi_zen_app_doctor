import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';

import '../../cubit/qualification_cubit/qualification_cubit.dart';
import '../../pages/qualification_page.dart';

void showCreateQualificationDialog(BuildContext context) {
  final qualificationCubit = context.read<QualificationCubit>();

  final issuerController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  File? selectedPdfFile;
  CodeModel? selectedQualificationType;
  bool isUploadingPdf = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final isDarkMode = theme.brightness == Brightness.dark;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'qualificationPage.createNewQualification'.tr(context),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: theme.secondaryHeaderColor),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: issuerController,
                    decoration: InputDecoration(
                      labelText: 'qualificationPage.issuer'.tr(context),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(16),

                  FutureBuilder<List<CodeModel>>(
                    future:
                        context
                            .read<CodeTypesCubit>()
                            .getQualificationTypeCodes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'qualificationPage.errorLoadingTypes'.tr(context),
                          style: TextStyle(
                            color: isDarkMode ? Colors.red[300] : Colors.red,
                          ),
                        );
                      }
                      final qualificationTypes = snapshot.data ?? [];
                      return DropdownButtonFormField<CodeModel>(
                        value: selectedQualificationType,
                        decoration: InputDecoration(
                          labelText: 'qualificationPage.type'.tr(context),
                        ),
                        dropdownColor:
                            isDarkMode ? Colors.grey[800] : Colors.white,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        items:
                            qualificationTypes.map((type) {
                              return DropdownMenuItem<CodeModel>(
                                value: type,
                                child: Text(
                                  type.display,
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQualificationType = value;
                          });
                        },
                      );
                    },
                  ),
                  const Gap(16),

                  TextField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'qualificationPage.startDate'.tr(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data:
                                    isDarkMode
                                        ? theme.copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.white,
                                            surface: Colors.grey[800]!,
                                            onSurface: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.primaryColor,
                                            ),
                                          ),
                                        )
                                        : theme.copyWith(
                                          colorScheme: theme.colorScheme
                                              .copyWith(
                                                primary: theme.primaryColor,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black87,
                                              ),
                                        ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            startDateController.text =
                                date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(16),

                  TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'qualificationPage.endDate'.tr(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data:
                                    isDarkMode
                                        ? theme.copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.white,
                                            surface: Colors.grey[800]!,
                                            onSurface: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.primaryColor,
                                            ),
                                          ),
                                        )
                                        : theme.copyWith(
                                          colorScheme: theme.colorScheme
                                              .copyWith(
                                                primary: theme.primaryColor,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black87,
                                              ),
                                        ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            endDateController.text =
                                date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.upload_file,
                            color:
                                theme.buttonTheme.colorScheme?.onPrimary ??
                                Colors.white,
                          ),
                          label: Text(
                            selectedPdfFile != null
                                ? selectedPdfFile!.path.split('/').last
                                : 'qualificationPage.selectPdf'.tr(context),
                            style: TextStyle(
                              color:
                                  theme.buttonTheme.colorScheme?.onPrimary ??
                                  Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );
                            if (result != null) {
                              setState(() {
                                selectedPdfFile = File(
                                  result.files.single.path!,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (selectedPdfFile != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: theme.primaryColor,
                          ),
                          onPressed:
                              () => viewPdfLocally(context, selectedPdfFile!),
                          tooltip: 'qualificationPage.viewSelectedPdf'.tr(
                            context,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isUploadingPdf) ...[
                    const Gap(8),
                    LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                      backgroundColor:
                          isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                    ),
                    const Gap(8),
                    Text(
                      'qualificationPage.uploadingPdf'.tr(context),
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                  const Gap(24),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'qualificationPage.cancel'.tr(context),
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed:
                    isUploadingPdf
                        ? null
                        : () async {
                          if (issuerController.text.trim().isEmpty ||
                              startDateController.text.trim().isEmpty ||
                              selectedQualificationType == null ||
                              selectedPdfFile == null) {
                            ShowToast.showToastError(
                              message: 'qualificationPage.allFieldsRequired'.tr(
                                context,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isUploadingPdf = true;
                          });

                          final newQualification = QualificationModel(
                            id: "0",
                            issuer: issuerController.text.trim(),
                            startDate: startDateController.text.trim(),
                            endDate:
                                endDateController.text.trim().isNotEmpty
                                    ? endDateController.text.trim()
                                    : null,
                            pdfFileName: selectedPdfFile!.path.split('/').last,
                            type: selectedQualificationType!,
                          );

                          try {
                            await qualificationCubit.createQualification(
                              qualificationModel: newQualification,
                              pdfFile: selectedPdfFile!,
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ShowToast.showToastError(
                              message:
                                  'qualificationPage.errorCreatingQualification'
                                      .tr(context),
                            );
                          } finally {
                            setState(() {
                              isUploadingPdf = false;
                            });
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('qualificationPage.create'.tr(context)),
              ),
            ],
          );
        },
      );
    },
  );
}
