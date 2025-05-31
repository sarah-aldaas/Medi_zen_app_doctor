import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/model/schedule_model.dart';

import '../../data/model/vacation_model.dart';
import '../cubit/vacation_cubit/vacation_cubit.dart';



class VacationFormPage extends StatefulWidget {
  final ScheduleModel schedule;
  final VacationModel? initialVacation;

  const VacationFormPage({
    required this.schedule,
    this.initialVacation,
    super.key,
  });

  @override
  State<VacationFormPage> createState() => _VacationFormPageState();
}

class _VacationFormPageState extends State<VacationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reasonController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final vacation = widget.initialVacation;
    _reasonController = TextEditingController(text: vacation?.reason ?? '');
    _startDate = vacation?.startDate ?? DateTime.now();
    _endDate = vacation?.endDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vacation = VacationModel(
        id: widget.initialVacation?.id,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text,
        schedule: widget.schedule,
      );

      if (widget.initialVacation == null) {
        context.read<VacationCubit>().createVacation(vacation);
      } else {
        context.read<VacationCubit>().updateVacation(vacation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialVacation == null
            ? 'Create Vacation'
            : 'Edit Vacation'),
      ),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationCreated || state is VacationUpdated) {
            context.pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('MMM d, y').format(_startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('MMM d, y').format(_endDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  if (state is VacationLoading)
                     Center(child: LoadingButton())
                  else
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Vacation'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}