import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/schedule_remote_data_source.dart';
import '../../../data/model/schedule_filter_model.dart';
import '../../../data/model/schedule_model.dart';
import '../../../data/model/toggle_schedule_response.dart';


part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRemoteDataSource remoteDataSource;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  ScheduleFilterModel currentFilter = ScheduleFilterModel();
  List<ScheduleModel> _allSchedules = [];

  ScheduleCubit({required this.remoteDataSource}) : super(ScheduleInitial());

  Future<void> getMySchedules({
    ScheduleFilterModel? filter,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allSchedules.clear();
      emit(ScheduleLoading());
    } else if (!_hasMore) {
      _isLoading = false;
      return;
    }

    if (filter != null) {
      currentFilter = filter;
    }

    try {
      final result = await remoteDataSource.getMySchedules(
        filters: currentFilter.toJson(),
        page: _currentPage,
        perPage: 10,
      );

      if (result is Success<PaginatedResponse<ScheduleModel>>) {
        final newSchedules = result.data.paginatedData?.items ?? [];
        _allSchedules.addAll(newSchedules);
        _hasMore = result.data.meta?.currentPage != null &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ScheduleSuccess(
          schedules: _allSchedules,
          hasMore: _hasMore,
          paginatedResponse: result.data,
        ));
      } else if (result is ResponseError<PaginatedResponse<ScheduleModel>>) {
        emit(ScheduleError(error: result.message ?? 'Failed to fetch schedules'));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> getScheduleDetails(String id) async {
    emit(ScheduleLoading());
    final result = await remoteDataSource.getScheduleDetails(id);
    if (result is Success<ScheduleModel>) {
      emit(ScheduleDetailsLoaded(schedule: result.data));
    } else if (result is ResponseError<ScheduleModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch schedule details');
      emit(ScheduleError(error: result.message ?? 'Failed to fetch schedule details'));
    }
  }
  Future<void> toggleScheduleStatus(String id, BuildContext context) async {
    emit(ScheduleLoading());
    final result = await remoteDataSource.toggleScheduleStatus(id);

    if (result is Success<ToggleScheduleResponse>) {
      if (result.data.bookedSlots.isEmpty) {
      } else {
        // Show dialog with booked slots
        _showBookedSlotsDialog(context, result.data);
      }
    } else if (result is ResponseError<ToggleScheduleResponse>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to toggle schedule status');
      emit(ScheduleError(error: result.message ?? 'Failed to toggle schedule status'));
    }
  }

  void _showBookedSlotsDialog(BuildContext context, ToggleScheduleResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Deactivate Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(response.msg),
              const SizedBox(height: 16),
              const Text('Booked slots:'),
              const SizedBox(height: 8),
              ...response.bookedSlots.map((slot) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${DateFormat('MMM d, y HH:mm').format(slot.startDate)} - '
                      '${DateFormat('HH:mm').format(slot.endDate)}',
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> createSchedule(ScheduleModel schedule) async {
    emit(ScheduleLoading());
    final result = await remoteDataSource.createSchedule(schedule);
    if (result is Success<PublicResponseModel>) {
     if(result.data.status) {
       emit(ScheduleCreated());
     }
      if(!result.data.status) {
        emit(ScheduleError(error: result.data.msg ?? 'Failed to update schedule'));
        ShowToast.showToastError(message: result.data.msg);

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create schedule');
      emit(ScheduleError(error: result.message ?? 'Failed to create schedule'));
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    emit(ScheduleLoading());
    final result = await remoteDataSource.updateSchedule(schedule);
    if (result is Success<PublicResponseModel>) {

      if(result.data.status) {
        emit(ScheduleUpdated());
      }
      if(!result.data.status) {
        emit(ScheduleError(error: result.data.msg ?? 'Failed to update schedule'));
        ShowToast.showToastError(message: result.data.msg);

      }

    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update schedule');
      emit(ScheduleError(error: result.message ?? 'Failed to update schedule'));
    }
  }

  void clearFilters() {
    currentFilter = ScheduleFilterModel();
    getMySchedules();
  }
}