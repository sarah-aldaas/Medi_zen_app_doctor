import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/data_source/schedule_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/schedule/presentation/pages/schedule_details_page.dart';

import '../../data/model/schedule_filter_model.dart';
import '../cubit/schedule_cubit/schedule_cubit.dart';
import '../widgets/schedule_filter_dialog.dart';
import '../widgets/schedule_form_page.dart';
import '../widgets/schedule_item.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<ScheduleCubit>().getMySchedules();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<ScheduleCubit>().getMySchedules(loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<ScheduleCubit>();
    final result = await showDialog<ScheduleFilterModel>(
      context: context,
      builder:
          (context) => ScheduleFilterDialog(currentFilter: cubit.currentFilter),
    );

    if (result != null) {
      cubit.getMySchedules(filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'schedulePage.my_schedules_title'.tr(context),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'schedulePage.add_schedule_tooltip'.tr(context),
        child: Icon(Icons.add_box_outlined, color: AppColors.whiteColor),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider(
                      create:
                          (context) => ScheduleCubit(
                            remoteDataSource:
                                serviceLocator<ScheduleRemoteDataSource>(),
                          ),
                      child: ScheduleFormPage(),
                    ),
              ),
            ).then((_) {
              context.read<ScheduleCubit>().getMySchedules();
            }),
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading && state is! ScheduleSuccess) {
            return const Center(child: LoadingPage());
          }

          if (state is ScheduleSuccess) {
            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 64),
                    const SizedBox(height: 16),
                    Text('schedulePage.no_schedules_found'.tr(context)),
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BlocProvider(
                                    create:
                                        (context) => ScheduleCubit(
                                          remoteDataSource:
                                              serviceLocator<
                                                ScheduleRemoteDataSource
                                              >(),
                                        ),
                                    child: ScheduleFormPage(),
                                  ),
                            ),
                          ).then((_) {
                            context.read<ScheduleCubit>().getMySchedules();
                          }),
                      child: Text(
                        'schedulePage.create_new_schedule'.tr(context),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.schedules.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.schedules.length) {
                  return Center(child: LoadingButton());
                }
                return ScheduleItem(
                  schedule: state.schedules[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BlocProvider(
                              create:
                                  (context) => ScheduleCubit(
                                    remoteDataSource:
                                        serviceLocator<
                                          ScheduleRemoteDataSource
                                        >(),
                                  ),
                              child: ScheduleDetailsPage(
                                scheduleId: state.schedules[index].id,
                              ),
                            ),
                      ),
                    ).then((_) {
                      context.read<ScheduleCubit>().getMySchedules();
                    });
                  },
                  // onTap: () => context.push(
                  //   '/schedules/${state.schedules[index].id}',
                  // ),
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
