import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../../../main.dart';
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
    _endDate =
        schedule?.planningHorizonEnd ??
        DateTime.now().add(const Duration(days: 30));
    _isActive = schedule?.active ?? true;
    _repeatPattern =
        schedule?.repeat ??
        RepeatPattern(daysOfWeek: [], timeOfDay: '09:00:00', duration: 1);
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _repeatPattern = _repeatPattern.copyWith(
          timeOfDay:
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00',
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
        comment:
            _commentController.text.isNotEmpty ? _commentController.text : null,
        doctorModel: loadingDoctorModel(),
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSchedule == null
              ? 'Create New Schedule'
              : 'Edit Schedule',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleCreated || state is ScheduleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.initialSchedule == null
                      ? 'Schedule created successfully!'
                      : 'Schedule updated successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Schedule Name',
                      hintText: 'e.g., Morning Consultations',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.title, color: primaryColor),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a schedule name';
                      }
                      return null;
                    },
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Planning Horizon'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: primaryColor,
                          ),
                          title: Text(
                            'Start Date',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, y').format(_startDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.edit, color: primaryColor),
                          onTap: () => _selectDate(context, true),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.calendar_month,
                            color: primaryColor,
                          ),
                          title: Text(
                            'End Date',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, y').format(_endDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.edit, color: primaryColor),
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Repeat Pattern'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Days of Week',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                  'sun',
                                  'mon',
                                  'tue',
                                  'wed',
                                  'thu',
                                  'fri',
                                  'sat',
                                ].map((day) {
                                  final isSelected = _repeatPattern.daysOfWeek
                                      .contains(day);
                                  return FilterChip(
                                    label: Text(day.toUpperCase()),
                                    selected: isSelected,
                                    onSelected: (_) => _toggleDay(day),
                                    selectedColor: primaryColor.withOpacity(
                                      0.2,
                                    ),
                                    showCheckmark: false,
                                    labelStyle: theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? primaryColor
                                              : Colors.grey.shade400,
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            leading: Icon(
                              Icons.access_time,
                              color: primaryColor,
                            ),
                            title: Text(
                              'Start Time',
                              style: theme.textTheme.titleSmall,
                            ),
                            subtitle: Text(
                              _repeatPattern.timeOfDay
                                  .split(':')
                                  .take(2)
                                  .join(':'),
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: Icon(Icons.edit, color: primaryColor),
                            onTap: () => _selectTime(context),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Duration: ${_repeatPattern.duration} hour${_repeatPattern.duration > 1 ? 's' : ''}',
                            style: theme.textTheme.titleSmall,
                          ),
                          Slider(
                            value: _repeatPattern.duration.toDouble(),
                            min: 0.5,
                            max: 8,
                            divisions: (8 - 0.5) ~/ 0.5,
                            label: '${_repeatPattern.duration} hours',
                            onChanged:
                                (value) => setState(() {
                                  _repeatPattern = _repeatPattern.copyWith(
                                    duration: value.round(),
                                  );
                                }),
                            activeColor: primaryColor,
                            inactiveColor: primaryColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Comment (optional)',
                      hintText: 'Add any specific notes for this schedule',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.comment, color: primaryColor),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child:
                        state is ScheduleLoading
                            ? LoadingButton()
                            : ElevatedButton.icon(
                              onPressed: _submitForm,

                              label: Text(
                                widget.initialSchedule == null
                                    ? 'Create Schedule'
                                    : 'Update Schedule',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(
            0.8,
          ), // Slightly subdued
        ),
      ),
    );
  }
}
