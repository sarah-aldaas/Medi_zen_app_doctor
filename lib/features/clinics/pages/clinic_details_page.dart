import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/constant/app_images.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
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
    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: BlocBuilder<ClinicCubit, ClinicState>(
          bloc: _clinicCubit,
          builder: (context, state) {
            if (state is ClinicLoadedSuccess) {
              return Text(
                state.clinic.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            }
            return const Text(
              'Clinic Details',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            );
          },
        ),
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<ClinicCubit, ClinicState>(
        bloc: _clinicCubit,
        builder: (context, clinicState) {
          if (clinicState is ClinicLoading) {
            return const Center(child: LoadingPage());
          }
          if (clinicState is ClinicError) {
            return Center(child: Text(clinicState.error));
          }
          if (clinicState is ClinicLoadedSuccess) {
            return _buildClinicDetails(clinicState.clinic);
          }
          return const Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildClinicDetails(ClinicModel clinic) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClinicImage(clinic),
            const Gap(20),
            Text(
              clinic.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const Gap(32),
            _buildServicesSection(clinic.healthCareServices as List<HealthCareServiceModel> ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicImage(ClinicModel clinic) {
    return SizedBox(
      width: context.width,
      child: Card(
        elevation: 2,
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



  Widget _buildServicesSection(List<HealthCareServiceModel> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const Gap(8),
            const Text(
              "Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const Gap(16),
        if (services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                Gap(8),
                Text(
                  "No services available at the moment.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ClinicServicesPage(services: services)
      ],
    );
  }
}

class ClinicServicesPage extends StatelessWidget {
  const ClinicServicesPage({super.key, required this.services});

  final List<HealthCareServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: context.height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        services.isEmpty
            ? const Center(
          child: Text(
            "No services available at the moment.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.separated(
          itemCount: services.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              elevation: 2,
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
                                  (
                                  context,
                                  error,
                                  stackTrace,
                                  ) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                service.comment ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.grey,
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
                          "No extra details provided.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Appointment: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
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
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              color: Colors.grey,
                            ),
                            const Gap(8),
                            Text(
                              service.price ?? "Free",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
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
