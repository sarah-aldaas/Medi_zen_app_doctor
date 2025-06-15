import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/widgets/allergy_form_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../../data/models/allergy_filter_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_filter_dialog.dart';
import 'allergy_details_page.dart';

class AllergyListPage extends StatefulWidget {
  final String patientId;

  const AllergyListPage({super.key, required this.patientId});

  @override
  State<AllergyListPage> createState() => _AllergyListPageState();
}

class _AllergyListPageState extends State<AllergyListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      context
          .read<AllergyCubit>()
          .getAllergies(patientId: widget.patientId, loadMore: true)
          .then((_) => _isLoadingMore = false);
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<AllergyCubit>();
    final result = await showDialog<AllergyFilterModel>(
      context: context,
      builder:
          (context) => AllergyFilterDialog(currentFilter: cubit.currentFilter),
    );

    if (result != null) {
      cubit.getAllergies(patientId: widget.patientId, filter: result);
    }
  }

  void _refreshAllergies() {
    context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AllergyFormPage(patientId: widget.patientId),
              ),
            ).then((value) {
              _refreshAllergies();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(
                'Add allergy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.add, color: AppColors.primaryColor),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading && state.isInitialLoad) {
            return const Center(child: LoadingPage());
          }

          if (state is AllergySuccess) {
            return _buildAllergyList(state);
          }

          if (state is AllergyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () => context.read<AllergyCubit>().getAllergies(
                          patientId: widget.patientId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white, // White text
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAllergyList(AllergySuccess state) {
    final theme = Theme.of(context);
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.allergies.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.allergies.length) {
          return _buildAllergyItem(state.allergies[index], theme);
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
      },
    );
  }

  Widget _buildAllergyItem(AllergyModel allergy, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AllergyDetailsPage(
                    patientId: widget.patientId,
                    allergyId: allergy.id!,
                  ),
            ),
          );
          _refreshAllergies();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allergy.name ?? 'Unknown Allergy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 10),
              if (allergy.type != null)
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'Type:',
                  value: allergy.type!.display,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.clinicalStatus != null)
                _buildInfoRow(
                  icon: Icons.healing,
                  label: 'Status:',
                  value: allergy.clinicalStatus!.display,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.lastOccurrence != null &&
                  allergy.lastOccurrence!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Last Occurrence:',
                  value: allergy.lastOccurrence!,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.onSetAge != null && allergy.onSetAge!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.cake,
                  label: 'Onset Age:',
                  value: allergy.onSetAge!,
                  theme: theme,
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
