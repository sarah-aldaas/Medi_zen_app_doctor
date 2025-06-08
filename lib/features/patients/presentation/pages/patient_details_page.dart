import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_list_screen.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/widgets/address_patient_page.dart';

import '../../../medical_record/medical_record.dart';
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
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildInfoTile(IconData icon, String title, String value ,BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style:  TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style:  TextStyle(color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
           Gap(8),
          Text(title, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(String title, IconData icon, VoidCallback onTap,BuildContext context) {
    return Card(
      margin:  EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
               Gap(12),
              Text(title, style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
               Spacer(),
               Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
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
            return  Center(child: LoadingPage());
          }

          if (state is PatientError) {
            return Center(child: Text(state.error));
          }

          if (state is PatientDetailsLoaded) {
            final patient = state.patient;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PatientListPage()));
                  }, icon:Icon(Icons.arrow_back)),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text("${patient.fName ?? 'No name'} ${patient.lName ?? ''}", style:  TextStyle(color: Colors.white)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (patient.avatar != null)
                          Image.network(
                            patient.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>  Icon(Icons.person, size: 60, color: Colors.white70),
                          )
                        else
                           Icon(Icons.person, size: 60, color: Colors.white70),
                         DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black, Colors.transparent]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PatientFormPage(initialPatient: patient,)));

                      },
                      icon:  Icon(Icons.edit, color: Colors.white),
                    ),
                     Gap(8),
                  ],
                ),
                SliverPadding(
                  padding:  EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding:  EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoTile(Icons.email_outlined, "Email", patient.email,context),
                              if (patient.gender != null) _buildInfoTile(Icons.person_outline, "Gender", patient.gender!.display,context),
                              if (patient.maritalStatus != null) _buildInfoTile(Icons.favorite_outline, "Marital Status", patient.maritalStatus!.display,context),
                              if (patient.dateOfBirth != null) _buildInfoTile(Icons.cake_outlined, "Age", '${_calculateAge(patient.dateOfBirth)} years',context),
                              _buildInfoTile(Icons.verified_user, "Status", patient.active == '1' ? 'Active' : 'Inactive',context),
                              _buildInfoTile(Icons.warning, "Deceased", patient.deceasedDate != null ? 'Yes' : 'No',context),
                            ],
                          ),
                        ),
                      ),
                       Gap(16),
                      _buildSectionTitle("Health Information", Icons.healing_outlined,context),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin:  EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          leading:  Icon(Icons.medical_information_outlined, color: Theme.of(context).primaryColor),
                          title:  Text("Medical Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          children: <Widget>[
                            if (patient.bloodType != null)
                              Column(
                                children: [
                                  ListTile(leading:  Icon(Icons.bloodtype, color: Theme.of(context).primaryColor), title: Text("Blood Type: ${patient.bloodType!.display}")),
                                   Divider(indent: 16.0, endIndent: 16.0),
                                ],
                              ),
                            Column(
                              children: [
                                ListTile(leading:  Icon(Icons.height, color: Theme.of(context).primaryColor), title: Text("Height: ${patient.height ?? 'N/A'} cm")),
                                 Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(leading:  Icon(Icons.fitness_center, color: Theme.of(context).primaryColor), title: Text("Weight: ${patient.weight ?? 'N/A'} kg")),
                                 Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading:  Icon(Icons.smoke_free, color: Theme.of(context).primaryColor),
                                  title: Text("Smoker: ${patient.smoker == '1' ? 'Yes' : 'No'}"),
                                ),
                                 Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading:  Icon(Icons.local_bar_outlined, color: Theme.of(context).primaryColor),
                                  title: Text("Alcohol Drinker: ${patient.alcoholDrinker == '1' ? 'Yes' : 'No'}"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                       Gap(16),
                      _buildSectionTitle("Contact Information", Icons.contact_phone,context),
                       Gap(15),
                      _buildNavigationItem("Medical record", Icons.health_and_safety, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicalRecordPage(patientModel: patient,)));
                      },context),
                      if (patient.telecoms != null && patient.telecoms!.isNotEmpty)
                        _buildNavigationItem("Telecom", Icons.phone, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TelecomPatientPage(list: patient.telecoms!,)));
                        },context),
                      if (patient.addresses != null)
                        _buildNavigationItem("Address", Icons.home, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddressPatientPage(list:patient.addresses??[])));
                        },context),
                       Gap(40),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.read<PatientCubit>().toggleActiveStatus(int.parse(patient.id!)),
                              style: ElevatedButton.styleFrom(backgroundColor: patient.active == '1' ? Colors.red : Colors.green),
                              child: Text(patient.active == '1' ? 'Deactivate' : 'Activate'),
                            ),
                            ElevatedButton(
                              onPressed: () => context.read<PatientCubit>().toggleDeceasedStatus(int.parse(patient.id!)),
                              style: ElevatedButton.styleFrom(backgroundColor: patient.deceasedDate != null ? Colors.green : Colors.red),
                              child: Text(patient.deceasedDate != null ? 'Mark Alive' : 'Mark Deceased'),
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
            return  Center(child: LoadingPage());
          }
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
//
// import '../../data/models/patient_model.dart';
// import '../cubit/patient_cubit/patient_cubit.dart';
//
//
// class PatientDetailsPage extends StatelessWidget {
//   final String patientId;
//
//    PatientDetailsPage({required this.patientId, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:  Text('Patient Details'),
//         actions: [
//           IconButton(
//             icon:  Icon(Icons.edit),
//             onPressed: () => context.push('/patients/$patientId/edit'),
//           ),
//         ],
//       ),
//       body: BlocConsumer<PatientCubit, PatientState>(
//         listener: (context, state) {
//           if (state is PatientError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.error)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is PatientDetailsLoaded) {
//             return _buildPatientDetails(context, state.patient);
//           } else if (state is PatientLoading) {
//             return  Center(child: LoadingPage());
//           } else {
//             context.read<PatientCubit>().showPatient(int.parse(patientId));
//             return  Center(child: LoadingPage());
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildPatientDetails(BuildContext context, PatientModel patient) {
//     return SingleChildScrollView(
//       padding:  EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: CircleAvatar(
//               radius: 50,
//               backgroundColor: Theme.of(context).primaryColor,
//               child: Text(
//                 patient.fName?.substring(0, 1) ?? 'P',
//                 style:  TextStyle(fontSize: 40, color: Colors.white),
//               ),
//             ),
//           ),
//            SizedBox(height: 16),
//           Center(
//             child: Text(
//               '${patient.fName} ${patient.lName}',
//               style: TextStyle(color: Theme.of(context).primaryColor),
//             ),
//           ),
//            Divider(),
//           _buildDetailItem(context, 'Email', patient.email, Icons.email),
//           if (patient.dateOfBirth != null)
//             _buildDetailItem(
//               context,
//               'Date of Birth',
//               DateFormat('MMM d, y').format(DateTime.parse(patient.dateOfBirth!)),
//               Icons.cake,
//             ),
//           if (patient.gender != null)
//             _buildDetailItem(
//               context,
//               'Gender',
//               patient.gender!.display,
//               Icons.person,
//             ),
//           if (patient.maritalStatus != null)
//             _buildDetailItem(
//               context,
//               'Marital Status',
//               patient.maritalStatus!.display,
//               Icons.favorite,
//             ),
//           if (patient.bloodType != null)
//             _buildDetailItem(
//               context,
//               'Blood Type',
//               patient.bloodType!.display,
//               Icons.bloodtype,
//             ),
//           _buildDetailItem(
//             context,
//             'Status',
//             patient.active == '1' ? 'Active' : 'Inactive',
//             patient.active == '1' ? Icons.check_circle : Icons.cancel,
//             color: patient.active == '1' ? Colors.green : Colors.red,
//           ),
//           _buildDetailItem(
//             context,
//             'Deceased',
//             patient.deceasedDate != null ? 'Yes' : 'No',
//             patient.deceasedDate != null ? Icons.warning : Icons.check,
//             color: patient.deceasedDate != null ? Colors.red : Colors.green,
//           ),
//           if (patient.addressModel != null) ...[
//              Divider(),
//              Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
//             _buildDetailItem(
//               context,
//               'Address',
//               patient.addressModel!.line ?? '',
//               Icons.location_on,
//             ),
//             _buildDetailItem(
//               context,
//               'City',
//               patient.addressModel!.city ?? '',
//               Icons.location_city,
//             ),
//             _buildDetailItem(
//               context,
//               'Postal Code',
//               patient.addressModel!.postalCode ?? '',
//               Icons.markunread_mailbox,
//             ),
//           ],
//            SizedBox(height: 32),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: () => context.read<PatientCubit>().toggleActiveStatus(int.parse(patient.id!)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: patient.active == '1' ? Colors.red : Colors.green,
//                 ),
//                 child: Text(patient.active == '1' ? 'Deactivate' : 'Activate'),
//               ),
//               ElevatedButton(
//                 onPressed: () => context.read<PatientCubit>().toggleDeceasedStatus(int.parse(patient.id!)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: patient.deceasedDate != null ? Colors.green : Colors.red,
//                 ),
//                 child: Text(patient.deceasedDate != null ? 'Mark Alive' : 'Mark Deceased'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailItem(
//       BuildContext context,
//       String title,
//       String value,
//       IconData icon, {
//         Color color = Theme.of(context).primaryColor,
//       }) {
//     return Padding(
//       padding:  EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: color),
//            SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style:  TextStyle(fontWeight: FontWeight.bold)),
//               Text(value),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
