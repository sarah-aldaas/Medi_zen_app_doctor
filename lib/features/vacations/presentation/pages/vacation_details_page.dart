import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/model/schedule_model.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/widgets/vacation_form_page.dart';

import '../../data/model/vacation_model.dart';
import '../cubit/vacation_cubit/vacation_cubit.dart';

class VacationDetailsPage extends StatefulWidget {
  final ScheduleModel schedule;
  final String vacationId;

  const VacationDetailsPage({required this.schedule, required this.vacationId, super.key});

  @override
  State<VacationDetailsPage> createState() => _VacationDetailsPageState();
}

class _VacationDetailsPageState extends State<VacationDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacationCubit>().getVacationDetails(widget.vacationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacation Details')),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is VacationDetailsLoaded) {
            return _buildVacationDetails(context, state.vacation);
          } else if (state is VacationLoading) {
            return const Center(child: LoadingPage());
          } else {
            return const Center(child: Text('Failed to load vacation details'));
          }
        },
      ),
    );
  }

  Widget _buildVacationDetails(BuildContext context, VacationModel vacation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(title: Text(vacation.reason ?? 'Vacation', style: TextStyle(color: Theme.of(context).primaryColor))),
          const Divider(),
          _buildDetailItem(
            context,
            'Period',
            '${DateFormat('MMM d, y').format(vacation.startDate!)} - '
                '${DateFormat('MMM d, y').format(vacation.endDate!)}',
            Icons.calendar_today,
          ),
          if (vacation.schedule != null) _buildDetailItem(context, 'Schedule', vacation.schedule!.name, Icons.schedule),
          if (vacation.reason != null) _buildDetailItem(context, 'Reason', vacation.reason!, Icons.note),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VacationFormPage(schedule: widget.schedule, initialVacation: vacation)),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.read<VacationCubit>().getVacationDetails(widget.vacationId);
                  });
                });
              },
              child: const Text('Edit Vacation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).primaryColor)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
