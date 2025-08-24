import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../../base/data/models/code_type_model.dart';
import '../../../../base/go_router/go_router.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../../base/widgets/show_toast.dart';
import '../../data/models/update_profile_request_Model.dart';
import '../cubit/profile_cubit/profile_cubit.dart';
import '../widgets/avatar_image_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.doctorModel});
  final UpdateProfileRequestModel doctorModel;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
 @override
  void initState() {
   context.read<ProfileCubit>().fetchMyProfile();

   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit(remoteDataSource: serviceLocator()),
        ),
        BlocProvider(
          create:
              (context) => CodeTypesCubit(remoteDataSource: serviceLocator()),
        ),
        BlocProvider(
          create:
              (context) => EditProfileFormCubit(context.read<CodeTypesCubit>()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: 70,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.whiteColor, height: 1.0),
          ),
          leadingWidth: 100,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "editProfileScreen.editProfile".tr(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
                builder: (context, formState) {
                  final cubit = context.read<EditProfileFormCubit>();
                  return TextButton(
                    onPressed:
                    cubit.isFormValid()
                        ? () => cubit.submitForm(context)
                        : null,
                    child:
                    context.read<ProfileCubit>().state.status ==
                        ProfileStatus.loadignUpdate
                        ?  LoadingButton(isWhite: false)
                        : Text(
                      'editProfileScreen.update'.tr(
                        context,
                      ), // Localized
                      style: TextStyle(
                        fontSize: 16,
                        color:
                        cubit.isFormValid()
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[SizedBox(height: 20), EditProfileForm()],
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final EditProfileFormCubit _cubit;
  String? image;
  bool avatarChanged = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<EditProfileFormCubit>();
    context.read<ProfileCubit>().fetchMyProfile();
    _cubit.loadCodes(context: context);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success &&
            state.doctorModel == null) {
          ShowToast.showToasts(
            message: 'editProfileScreen.profileUpdatedSuccessfully'.tr(context),
          );
          Navigator.pop(context);
          // context.pushNamed(AppRouter.profileDetails.name);
        } else if (state.errorMessage.isNotEmpty) {
          ShowToast.showToastError(message: state.errorMessage);
        } else if (state.status == ProfileStatus.success &&
            state.doctorModel != null) {
          _cubit.preFillForm(
            firstName: state.doctorModel!.fName,
            lastName: state.doctorModel!.lName,
            genderId: state.doctorModel!.genderId?.toString(),
            image: state.doctorModel!.avatar,
            dateOfBirth: state.doctorModel!.dateOfBirth,
            text: state.doctorModel!.text,
            family: state.doctorModel!.family,
            given: state.doctorModel!.given,
            prefix: state.doctorModel!.prefix,
            suffix: state.doctorModel!.suffix,
            address: state.doctorModel!.address,
          );
          setState(() {
            image = state.doctorModel!.avatar;
          });
        }
      },
      builder: (context, profileState) {
        return BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
          builder: (context, formState) {
            if (formState.isLoadingCodes ||
                profileState.status == ProfileStatus.loadignUpdate) {
              return  Center(child: LoadingButton());
            }

            return Form(
              key: const Key('EditProfileForm'),
              child: Column(
                children: [
                  _buildAvatarPicker(formState.avatar),
                  const SizedBox(height: 25),
                  _buildTextField('firstName', 'editProfileScreen.firstName'),
                  const Gap(20),
                  _buildTextField('lastName', 'editProfileScreen.lastName'),
                  const Gap(20),
                  _buildDropdown(
                    'genderId',
                    'editProfileScreen.gender',
                    formState.genderCodes,
                        (value) => _cubit.updateGenderId(value),
                    formState.genderId,
                  ),
                  const Gap(20),
                  _buildDatePicker(context),
                  const Gap(20),
                  _buildTextField('text', 'editProfileScreen.aboutMe'),
                  const Gap(20),
                  _buildTextField('family', 'editProfileScreen.familyName'),
                  const Gap(20),
                  _buildTextField('given', 'editProfileScreen.givenName'),
                  const Gap(20),
                  _buildTextField('prefix', 'editProfileScreen.prefix'),
                  const Gap(20),
                  _buildTextField('suffix', 'editProfileScreen.suffix'),
                  const Gap(20),
                  _buildTextField('address', 'editProfileScreen.address'),
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarPicker(File? avatar) {
    return Center(
      child: Stack(
        children: [
          avatar != null
              ? CircleAvatar(radius: 80, backgroundImage: FileImage(avatar))
              : image != null && image!.isNotEmpty
              ? AvatarImage(imageUrl: image, radius: 80, key: ValueKey(image))
              : CircleAvatar(
            radius: 80,
            backgroundImage: const AssetImage("assets/images/person.jpg"),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 4.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
              onPressed: _showImageSourceDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String key, String hintKey) {
    return TextFormField(
      onChanged: (value) => _cubit.updateFormData(key, value),
      initialValue: _cubit.state.formData[key],
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        hintText: hintKey.tr(context),
        prefixIcon: Icon(_getIconForKey(key), color: const Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'editProfileScreen.thisFieldIsRequired'.tr(context);
        }
        return null;
      },
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'firstName':
      case 'lastName':
      case 'given':
        return Icons.person;
      case 'text':
        return Icons.info;
      case 'family':
        return Icons.family_restroom;
      case 'prefix':
      case 'suffix':
        return Icons.title;
      case 'address':
        return Icons.location_on;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildDropdown(
      String key,
      String hintKey,
      List<CodeModel> codes,
      Function(String?) onChanged,
      String? value,
      ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintKey.tr(context),
        prefixIcon: Icon(
          key == 'genderId' ? Icons.male : Icons.people,
          color: const Color(0xFF47BD93),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      items:
      codes.map((code) {
        return DropdownMenuItem<String>(
          value: code.id.toString(),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child:
            key == 'genderId'
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    code.display.toLowerCase() == 'male'
                        ? Icons.male
                        : Icons.female,
                    color:
                    code.display.toLowerCase() == 'male'
                        ? Colors.blue
                        : Colors.pink,
                  ),
                ),
                const SizedBox(width: 8),
                Text(code.display),
              ],
            )
                : Text(code.display),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'editProfileScreen.thisFieldIsRequired'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: () => _selectDate(context),
      controller: TextEditingController(
        text:
        _cubit.state.dateOfBirth ??
            'editProfileScreen.selectDateOfBirth'.tr(context),
      ),
      decoration: InputDecoration(
        labelText: 'editProfileScreen.dateOfBirth'.tr(context),
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _cubit.state.copyWith(
        dateOfBirth:
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'editProfileScreen.selectImageSource'.tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera, color: AppColors.camera),
                title: Text('editProfileScreen.camera'.tr(context)),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      avatarChanged = true;
                      image = null;
                    });
                    _cubit.updateAvatar(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.gallery,
                ),
                title: Text('editProfileScreen.gallery'.tr(context)),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      avatarChanged = true;
                      image = null;
                    });
                    _cubit.updateAvatar(File(pickedFile.path));
                  }
                },
              ),
              if (_cubit.state.avatar != null || image != null)
                ListTile(
                  leading: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  title: Text('editProfileScreen.removeImage'.tr(context)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      avatarChanged = true;
                      image = null;
                    });
                    _cubit.updateAvatar(null);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'editProfileScreen.cancel'.tr(context),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileFormState {
  final List<CodeModel> genderCodes;
  final List<CodeModel> maritalStatusCodes;
  final String? genderId;
  final String? maritalStatusId;
  final String? image;
  final bool isLoadingCodes;
  final Map<String, String> formData;
  final File? avatar;
  final String? dateOfBirth;

  EditProfileFormState({
    this.genderCodes = const [],
    this.maritalStatusCodes = const [],
    this.genderId,
    this.maritalStatusId,
    this.isLoadingCodes = true,
    this.formData = const {
      'firstName': '',
      'lastName': '',
      'text': '',
      'family': '',
      'given': '',
      'prefix': '',
      'suffix': '',
      'address': '',
    },
    this.avatar,
    this.image,
    this.dateOfBirth,
  });

  EditProfileFormState copyWith({
    List<CodeModel>? genderCodes,
    List<CodeModel>? maritalStatusCodes,
    String? genderId,
    String? maritalStatusId,
    String? image,
    bool? isLoadingCodes,
    Map<String, String>? formData,
    File? avatar,
    String? dateOfBirth,
  }) {
    return EditProfileFormState(
      genderCodes: genderCodes ?? this.genderCodes,
      maritalStatusCodes: maritalStatusCodes ?? this.maritalStatusCodes,
      genderId: genderId ?? this.genderId,
      maritalStatusId: maritalStatusId ?? this.maritalStatusId,
      isLoadingCodes: isLoadingCodes ?? this.isLoadingCodes,
      formData: formData ?? this.formData,
      avatar: avatar ?? this.avatar,
      image: image ?? this.image,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class EditProfileFormCubit extends Cubit<EditProfileFormState> {
  final CodeTypesCubit codeTypesCubit;

  EditProfileFormCubit(this.codeTypesCubit) : super(EditProfileFormState());

  Future<void> loadCodes({required BuildContext context}) async {
    if (state.isLoadingCodes) {
      final results = await Future.wait([
        codeTypesCubit.getGenderCodes(context: context),
        codeTypesCubit.getMaritalStatusCodes(context: context),
      ]);

      emit(
        state.copyWith(
          genderCodes: results[0],
          maritalStatusCodes: results[1],
          isLoadingCodes: false,
          genderId: state.genderId ?? results[0].first.id.toString(),
          maritalStatusId:
          state.maritalStatusId ?? results[1].first.id.toString(),
        ),
      );
    }
  }

  void updateFormData(String key, String value) {
    final newFormData = Map<String, String>.from(state.formData)..[key] = value;
    emit(state.copyWith(formData: newFormData));
  }

  void updateGenderId(String? value) {
    emit(state.copyWith(genderId: value));
  }

  void updateAvatar(File? avatar) {
    emit(state.copyWith(avatar: avatar));
  }

  void preFillForm({
    required String? firstName,
    required String? lastName,
    required String? genderId,
    String? image,
    String? dateOfBirth,
    String? text,
    String? family,
    String? given,
    String? prefix,
    String? suffix,
    String? address,
  }) {
    final newFormData =
    Map<String, String>.from(state.formData)
      ..['firstName'] = firstName ?? ''
      ..['lastName'] = lastName ?? ''
      ..['text'] = text ?? ''
      ..['family'] = family ?? ''
      ..['given'] = given ?? ''
      ..['prefix'] = prefix ?? ''
      ..['suffix'] = suffix ?? ''
      ..['address'] = address ?? '';

    emit(
      state.copyWith(
        formData: newFormData,
        genderId: genderId,
        avatar: image == null || image!.isEmpty ? null : null,
        image: image,
        dateOfBirth: dateOfBirth,
      ),
    );
  }

  void submitForm(BuildContext context) {
    if (isFormValid()) {
      final cubit = context.read<ProfileCubit>();
      cubit.updateMyProfile(
        updateProfileRequestModel: UpdateProfileRequestModel(
          fName: state.formData['firstName']!,
          lName: state.formData['lastName']!,
          avatar: state.avatar,
          image: state.image,
          genderId: state.genderId!,
          dateOfBirth: state.dateOfBirth,
          text: state.formData['text'],
          family: state.formData['family'],
          given: state.formData['given'],
          prefix: state.formData['prefix'],
          suffix: state.formData['suffix'],
          address: state.formData['address'],
        ),
      );
    }
  }

  bool isFormValid() {
    final data = state.formData;
    return data['firstName']!.isNotEmpty &&
        data['lastName']!.isNotEmpty &&
        state.genderId != null;
  }
}

