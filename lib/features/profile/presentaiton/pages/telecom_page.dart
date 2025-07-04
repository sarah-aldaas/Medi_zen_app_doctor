import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../data/models/telecom_model.dart';
import '../cubit/telecom_cubit/telecom_cubit.dart';
import '../widgets/telecom/telecom_details_dialog.dart';
import '../widgets/telecom/telecom_update_create_dialogs.dart';

class TelecomPage extends StatefulWidget {
  const TelecomPage({super.key});

  @override
  State<TelecomPage> createState() => _TelecomPageState();
}

class _TelecomPageState extends State<TelecomPage> {
  late Future<List<CodeModel>> telecomTypesFuture;
  late Future<List<CodeModel>> telecomUseFuture;

  @override
  void initState() {
    super.initState();
    telecomTypesFuture = context.read<CodeTypesCubit>().getTelecomTypeCodes(context: context);
    telecomUseFuture = context.read<CodeTypesCubit>().getTelecomUseCodes(context: context);
    context.read<TelecomCubit>().fetchTelecoms(
      paginationCount: '100',
      rank: '',
    );
  }

  Widget _buildTelecomCard(BuildContext context, TelecomModel telecom) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: theme.cardColor,
      child: ExpansionTile(
        leading: Icon(
          Icons.phone_android,
          color: theme.iconTheme.color,
          size: 30,
        ),
        title: Text(
          telecom.value ?? 'N/A',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${telecom.type?.display ?? 'N/A'} - ${telecom.use?.display ?? 'N/A'}',
          style: theme.textTheme.bodyMedium,
        ),
        childrenPadding: const EdgeInsets.all(20),
        collapsedIconColor: theme.iconTheme.color,
        iconColor: theme.primaryColor,
        children: [
          Row(
            children: [
              Icon(Icons.tag, size: 25, color: theme.iconTheme.color),
              const Gap(12),
              Text(
                "telecomPage.type".tr(context) +
                    "${telecom.type?.display ?? 'N/A'}",
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Icon(Icons.label, size: 25, color: theme.iconTheme.color),
              const Gap(12),
              Text(
                "telecomPage.use".tr(context) +
                    "${telecom.use?.display ?? 'N/A'}",
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),

          const Gap(25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                onPressed:
                    () => showUpdateTelecomDialog(
                      context: context,
                      telecom: telecom,
                      telecomCubit: context.read<TelecomCubit>(),
                      telecomTypesFuture: telecomTypesFuture,
                      telecomUseFuture: telecomUseFuture,
                    ),
              ),
              const Gap(10),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed:
                    () => showUpdateDeleteTelecomDialog(
                      context: context,
                      telecom: telecom,
                      telecomCubit: context.read<TelecomCubit>(),
                    ),
              ),
              const Gap(10),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
                onPressed:
                    () => showTelecomDetailsDialog(
                      context: context,
                      telecom: telecom,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentForTab(CodeModel? type) {
    if (type == null) return const SizedBox.shrink();

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        final ThemeData theme = Theme.of(context);
        if (state is TelecomInitial) {
          // context.read<TelecomCubit>().fetchTelecoms(
          //   rank: '1',
          //   paginationCount: '100',
          // );
        }

        if (state is TelecomLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          );
        }

        final telecoms =
            state is TelecomSuccess
                ? state.paginatedResponse.paginatedData?.items
                : [];
        final filteredTelecoms =
            telecoms
                ?.where((telecom) => telecom.type?.id == type.id)
                .toList() ??
            [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Gap(30),
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    showCreateTelecomDialog(
                      context: context,
                      telecomTypesFuture: telecomTypesFuture,
                      telecomUseFuture: telecomUseFuture,
                      telecomCubit: context.read<TelecomCubit>(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    elevation: 3,
                  ),
                  child: Text('telecomPage.addNewTelecom'.tr(context)),
                ),
              ),
              const Gap(30),
              filteredTelecoms.isEmpty
                  ? Center(
                    child: Text(
                      'telecomPage.noTelecomsOfType'.tr(context),
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTelecoms.length,
                    itemBuilder: (context, index) {
                      return _buildTelecomCard(
                        context,
                        filteredTelecoms[index],
                      );
                    },
                  ),
            ],
          ),
        );
      },
    );
  }

  CodeModel? _selectedTab;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()),
        BlocProvider(create: (context) => serviceLocator<TelecomCubit>()),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'telecomPage.telecoms'.tr(context),
            style:
                theme.appBarTheme.titleTextStyle?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: FutureBuilder<List<CodeModel>>(
              future: telecomTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LinearProgressIndicator(color: theme.primaryColor),
                  );
                }
                final telecomTypes = snapshot.data ?? [];
                if (telecomTypes.isEmpty) {
                  return const SizedBox.shrink();
                }
                _selectedTab ??= telecomTypes.first;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        telecomTypes.map((type) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ChoiceChip(
                              label: Text(type.display ?? 'N/A'),
                              selected: _selectedTab == type,
                              selectedColor: theme.primaryColor,
                              backgroundColor: theme.chipTheme.backgroundColor,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTab = type;
                                });
                              },
                              labelStyle: theme.chipTheme.labelStyle?.copyWith(
                                color:
                                    _selectedTab == type
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        body: FutureBuilder<List<CodeModel>>(
          future: telecomTypesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              );
            }
            final telecomTypes = snapshot.data ?? [];
            return _buildContentForTab(_selectedTab ?? telecomTypes.first);
          },
        ),
      ),
    );
  }
}
