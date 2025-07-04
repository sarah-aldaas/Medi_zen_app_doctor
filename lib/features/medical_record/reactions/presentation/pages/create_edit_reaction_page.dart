import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/reaction_cubit/reaction_cubit.dart';


class CreateEditReactionPage extends StatefulWidget {
  final int patientId;
  final int allergyId;
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
    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes(context: context);

    if (widget.reaction != null) {
      _substanceController.text = widget.reaction!.substance ?? '';
      _manifestationController.text = widget.reaction!.manifestation ?? '';
      _descriptionController.text = widget.reaction!.description ?? '';
      _onSetController.text = widget.reaction!.onSet ?? '';
      _noteController.text = widget.reaction!.note ?? '';
      _selectedSeverityId = widget.reaction!.severity?.id;
      _selectedExposureRouteId = widget.reaction!.exposureRoute?.id;
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
        exposureRoute: exposureRoutes.firstWhere((r) => r.id == _selectedExposureRouteId),
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
          reactionId: int.parse(widget.reaction!.id!),
          reaction: reaction,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reaction == null ? 'Create Reaction' : 'Edit Reaction'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionActionSuccess) {
            context.pop();
          } else if (state is ReactionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading) {
            return  Center(child: LoadingPage());
          }

          return BlocBuilder<CodeTypesCubit, CodeTypesState>(
            builder: (context, codeState) {
              if (codeState is CodeTypesSuccess) {
                severities = codeState.codes?.where((code) => code.codeTypeModel?.name == 'reaction_severity').toList() ?? [];
                exposureRoutes = codeState.codes?.where((code) => code.codeTypeModel?.name == 'reaction_exposure_route').toList() ?? [];
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
                          decoration: const InputDecoration(labelText: 'Substance', border: OutlineInputBorder()),
                          validator: (value) => value?.isEmpty ?? true ? 'Substance is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _manifestationController,
                          decoration: const InputDecoration(labelText: 'Manifestation', border: OutlineInputBorder()),
                          validator: (value) => value?.isEmpty ?? true ? 'Manifestation is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                          validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _onSetController,
                          decoration: const InputDecoration(labelText: 'Onset (YYYY-MM-DD)', border: OutlineInputBorder()),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Onset is required';
                            try {
                              DateTime.parse(value!);
                              return null;
                            } catch (e) {
                              return 'Invalid date format';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(labelText: 'Note (Optional)', border: OutlineInputBorder()),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder()),
                          value: _selectedSeverityId,
                          items: severities
                              .map((severity) => DropdownMenuItem(
                            value: severity.id,
                            child: Text(severity.display),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedSeverityId = value),
                          validator: (value) => value == null ? 'Severity is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Exposure Route', border: OutlineInputBorder()),
                          value: _selectedExposureRouteId,
                          items: exposureRoutes
                              .map((route) => DropdownMenuItem(
                            value: route.id,
                            child: Text(route.display),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedExposureRouteId = value),
                          validator: (value) => value == null ? 'Exposure Route is required' : null,
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