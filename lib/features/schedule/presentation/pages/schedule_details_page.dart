import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/pages/vacation_list_page.dart';

import '../../data/data_source/schedule_remote_data_source.dart';
import '../../data/model/schedule_model.dart';
import '../cubit/schedule_cubit/schedule_cubit.dart';
import '../widgets/schedule_form_page.dart';



class ScheduleDetailsPage extends StatefulWidget {
  final String scheduleId;

  const ScheduleDetailsPage({required this.scheduleId, super.key});

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Get the cubit from the context after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleCubit>().getScheduleDetails(widget.scheduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is ScheduleDetailsLoaded) {
            return _buildScheduleDetails(context, state.schedule);
          }
          else if (state is ScheduleLoading || state is ScheduleInitial) {
            return const Center(child: LoadingPage());
          }
          else if (state is ScheduleError) {
            return Center(child: Text(state.error));
          }
          else {
            // This should theoretically never be reached if all states are handled
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildScheduleDetails(BuildContext context, ScheduleModel schedule) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(schedule.name, style: TextStyle(color: Theme.of(context).primaryColor)),
            subtitle: Text(schedule.active ? 'Active' : 'Inactive'),
            trailing: Switch(
              value: schedule.active,
              onChanged: (value) {
                context.read<ScheduleCubit>().toggleScheduleStatus(schedule.id,context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<ScheduleCubit>().getScheduleDetails(widget.scheduleId);
                });
                },
            ),
          ),
          const Divider(),
          _buildDetailItem(
            context,
            'Period',
            '${DateFormat('MMM d, y').format(schedule.planningHorizonStart)} - '
                '${DateFormat('MMM d, y').format(schedule.planningHorizonEnd)}',
            Icons.calendar_today,
          ),
          _buildDetailItem(
            context,
            'Repeat Pattern',
            '${schedule.repeat.daysOfWeek.join(', ')}\n'
                'Time: ${schedule.repeat.timeOfDay}\n'
                'Duration: ${schedule.repeat.duration} hours',
            Icons.repeat,
          ),
          if (schedule.comment != null)
            _buildDetailItem(
              context,
              'Comment',
              schedule.comment!,
              Icons.comment,
            ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => ScheduleCubit(
                      remoteDataSource: serviceLocator<ScheduleRemoteDataSource>(),
                    ),
                    child: ScheduleFormPage(
                      initialSchedule: schedule,
                    ),
                  ),
                ),
              ).then((_){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<ScheduleCubit>().getScheduleDetails(widget.scheduleId);
                });
              }),              child: const Text('Edit Schedule'),
            ),
          ),

          Gap(30),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>VacationListPage(schedule: schedule,)));
              },
              leading:  const Icon(Icons.beach_access, size: 30),
              title: Text("Vacations"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
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
                Text(value, style:  TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}