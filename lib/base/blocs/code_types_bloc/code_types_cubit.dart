import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../base/error/exception.dart';
import '../../../../../base/services/network/resource.dart';
import '../../constant/storage_key.dart';
import '../../data/data_sources/remote_data_sources.dart';
import '../../data/models/code_type_model.dart';
import '../../data/models/respons_model.dart';
import '../../services/di/injection_container_common.dart';
import '../../services/storage/storage_service.dart';

part 'code_types_state.dart';

class CodeTypesCubit extends Cubit<CodeTypesState> {
  final RemoteDataSourcePublic remoteDataSource;

  CodeTypesCubit({required this.remoteDataSource}) : super(CodeTypesInitial()) {
    // _initializeData();
  }

  Future<void> _initializeData({required BuildContext context}) async {
    final cachedCodeTypes = await getCachedCodeTypes();
    if (cachedCodeTypes == null || cachedCodeTypes.isEmpty) {
      await fetchCodeTypes(context: context);
    } else {
      if (!isClosed) {
        emit(CodeTypesSuccess(codeTypes: cachedCodeTypes, codes: []));
      }
      await _fetchInitialCodes(context: context);
    }
  }

  Future<void> fetchCodeTypes({required BuildContext context}) async {
    if (isClosed) return;
    emit(CodeTypesLoading());
    try {
      final result = await remoteDataSource.getCodeTypes();
      if (result is Success<CodeTypesResponseModel>) {
        final codeTypes = result.data.codeTypes;
        final codeTypesJson = jsonEncode(
          codeTypes.map((e) => e.toJson()).toList(),
        );
        serviceLocator<StorageService>().saveToDisk(
          StorageKey.codeTypesKey,
          codeTypesJson,
        );
        if (!isClosed) {
          emit(CodeTypesSuccess(codeTypes: codeTypes, codes: []));
        }
        await _fetchInitialCodes(context: context);
      } else if (result is ResponseError<CodeTypesResponseModel>) {
        if (!isClosed) {
          emit(
            CodeTypesError(
              error: result.message ?? 'Failed to fetch code types',
            ),
          );
        }
      }
    } on ServerException catch (e) {
      if (!isClosed) {
        emit(CodeTypesError(error: e.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CodeTypesError(error: 'Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<void> _fetchInitialCodes({required BuildContext context}) async {
    await getGenderCodes(context: context);
    await getMaritalStatusCodes(context: context);
  }

  Future<List<CodeModel>> getGenderCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getGenderCodes(context: context);
    }

    final genderCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'gender',
      orElse: () => throw Exception('Gender code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == genderCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: genderCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == genderCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getTelecomTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getTelecomTypeCodes(context: context);
    }

    final telecomTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'telecom_type',
      orElse: () => throw Exception('Telecom type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == telecomTypeCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: telecomTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == telecomTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getTelecomUseCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getTelecomUseCodes(context: context);
    }

    final telecomUseCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'telecom_use',
      orElse: () => throw Exception('Telecom use code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == telecomUseCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: telecomUseCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == telecomUseCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMaritalStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMaritalStatusCodes(context: context);
    }

    final maritalStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'marital_status',
      orElse: () => throw Exception('Marital status code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == maritalStatusCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: maritalStatusCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == maritalStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAppointmentTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAppointmentTypeCodes(context: context);
    }

    final appointmentTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'type_appointment',
      orElse: () => throw Exception('appointment type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == appointmentTypeCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: appointmentTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == appointmentTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAppointmentStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAppointmentTypeCodes(context: context);
    }

    final appointmentStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'status_appointment',
      orElse: () => throw Exception('appointment status code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == appointmentStatusCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: appointmentStatusCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel!.id == appointmentStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getServiceCategoryCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getServiceCategoryCodes(context: context);
    }

    final CategoryCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'categories',
      orElse: () => throw Exception('Categories type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == CategoryCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: CategoryCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == CategoryCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getDiagnosticReportStatusTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getDiagnosticReportStatusTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'diagnostic_report_status',
      orElse: () => throw Exception('Article category not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getDiagnosticReportTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getDiagnosticReportTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'diagnostic_report_type',
      orElse: () => throw Exception('Diagnostic Report Type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getDiagnosticReportCategoryCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getDiagnosticReportCategoryCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'diagnostic_report_category',
      orElse: () => throw Exception('Diagnostic Report Category not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getBloodGroupCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getBloodGroupCodes(context: context);
    }

    final bloodGroup = codeTypes.firstWhere(
      (ct) => ct.name == 'blood_group',
      orElse: () => throw Exception('blood group code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == bloodGroup.id)) {
      await fetchCodes(
        context: context,
        codeTypeId: bloodGroup.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == bloodGroup.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<void> fetchCodes({
    required int codeTypeId,
    required List<CodeTypeModel> codeTypes,
    required BuildContext context,
  }) async {
    if (isClosed) return;
    emit(CodesLoading());
    try {
      final result = await remoteDataSource.getCodes(codeTypeId: codeTypeId);
      if (result is Success<CodesResponseModel>) {
        final currentState = state;
        final existingCodes =
            (currentState is CodeTypesSuccess ? currentState.codes : null) ??
            [];
        if (!isClosed) {
          emit(
            CodeTypesSuccess(
              codeTypes: codeTypes,
              codes: [...existingCodes, ...result.data.codes],
            ),
          );
        }
      } else if (result is ResponseError<CodesResponseModel>) {
        if (!isClosed) {
          emit(CodesError(error: result.message ?? 'Failed to fetch codes'));
        }
      }
    } on ServerException catch (e) {
      if (!isClosed) {
        emit(CodesError(error: e.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CodesError(error: 'Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<List<CodeTypeModel>?> getCachedCodeTypes() async {
    try {
      final jsonString = serviceLocator<StorageService>().getFromDisk(
        StorageKey.codeTypesKey,
      );
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => CodeTypeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Add these new methods to specifically fetch address types and uses
  Future<List<CodeModel>> getAddressTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAddressTypeCodes(context: context);
    }

    final addressTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'address_type',
      orElse: () => throw Exception('Address type code type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == addressTypeCodeType.id,
    )) {
      await fetchCodes(
        context: context,
        codeTypeId: addressTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == addressTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAddressUseCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAddressUseCodes(context: context);
    }

    final addressUseCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'address_use',
      orElse: () => throw Exception('Address use code type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == addressUseCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: addressUseCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == addressUseCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'allergy_type',
      orElse: () => throw Exception('allergy type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyTypeCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == allergyTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyCategoryCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyCategoryCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'allergy_category',
      orElse: () => throw Exception('allergy category not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyCategoryCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyCategoryCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == allergyCategoryCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyCriticalityCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyCriticalityCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'allergy_criticality',
      orElse: () => throw Exception('allergy criticality not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyCriticalityCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyCriticalityCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel?.id == allergyCriticalityCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyVerificationStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyVerificationStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'allergy_verification_status',
      orElse: () => throw Exception('allergy verification status not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyVerificationStatusCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyVerificationStatusCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel?.id ==
                    allergyVerificationStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyClinicalStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyClinicalStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'allergy_clinical_status',
      orElse: () => throw Exception('allergy clinical status not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyClinicalStatusCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyClinicalStatusCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel?.id == allergyClinicalStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getEncounterTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final encounterTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'encounter_type',
      orElse: () => throw Exception('encounter type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == encounterTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: encounterTypeCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == encounterTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getEncounterStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final encounterStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'encounter_status',
      orElse: () => throw Exception('encounter status not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == encounterStatusCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: encounterStatusCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == encounterStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyReactionExposureRouteCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyReactionExposureRouteCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'reaction_exposure_route',
      orElse: () => throw Exception('reaction exposure route not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) =>
          code.codeTypeModel?.id == allergyReactionExposureRouteCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyReactionExposureRouteCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel?.id ==
                    allergyReactionExposureRouteCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAllergyReactionSeverityCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getAllergyTypeCodes(context: context);
    }

    final allergyReactionSeverityCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'reaction_severity',
      orElse: () => throw Exception('reaction severity not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == allergyReactionSeverityCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: allergyReactionSeverityCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel?.id ==
                    allergyReactionSeverityCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getQualificationTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getQualificationTypeCodes(context: context);
    }

    final qualificationTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'qualification_type',
      orElse: () => throw Exception('Qualification type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == qualificationTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: qualificationTypeCodeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) =>
                    code.codeTypeModel!.id == qualificationTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getServiceRequestStatusCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getServiceRequestStatusCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'service_request_status',
      orElse: () => throw Exception('Service request status not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getServiceRequestCategoryCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getServiceRequestCategoryCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'service_request_category',
      orElse: () => throw Exception('Service request category not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getServiceRequestPriorityCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getServiceRequestPriorityCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'service_request_priority',
      orElse: () => throw Exception('Service request priority not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getBodySiteCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getBodySiteCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'body_site',
      orElse: () => throw Exception('Body site not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationStatusTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationStatusTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_status',
      orElse: () => throw Exception('medication status not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationRouteTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationRouteTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_route',
      orElse: () => throw Exception('medication route not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationOffsetUnitTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationOffsetUnitTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_offset_unit',
      orElse: () => throw Exception('medication route not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationDoseFormTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationDoseFormTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_dose_form',
      orElse: () => throw Exception('medication route not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationRequestStatusTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationRequestStatusTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_request_status',
      orElse: () => throw Exception('medication request status not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationRequestIntentTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationRequestIntentTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_request_intent',
      orElse: () => throw Exception('medication request intent not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationRequestPriorityTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationRequestPriorityTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_request_priority',
      orElse: () => throw Exception('medication request priority not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMedicationRequestTherapyTypeTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getMedicationRequestTherapyTypeTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'medication_request_therapy_type',
      orElse:
          () => throw Exception('medication request therapy type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getConditionStageTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getConditionStageTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'condition_stage',
      orElse: () => throw Exception('condition stage not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getConditionVerificationStatusTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getConditionVerificationStatusTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'condition_verification_status',
      orElse: () => throw Exception('condition verification status not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getConditionClinicalStatusTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return getConditionClinicalStatusTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'condition_clinical_status',
      orElse: () => throw Exception('condition clinical status not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> articleCategoryTypeCodes({
    required BuildContext context,
  }) async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(context: context);
      return articleCategoryTypeCodes(context: context);
    }

    final codeType = codeTypes.firstWhere(
      (ct) => ct.name == 'article_category',
      orElse: () => throw Exception('Article category not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any((code) => code.codeTypeModel?.id == codeType.id)) {
      await fetchCodes(
        codeTypeId: codeType.id,
        codeTypes: codeTypes,
        context: context,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == codeType.id)
              .toList() ??
          [];
    }
    return [];
  }
}
