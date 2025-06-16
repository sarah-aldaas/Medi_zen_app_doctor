import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/network/network_client.dart';
import '../cubit/qualification_cubit/qualification_cubit.dart';
import '../widgets/qualification/create_qualification_dialog.dart';
import '../widgets/qualification/error_widget.dart';
import '../widgets/qualification/qualification_card.dart';
import '../widgets/qualification/qualification_details_dialog.dart';
import '../widgets/qualification/update_qualification_dialog.dart';

class QualificationPage extends StatefulWidget {
  const QualificationPage({super.key});

  @override
  State<QualificationPage> createState() => _QualificationPageState();
}

class _QualificationPageState extends State<QualificationPage> {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadComplete = {};
  final Dio _dio = serviceLocator<NetworkClient>().dio;

  @override
  void initState() {
    _fetchQualifications();
    super.initState();
  }

  Future<void> _fetchQualifications() async {
    await context.read<QualificationCubit>().fetchQualifications(
      context: context,
      paginationCount: '100',
    );
  }

  Future<void> _downloadAndViewPdf(
      String pdfUrl,
      String qualificationId,
      ) async {
    try {
      if (!Uri.parse(pdfUrl).isAbsolute) {
        throw Exception('Invalid PDF URL');
      }

      setState(() {
        _downloadProgress[qualificationId] = 0.0;
        _downloadComplete[qualificationId] = false;
      });

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception(
            'Storage permission denied. Please allow storage access.',
          );
        }
      }

