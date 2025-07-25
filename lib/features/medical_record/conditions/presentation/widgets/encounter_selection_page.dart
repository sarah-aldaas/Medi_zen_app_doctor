import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/pages/edit_profile_screen.dart';

import '../cubit/condition_cubit/conditions_cubit.dart';

class EncounterSelectionPage extends StatefulWidget {
  final String patientId;
  final List<String> initiallySelected;

  const EncounterSelectionPage({
    super.key,
    required this.patientId,
    required this.initiallySelected,
  });

  @override
  _EncounterSelectionPageState createState() => _EncounterSelectionPageState();
}

class _EncounterSelectionPageState extends State<EncounterSelectionPage> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initiallySelected);
    context.read<ConditionsCubit>().getLast10Encounters(
      patientId: widget.patientId,
      context: context,
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Encounters'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedIds);
            },
          ),
        ],
      ),
      body: BlocBuilder<ConditionsCubit, ConditionsState>(
        builder: (context, state) {
          if (state is Last10EncountersLoaded) {
            return ListView.builder(
              itemCount: state.encounters.length,
              itemBuilder: (context, index) {
                final encounter = state.encounters[index];
                return CheckboxListTile(
                  title: Text(encounter.reason ?? 'No reason'),
                  subtitle: Text('${encounter.actualStartDate}'),
                  value: _selectedIds.contains(encounter.id),
                  onChanged: (_) => _toggleSelection(encounter.id!),
                );
              },
            );
          }
          return Center(child: LoadingButton());
        },
      ),
    );
  }
}