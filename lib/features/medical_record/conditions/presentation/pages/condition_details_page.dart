// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
//
// import '../../../../../base/theme/app_color.dart';
// import '../../../../../base/widgets/loading_page.dart';
// import '../../../../../base/widgets/show_toast.dart';
// import '../../../../articles/data/model/ai_model.dart';
// import '../../../../articles/data/model/article_model.dart';
// import '../../../../articles/presentation/cubit/article_cubit/article_cubit.dart';
// import '../../data/models/conditions_model.dart';
// import '../cubit/condition_cubit/conditions_cubit.dart';
//
// class ConditionDetailsPage extends StatefulWidget {
//   final String conditionId;
//
//   const ConditionDetailsPage({super.key, required this.conditionId});
//
//   @override
//   State<ConditionDetailsPage> createState() => _ConditionDetailsPageState();
// }
//
// class _ConditionDetailsPageState extends State<ConditionDetailsPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<ConditionsCubit>().getConditionDetails(conditionId: widget.conditionId, context: context);
//   }
//
//   // Stream to update the remaining cooldown time every second
//   Stream<String> _getCooldownStream(DateTime? lastGenerationTime, int generationCount) async* {
//     while (true) {
//       if (lastGenerationTime == null) {
//         yield "Ready to generate";
//         return;
//       }
//       final now = DateTime.now();
//       final difference = now.difference(lastGenerationTime);
//       String message;
//
//       if (generationCount <= 3) {
//         final remainingMinutes = 30 - difference.inMinutes;
//         if (remainingMinutes <= 0) {
//           yield "Ready to generate";
//           return;
//         }
//         final seconds = 60 - (difference.inSeconds % 60);
//         message = "$remainingMinutes:${seconds.toString().padLeft(2, '0')} min";
//       } else if (generationCount <= 5) {
//         final remainingHours = 2 - difference.inHours;
//         if (remainingHours <= 0) {
//           yield "Ready to generate";
//           return;
//         }
//         final minutes = 60 - (difference.inMinutes % 60);
//         message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
//       } else {
//         final remainingHours = 4 - difference.inHours;
//         if (remainingHours <= 0) {
//           yield "Ready to generate";
//           return;
//         }
//         final minutes = 60 - (difference.inMinutes % 60);
//         message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
//       }
//
//       yield message;
//       await Future.delayed(const Duration(seconds: 1));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Condition Details".tr(context)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
//       body: BlocConsumer<ConditionsCubit, ConditionsState>(
//         listener: (context, state) {
//           if (state is ConditionsError) {
//             ShowToast.showToastError(message: state.error);
//           }
//         },
//         builder: (context, state) {
//           if (state is ConditionDetailsSuccess) {
//             return _buildConditionDetails(state.condition);
//           } else if (state is ConditionsLoading) {
//             return const Center(child: LoadingPage());
//           } else {
//             return const Center(child: Text('Failed to load condition details'));
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildConditionDetails(ConditionsModel condition) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeaderSection(context, condition),
//           const SizedBox(height: 24),
//           _buildMainDetailsCard(context, condition),
//           const SizedBox(height: 16),
//           _buildArticlesSection(context, condition),
//           if (condition.onSetDate != null || condition.abatementDate != null || condition.recordDate != null) _buildTimelineSection(context, condition),
//           if (condition.bodySite != null) _buildBodySiteSection(context, condition),
//           _buildClinicalInfoSection(context, condition),
//           if (condition.encounters != null && condition.encounters!.isNotEmpty) _buildEncountersSection(context, condition),
//           if (condition.serviceRequests != null && condition.serviceRequests!.isNotEmpty) _buildServiceRequestsSection(context, condition),
//           if (condition.note != null || condition.summary != null || condition.extraNote != null) _buildNotesSection(context, condition),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(Icons.medical_services, size: 40, color: Theme.of(context).primaryColor),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(condition.healthIssue ?? 'Unknown Condition', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   if (condition.clinicalStatus != null)
//                     Chip(
//                       backgroundColor: _getStatusColor(condition.clinicalStatus!.code),
//                       label: Text(condition.clinicalStatus!.display, style: const TextStyle(color: Colors.white)),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMainDetailsCard(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Overview'.tr(context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             _buildDetailRow(
//               icon: Icons.calendar_today,
//               label: 'Type'.tr(context),
//               value: condition.isChronic != null ? (condition.isChronic! ? 'Chronic' : 'Acute') : 'Not specified',
//             ),
//             if (condition.verificationStatus != null)
//               _buildDetailRow(icon: Icons.verified, label: 'Verification'.tr(context), value: condition.verificationStatus!.display),
//             if (condition.stage != null) _buildDetailRow(icon: Icons.stacked_line_chart, label: 'Stage'.tr(context), value: condition.stage!.display),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimelineSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Timeline'.tr(context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             if (condition.onSetDate != null)
//               _buildTimelineItem(
//                 icon: Icons.event,
//                 title: 'Onset Date'.tr(context),
//                 date: DateFormat('MMM d, y').format(DateTime.parse(condition.onSetDate!)),
//                 age: condition.onSetAge,
//               ),
//             if (condition.abatementDate != null)
//               _buildTimelineItem(
//                 icon: Icons.event_available,
//                 title: 'Abatement Date'.tr(context),
//                 date: DateFormat('MMM d, y').format(DateTime.parse(condition.abatementDate!)),
//                 age: condition.abatementAge,
//               ),
//             if (condition.recordDate != null)
//               _buildTimelineItem(
//                 icon: Icons.note_add,
//                 title: 'Recorded Date'.tr(context),
//                 date: DateFormat('MMM d, y').format(DateTime.parse(condition.recordDate!)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildArticlesSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Articles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                   onPressed: () => _showConditionArticles(context, condition.id!),
//                   icon: const Icon(Icons.article),
//                   tooltip: 'View articles about this condition',
//                 ),
//                 BlocBuilder<ArticleCubit, ArticleState>(
//                   builder: (context, state) {
//                     final cubit = context.read<ArticleCubit>();
//                     final lastGenerationTime = cubit.lastGenerationTime;
//                     final generationCount = cubit.generationCount;
//                     final canGenerate = _checkGenerationCooldown(lastGenerationTime, generationCount);
//
//                     return canGenerate
//                         ? IconButton(
//                           onPressed: () => _showAiModelSelection(context, condition.id!),
//                           icon: const Icon(Icons.note_add),
//                           tooltip: 'Generate AI article',
//                         )
//                         : StreamBuilder<String>(
//                           stream: _getCooldownStream(lastGenerationTime, generationCount),
//                           builder: (context, snapshot) {
//                             return Row(
//                               children: [
//                                 const Icon(Icons.timer, color: Colors.grey),
//                                 const SizedBox(width: 8),
//                                 Text(snapshot.data ?? 'Calculating...', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                               ],
//                             );
//                           },
//                         );
//                   },
//                 ),
//               ],
//             ),
//             BlocBuilder<ArticleCubit, ArticleState>(
//               builder: (context, state) {
//                 if (state is ArticleGenerateLoading) {
//                   return const LinearProgressIndicator();
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showConditionArticles(BuildContext context, String conditionId) {
//     final cubit = context.read<ArticleCubit>();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Loading articles...'),
//             content: BlocConsumer<ArticleCubit, ArticleState>(
//               listener: (context, state) {
//                 if (state is ArticleConditionSuccess) {
//                   Navigator.pop(context); // Close loading dialog
//                   _showArticleDialog(context, state.article);
//                 } else if (state is ArticleError) {
//                   Navigator.pop(context); // Close loading dialog
//                   ShowToast.showToastError(message: state.error);
//                 }
//               },
//               builder: (context, state) {
//                 return  Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [LoadingButton(), SizedBox(height: 16), Text('Fetching articles...')],
//                 );
//               },
//             ),
//           ),
//     );
//
//     cubit.getArticleOfCondition(conditionId: conditionId, context: context);
//   }
//
//   void _showArticleDialog(BuildContext context, ArticleModel? article) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: article != null ? Text(article.title ?? 'Article') : SizedBox.shrink(),
//             content:
//                 article == null
//                     ? Text(
//                       "There are not article you can generate it.",
//                       // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
//                     )
//                     : SizedBox(
//                       width: double.maxFinite, // Ensure the dialog takes the maximum available width
//                       height: MediaQuery.of(context).size.height * 0.5, // Set a height relative to screen size
//                       child: SingleChildScrollView(
//                         child: Text(
//                           article.content ?? 'No content available',
//                           // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
//                         ),
//                       ),
//                     ),
//             actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context)))],
//           ),
//     );
//   }
//
//   // void _showAiModelSelection(BuildContext context, String conditionId) {
//   //   final cubit = context.read<ArticleCubit>();
//   //   final lastGenerationTime = cubit.lastGenerationTime;
//   //   final generationCount = cubit.generationCount;
//   //
//   //   if (!_checkGenerationCooldown(lastGenerationTime, generationCount)) {
//   //     _showCooldownMessage(context, lastGenerationTime, generationCount);
//   //     return;
//   //   }
//   //
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: Text('Select AI Model'.tr(context)),
//   //       content: SizedBox(
//   //         width: double.maxFinite,
//   //         height: MediaQuery.of(context).size.height * 0.5,
//   //         child: SingleChildScrollView(
//   //           child: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: [
//   //               Text('Select language:'.tr(context)),
//   //               Row(
//   //                 children: [
//   //                   ChoiceChip(
//   //                     label: const Text('English'),
//   //                     selected: true,
//   //                     onSelected: (_) {
//   //                       Navigator.pop(context);
//   //                       _generateAiArticle(context, conditionId, null, 'en');
//   //                     },
//   //                   ),
//   //                   const SizedBox(width: 8),
//   //                   ChoiceChip(
//   //                     label: const Text('العربية'),
//   //                     selected: false,
//   //                     onSelected: (_) {
//   //                       Navigator.pop(context);
//   //                       _generateAiArticle(context, conditionId, null, 'ar');
//   //                     },
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 16),
//   //               Text('Select model:'.tr(context)),
//   //               ListView.builder(
//   //                 shrinkWrap: true,
//   //                 physics: const NeverScrollableScrollPhysics(),
//   //                 itemCount: listModels.length,
//   //                 itemBuilder: (context, index) {
//   //                   final model = listModels[index];
//   //                   return ListTile(
//   //                     title: Text(
//   //                       model.nameModel,
//   //                       // textDirection: model.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
//   //                     ),
//   //                     onTap: () {
//   //                       Navigator.pop(context);
//   //                       _generateAiArticle(context, conditionId, model.apiModel, 'en');
//   //                     },
//   //                   );
//   //                 },
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: Text('Close'.tr(context)),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   void _showAiModelSelection(BuildContext context, String conditionId) {
//     final cubit = context.read<ArticleCubit>();
//     final lastGenerationTime = cubit.lastGenerationTime;
//     final generationCount = cubit.generationCount;
//
//     if (!_checkGenerationCooldown(lastGenerationTime, generationCount)) {
//       _showCooldownMessage(context, lastGenerationTime, generationCount);
//       return;
//     }
//
//     // Track selections outside the builder
//     String selectedLanguage = 'en';
//     AiModel? selectedModel;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Select AI Model'.tr(context)),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 height: MediaQuery.of(context).size.height * 0.5,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Select language:'.tr(context)),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           ChoiceChip(
//                             label: const Text('English'),
//                             selected: selectedLanguage == 'en',
//                             onSelected: (_) => setState(() => selectedLanguage = 'en'),
//                           ),
//                           const SizedBox(width: 8),
//                           ChoiceChip(
//                             label: const Text('العربية'),
//                             selected: selectedLanguage == 'ar',
//                             onSelected: (_) => setState(() => selectedLanguage = 'ar'),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text('Select model:'.tr(context)),
//                       const SizedBox(height: 8),
//                       ...listModels.map((model) {
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           color: selectedModel == model ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
//                           child: ListTile(title: Text(model.nameModel), onTap: () => setState(() => selectedModel = model)),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context))),
//                 ElevatedButton(
//                   onPressed:
//                       selectedModel != null
//                           ? () {
//                             Navigator.pop(context);
//                             _generateAiArticle(context, conditionId, selectedModel!.apiModel, selectedLanguage);
//                           }
//                           : null,
//                   child: Text('Generate'.tr(context)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   bool _checkGenerationCooldown(DateTime? lastGenerationTime, int generationCount) {
//     if (lastGenerationTime == null) return true;
//     final now = DateTime.now();
//     final difference = now.difference(lastGenerationTime);
//
//     if (generationCount <= 3) {
//       return difference.inMinutes >= 30;
//     } else if (generationCount <= 5) {
//       return difference.inHours >= 2;
//     } else {
//       return difference.inHours >= 4;
//     }
//   }
//
//   void _showCooldownMessage(BuildContext context, DateTime? lastGenerationTime, int generationCount) {
//     String message;
//     final now = DateTime.now();
//     final difference = now.difference(lastGenerationTime!);
//
//     if (generationCount <= 3) {
//       final remaining = 30 - difference.inMinutes;
//       message = 'cooldown_message_minutes'.tr(context);
//     } else if (generationCount <= 5) {
//       final remaining = 2 - difference.inHours;
//       message = 'cooldown_message_hours'.tr(context);
//     } else {
//       final remaining = 4 - difference.inHours;
//       message = 'cooldown_message_hours'.tr(context);
//     }
//
//     ShowToast.showToastError(message: message);
//   }
//
//   void _generateAiArticle(BuildContext context, String conditionId, String? apiModel, String language) {
//     final cubit = context.read<ArticleCubit>();
//     cubit.generateAiArticle(conditionId: conditionId, apiModel: apiModel ?? '', language: language, context: context).then((_) {
//       if (mounted) {
//         if (cubit.state is ArticleGenerateSuccess) {
//           ShowToast.showToastSuccess(message: 'article generated successfully');
//         }
//         if (cubit.state is ArticleError) {
//           ShowToast.showToastError(message: 'article can');
//         }
//       }
//     });
//   }
//
//   Widget _buildBodySiteSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Body Site'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             ListTile(
//               leading: const Icon(Icons.location_on, color: Colors.red),
//               title: Text(condition.bodySite!.display, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: condition.bodySite!.description != null ? Text(condition.bodySite!.description!) : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClinicalInfoSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Clinical Information'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             if (condition.clinicalStatus != null)
//               _buildDetailRow(icon: Icons.medical_information, label: 'Clinical Status'.tr(context), value: condition.clinicalStatus!.display),
//             if (condition.verificationStatus != null)
//               _buildDetailRow(icon: Icons.verified_user, label: 'Verification Status'.tr(context), value: condition.verificationStatus!.display),
//             if (condition.stage != null) _buildDetailRow(icon: Icons.timeline, label: 'Stage'.tr(context), value: condition.stage!.display),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEncountersSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Related Encounters'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             ...condition.encounters!
//                 .map(
//                   (encounter) => Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       leading: const Icon(Icons.event_note),
//                       title: Text(encounter.reason ?? 'Unknown reason'),
//                       subtitle: Text(encounter.actualStartDate != null ? DateFormat('MMM d, y').format(DateTime.parse(encounter.actualStartDate!)) : 'No date'),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceRequestsSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Related Service Requests (${condition.serviceRequests!.length})'.tr(context),
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
//             ),
//             const Divider(),
//             const SizedBox(height: 8),
//             ...condition.serviceRequests!
//                 .map(
//                   (request) => Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       leading: const Icon(Icons.medical_services),
//                       title: Text(request.healthCareService?.name ?? 'Unknown service'),
//                       subtitle: Text(
//                         request.serviceRequestStatus?.display ?? 'Unknown status',
//                         style: TextStyle(color: _getStatusColor(request.serviceRequestStatus?.code), fontWeight: FontWeight.bold),
//                       ),
//                       trailing: const Icon(Icons.chevron_right),
//                       onTap: () {
//                         // Navigate to service request details
//                       },
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNotesSection(BuildContext context, ConditionsModel condition) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Notes'.tr(context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
//             const Divider(),
//             const SizedBox(height: 8),
//             if (condition.summary != null) _buildNoteItem(icon: Icons.summarize, title: 'Summary'.tr(context), content: condition.summary!),
//             if (condition.note != null) _buildNoteItem(icon: Icons.note, title: 'Notes'.tr(context), content: condition.note!),
//             if (condition.extraNote != null) _buildNoteItem(icon: Icons.note_add, title: 'Additional Notes'.tr(context), content: condition.extraNote!),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                 const SizedBox(height: 4),
//                 Text(value, style: const TextStyle(fontSize: 16)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimelineItem({required IconData icon, required String title, required String date, String? age}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(date, style: const TextStyle(fontSize: 16)),
//                     if (age != null) ...[const SizedBox(width: 8), Text('($age years)', style: const TextStyle(fontSize: 14, color: Colors.grey))],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoteItem({required IconData icon, required String title, required String content}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
//           const SizedBox(height: 8),
//           Text(content, style: const TextStyle(fontSize: 15)),
//         ],
//       ),
//     );
//   }
//
//   Color _getStatusColor(String? statusCode) {
//     switch (statusCode) {
//       case 'active':
//       case 'in-progress':
//         return Colors.blue;
//       case 'recurrence':
//       case 'relapse':
//         return Colors.orange;
//       case 'inactive':
//       case 'remission':
//       case 'resolved':
//         return Colors.green;
//       case 'completed':
//         return Colors.purple;
//       case 'entered-in-error':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../../articles/data/model/article_model.dart';
import '../../../../articles/presentation/cubit/article_cubit/article_cubit.dart';
import '../../../service_request/presentation/pages/service_request_details_page.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/edit_consition_page.dart';


class ConditionDetailsPage extends StatefulWidget {
  final String conditionId;
  final String patientId;

  const ConditionDetailsPage({super.key, required this.conditionId, required this.patientId});

  @

  override
  State<ConditionDetailsPage> createState() => _ConditionDetailsPageState();
}

class _ConditionDetailsPageState extends State<ConditionDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConditionsCubit>().getConditionDetails(
      conditionId: widget.conditionId,
      patientId: widget.patientId,
      context: context,
    );
  }

  Stream<String> _getCooldownStream(DateTime? lastGenerationTime, int generationCount) async* {
    while (true) {
      if (lastGenerationTime == null) {
        yield "Ready to generate";
        return;
      }
      final now = DateTime.now();
      final difference = now.difference(lastGenerationTime);
      String message;

      if (generationCount <= 3) {
        final remainingMinutes = 30 - difference.inMinutes;
        if (remainingMinutes <= 0) {
          yield "Ready to generate";
          return;
        }
        final seconds = 60 - (difference.inSeconds % 60);
        message = "$remainingMinutes:${seconds.toString().padLeft(2, '0')} min";
      } else if (generationCount <= 5) {
        final remainingHours = 2 - difference.inHours;
        if (remainingHours <= 0) {
          yield "Ready to generate";
          return;
        }
        final minutes = 60 - (difference.inMinutes % 60);
        message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
      } else {
        final remainingHours = 4 - difference.inHours;
        if (remainingHours <= 0) {
          yield "Ready to generate";
          return;
        }
        final minutes = 60 - (difference.inMinutes % 60);
        message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
      }

      yield message;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _showDeleteConfirmation(ConditionsModel condition) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        conditionId: condition.id!,
        patientId: widget.patientId,
        onConfirm: () {
          context.read<ConditionsCubit>().deleteCondition(
            conditionId: condition.id!,
            patientId: widget.patientId,
            context: context,
          ).then((_) {
            if (context.read<ConditionsCubit>().state is ConditionDeletedSuccess) {
              Navigator.pop(context); // Pop details page
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Condition Details".tr(context)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          BlocBuilder<ConditionsCubit, ConditionsState>(
            builder: (context, state) {
              if (state is ConditionDetailsSuccess) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditConditionPage(
                            condition: state.condition,
                            patientId: widget.patientId,
                          ),
                        ),
                      ).then((_) => context.read<ConditionsCubit>().getConditionDetails(
                        conditionId: widget.conditionId,
                        patientId: widget.patientId,
                        context: context,
                      )),
                      tooltip: 'Edit Condition',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(state.condition),
                      tooltip: 'Delete Condition',
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ConditionDetailsSuccess) {
            return _buildConditionDetails(state.condition);
          } else if (state is ConditionsLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(child: Text('Failed to load condition details'.tr(context)));
          }
        },
      ),
    );
  }

  Widget _buildConditionDetails(ConditionsModel condition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, condition),
          const SizedBox(height: 24),
          _buildMainDetailsCard(context, condition),
          const SizedBox(height: 16),
          if (condition.onSetDate != null || condition.abatementDate != null || condition.recordDate != null)
            _buildTimelineSection(context, condition),
          if (condition.bodySite != null) _buildBodySiteSection(context, condition),
          _buildClinicalInfoSection(context, condition),
          if (condition.encounters != null && condition.encounters!.isNotEmpty) _buildEncountersSection(context, condition),
          if (condition.serviceRequests != null && condition.serviceRequests!.isNotEmpty) _buildServiceRequestsSection(context, condition),
          if (condition.note != null || condition.summary != null || condition.extraNote != null) _buildNotesSection(context, condition),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.medical_services, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(condition.healthIssue ?? 'Unknown Condition', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (condition.clinicalStatus != null)
                    Chip(
                      backgroundColor: _getStatusColor(condition.clinicalStatus!.code),
                      label: Text(condition.clinicalStatus!.display, style: const TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview'.tr(context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Type'.tr(context),
              value: condition.isChronic != null ? (condition.isChronic! ? 'Chronic' : 'Acute') : 'Not specified',
            ),
            if (condition.verificationStatus != null)
              _buildDetailRow(icon: Icons.verified, label: 'Verification'.tr(context), value: condition.verificationStatus!.display),
            if (condition.stage != null)
              _buildDetailRow(icon: Icons.stacked_line_chart, label: 'Stage'.tr(context), value: condition.stage!.display),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline'.tr(context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            if (condition.onSetDate != null)
              _buildTimelineItem(
                icon: Icons.event,
                title: 'Onset Date'.tr(context),
                date: DateFormat('MMM d, y').format(DateTime.parse(condition.onSetDate!)),
                age: condition.onSetAge,
              ),
            if (condition.abatementDate != null)
              _buildTimelineItem(
                icon: Icons.event_available,
                title: 'Abatement Date'.tr(context),
                date: DateFormat('MMM d, y').format(DateTime.parse(condition.abatementDate!)),
                age: condition.abatementAge,
              ),
            if (condition.recordDate != null)
              _buildTimelineItem(
                icon: Icons.note_add,
                title: 'Recorded Date'.tr(context),
                date: DateFormat('MMM d, y').format(DateTime.parse(condition.recordDate!)),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildBodySiteSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Body Site'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(condition.bodySite!.display, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: condition.bodySite!.description != null ? Text(condition.bodySite!.description!) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInfoSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clinical Information'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            if (condition.clinicalStatus != null)
              _buildDetailRow(icon: Icons.medical_information, label: 'Clinical Status'.tr(context), value: condition.clinicalStatus!.display),
            if (condition.verificationStatus != null)
              _buildDetailRow(icon: Icons.verified_user, label: 'Verification Status'.tr(context), value: condition.verificationStatus!.display),
            if (condition.stage != null)
              _buildDetailRow(icon: Icons.timeline, label: 'Stage'.tr(context), value: condition.stage!.display),
          ],
        ),
      ),
    );
  }

  Widget _buildEncountersSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Related Encounters'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            ...condition.encounters!
                .map(
                  (encounter) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.event_note),
                  title: Text(encounter.reason ?? 'Unknown reason'.tr(context)),
                  subtitle: Text(encounter.actualStartDate != null
                      ? DateFormat('MMM d, y').format(DateTime.parse(encounter.actualStartDate!))
                      : 'No date'.tr(context)),
                ),
              ),
            )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestsSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Service Requests (${condition.serviceRequests!.length})'.tr(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...condition.serviceRequests!
                .map(
                  (request) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(request.healthCareService?.name ?? 'Unknown service'.tr(context)),
                  subtitle: Text(
                    request.serviceRequestStatus?.display ?? 'Unknown status'.tr(context),
                    style: TextStyle(color: _getStatusColor(request.serviceRequestStatus?.code), fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceRequestDetailsPage(serviceId: request.id!,patientId: widget.patientId,),
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            const Divider(),
            const SizedBox(height: 8),
            if (condition.summary != null)
              _buildNoteItem(icon: Icons.summarize, title: 'Summary'.tr(context), content: condition.summary!),
            if (condition.note != null) _buildNoteItem(icon: Icons.note, title: 'Notes'.tr(context), content: condition.note!),
            if (condition.extraNote != null)
              _buildNoteItem(icon: Icons.note_add, title: 'Additional Notes'.tr(context), content: condition.extraNote!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required IconData icon, required String title, required String date, String? age}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(date, style: const TextStyle(fontSize: 16)),
                    if (age != null) ...[const SizedBox(width: 8), Text('($age years)', style: const TextStyle(fontSize: 14, color: Colors.grey))],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({required IconData icon, required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
      case 'in-progress':
        return Colors.blue;
      case 'recurrence':
      case 'relapse':
        return Colors.orange;
      case 'inactive':
      case 'remission':
      case 'resolved':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'entered-in-error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}