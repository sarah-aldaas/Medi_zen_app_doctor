import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/telecom_model.dart';

import '../../../../../../../../base/theme/app_color.dart';
import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';

class TelecomPatientPage extends StatefulWidget {
  final List<TelecomModel> list;
  const TelecomPatientPage({super.key, required this.list});

  @override
  State<TelecomPatientPage> createState() => _TelecomPatientPageState();
}

class _TelecomPatientPageState extends State<TelecomPatientPage> {
  late Future<List<CodeModel>> telecomTypesFuture;
  late Future<List<CodeModel>> telecomUseFuture;

  @override
  void initState() {
    super.initState();
    telecomTypesFuture = context.read<CodeTypesCubit>().getTelecomTypeCodes(context: context);
    telecomUseFuture = context.read<CodeTypesCubit>().getTelecomUseCodes(context: context);
  }

  Widget _buildTelecomCard(TelecomModel telecom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(
          Icons.phone_android,
          color: AppColors.gallery,
          size: 30,
        ),
        title: Text(
          telecom.value ?? 'patientPage.not_available'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${telecom.type?.display ?? 'patientPage.not_available'.tr(context)} - ${telecom.use?.display ?? 'patientPage.not_available'.tr(context)}',
          style: const TextStyle(fontSize: 15),
        ),

        onTap: () {
          showTelecomDetailsDialog(context: context, telecom: telecom);
        },
      ),
    );
  }

  Widget _buildContentForTab(CodeModel? type) {
    if (type == null) return const SizedBox.shrink();

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        final filteredTelecoms =
        widget.list
            .where((telecom) => telecom.type!.id == type.id)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Gap(30),
              filteredTelecoms.isEmpty
                  ? Center(
                child: Text('patientPage.no_telecoms_of_type'.tr(context)),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTelecoms.length,
                itemBuilder: (context, index) {
                  return _buildTelecomCard(filteredTelecoms[index]);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()),
        BlocProvider(create: (context) => serviceLocator<TelecomCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'patientPage.telecoms'.tr(context),
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.primaryColor,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: FutureBuilder<List<CodeModel>>(
              future: telecomTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
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
                          label: Text(
                            type.display ??
                                'patientPage.not_available'.tr(context),
                          ),
                          selected: _selectedTab == type,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: Colors.grey[200],
                          onSelected: (selected) {
                            setState(() {
                              _selectedTab = type;
                            });
                          },
                          labelStyle: TextStyle(
                            color:
                            _selectedTab == type
                                ? Colors.white
                                : Colors.black,
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
              return Center(child: LoadingButton());
            }
            final telecomTypes = snapshot.data ?? [];
            return _buildContentForTab(_selectedTab ?? telecomTypes.first);
          },
        ),
      ),
    );
  }
}

void showTelecomDetailsDialog({
  required BuildContext context,
  required TelecomModel telecom,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'patientPage.telecom_details'.tr(context),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: AppColors.blackColor),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              context,
              "patientPage.value_label",
              telecom.value,
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              context,
              'patientPage.type_label',
              telecom.type?.display,
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              context,
              'patientPage.use_label',
              telecom.use?.display,
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              context,
              'patientPage.start_date_label',
              telecom.startDate,
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              context,
              'patientPage.end_date_label',
              telecom.endDate,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'patientPage.cancel'.tr(context),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(BuildContext context, String titleKey, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(Icons.circle_outlined, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          titleKey.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'patientPage.not_available'.tr(context),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    ),
  );
}
