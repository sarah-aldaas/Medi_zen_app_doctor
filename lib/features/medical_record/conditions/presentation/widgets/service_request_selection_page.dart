import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class ServiceRequestSelectionPage extends StatefulWidget {
  final String patientId;
  final List<String> initiallySelectedObservations;
  final List<String> initiallySelectedImaging;

  const ServiceRequestSelectionPage({
    super.key,
    required this.patientId,
    required this.initiallySelectedObservations,
    required this.initiallySelectedImaging,
  });

  @override
  _ServiceRequestSelectionPageState createState() => _ServiceRequestSelectionPageState();
}

class _ServiceRequestSelectionPageState extends State<ServiceRequestSelectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _selectedObservations;
  late List<String> _selectedImaging;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedObservations = List.from(widget.initiallySelectedObservations);
    _selectedImaging = List.from(widget.initiallySelectedImaging);

    // Call the combined function instead of separate ones
    context.read<ConditionsCubit>().getCombinedServiceRequests(
      patientId: widget.patientId,
      context: context,
    );
  }

  void _toggleObservation(String id) {
    setState(() {
      if (_selectedObservations.contains(id)) {
        _selectedObservations.remove(id);
      } else {
        _selectedObservations.add(id);
      }
    });
  }

  void _toggleImaging(String id) {
    setState(() {
      if (_selectedImaging.contains(id)) {
        _selectedImaging.remove(id);
      } else {
        _selectedImaging.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Service Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Observations'),
            Tab(text: 'Imaging Studies'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'observations': _selectedObservations,
                'imaging': _selectedImaging,
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Observation Tab
          BlocBuilder<ConditionsCubit, ConditionsState>(
            builder: (context, state) {
              if (state is ServiceRequestsLoaded) {
                // Filter for observation requests
                final observationRequests = state.serviceRequests
                    .where((sr) => sr.observation != null)
                    .toList();

                return ListView.builder(
                  itemCount: observationRequests.length,
                  itemBuilder: (context, index) {
                    final sr = observationRequests[index];
                    return CheckboxListTile(
                      title: Text(sr.orderDetails ?? 'No details'),
                      subtitle: Text(sr.healthCareService?.name ?? 'No service'),
                      value: _selectedObservations.contains(sr.id),
                      onChanged: (_) => _toggleObservation(sr.id!),
                    );
                  },
                );
              }
              return Center(child: LoadingButton());
            },
          ),

          // Imaging Study Tab
          BlocBuilder<ConditionsCubit, ConditionsState>(
            builder: (context, state) {
              if (state is ServiceRequestsLoaded) {
                // Filter for imaging study requests
                final imagingRequests = state.serviceRequests
                    .where((sr) => sr.imagingStudy != null)
                    .toList();

                return ListView.builder(
                  itemCount: imagingRequests.length,
                  itemBuilder: (context, index) {
                    final sr = imagingRequests[index];
                    return CheckboxListTile(
                      title: Text(sr.orderDetails ?? 'No details'),
                      subtitle: Text(sr.healthCareService?.name ?? 'No service'),
                      value: _selectedImaging.contains(sr.id),
                      onChanged: (_) => _toggleImaging(sr.id!),
                    );
                  },
                );
              }
              return Center(child: LoadingButton());
            },
          ),
        ],
      ),
    );
  }
}