      Directory directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory() ??
                await getTemporaryDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/qualification_$qualificationId.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress[qualificationId] = received / total;
            });
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (!await file.exists() || (await file.length()) == 0) {
        throw Exception('Downloaded file is invalid or empty');
      }

      setState(() {
        _downloadComplete[qualificationId] = true;
      });

      final result = await OpenFilex.open(filePath, type: 'application/pdf');
      if (result.type != ResultType.done) {
        throw Exception('Failed to open PDF: ${result.message}');
      }
    } catch (e) {
      ShowToast.showToastError(message: 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _downloadProgress.remove(qualificationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text(
          'qualificationPage.qualifications'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () {
              showCreateQualificationDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<QualificationCubit, QualificationState>(
        listener: (context, state) {
          if (state is QualificationError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is QualificationInitial || state is QualificationLoading) {
            return Center(child: LoadingButton());
          }

          if (state is QualificationError) {
            return QualificationErrorWidget(state.error, _fetchQualifications);
          }

          if (state is QualificationSuccess) {
            final qualifications =
                state.paginatedResponse.paginatedData?.items ?? [];

            if (qualifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('qualificationPage.noQualifications'.tr(context)),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        showCreateQualificationDialog(context);
                      },
                      child: Text('qualificationPage.addFirst'.tr(context)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _fetchQualifications,
              child: ListView.builder(
                itemCount: qualifications.length,
                itemBuilder: (context, index) {
                  final qualification = qualifications[index];
                  return QualificationCard(
                    qualification: qualification,
                    downloadProgress:
                    _downloadProgress[qualification.id.toString()],
                    downloadComplete:
                    _downloadComplete[qualification.id.toString()] ?? false,
                    onDownloadAndViewPdf:
                        (pdfUrl, id) => _downloadAndViewPdf(pdfUrl, id),
                    onEdit:
                        (qual) => showUpdateQualificationDialog(context, qual),
                    onDelete: (id) {
                      serviceLocator<QualificationCubit>().deleteQualification(
                        id: id.toString(),
                        context: context
                      );
                    },
                    onViewDetails:
                        (qual) => showQualificationDetailsDialog(
                      context,
                      qual,
                      _downloadProgress,
                      _downloadComplete,
                      _downloadAndViewPdf,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Future<void> viewPdfLocally(BuildContext context, File pdfFile) async {
  try {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    final directory =
    Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    if (directory == null) {
      throw Exception('Could not access storage');
    }

    final filePath = '${directory.path}/temp_qualification_preview.pdf';
    final newFile = File(filePath);
    await newFile.writeAsBytes(await pdfFile.readAsBytes());

    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open PDF: ${result.message}');
    }
  } catch (e) {
    ShowToast.showToastError(message: 'Error viewing PDF: ${e.toString()}');
  }
}

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';
// import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
// import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
// import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
// import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
// import '../../../../base/data/models/code_type_model.dart';
// import '../../../../base/helpers/enums.dart';
// import '../../../../base/services/di/injection_container_common.dart';
// import '../../../../base/configuration/app_config.dart';
// import '../../../../base/services/network/network_client.dart';
// import '../../../../base/theme/app_color.dart';
// import '../cubit/qualification_cubit/qualification_cubit.dart';
//
// class QualificationPage extends StatefulWidget {
//   const QualificationPage({super.key});
//
//   @override
//   State<QualificationPage> createState() => _QualificationPageState();
// }
//
// class _QualificationPageState extends State<QualificationPage> {
//   final Map<String, double> _downloadProgress = {};
//   final Map<String, bool> _downloadComplete = {};
//   final Dio _dio = serviceLocator<NetworkClient>().dio;
//   File? _selectedPdfFile;
//   CodeModel? _selectedQualificationType;
//   bool _isUploadingPdf = false;
//
//   @override
//   void initState() {
//     _fetchQualifications();
//     super.initState();
//   }
//
//
//   Future<void> _fetchQualifications() async {
//     await context.read<QualificationCubit>().fetchQualifications(paginationCount: '100');
//   }
//
//   Future<void> _downloadAndViewPdf(String pdfUrl, String qualificationId) async {
//     try {
//       if (!Uri.parse(pdfUrl).isAbsolute) {
//         throw Exception('Invalid PDF URL');
//       }
//
//       setState(() {
//         _downloadProgress[qualificationId] = 0.0;
//         _downloadComplete[qualificationId] = false;
//       });
//
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           throw Exception('Storage permission denied. Please allow storage access.');
//         }
//       }
//
//       Directory directory;
//       if (Platform.isAndroid) {
//         directory = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }
//
//       final filePath = '${directory.path}/qualification_$qualificationId.pdf';
//       final file = File(filePath);
//
//       if (await file.exists()) {
//         await file.delete();
//       }
//
//       await _dio.download(
//         pdfUrl,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             setState(() {
//               _downloadProgress[qualificationId] = received / total;
//             });
//           }
//         },
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       if (!await file.exists() || (await file.length()) == 0) {
//         throw Exception('Downloaded file is invalid or empty');
//       }
//
//       setState(() {
//         _downloadComplete[qualificationId] = true;
//       });
//
//       final result = await OpenFilex.open(filePath, type: 'application/pdf');
//       if (result.type != ResultType.done) {
//         throw Exception('Failed to open PDF: ${result.message}');
//       }
//     } catch (e) {
//       ShowToast.showToastError(message: 'Error: ${e.toString()}');
//     } finally {
//       setState(() {
//         _downloadProgress.remove(qualificationId);
//       });
//     }
//   }
//   void _showUpdateDialog(QualificationModel qualification, BuildContext context) async {
//     final qualificationCubit = context.read<QualificationCubit>();
//     final issuerController = TextEditingController(text: qualification.issuer);
//     final startDateController = TextEditingController(text: qualification.startDate);
//     final endDateController = TextEditingController(text: qualification.endDate);
//
//     _selectedPdfFile = null;
//     _isUploadingPdf = false;
//
//     final qualificationTypes = await context.read<CodeTypesCubit>().getQualificationTypeCodes();
//
//     _selectedQualificationType = qualificationTypes.firstWhere(
//           (type) => type.id == qualification.type!.id,
//       orElse: () => qualification.type!,
//     );
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'qualificationPage.updateQualification'.tr(context),
//                   style: TextStyle(
//                     color: Theme.of(context).primaryColor,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, color: AppColors.secondaryColor),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: issuerController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.issuer'.tr(context),
//                     ),
//                   ),
//                   const Gap(16),
//                   if (qualificationTypes.isNotEmpty)
//                     DropdownButtonFormField<CodeModel>(
//                       value: qualificationTypes.any((type) => type.id == _selectedQualificationType!.id)
//                           ? _selectedQualificationType
//                           : null,
//                       items: qualificationTypes.map((type) {
//                         return DropdownMenuItem<CodeModel>(
//                           value: type,
//                           child: Text(type.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedQualificationType = value;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'qualificationPage.type'.tr(context),
//                       ),
//                     )
//                   else
//                     const Text('No qualification types available'),
//                   const Gap(16),
//                   TextField(
//                     controller: startDateController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.startDate'.tr(context),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.calendar_today),
//                         onPressed: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime.now(),
//                           );
//                           if (date != null) {
//                             startDateController.text = date.toIso8601String().split('T')[0];
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const Gap(16),
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.endDate'.tr(context),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.calendar_today),
//                         onPressed: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime(2100),
//                           );
//                           if (date != null) {
//                             endDateController.text = date.toIso8601String().split('T')[0];
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const Gap(16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final result = await FilePicker.platform.pickFiles(
//                               type: FileType.custom,
//                               allowedExtensions: ['pdf'],
//                             );
//                             if (result != null) {
//                               setState(() {
//                                 _selectedPdfFile = File(result.files.single.path!);
//                               });
//                             }
//                           },
//                           child: Text(_selectedPdfFile != null
//                               ? _selectedPdfFile!.path.split('/').last
//                               : 'qualificationPage.selectPdf'.tr(context)),
//                         ),
//                       ),
//                       if (_selectedPdfFile != null) ...[
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: Icon(Icons.visibility, color: Theme.of(context).primaryColor),
//                           onPressed: () => _viewPdf(context, _selectedPdfFile!),
//                         ),
//                       ],
//                     ],
//                   ),
//                   if (_isUploadingPdf) ...[
//                     const Gap(8),
//                     const LinearProgressIndicator(),
//                     const Gap(8),
//                     Text('Uploading PDF...', style: TextStyle(color: Theme.of(context).primaryColor)),
//                   ],
//                   const Gap(24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text(
//                           'qualificationPage.cancel'.tr(context),
//                           style: TextStyle(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (issuerController.text.isNotEmpty &&
//                               startDateController.text.isNotEmpty &&
//                               _selectedQualificationType != null) {
//
//                             setState(() {
//                               _isUploadingPdf = true;
//                             });
//
//                             final updatedQualification = QualificationModel(
//                               id: qualification.id,
//                               issuer: issuerController.text,
//                               startDate: startDateController.text,
//                               endDate: endDateController.text.isNotEmpty ? endDateController.text : null,
//                               pdfFileName: _selectedPdfFile != null
//                                   ? _selectedPdfFile!.path.split('/').last
//                                   : qualification.pdfFileName,
//                               pdfUrl: qualification.pdfUrl,
//                               type: _selectedQualificationType!,
//                             );
//
//                             try {
//                               await qualificationCubit.updateQualification(
//                                 id: qualification.id.toString(),
//                                 qualificationModel: updatedQualification,
//                                 pdfFile: _selectedPdfFile,
//                               );
//                               Navigator.pop(context);
//                             } catch (e) {
//                               setState(() {
//                                 _isUploadingPdf = false;
//                               });
//                               ShowToast.showToastError(message: 'Error updating qualification: ${e.toString()}');
//                             }
//                           } else {
//                             ShowToast.showToastError(
//                               message: 'qualificationPage.requiredFields'.tr(context),
//                             );
//                           }
//                         },
//                         child: Text('qualificationPage.update'.tr(context)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showCreateDialog(BuildContext context) async {
//     final qualificationCubit = context.read<QualificationCubit>();
//     final issuerController = TextEditingController();
//     final startDateController = TextEditingController();
//     final endDateController = TextEditingController();
//
//     _selectedPdfFile = null;
//     _selectedQualificationType = null;
//     _isUploadingPdf = false;
//
//     final qualificationTypes = await context.read<CodeTypesCubit>().getQualificationTypeCodes();
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'qualificationPage.createNewQualification'.tr(context),
//                   style: TextStyle(
//                     color: Theme.of(context).primaryColor,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, color: AppColors.secondaryColor),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: issuerController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.issuer'.tr(context),
//                     ),
//                   ),
//                   const Gap(16),
//                   DropdownButtonFormField<CodeModel>(
//                     value: _selectedQualificationType,
//                     items: qualificationTypes.map((type) {
//                       return DropdownMenuItem<CodeModel>(
//                         value: type,
//                         child: Text(type.display),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedQualificationType = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.type'.tr(context),
//                     ),
//                   ),
//                   const Gap(16),
//                   TextField(
//                     controller: startDateController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.startDate'.tr(context),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.calendar_today),
//                         onPressed: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime.now(),
//                           );
//                           if (date != null) {
//                             startDateController.text = date.toIso8601String().split('T')[0];
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const Gap(16),
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'qualificationPage.endDate'.tr(context),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.calendar_today),
//                         onPressed: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime(2100),
//                           );
//                           if (date != null) {
//                             endDateController.text = date.toIso8601String().split('T')[0];
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const Gap(16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final result = await FilePicker.platform.pickFiles(
//                               type: FileType.custom,
//                               allowedExtensions: ['pdf'],
//                             );
//                             if (result != null) {
//                               setState(() {
//                                 _selectedPdfFile = File(result.files.single.path!);
//                               });
//                             }
//                           },
//                           child: Text(_selectedPdfFile != null
//                               ? _selectedPdfFile!.path.split('/').last
//                               : 'qualificationPage.selectPdf'.tr(context)),
//                         ),
//                       ),
//                       if (_selectedPdfFile != null) ...[
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: Icon(Icons.visibility, color: Theme.of(context).primaryColor),
//                           onPressed: () => _viewPdf(context, _selectedPdfFile!),
//                         ),
//                       ],
//                     ],
//                   ),
//                   if (_isUploadingPdf) ...[
//                     const Gap(8),
//                     const LinearProgressIndicator(),
//                     const Gap(8),
//                     Text('Uploading PDF...', style: TextStyle(color: Theme.of(context).primaryColor)),
//                   ],
//                   const Gap(24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text(
//                           'qualificationPage.cancel'.tr(context),
//                           style: TextStyle(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (issuerController.text.isNotEmpty &&
//                               startDateController.text.isNotEmpty &&
//                               _selectedQualificationType != null &&
//                               _selectedPdfFile != null) {
//
//                             setState(() {
//                               _isUploadingPdf = true;
//                             });
//
//                             final newQualification = QualificationModel(
//                               id: "0",
//                               issuer: issuerController.text,
//                               startDate: startDateController.text,
//                               endDate: endDateController.text.isNotEmpty ? endDateController.text : null,
//                               pdfFileName: _selectedPdfFile!.path.split('/').last,
//                               type: _selectedQualificationType!,
//                             );
//
//                             try {
//                               await qualificationCubit.createQualification(
//                                 qualificationModel: newQualification,
//                                 pdfFile: _selectedPdfFile!,
//                               );
//                               Navigator.pop(context);
//                             } catch (e) {
//                               setState(() {
//                                 _isUploadingPdf = false;
//                               });
//                               ShowToast.showToastError(message: 'Error creating qualification: ${e.toString()}');
//                             }
//                           } else {
//                             ShowToast.showToastError(
//                               message: 'qualificationPage.allFieldsRequired'.tr(context),
//                             );
//                           }
//                         },
//                         child: Text('qualificationPage.create'.tr(context)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showDetailsDialog(QualificationModel qualification) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'qualificationPage.qualificationDetails'.tr(context),
//               style: TextStyle(
//                 color: Theme.of(context).primaryColor,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: Icon(Icons.close, color: AppColors.secondaryColor),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildDetailRow(
//                 'qualificationPage.issuer'.tr(context),
//                 qualification.issuer!,
//               ),
//               _buildDetailRow(
//                 'qualificationPage.type'.tr(context),
//                 qualification.type!.display,
//               ),
//               _buildDetailRow(
//                 'qualificationPage.startDate'.tr(context),
//                 qualification.startDate!,
//               ),
//               _buildDetailRow(
//                 'qualificationPage.endDate'.tr(context),
//                 qualification.endDate ?? 'N/A',
//               ),
//               if (qualification.pdfFileName != null && qualification.pdfUrl != null) ...[
//                 _buildDetailRow(
//                   'qualificationPage.pdf'.tr(context),
//                   qualification.pdfFileName!,
//                 ),
//                 const Gap(8),
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     if (_downloadProgress.containsKey(qualification.id.toString()))
//                       SizedBox(
//                         width: 30,
//                         height: 30,
//                         child: CircularProgressIndicator(
//                           value: _downloadProgress[qualification.id.toString()],
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
//                         ),
//                       ),
//                     ElevatedButton(
//                       onPressed: _downloadProgress.containsKey(qualification.id.toString())
//                           ? null
//                           : () => _downloadAndViewPdf(
//                         qualification.pdfUrl!,
//                         qualification.id.toString(),
//                       ),
//                       child: Text('qualificationPage.viewPdf'.tr(context)),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('qualificationPage.close'.tr(context)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _viewPdf(BuildContext context, File pdfFile) async {
//     try {
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           throw Exception('Storage permission denied');
//         }
//       }
//
//       final directory = Platform.isAndroid
//           ? await getExternalStorageDirectory()
//           : await getApplicationDocumentsDirectory();
//
//       if (directory == null) {
//         throw Exception('Could not access storage');
//       }
//
//       final filePath = '${directory.path}/temp_qualification.pdf';
//       final newFile = File(filePath);
//       await newFile.writeAsBytes(await pdfFile.readAsBytes());
//
//       final result = await OpenFilex.open(filePath);
//       if (result.type != ResultType.done) {
//         throw Exception('Failed to open PDF: ${result.message}');
//       }
//     } catch (e) {
//       ShowToast.showToastError(message: 'Error viewing PDF: ${e.toString()}');
//     }
//   }
//
//   Widget _buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$title: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//                 value,
//                 style: TextStyle(color: Colors.grey[700])),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQualificationCard(QualificationModel qualification) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   qualification.issuer!,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//                 Text(
//                   qualification.type!.display,
//                   style: TextStyle(
//                     color: Theme.of(context).primaryColor,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//             const Gap(8),
//             Text(
//               '${'qualificationPage.startDate'.tr(context)}: ${qualification.startDate}',
//             ),
//             if (qualification.endDate != null)
//               Text(
//                 '${'qualificationPage.endDate'.tr(context)}: ${qualification.endDate}',
//               ),
//             if (qualification.pdfFileName != null && qualification.pdfUrl != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.picture_as_pdf, color: Colors.red),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         qualification.pdfFileName!,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         if (_downloadProgress.containsKey(qualification.id.toString()))
//                           SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               value: _downloadProgress[qualification.id.toString()],
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
//                             ),
//                           ),
//                         IconButton(
//                           icon: Icon(
//                             _downloadComplete[qualification.id.toString()] == true
//                                 ? Icons.check_circle
//                                 : Icons.visibility,
//                             color: _downloadComplete[qualification.id.toString()] == true
//                                 ? Colors.green
//                                 : Theme.of(context).primaryColor,
//                           ),
//                           onPressed: _downloadProgress.containsKey(qualification.id.toString())
//                               ? null
//                               : () => _downloadAndViewPdf(
//                             qualification.pdfUrl!,
//                             qualification.id.toString(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             const Gap(16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () => _showUpdateDialog(qualification, context),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () {
//                     serviceLocator<QualificationCubit>().deleteQualification(
//                       id: qualification.id.toString(),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.info_outline, color: Colors.green),
//                   onPressed: () => _showDetailsDialog(qualification),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildErrorWidget(String error, VoidCallback onRetry) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             error,
//             style: TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: onRetry,
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('qualificationPage.qualifications'.tr(context)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _showCreateDialog(context),
//           ),
//         ],
//       ),
//       body: BlocConsumer<QualificationCubit, QualificationState>(
//         listener: (context, state) {
//           if (state is QualificationError) {
//             ShowToast.showToastError(message: state.error);
//           }
//         },
//         builder: (context, state) {
//           if (state is QualificationInitial || state is QualificationLoading) {
//             return Center(child: LoadingButton());
//           }
//
//           if (state is QualificationError) {
//             return _buildErrorWidget(state.error, _fetchQualifications);
//           }
//
//           if (state is QualificationSuccess) {
//             final qualifications = state.paginatedResponse.paginatedData?.items ?? [];
//
//             if (qualifications.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('qualificationPage.noQualifications'.tr(context)),
//                     const Gap(16),
//                     ElevatedButton(
//                       onPressed: () => _showCreateDialog(context),
//                       child: Text('qualificationPage.addFirst'.tr(context)),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return RefreshIndicator(
//               onRefresh: _fetchQualifications,
//               child: ListView.builder(
//                 itemCount: qualifications.length,
//                 itemBuilder: (context, index) {
//                   return _buildQualificationCard(qualifications[index]);
//                 },
//               ),
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }