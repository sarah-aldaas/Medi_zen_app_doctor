import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/reaction_cubit/reaction_cubit.dart';

class CreateEditReactionPage extends StatefulWidget {
  final String patientId;
  final String allergyId;
  final ReactionModel? reaction;

  const CreateEditReactionPage({
    super.key,
    required this.patientId,
    required this.allergyId,
    this.reaction,
  });

  @override
  State<CreateEditReactionPage> createState() => _CreateEditReactionPageState();
}

class _CreateEditReactionPageState extends State<CreateEditReactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _substanceController = TextEditingController();
  final _manifestationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _onSetController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedSeverityId;
  String? _selectedExposureRouteId;
  List<CodeModel> severities = [];
  List<CodeModel> exposureRoutes = [];

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes(
      context: context,
    );

    if (widget.reaction != null) {
      _substanceController.text = widget.reaction!.substance ?? '';
      _manifestationController.text = widget.reaction!.manifestation ?? '';
      _descriptionController.text = widget.reaction!.description ?? '';
      _noteController.text = widget.reaction!.note ?? '';
      _selectedSeverityId = widget.reaction!.severity?.id;
      _selectedExposureRouteId = widget.reaction!.exposureRoute?.id;

      if (widget.reaction!.onSet != null) {
        try {
          final date = DateTime.parse(widget.reaction!.onSet!);
          _onSetController.text = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          _onSetController.text = widget.reaction!.onSet!;
        }
      }
    }
  }

  @override
  void dispose() {
    _substanceController.dispose();
    _manifestationController.dispose();
    _descriptionController.dispose();
    _onSetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _onSetController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final reaction = ReactionModel(
        id: widget.reaction?.id,
        substance: _substanceController.text,
        manifestation: _manifestationController.text,
        description: _descriptionController.text,
        onSet: _onSetController.text,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        severity: severities.firstWhere((s) => s.id == _selectedSeverityId),
        exposureRoute: exposureRoutes.firstWhere(
          (r) => r.id == _selectedExposureRouteId,
        ),
      );

      if (widget.reaction == null) {
        context.read<ReactionCubit>().createReaction(
          patientId: widget.patientId,
          allergyId: widget.allergyId,
          reaction: reaction,
        );
      } else {
        context.read<ReactionCubit>().updateReaction(
          patientId: widget.patientId,
          allergyId: widget.allergyId,
          reactionId: widget.reaction!.id!,
          reaction: reaction,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reaction == null
              ? 'createEditReaction.createReaction'.tr(context)
              : 'createEditReaction.editReaction'.tr(context),
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'createEditReaction.save'.tr(context),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionActionSuccess) {
            context.pop();
          } else if (state is ReactionError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading) {
            return const Center(child: LoadingPage());
          }

          return BlocBuilder<CodeTypesCubit, CodeTypesState>(
            builder: (context, codeState) {
              if (codeState is CodeTypesSuccess) {
                severities =
                    codeState.codes
                        ?.where(
                          (code) =>
                              code.codeTypeModel?.name == 'reaction_severity',
                        )
                        .toList() ??
                    [];
                exposureRoutes =
                    codeState.codes
                        ?.where(
                          (code) =>
                              code.codeTypeModel?.name ==
                              'reaction_exposure_route',
                        )
                        .toList() ??
                    [];
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _substanceController,
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.substance'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'createEditReaction.substanceRequired'
                                          .tr(context)
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _manifestationController,
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.manifestation'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'createEditReaction.manifestationRequired'
                                          .tr(context)
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.description'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'createEditReaction.descriptionRequired'
                                          .tr(context)
                                      : null,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _onSetController,
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.onsetDateFormat'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                            hintText: 'YYYY-MM-DD',
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'createEditReaction.onsetRequired'.tr(
                                context,
                              );
                            }
                            try {
                              DateTime.parse(value!);
                              return null;
                            } catch (e) {
                              return 'createEditReaction.invalidDateFormat'.tr(
                                context,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.noteOptional'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.severity'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          value: _selectedSeverityId,
                          items:
                              severities
                                  .map(
                                    (severity) => DropdownMenuItem(
                                      value: severity.id,
                                      child: Text(severity.display),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedSeverityId = value),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'createEditReaction.severityRequired'
                                          .tr(context)
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'createEditReaction.exposureRoute'.tr(
                              context,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          value: _selectedExposureRouteId,
                          items:
                              exposureRoutes
                                  .map(
                                    (route) => DropdownMenuItem(
                                      value: route.id,
                                      child: Text(route.display),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(
                                () => _selectedExposureRouteId = value,
                              ),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'createEditReaction.exposureRouteRequired'
                                          .tr(context)
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
