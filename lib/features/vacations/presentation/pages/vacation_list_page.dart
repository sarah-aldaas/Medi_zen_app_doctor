import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/model/schedule_model.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/pages/vacation_details_page.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/widgets/vacation_form_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/show_toast.dart';
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
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<VacationCubit>()
          .getVacations(scheduleId: widget.schedule.id, loadMore: true)
          .then((_) {
            if (mounted) {
              setState(() => _isLoadingMore = false);
            }
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<VacationCubit>();
    final result = await showDialog<VacationFilterModel>(
      context: context,
      builder:
          (context) => VacationFilterDialog(currentFilter: cubit.currentFilter),
    );

    if (result != null) {
      cubit.getVacations(scheduleId: widget.schedule.id, filter: result);
    }
  }

  Future<void> _refreshVacations() async {
    await context.read<VacationCubit>().getVacations(
      scheduleId: widget.schedule.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${widget.schedule.name} ${'vacationListPage.titleSuffix'.tr(context)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 28),
            color: AppColors.primaryColor,
            onPressed: _showFilterDialog,
            tooltip: 'vacationListPage.filterTooltip'.tr(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VacationFormPage(schedule: widget.schedule),
            ),
          );

          if (mounted) {
            _refreshVacations();
          }
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        tooltip: 'vacationListPage.addVacationTooltip'.tr(context),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_box_outlined, size: 32),
      ),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationError) {
            ShowToast.showToastError(message: state.error);

            _refreshVacations();
          }
        },
        builder: (context, state) {
          if (state is VacationLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is VacationSuccess) {
            if (state.vacations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.beach_access,
                        size: 90,
                        color: primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'vacationListPage.noVacationsTitle'.tr(context),

                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'vacationListPage.noVacationsDescription'.tr(context),

                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VacationFormPage(
                                    schedule: widget.schedule,
                                  ),
                            ),
                          );
                          if (mounted) {
                            _refreshVacations();
                          }
                        },
                        icon: const Icon(Icons.add_circle, size: 28),
                        label: Text(
                          'vacationListPage.addFirstVacationButton'.tr(context),

                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshVacations,
              color: primaryColor,
              displacement: 80,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                itemCount: state.vacations.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index >= state.vacations.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: LoadingButton()),
                    );
                  }
                  return VacationItem(
                    vacation: state.vacations[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BlocProvider(
                                create:
                                    (context) =>
                                        serviceLocator<VacationCubit>(),
                                child: VacationDetailsPage(
                                  schedule: widget.schedule,
                                  vacationId: state.vacations[index].id!,
                                ),
                              ),
                        ),
                      );

                      if (mounted) {
                        _refreshVacations();
                      }
                    },
                    onDelete: () => confirmDelete(state.vacations[index].id!),
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

  Future<void> confirmDelete(String id) async {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'vacationListPage.confirmDeletionTitle'.tr(context),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'vacationListPage.confirmDeletionContent'.tr(context),
              // Localized
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor.withOpacity(0.7),
                ),
                child: Text(
                  'vacationListPage.cancelButton'.tr(context),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'vacationListPage.deleteButton'.tr(context),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      context.read<VacationCubit>().deleteVacation(int.parse(id));
    }
  }
}
