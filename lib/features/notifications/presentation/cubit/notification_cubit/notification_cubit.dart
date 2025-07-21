import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/network_info.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/data_source/notification_remote_datasource.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/store_FCM_model.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationCubit({required this.remoteDataSource, required this.networkInfo}) : super(NotificationInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  List<NotificationModel> _allNotifications = [];

  Future<void> getMyNotifications({bool isRead = false, bool loadMore = false, required BuildContext context, int perPage = 10, int currentPage = 1}) async {
    if (!loadMore) {
      _currentPage = currentPage;
      _hasMore = true;
      _allNotifications = [];
      emit(NotificationLoading());
    } else if (!_hasMore) {
      return;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(NotificationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getMyNotification(page: _currentPage, perPage: perPage, isRead: isRead);

    if (result is Success<PaginatedResponse<NotificationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allNotifications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          NotificationSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<NotificationModel>(
              paginatedData: PaginatedData<NotificationModel>(items: _allNotifications),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(NotificationError(error: result.data.msg ?? 'Failed to fetch notifications'));
      }
    } else if (result is ResponseError<PaginatedResponse<NotificationModel>>) {
      emit(NotificationError(error: result.message ?? 'Failed to fetch notifications'));
    }
  }

  Future<void> storeFCMToken({required StoreFCMModel model, required BuildContext context}) async {
    emit(NotificationOperationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(NotificationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.storeFCMToken(storeFCMModel: model);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(FCMOperationSuccess(response: result.data));
      // ShowToast.showToastSuccess(message: result.data.msg ?? 'FCM token stored successfully');
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(NotificationError(error: result.message ?? 'Failed to store FCM token'));
    }
  }

  Future<void> deleteFCMToken({required StoreFCMModel model, required BuildContext context}) async {
    emit(NotificationOperationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(NotificationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.deleteFCMToken(storeFCMModel: model);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(FCMOperationSuccess(response: result.data));
      getMyNotifications(context: context);
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(NotificationError(error: result.message ?? 'Failed to delete FCM token'));
    }
  }

  Future<void> markNotificationAsRead({required String notificationId, required BuildContext context}) async {
    emit(NotificationOperationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(NotificationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.makeNotificationAsRead(notificationId: notificationId);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(FCMOperationSuccess(response: result.data));
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(NotificationError(error: result.message ?? 'Failed to mark notification as read'));
    }
  }

  Future<void> deleteNotification({required String notificationId, required BuildContext context, required bool isRead}) async {
    emit(NotificationOperationLoading());
    final result = await remoteDataSource.deleteNotification(notificationId: notificationId);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      getMyNotifications(context: context, currentPage: 1, isRead: isRead);
      emit(FCMOperationSuccess(response: result.data));
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(NotificationError(error: result.message ?? 'Failed to delete notification'));
    }
  }

  Future<void> sendNotification({required String appointmentId, required BuildContext context}) async {
    emit(NotificationOperationLoading());
    final result = await remoteDataSource.sendNotification(appointmentId: appointmentId);

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        ShowToast.showToastSuccess(message: "Send");
        emit(FCMOperationSuccess(response: result.data));
      } else {
        emit(NotificationError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(NotificationError(error: result.message ?? 'Failed to send notification'));
    }
  }
}
