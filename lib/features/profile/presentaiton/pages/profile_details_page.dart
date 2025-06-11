import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/update_profile_request_Model.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  int _calculateAge(String dateOfBirthStr) {
    final dob = DateTime.parse(dateOfBirthStr);
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildInfoTile(IconData icon, String titleKey, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        titleKey.tr(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildSectionTitle(String titleKey, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Gap(8),
          Text(
            titleKey.tr(context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
      String titleKey,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const Gap(12),
              Text(
                titleKey.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error) {
            ShowToast.showToastError(message: state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: LoadingPage());
          }

          if (state.status == ProfileStatus.error) {
            return Center(child: Text(state.errorMessage));
          }

          if (state.status == ProfileStatus.success && state.doctorModel != null) {
            final doctor = state.doctorModel!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "${doctor.fName ?? 'profileDetailsPage.noAddressAvailable'.tr(context)} ${doctor.lName ?? 'profileDetailsPage.noAddressAvailable'.tr(context)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (doctor.avatar != null)
                          Image.network(
                            doctor.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            ),
                          )
                        else
                          const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white70,
                          ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black, Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.editProfile.name,
                          extra: {
                            'doctorModel': UpdateProfileRequestModel(
                              image: doctor.avatar,
                              genderId: doctor.genderId,
                              fName: doctor.fName,
                              lName: doctor.lName,
                            ),
                          },
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const Gap(8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoTile(
                                Icons.person,
                                "profileDetailsPage.fullName",
                                '${doctor.prefix ?? ''} ${doctor.given ?? ''} ${doctor.family ?? ''}'.trim(),
                              ),
                              _buildInfoTile(
                                Icons.email_outlined,
                                "profileDetailsPage.email",
                                doctor.email!,
                              ),
                              _buildInfoTile(
                                Icons.person_outline,
                                "profileDetailsPage.gender",
                                doctor.gender!.display,
                              ),
                              _buildInfoTile(
                                Icons.calendar_today_outlined,
                                "profileDetailsPage.birthDate",
                                doctor.dateOfBirth!,
                              ),
                              if (doctor.dateOfBirth != null)
                                _buildInfoTile(
                                  Icons.cake_outlined,
                                  "profileDetailsPage.age",
                                  '${_calculateAge(doctor.dateOfBirth!)} ${"profileDetailsPage.age".tr(context).toLowerCase().replaceAll(':', '')}',
                                ),
                              _buildInfoTile(
                                Icons.location_on,
                                "profileDetailsPage.address",
                                doctor.address ?? 'profileDetailsPage.noAddressAvailable'.tr(context),
                              ),

                              if (doctor.suffix != null)
                                _buildInfoTile(
                                  Icons.medical_services,
                                  "profileDetailsPage.title",
                                  doctor.suffix!,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "profileDetailsPage.aboutMe",
                        Icons.info_outline,
                      ),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            doctor.text ??
                                'profileDetailsPage.noBioAvailable'.tr(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "profileDetailsPage.contactInformation",
                        Icons.contact_phone,
                      ),
                      _buildNavigationItem(
                        "profileDetailsPage.telecom",
                        Icons.phone,
                            () {
                          context.pushNamed(AppRouter.telecomDetails.name);
                        },
                      ),const Gap(8),
                      _buildNavigationItem(
                        "profileDetailsPage.qualification",
                        Icons.file_present,
                            () {
                          context.pushNamed(AppRouter.qualification.name);
                        },
                      ),
                      const Gap(8),
                      _buildNavigationItem(
                        "profileDetailsPage.clinic",
                        Icons.healing,
                            () {
                          context.pushNamed(AppRouter.clinicProfilePage.name);
                        },
                      ),const Gap(8),
                      _buildNavigationItem(
                        "profileDetailsPage.communications",
                        Icons.language,
                            () {
                          context.pushNamed(AppRouter.communicationsPage.name, extra: {"list":doctor.communications??[]});
                        },
                      ),
                      const Gap(40),
                    ]),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text("no data"));
        },
      ),
    );
  }
}
