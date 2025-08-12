import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_details_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/show_toast.dart';
import '../../data/models/patient_filter_model.dart';
import '../cubit/patient_cubit/patient_cubit.dart';
import '../widgets/patient_filter_dialog.dart';
import '../widgets/patient_item.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController.addListener(_scrollListener);
    _loadPatients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _loadPatients();
    }
  }

  void _loadPatients() {
    final isActive = _currentTabIndex == 0;
    context.read<PatientCubit>().listPatients(
      filter: PatientFilterModel(isActive: isActive),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final isActive = _currentTabIndex == 0;
      context
          .read<PatientCubit>()
          .listPatients(
            filter: PatientFilterModel(isActive: isActive),
            loadMore: true,
          )
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<PatientCubit>();
    final result = await showDialog<PatientFilterModel>(
      context: context,
      builder:
          (context) => PatientFilterDialog(currentFilter: cubit.currentFilter),
    );

    if (result != null) {
      final isActive = _currentTabIndex == 0;
      cubit.listPatients(filter: result.copyWith(isActive: isActive));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'patientPage.patients'.tr(context),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: 'patientPage.active'.tr(context)),
            Tab(text: 'patientPage.inactive'.tr(context)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPatientList(), _buildPatientList()],
      ),
    );
  }

  Widget _buildPatientList() {
    return BlocConsumer<PatientCubit, PatientState>(
      listener: (context, state) {
        if (state is PatientError) {
          ShowToast.showToastError(message: state.error);
        }
      },
      builder: (context, state) {
        if (state is PatientLoading && state is! PatientSuccess) {
          return const Center(child: LoadingPage());
        }

        if (state is PatientSuccess) {
          final patients =
              state.patients.where((patient) {
                return _currentTabIndex == 0
                    ? patient.active == '1'
                    : patient.active != '1';
              }).toList();

          if (patients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _currentTabIndex == 0
                        ? 'patientPage.no_active_patients'.tr(context)
                        : 'patientPage.no_inactive_patients'.tr(context),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: patients.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= patients.length) {
                return Center(child: LoadingButton());
              }
              return PatientItem(
                patient: patients[index],
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PatientDetailsPage(
                            patientId: patients[index].id!,
                          ),
                    ),
                  );
                },
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
