import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/theme/app_color.dart';
import '../../data/models/allergy_filter_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import 'allergy_details_page.dart';

class AllergyListPage extends StatefulWidget {
  final String patientId;
AllergyFilterModel filter=AllergyFilterModel();
   AllergyListPage({
    super.key,
    required this.patientId,
    required this.filter,
  });

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

    _fetchInitialAllergies();
  }

  @override
  void didUpdateWidget(AllergyListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter || widget.patientId != oldWidget.patientId) {
      _fetchInitialAllergies();
    }
  }


  void _fetchInitialAllergies() {
      context.read<AllergyCubit>().getAllergies(patientId: widget.patientId,filter: widget.filter);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _isLoadingMore = true;
        context
            .read<AllergyCubit>()
            .getAllergies(patientId: widget.patientId,filter: widget.filter, loadMore: true)
            .then((_) => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            if (state.allergies.isEmpty && !state.hasMore) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'allergyPage.no_allergies_found'.tr(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchInitialAllergies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: Text('allergyPage.retry_button'.tr(context)),
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
          return const Center(child: LoadingPage());
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
                    appointmentId: null,
                  ),
            ),
          );
          _fetchInitialAllergies();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allergy.name ?? 'allergyPage.unknown_allergy'.tr(context),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              if (allergy.type != null)
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'allergyPage.type_label'.tr(context),
                  value: allergy.type!.display,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.clinicalStatus != null)
                _buildInfoRow(
                  icon: Icons.healing,
                  label: 'allergyPage.status_label'.tr(context),
                  value: allergy.clinicalStatus!.display,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.lastOccurrence != null &&
                  allergy.lastOccurrence!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'allergyPage.last_occurrence_label'.tr(context),
                  value:  DateFormat('MMM d, y').format(DateTime.parse(allergy.lastOccurrence!)).toString(),
                  theme: theme,
                  isDate: true
                ),
              const SizedBox(height: 10),
              if (allergy.onSetAge != null && allergy.onSetAge!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.cake,
                  label: 'allergyPage.onset_age_label'.tr(context),
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
    bool isDate=false
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
              color: AppColors.label,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
