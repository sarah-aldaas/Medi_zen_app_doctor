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

    if (_endDate.isBefore(_startDate)) {
      _endDate = _startDate.add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(

          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface:
                  theme.canvasColor,
              onSurface:
                  theme
                      .colorScheme
                      .onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
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
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;

          if (_startDate.isAfter(picked)) {
            _startDate = picked.subtract(const Duration(days: 1));
          }
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
        reason:
            _reasonController.text.trim().isNotEmpty
                ? _reasonController.text.trim()
                : 'Vacation',
        schedule: widget.schedule,
      );

      if (widget.initialVacation == null) {
        context.read<VacationCubit>().createVacation(vacation,context);
      } else {
        context.read<VacationCubit>().updateVacation(vacation,context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialVacation == null
              ? 'Create New Vacation'
              : 'Edit Vacation',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.9), primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vacation created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is VacationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vacation updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is VacationError) {
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vacation Period',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.event_available,
                            color: primaryColor,
                            size: 28,
                          ),
                          title: Text(
                            'Start Date',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            DateFormat('MMMM d, y').format(_startDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          trailing: Icon(Icons.edit, color: primaryColor),
                          onTap: () => _selectDate(context, true),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                        ),
                        const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.event_busy,
                            color: primaryColor,
                            size: 28,
                          ),
                          title: Text(
                            'End Date',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            DateFormat('MMMM d, y').format(_endDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          trailing: Icon(Icons.edit, color: primaryColor),
                          onTap: () => _selectDate(context, false),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Reason for Vacation',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason (e.g., Annual Leave, Conference)',
                      hintText: 'Enter reason for vacation',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          theme.brightness == Brightness.light
                              ? Colors.grey[100]
                              : Colors.grey[800],
                      prefixIcon: Icon(
                        Icons.notes,
                        color: primaryColor,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      errorStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a reason for the vacation.';
                      }
                      return null;
                    },
                    style: theme.textTheme.bodyLarge,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child:
                        state is VacationLoading
                            ? LoadingButton()
                            : ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: const Icon(Icons.save),
                              label: Text(
                                widget.initialVacation == null
                                    ? 'Create Vacation'
                                    : 'Update Vacation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ),
                                ),
                                elevation: 8, // Prominent shadow
                                shadowColor: primaryColor.withOpacity(
                                  0.4,
                                ),
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
}
