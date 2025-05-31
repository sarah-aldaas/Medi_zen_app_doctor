import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../../../main.dart';
import '../../../authentication/data/models/doctor_model.dart';
import '../../data/model/schedule_model.dart';
import '../cubit/schedule_cubit/schedule_cubit.dart';


class ScheduleFormPage extends StatefulWidget {
  final ScheduleModel? initialSchedule;
  const ScheduleFormPage({this.initialSchedule, super.key});

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _commentController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isActive;
  late RepeatPattern _repeatPattern;

  @override
  void initState() {
    super.initState();
    final schedule = widget.initialSchedule;
    _nameController = TextEditingController(text: schedule?.name ?? '');
    _commentController = TextEditingController(text: schedule?.comment ?? '');
    _startDate = schedule?.planningHorizonStart ?? DateTime.now();
    _endDate = schedule?.planningHorizonEnd ?? DateTime.now().add(const Duration(days: 30));
    _isActive = schedule?.active ?? true;
    _repeatPattern = schedule?.repeat ?? RepeatPattern(
      daysOfWeek: [],
      timeOfDay: '09:00:00',
      duration: 1,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
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
            _endDate = picked.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeParts = _repeatPattern.timeOfDay.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _repeatPattern = _repeatPattern.copyWith(
          timeOfDay: '${picked.hour.toString().padLeft(2, '0')}:'
              '${picked.minute.toString().padLeft(2, '0')}:00',
        );
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_repeatPattern.daysOfWeek.contains(day)) {
        _repeatPattern.daysOfWeek.remove(day);
      } else {
        _repeatPattern.daysOfWeek.add(day);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final schedule = ScheduleModel(
        id: widget.initialSchedule?.id ?? "",
        name: _nameController.text,
        active: _isActive,
        planningHorizonStart: _startDate,
        planningHorizonEnd: _endDate,
        repeat: _repeatPattern,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        doctorModel:loadingDoctorModel(),
      );

      if (widget.initialSchedule == null) {
        context.read<ScheduleCubit>().createSchedule(schedule);
      } else {
        context.read<ScheduleCubit>().updateSchedule(schedule);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialSchedule == null
            ? 'Create Schedule'
            : 'Edit Schedule'),
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleCreated || state is ScheduleUpdated) {
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Schedule Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const Text('Repeat Pattern', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].map((day) {
                      return FilterChip(
                        label: Text(day.toUpperCase()),
                        selected: _repeatPattern.daysOfWeek.contains(day),
                        onSelected: (_) => _toggleDay(day),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(_repeatPattern.timeOfDay.split(':').take(2).join(':')),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _repeatPattern.duration.toDouble(),
                    min: 0.5,
                    max: 8,
                    divisions: 15,
                    label: '${_repeatPattern.duration} hours',
                    onChanged: (value) => setState(() {
                      _repeatPattern = _repeatPattern.copyWith(
                        duration: value.round(),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: 'Comment (optional)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  if (state is ScheduleLoading)
                     Center(child: LoadingButton())
                  else
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Schedule'),
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