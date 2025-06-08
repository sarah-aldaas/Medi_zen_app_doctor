import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_details_page.dart';

import '../../data/models/patient_filter_model.dart';
import '../cubit/patient_cubit/patient_cubit.dart';
import '../widgets/patient_filter_dialog.dart';
import '../widgets/patient_item.dart';


class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<PatientCubit>().listPatients();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<PatientCubit>().listPatients(loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<PatientCubit>();
    final result = await showDialog<PatientFilterModel>(
      context: context,
      builder: (context) =>
          PatientFilterDialog(
            currentFilter: cubit.currentFilter,
          ),
    );

    if (result != null) {
      cubit.listPatients(filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text  (state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientLoading && state is! PatientSuccess) {
            return const Center(child: LoadingPage());
          }

          if (state is PatientSuccess) {
            if (state.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 64),
                    const SizedBox(height: 16),
                    const Text('No patients found'),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.patients.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.patients.length) {
                  return Center(child: LoadingButton());
                }
                return PatientItem(
                  patient: state.patients[index],
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientDetailsPage(patientId: state.patients[index].id!)));
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../base/theme/app_color.dart';
// import '../../base/theme/app_style.dart';
// import '../medical_record/medical_record.dart';
// import 'cubit/patients_cubit.dart';
// import 'cubit/patients_state.dart';
// import 'model/patient_model.dart';
//
// class PatientListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PatientCubit(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('قائمة المرضى', style: AppStyles.titleStyle),
//           backgroundColor: AppColors.primaryColor,
//           elevation: 1,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: BlocBuilder<PatientCubit, PatientState>(
//             builder: (context, state) {
//               return ListView.builder(
//                 itemCount: state.patients.length,
//                 itemBuilder: (context, index) {
//                   final patient = state.patients[index];
//                   return _buildPatientCard(context, patient);
//                 },
//               );
//             },
//           ),
//         ),
//         backgroundColor: Colors.grey[100],
//       ),
//     );
//   }
//
//   Widget _buildPatientCard(BuildContext context, Patient patient) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12.0),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (context) => MedicalRecordPage(patientName: patient.name),
//               ),
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12.0),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: AppColors.primaryColor,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         patient.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                       const SizedBox(height: 6.0),
//                       Row(
//                         children: [
//                           const Text(
//                             'الحالة:',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(width: 4.0),
//                           Text(
//                             patient.condition,
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: _getConditionColor(patient.condition),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getConditionColor(String condition) {
//     switch (condition) {
//       case 'مستقرة':
//         return Colors.green[400]!;
//       case 'يتحسن':
//         return Colors.orange[400]!;
//       case 'بحاجة لمتابعة':
//         return Colors.red[400]!;
//       case 'تحت العلاج':
//         return Colors.blue[400]!;
//       case 'متعافية':
//         return Colors.teal[400]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }
// }
