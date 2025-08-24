import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/flexible_image.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';
import 'package:medi_zen_app_doctor/features/services/pages/widgets/health_care_service_filter_dialog.dart';

import '../../../base/widgets/loading_page.dart';
import '../../../base/widgets/show_toast.dart';
import '../data/model/health_care_service_filter.dart';
import 'cubits/service_cubit/service_cubit.dart';

class HealthCareServicesPage extends StatefulWidget {
  const HealthCareServicesPage({super.key});

  @override
  State<HealthCareServicesPage> createState() => _HealthCareServicesPageState();
}

class _HealthCareServicesPageState extends State<HealthCareServicesPage> {
  final ScrollController _scrollController = ScrollController();
  HealthCareServiceFilter _filter = HealthCareServiceFilter();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialServices() {
    _isLoadingMore = false;
    context.read<ServiceCubit>().getAllServiceHealthCare(filters: _filter.toJson());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<ServiceCubit>().getAllServiceHealthCare(filters: _filter.toJson(), loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<HealthCareServiceFilter>(context: context, builder: (context) => HealthCareServiceFilterDialog(currentFilter: _filter));

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Health Care Services', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.filter_list, color: Colors.grey), onPressed: _showFilterDialog)],
      ),
      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceHealthCareError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ServiceHealthCareLoading && !state.isLoadMore) {
            return Center(child: LoadingPage());
          }

          final services = state is ServiceHealthCareSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is ServiceHealthCareSuccess ? state.hasMore : false;
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("There are not any services.", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 24),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: services.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < services.length) {
                return _buildServiceItem(services[index]);
              } else if (hasMore && state is! ServiceHealthCareError) {
                return Center(child: LoadingButton());
              }
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(HealthCareServiceModel service) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading:FlexibleImage(width: 50, height: 50,imageUrl: service.photo,),
        title: Text(service.name ?? 'Unnamed Service'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.comment ?? 'No description'),
            Text('Price: \$${service.price ?? 'N/A'}'),
            if (service.category != null) Text('Category: ${service.category!.display}'),
          ],
        ),
        trailing: service.appointmentRequired ?? false ? const Icon(Icons.calendar_today) : const Icon(Icons.ac_unit),
        onTap:
            () => context.pushNamed(AppRouter.healthServiceDetails.name, extra: {"serviceId": service.id.toString()}).then((value) {
              _loadInitialServices();
            }),
      ),
    );
  }
}
