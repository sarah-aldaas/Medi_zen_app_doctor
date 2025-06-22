import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_list_screen.dart';

import '../../../../base/theme/app_color.dart';
import '../../../appointment/presentation/pages/appointments_patient.dart';
import '../../../medical_record/medical_record.dart';
import '../widgets/address_patient_page.dart';
import '../widgets/patient_form_page.dart';
import '../widgets/telecom_patient_page.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientId;

  PatientDetailsPage({required this.patientId, super.key});

  int _calculateAge(String? dateOfBirthStr) {
    if (dateOfBirthStr == null) return 0;
    final dob = DateTime.parse(dateOfBirthStr);
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Gap(8),
          Text(
            title,
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
    String title,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
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
                title,
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
      body: BlocConsumer<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is PatientError) {
            return Center(child: Text(state.error));
          }

          if (state is PatientDetailsLoaded) {
            final patient = state.patient;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "${patient.fName ?? 'patientPage.no_name'.tr(context)} ${patient.lName ?? ''}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (patient.avatar != null)
                          Image.network(
                            patient.avatar!,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PatientFormPage(initialPatient: patient),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: AppColors.whiteColor),
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
                                Icons.email_outlined,
                                "patientPage.email".tr(context),
                                patient.email,
                                context,
                              ),
                              if (patient.gender != null)
                                _buildInfoTile(
                                  Icons.person_outline,
                                  "patientPage.gender".tr(context),
                                  patient.gender!.display,
                                  context,
                                ),
                              if (patient.maritalStatus != null)
                                _buildInfoTile(
                                  Icons.favorite_outline,
                                  "patientPage.marital_status".tr(context),
                                  patient.maritalStatus!.display,
                                  context,
                                ),
                              if (patient.dateOfBirth != null)
                                _buildInfoTile(
                                  Icons.cake_outlined,
                                  "patientPage.age".tr(context),
                                  '${_calculateAge(patient.dateOfBirth)}' +
                                      'patientPage.years'.tr(context),
                                  context,
                                ),
                              _buildInfoTile(
                                Icons.verified_user,
                                "patientPage.status".tr(context),
                                patient.active == '1'
                                    ? 'patientPage.active'.tr(context)
                                    : 'patientPage.inactive'.tr(context),
                                context,
                              ),
                              _buildInfoTile(
                                Icons.warning,
                                "patientPage.deceased".tr(context),
                                patient.deceasedDate != null
                                    ? 'patientPage.yes'.tr(context)
                                    : 'patientPage.no'.tr(context),
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "patientPage.health_information".tr(context),
                        Icons.healing_outlined,
                        context,
                      ),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.medical_information_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            "patientPage.medical_details".tr(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: <Widget>[
                            if (patient.bloodType != null)
                              Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.bloodtype,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(
                                      "${'patientPage.blood_type'.tr(context)}${patient.bloodType!.display}",
                                    ),
                                  ),
                                  const Divider(indent: 16.0, endIndent: 16.0),
                                ],
                              ),
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.height,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    "${'patientPage.height'.tr(context)}${patient.height ?? 'patientPage.na'.tr(context)}${'patientPage.cm'.tr(context)}",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.fitness_center,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    "${'patientPage.weight'.tr(context)}${patient.weight ?? 'patientPage.na'.tr(context)}${'patientPage.kg'.tr(context)}",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.smoke_free,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    "${'patientPage.smoker'.tr(context)}${patient.smoker == '1' ? 'patientPage.yes'.tr(context) : 'patientPage.no'.tr(context)}",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.local_bar_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    "${'patientPage.alcohol_drinker'.tr(context)}${patient.alcoholDrinker == '1' ? 'patientPage.yes'.tr(context) : 'patientPage.no'.tr(context)}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "patientPage.contact_information".tr(context),
                        Icons.contact_phone,
                        context,
                      ),
                      _buildNavigationItem(
                        "patientPage.appointments".tr(context),
                        Icons.date_range_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AppointmentsPatient(
                                    patientId: patient.id!,
                                  ),
                            ),
                          );
                        },
                        context,
                      ),
                      _buildNavigationItem(
                        "patientPage.medical_record".tr(context),
                        Icons.health_and_safety,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MedicalRecordPage(patientModel: patient),
                            ),
                          );
                        },
                        context,
                      ),
                      if (patient.telecoms != null &&
                          patient.telecoms!.isNotEmpty)
                        _buildNavigationItem(
                          "patientPage.telecom".tr(context),
                          Icons.phone,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TelecomPatientPage(
                                      list: patient.telecoms!,
                                    ),
                              ),
                            );
                          },
                          context,
                        ),
                      if (patient.addresses != null)
                        _buildNavigationItem(
                          "patientPage.address".tr(context),
                          Icons.home,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddressPatientPage(
                                      list: patient.addresses ?? [],
                                    ),
                              ),
                            );
                          },
                          context,
                        ),
                      const Gap(40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  () => context
                                      .read<PatientCubit>()
                                      .toggleActiveStatus(
                                        int.parse(patient.id!),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    patient.active == '1'
                                        ? AppColors.primaryColor
                                        : AppColors.secondaryColor,
                              ),
                              child: Text(
                                patient.active == '1'
                                    ? 'patientPage.deactivate'.tr(context)
                                    : 'patientPage.activate'.tr(context),
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => context
                                      .read<PatientCubit>()
                                      .toggleDeceasedStatus(
                                        int.parse(patient.id!),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    patient.deceasedDate != null
                                        ? AppColors.primaryColor
                                        : AppColors.secondaryColor,
                              ),
                              child: Text(
                                patient.deceasedDate != null
                                    ? 'patientPage.mark_alive'.tr(context)
                                    : 'patientPage.mark_deceased'.tr(context),
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          } else {
            context.read<PatientCubit>().showPatient(int.parse(patientId));
            return const Center(child: LoadingPage());
          }
        },
      ),
    );
  }
}
