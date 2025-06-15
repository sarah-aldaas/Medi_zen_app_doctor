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
