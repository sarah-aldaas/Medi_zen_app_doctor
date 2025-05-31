import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/model/schedule_model.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/pages/vacation_details_page.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/widgets/vacation_form_page.dart';

import '../../data/model/vacation_filter_model.dart';
import '../cubit/vacation_cubit/vacation_cubit.dart';
import '../widgets/vacation_filter_dialog.dart';
import '../widgets/vacation_item.dart';

class VacationListPage extends StatefulWidget {
  final ScheduleModel schedule;

  const VacationListPage({required this.schedule, super.key});

  @override
  State<VacationListPage> createState() => _VacationListPageState();
}

class _VacationListPageState extends State<VacationListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    context.read<VacationCubit>().getVacations(scheduleId: widget.schedule.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<VacationCubit>().getVacations(scheduleId: widget.schedule.id, loadMore: true).then((_) {
        if (mounted) {
          setState(() => _isLoadingMore = false);
        }
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<VacationCubit>();
    final result = await showDialog<VacationFilterModel>(context: context, builder: (context) => VacationFilterDialog(currentFilter: cubit.currentFilter));

    if (result != null) {
      cubit.getVacations(scheduleId: widget.schedule.id, filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacations'), actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog)]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VacationFormPage(schedule: widget.schedule)));
        },
      ),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is VacationLoading && state is! VacationSuccess) {
            return const Center(child: LoadingPage());
          }

          if (state is VacationSuccess) {
            if (state.vacations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const Icon(Icons.beach_access, size: 64), const SizedBox(height: 16), const Text('No vacations found')],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.vacations.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.vacations.length) {
                  return  Center(child: LoadingButton());
                }
                return VacationItem(
                  vacation: state.vacations[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BlocProvider(
                              create: (context) => serviceLocator<VacationCubit>(),
                              child: VacationDetailsPage(schedule: widget.schedule, vacationId: state.vacations[index].id!),
                            ),
                      ),
                    );
                    if (mounted) {
                      context.read<VacationCubit>().getVacations(scheduleId: widget.schedule.id);
                    }
                  },
                  onDelete: () => confirmDelete(state.vacations[index].id!),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Future<void> confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this vacation?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
    );

    if (confirmed == true) {
      context.read<VacationCubit>().deleteVacation(int.parse(id));
    }
  }
}
