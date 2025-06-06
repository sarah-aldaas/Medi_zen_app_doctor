import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/constant/app_images.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';

import '../data/models/clinic_model.dart';
import 'cubit/clinic_cubit/clinic_cubit.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  late ClinicCubit _clinicCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _clinicCubit = ClinicCubit(
      remoteDataSource: serviceLocator<ClinicRemoteDataSource>(),
    );
    _clinicCubit.getMyClinic();
  }

  @override
  void dispose() {
    _clinicCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),

          icon: Icon(Icons.arrow_back_ios, color: theme.secondaryHeaderColor),
        ),
        toolbarHeight: 70,

        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        title: BlocBuilder<ClinicCubit, ClinicState>(
          bloc: _clinicCubit,
          builder: (context, state) {
            if (state is ClinicLoadedSuccess) {
              return Text(
                state.clinic.name,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            }
            return Text(
              'clinicsPage.clinicDetails'.tr(context),
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            );
          },
        ),
        elevation: 1,

        shadowColor: theme.shadowColor,
      ),
      body: BlocBuilder<ClinicCubit, ClinicState>(
        bloc: _clinicCubit,
        builder: (context, clinicState) {
          if (clinicState is ClinicLoading) {
            return Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            );
          }
          if (clinicState is ClinicError) {
            return Center(
              child: Text(
                clinicState.error,
                style: TextStyle(
                  color: isDarkMode ? Colors.red[300] : Colors.red,
                  fontSize: 16,
                ),
              ),
            );
          }
          if (clinicState is ClinicLoadedSuccess) {
            return _buildClinicDetails(clinicState.clinic, theme, isDarkMode);
          }

          return Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClinicDetails(
    ClinicModel clinic,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClinicImage(clinic, theme),
            const Gap(20),
            Text(
              clinic.description,
              style: TextStyle(
                fontSize: 16,

                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            const Gap(32),
            _buildServicesSection(
              clinic.healthCareServices as List<HealthCareServiceModel>? ?? [],
              theme,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicImage(ClinicModel clinic, ThemeData theme) {
    return SizedBox(
      width: context.width,
      child: Card(
        elevation: 2,

        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            clinic.photo,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    Image.asset(AppAssetImages.clinic6, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(
    List<HealthCareServiceModel> services,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services_outlined, color: theme.primaryColor),
            const Gap(8),
            Text(
              'clinicsPage.services'.tr(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,

                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const Gap(16),
        if (services.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
                const Gap(8),
                Text(
                  'clinicsPage.Noavailable'.tr(context),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          ClinicServicesPage(
            services: services,
            theme: theme,
            isDarkMode: isDarkMode,
          ),
      ],
    );
  }
}

class ClinicServicesPage extends StatelessWidget {
  const ClinicServicesPage({
    super.key,
    required this.services,
    required this.theme,
    required this.isDarkMode,
  });

  final List<HealthCareServiceModel> services;
  final ThemeData theme;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            services.isEmpty
                ? Center(
                  child: Text(
                    'clinicsPage.Noavailable'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                )
                : ListView.separated(
                  itemCount: services.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        color:
                            isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey.shade300,
                        height: 32,
                        thickness: 1,
                      ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      elevation: 2,

                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      service.photo!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey,
                                          ),
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,

                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        service.comment ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            Text(
                              service.extraDetails ??
                                  'clinicsPage.Noextra'.tr(context),
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const Gap(12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'clinicsPage.appointment'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,

                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                    const Gap(4),
                                    Icon(
                                      service.appointmentRequired!
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color:
                                          service.appointmentRequired!
                                              ? Colors.green
                                              : (isDarkMode
                                                  ? Colors.red[300]
                                                  : Colors.redAccent),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on_outlined,
                                      color:
                                          isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey,
                                    ),
                                    const Gap(8),
                                    Text(
                                      service.price ??
                                          'clinicsPage.free'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,

                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
