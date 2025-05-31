import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../../base/widgets/show_toast.dart';
import '../../data/models/telecom_model.dart';
import '../cubit/telecom_cubit/telecom_cubit.dart';

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
    telecomTypesFuture = context.read<CodeTypesCubit>().getTelecomTypeCodes();
    telecomUseFuture = context.read<CodeTypesCubit>().getTelecomUseCodes();
    context.read<TelecomCubit>().fetchTelecoms(paginationCount: '100');
    super.initState();
  }

  void _showUpdateDialog(TelecomModel telecom, BuildContext context) {
    final telecomCubit = context.read<TelecomCubit>();
    final valueController = TextEditingController(text: telecom.value);
    CodeModel? selectedType;
    CodeModel? selectedUse;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: FutureBuilder<List<CodeModel>>(
              future: Future.wait([telecomTypesFuture, telecomUseFuture]).then((results) => results[0]),
              builder: (context, typeSnapshot) {
                return FutureBuilder<List<CodeModel>>(
                  future: telecomUseFuture,
                  builder: (context, useSnapshot) {
                    if (typeSnapshot.connectionState == ConnectionState.waiting || useSnapshot.connectionState == ConnectionState.waiting) {
                      return Padding(padding: EdgeInsets.all(8.0), child: Center(child: LoadingButton(isWhite: false)));
                    }

                    final telecomTypes = typeSnapshot.data ?? [];
                    final telecomUses = useSnapshot.data ?? [];

                    selectedType =
                        telecomTypes.isNotEmpty
                            ? telecomTypes.firstWhere(
                              (type) => type.id == telecom.type?.id,
                              orElse: () => telecomTypes.first, // Provide default
                            )
                            : null;

                    selectedUse =
                        telecomUses.isNotEmpty
                            ? telecomUses.firstWhere(
                              (use) => use.id == telecom.use?.id,
                              orElse: () => telecomUses.first, // Provide default
                            )
                            : null;

                    return SingleChildScrollView(
                      child: Column(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'telecomPage.updateTelecom'.tr(context),
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.dangerous_outlined, color: AppColors.secondaryColor)),
                            ],
                          ),
                          TextField(
                            controller: valueController,
                            style: TextStyle(fontSize: 15),
                            decoration: InputDecoration(labelText: 'telecomPage.value'.tr(context)),
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomTypes.map((type) => DropdownMenuItem<CodeModel>(value: type, child: Text(type.display))).toList(),
                            onChanged: (value) => setState(() => selectedType = value),
                            decoration: InputDecoration(labelText: 'telecomPage.typeLabel'.tr(context)),
                            value: selectedType,
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomUses.map((use) => DropdownMenuItem<CodeModel>(value: use, child: Text(use.display))).toList(),
                            onChanged: (value) => setState(() => selectedUse = value),
                            decoration: InputDecoration(labelText: 'telecomPage.useLabel'.tr(context)),
                            value: selectedUse,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('telecomPage.cancel'.tr(context), style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (valueController.text.isNotEmpty && selectedType != null && selectedUse != null) {
                                    final updatedTelecom = TelecomModel(
                                      id: telecom.id,
                                      value: valueController.text,
                                      startDate: telecom.startDate,
                                      endDate: telecom.endDate,
                                      type: selectedType,
                                      use: selectedUse,
                                      useId: selectedUse!.id,
                                      typeId: selectedType!.id,
                                    );
                                    telecomCubit.updateTelecom(id: telecom.id!, telecomModel: updatedTelecom);
                                    Navigator.pop(context);
                                  } else {
                                    ShowToast.showToastError(message: 'telecomPage.allFieldsRequired'.tr(context));
                                  }
                                },
                                child: Text('telecomPage.update'.tr(context), style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final telecomCubit = context.read<TelecomCubit>();
    final valueController = TextEditingController();
    CodeModel? selectedType;
    CodeModel? selectedUse;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: FutureBuilder<List<CodeModel>>(
              future: Future.wait([telecomTypesFuture, telecomUseFuture]).then((results) => results[0]),
              builder: (context, typeSnapshot) {
                return FutureBuilder<List<CodeModel>>(
                  future: telecomUseFuture,
                  builder: (context, useSnapshot) {
                    if (typeSnapshot.connectionState == ConnectionState.waiting || useSnapshot.connectionState == ConnectionState.waiting) {
                      return Padding(padding: EdgeInsets.all(8.0), child: Center(child: LoadingButton(isWhite: false)));
                    }

                    final telecomTypes = typeSnapshot.data ?? [];
                    final telecomUses = useSnapshot.data ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        spacing: 20,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'telecomPage.createNewTelecom'.tr(context),
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.dangerous_outlined, color: AppColors.secondaryColor)),
                            ],
                          ),
                          TextField(
                            controller: valueController,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(labelText: 'telecomPage.valueLabel'.tr(context)),
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomTypes.map((type) => DropdownMenuItem(value: type, child: Text(type.display))).toList(),
                            onChanged: (value) => selectedType = value,
                            decoration: InputDecoration(labelText: 'telecomPage.typeLabel'.tr(context)),
                            value: selectedType,
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomUses.map((use) => DropdownMenuItem(value: use, child: Text(use.display))).toList(),
                            onChanged: (value) => selectedUse = value,
                            decoration: InputDecoration(labelText: 'telecomPage.use'.tr(context)),
                            value: selectedUse,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('telecomPage.cancel'.tr(context), style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (valueController.text.isNotEmpty && selectedType != null && selectedUse != null) {
                                    final newTelecom = TelecomModel(
                                      id: '',
                                      value: valueController.text,
                                      startDate: null,
                                      endDate: null,
                                      type: selectedType,
                                      use: selectedUse,
                                      typeId: selectedType!.id,
                                      useId: selectedUse!.id,
                                    );
                                    telecomCubit.createTelecom(telecomModel: newTelecom);
                                    Navigator.pop(context);
                                  } else {
                                    ShowToast.showToastError(message: 'telecomPage.allFieldsRequired'.tr(context));
                                  }
                                },
                                child: Text('telecomPage.create'.tr(context), style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
  }

  void _showDetailsDialog(TelecomModel telecom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'telecomPage.telecomDetails'.tr(context),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: AppColors.blackColor)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('telecomPage.value : ', telecom.value ?? 'N/A'.tr(context)),
                  _buildDetailRow('telecomPage.type : ', telecom.type?.display ?? 'N/A'.tr(context)),
                  _buildDetailRow('telecomPage.use : ', telecom.use?.display ?? 'N/A'.tr(context)),
                  _buildDetailRow('telecomPage.startDateLabel : ', telecom.startDate ?? 'N/A'.tr(context)),
                  _buildDetailRow('telecomPage.endDateLabel : ', telecom.endDate ?? 'N/A'.tr(context)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('telecomPage.cancel'.tr(context), style: TextStyle(fontSize: 15, color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle_outlined, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _buildTelecomCard(TelecomModel telecom) {

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        if (state is TelecomInitial) {
          context.read<TelecomCubit>().fetchTelecoms(paginationCount: '100');
        }

        if (state is TelecomLoading) {
          return Center(child: LoadingButton());
        }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: const Icon(Icons.phone_android, color: AppColors.gallery),
        title: Text(telecom.value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${telecom.type?.display ?? 'N/A'} - ${telecom.use?.display ?? 'N/A'}', style: TextStyle(fontSize: 16)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [Icon(Icons.tag), const Gap(8), Text('telecomPage.type: ${telecom.type?.display ?? 'N/A'}'.tr(context), style: TextStyle(fontSize: 16))],
          ),
          const Gap(8),
          Row(
            children: [
              const Icon(Icons.label),
              const Gap(8),
              Text('telecomPage.use: ${telecom.use?.display ?? 'N/A'}'.tr(context), style: TextStyle(fontSize: 16)),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.cyan), onPressed: () => _showUpdateDialog(telecom, context)),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  serviceLocator<TelecomCubit>().deleteTelecom(id: telecom.id!);
                  setState(() {
                    context.read<TelecomCubit>().fetchTelecoms( paginationCount: '100');
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.info_outline, color: Colors.blueGrey), onPressed: () => _showDetailsDialog(telecom)),
            ],
          ),
        ],
      ),
    );
  },
);
  }

  Widget _buildContentForTab(CodeModel? type) {
    if (type == null) return const SizedBox.shrink();

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        if (state is TelecomInitial) {
          context.read<TelecomCubit>().fetchTelecoms( paginationCount: '100');
        }

        if (state is TelecomLoading) {
          return Center(child: LoadingButton());
        }

        final telecoms = state is TelecomSuccess ? state.paginatedResponse.paginatedData!.items : [];
        final filteredTelecoms = telecoms.where((telecom) => telecom.type!.id == type.id).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showCreateDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.blackColor),
                      Gap(8),
                      Text('telecomPage.addNewTelecom'.tr(context), style: TextStyle(color: AppColors.blackColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              filteredTelecoms!.isEmpty
                  ? const Center(child: Text('No telecoms of this type.'))
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
      providers: [BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()), BlocProvider(create: (context) => serviceLocator<TelecomCubit>())],
      child: Scaffold(
        appBar: AppBar(
          title: Text('telecomPage.telecoms'.tr(context), style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_outlined), onPressed: () => Navigator.of(context).pop(), color: AppColors.primaryColor),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChoiceChip(
                              label: Text(type.display ?? 'N/A'),
                              selected: _selectedTab == type,
                              selectedColor: AppColors.primaryColor,
                              backgroundColor: Colors.grey[200],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTab = type;
                                });
                              },
                              labelStyle: TextStyle(color: _selectedTab == type ? Colors.white : Colors.black),
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
