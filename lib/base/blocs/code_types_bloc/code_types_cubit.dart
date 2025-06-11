import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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

  Future<void> _initializeData() async {
    final cachedCodeTypes = await getCachedCodeTypes();
    if (cachedCodeTypes == null || cachedCodeTypes.isEmpty) {
      await fetchCodeTypes();
    } else {
      if (!isClosed) {
        emit(CodeTypesSuccess(codeTypes: cachedCodeTypes, codes: []));
      }
      await _fetchInitialCodes();
    }
  }

  Future<void> fetchCodeTypes() async {
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
        await _fetchInitialCodes();
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

  Future<void> _fetchInitialCodes() async {
    await getGenderCodes();
    await getMaritalStatusCodes();
  }

  Future<List<CodeModel>> getGenderCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getGenderCodes();
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
      await fetchCodes(codeTypeId: genderCodeType.id, codeTypes: codeTypes);
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

  Future<List<CodeModel>> getTelecomTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getTelecomTypeCodes();
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

  Future<List<CodeModel>> getTelecomUseCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getTelecomUseCodes();
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
      await fetchCodes(codeTypeId: telecomUseCodeType.id, codeTypes: codeTypes);
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

  Future<List<CodeModel>> getMaritalStatusCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getMaritalStatusCodes();
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

  Future<List<CodeModel>> getAppointmentTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAppointmentTypeCodes();
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


  Future<List<CodeModel>> getAppointmentStatusCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAppointmentTypeCodes();
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
        codeTypeId: appointmentStatusCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where(
            (code) => code.codeTypeModel!.id == appointmentStatusCodeType.id,
      )
          .toList() ??
          [];
    }
    return [];
  }




  Future<List<CodeModel>> getServiceCategoryCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getServiceCategoryCodes();
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
        codeTypeId: CategoryCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where(
            (code) => code.codeTypeModel!.id == CategoryCodeType.id,
      )
          .toList() ??
          [];
    }
    return [];
  }


  Future<void> fetchCodes({
    required int codeTypeId,
    required List<CodeTypeModel> codeTypes,
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
  Future<List<CodeModel>> getAddressTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAddressTypeCodes();
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

  Future<List<CodeModel>> getAddressUseCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAddressUseCodes();
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
      await fetchCodes(codeTypeId: addressUseCodeType.id, codeTypes: codeTypes);
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


  Future<List<CodeModel>> getAllergyTypeCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyTypeCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyTypeCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getAllergyCategoryCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyCategoryCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyCategoryCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }





  Future<List<CodeModel>> getAllergyCriticalityCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyCriticalityCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyCriticalityCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getAllergyVerificationStatusCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyVerificationStatusCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyVerificationStatusCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getAllergyClinicalStatusCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyClinicalStatusCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyClinicalStatusCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getEncounterTypeCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: encounterTypeCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == encounterTypeCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }
  Future<List<CodeModel>> getEncounterStatusCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: encounterStatusCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == encounterStatusCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getAllergyReactionExposureRouteCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
          (code) => code.codeTypeModel?.id == allergyReactionExposureRouteCodeType.id,
    )) {
      await fetchCodes(codeTypeId: allergyReactionExposureRouteCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyReactionExposureRouteCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getAllergyReactionSeverityCodes() async {
    final codeTypes =
    state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAllergyTypeCodes();
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
      await fetchCodes(codeTypeId: allergyReactionSeverityCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel?.id == allergyReactionSeverityCodeType.id)
          .toList() ??
          [];
    }
    return [];
  }


  Future<List<CodeModel>> getQualificationTypeCodes() async {
    final codeTypes = state is CodeTypesSuccess
        ? (state as CodeTypesSuccess).codeTypes
        : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getQualificationTypeCodes();
    }

    final qualificationTypeCodeType = codeTypes.firstWhere(
          (ct) => ct.name == 'qualification_type',
      orElse: () => throw Exception('Qualification type code type not found'),
    );
    final currentCodes = (state is CodeTypesSuccess ? (state as CodeTypesSuccess).codes : null) ?? [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == qualificationTypeCodeType.id)) {
      await fetchCodes(codeTypeId: qualificationTypeCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
          ?.where((code) => code.codeTypeModel!.id == qualificationTypeCodeType.id)
          .toList() ?? [];
    }
    return [];
  }
}
