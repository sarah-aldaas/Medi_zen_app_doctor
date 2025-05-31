// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
// import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:gap/gap.dart';
// import 'package:intl/intl.dart';
// import 'package:medi_zen_app_doctor/base/constant/app_images.dart';
// import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
// import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
// import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
// import 'package:medi_zen_app_doctor/main.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../../base/theme/app_style.dart';
// import '../../authentication/data/models/doctor_model.dart';
//
// class DoctorDetailsPage extends StatefulWidget {
//   const DoctorDetailsPage({super.key, required this.doctorModel});
//
//   final DoctorModel doctorModel;
//
//   @override
//   State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
// }
//
// class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay? _selectedTime;
//   List<SlotModel> _availableSlots = [];
//   bool _isLoadingSlots = false;
//   DaysWorkDoctorModel? _doctorAvailability;
//   bool _isLoadingAvailability = false;
//   final Map<String, double> _downloadProgress = {};
//   final Map<String, bool> _downloadComplete = {};
//   final Dio _dio = serviceLocator<NetworkClient>().dio;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctorAvailability();
//   }
//
//   Future<void> _fetchDoctorAvailability() async {
//     setState(() => _isLoadingAvailability = true);
//     await context.read<AppointmentCubit>().getDaysWorkDoctor(doctorId: widget.doctorModel.id.toString());
//   }
//
//   void _fetchSlotsForDate(DateTime date) {
//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     final isAvailable = _doctorAvailability?.availability.any(
//             (day) => DateFormat('yyyy-MM-dd').format(day.date) == formattedDate && day.isAvailable) ??
//         false;
//
//     if (!isAvailable) return;
//
//     setState(() {
//       _isLoadingSlots = true;
//       _availableSlots = [];
//       _selectedTime = null;
//     });
//
//     context.read<AppointmentCubit>().geSlotsAppointment(
//         practitionerId: widget.doctorModel.id.toString(), date: formattedDate);
//   }
//
//   Future<void> downloadAndViewPdf(String pdfUrl, String qualificationId) async {
//     try {
//       // Validate URL
//       if (!Uri.parse(pdfUrl).isAbsolute) {
//         throw Exception('Invalid PDF URL');
//       }
//
//       // Update progress state
//       setState(() {
//         _downloadProgress[qualificationId] = 0.0;
//         _downloadComplete[qualificationId] = false;
//       });
//
//       // Request storage permissions for Android
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           throw Exception('Storage permission denied. Please allow storage access.');
//         }
//       }
//
//       // Get appropriate directory
//       Directory directory;
//       if (Platform.isAndroid) {
//         directory = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }
//
//       final filePath = '${directory.path}/qualification_$qualificationId.pdf';
//       final file = File(filePath);
//
//       // Ensure file doesn't exist before downloading
//       if (await file.exists()) {
//         await file.delete();
//       }
//
//       // Download the file with Dio
//       await _dio.download(
//         pdfUrl,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             final progress = received / total;
//             print('Download progress: $progress for $qualificationId');
//             setState(() {
//               _downloadProgress[qualificationId] = progress;
//             });
//           }
//         },
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       // Verify file exists and is not empty
//       if (!await file.exists() || (await file.length()) == 0) {
//         throw Exception('Downloaded file is invalid or empty');
//       }
//
//       // Update state to indicate download completion
//       setState(() {
//         _downloadComplete[qualificationId] = true;
//       });
//
//
//       // Open the PDF
//       final result = await OpenFilex.open(filePath, type: 'application/pdf');
//       if (result.type != ResultType.done) {
//         throw Exception('Failed to open PDF: ${result.message}');
//       }
//     } catch (e, stackTrace) {
//       // Log error for debugging
//       print('Error downloading/opening PDF: $e\n$stackTrace');
//
//       // Show error notification
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       // Clean up progress state
//       setState(() {
//         _downloadProgress.remove(qualificationId);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AppointmentCubit, AppointmentState>(
//       listener: (context, state) {
//         if (state is DaysWorkDoctorSuccess) {
//           final sortedAvailability = state.days.availability..sort((a, b) => a.date.compareTo(b.date));
//           setState(() {
//             _doctorAvailability = state.days.copyWith(availability: sortedAvailability);
//             _isLoadingAvailability = false;
//           });
//
//           if (_doctorAvailability!.availability.isNotEmpty) {
//             final firstAvailable = sortedAvailability.firstWhere((day) => day.isAvailable, orElse: () => sortedAvailability.first);
//             setState(() {
//               _selectedDate = firstAvailable.date;
//             });
//             _fetchSlotsForDate(_selectedDate);
//           }
//         }
//         if (state is SlotsAppointmentSuccess) {
//           setState(() {
//             _availableSlots = state.listSlots!;
//             _isLoadingSlots = false;
//           });
//         } else if (state is AppointmentError) {
//           setState(() {
//             _isLoadingSlots = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(state.error)));
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           title: Text("${widget.doctorModel.fName} ${widget.doctorModel.lName}"),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             IconButton(icon: const Icon(Icons.favorite_border, color: Colors.grey), onPressed: () {}),
//             IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: () {}),
//           ],
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const CircleAvatar(radius: 40, backgroundImage: AssetImage(AppAssetImages.photoDoctor1)),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("${widget.doctorModel.fName} ${widget.doctorModel.lName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       Text(widget.doctorModel.email),
//                       Text(widget.doctorModel.address),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildInfoColumn(Icons.people, '5.000+', 'patients', context),
//                   _buildInfoColumn(Icons.calendar_today, widget.doctorModel.dateOfBirth, 'birthday', context),
//                   _buildInfoColumn(Icons.star, '4.8', 'rating', context),
//                   _buildInfoColumn(Icons.emoji_people, widget.doctorModel.gender!.display, "gender", context),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Text('doctorDetails.aboutMe'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(widget.doctorModel.text),
//               const SizedBox(height: 20),
//               Text('doctorDetails.workingTime'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_isLoadingAvailability) Center(child: LoadingButton()),
//                   if (!_isLoadingAvailability && _doctorAvailability?.availability.isEmpty == true) const Text('No available days for this doctor'),
//                   if (!_isLoadingAvailability && _doctorAvailability?.availability.isNotEmpty == true)
//                     SizedBox(
//                       height: 60,
//                       child: Center(
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const ClampingScrollPhysics(),
//                           scrollDirection: Axis.horizontal,
//                           itemCount: _doctorAvailability!.availability.length,
//                           separatorBuilder: (context, index) => const SizedBox(width: 8),
//                           itemBuilder: (context, index) {
//                             final day = _doctorAvailability!.availability[index];
//                             final isSelected =
//                                 day.date.day == _selectedDate.day && day.date.month == _selectedDate.month && day.date.year == _selectedDate.year;
//
//                             return InkWell(
//                               onTap: day.isAvailable
//                                   ? () {
//                                 _fetchSlotsForDate(day.date);
//                                 setState(() {
//                                   _selectedDate = day.date;
//                                   _selectedTime = null;
//                                 });
//                               }
//                                   : null,
//                               child: Container(
//                                 width: 45,
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? const Color(0xFF00CBA9) : day.isAvailable ? Colors.grey[200] : Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       DateFormat('E').format(day.date).substring(0, 3),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isSelected ? Colors.white : day.isAvailable ? Colors.grey[600] : Colors.grey[400],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       DateFormat('d').format(day.date),
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: isSelected ? Colors.white : day.isAvailable ? Colors.black : Colors.grey[400],
//                                       ),
//                                     ),
//                                     if (!day.isAvailable) const Icon(Icons.block, size: 12, color: Colors.red),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   if (_isLoadingAvailability) Center(child: LoadingButton()),
//                   if (_isLoadingSlots) Center(child: LoadingButton()),
//                   if (!_isLoadingSlots && _availableSlots.isEmpty) const Text('No available slots for this day'),
//                   if (!_isLoadingSlots && _availableSlots.isNotEmpty)
//                     SizedBox(
//                       width: context.width,
//                       child: Wrap(
//                         spacing: 8.0,
//                         alignment: WrapAlignment.spaceBetween,
//                         runSpacing: 8.0,
//                         children: _availableSlots.map((slot) {
//                           final startTime = DateTime.parse(slot.startDate);
//                           final endTime = DateTime.parse(slot.endDate);
//                           final timeStr = '${DateFormat('hh:mm a').format(startTime)}';
//                           final isSelected = _selectedTime?.hour == startTime.hour && _selectedTime?.minute == startTime.minute;
//                           final isBooked = slot.status.code != 'available';
//
//                           return InkWell(
//                             onTap: isBooked
//                                 ? null
//                                 : () {
//                               setState(() {
//                                 _selectedTime = TimeOfDay.fromDateTime(startTime);
//                               });
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: isSelected ? const Color(0xFF00CBA9) : isBooked ? Colors.grey[300] : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(timeStr, style: TextStyle(fontSize: 14, color: isSelected || isBooked ? Colors.white : Colors.black)),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   if (_selectedDate != null && _selectedTime != null)
//                     Text(
//                       '${'doctorDetails.selected'.tr(context)}: ${DateFormat('EEE, MMM d').format(_selectedDate)} at ${_selectedTime!.format(context)}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _selectedTime == null
//                       ? null
//                       : () async {
//                     await _showAppointmentDialog(
//                       context: context,
//                       title: 'Booking appointment on ${'doctorDetails.selected'.tr(context)}: ${DateFormat('EEE, MMM d').format(_selectedDate)} at ${_selectedTime!.format(context)}',
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     disabledBackgroundColor: Colors.grey[400],
//                     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
//                   ),
//                   child: Text('doctorDetails.bookAppointment'.tr(context), style: const TextStyle(fontSize: 18, color: Colors.white)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintSubmissionScreen()));
//                   },
//                   child: Text('doctorDetails.SubmitAComplaint'.tr(context), style: AppStyles.complaintTextStyle),
//                 ),
//               ),
//               Divider(),
//               Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text("Telecom", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
//               if (widget.doctorModel.telecoms!.isNotEmpty)
//                 Column(
//                   children: List.generate(widget.doctorModel.telecoms!.length, (index) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ListTile(
//                         subtitle: Text("${widget.doctorModel.telecoms![index].type!.display} :${widget.doctorModel.telecoms![index].value!}"),
//                         title: Text("${widget.doctorModel.telecoms![index].use!.display}"),
//                       ),
//                     );
//                   }),
//                 ),
//               if (widget.doctorModel.telecoms!.isEmpty) Text("There are not any telecoms"),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [Text("Communications", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
//               ),
//               if (widget.doctorModel.communications!.isNotEmpty)
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: List.generate(widget.doctorModel.communications!.length, (index) {
//                       return Container(
//                         padding: EdgeInsets.all(10),
//                         margin: EdgeInsets.all(5),
//                         width: 100,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: widget.doctorModel.communications![index].preferred ? Theme.of(context).primaryColor : Colors.grey,
//                         ),
//                         child: Center(child: Text(widget.doctorModel.communications![index].language.display, style: TextStyle(color: Colors.white))),
//                       );
//                     }),
//                   ),
//                 ),
//               if (widget.doctorModel.communications!.isEmpty) Text("There are not any communications"),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [Text("Qualifications", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
//               ),
//               if (widget.doctorModel.qualifications!.isNotEmpty)
//                 Column(
//                   children: List.generate(widget.doctorModel.qualifications!.length, (index) {
//                     final qualificationId = widget.doctorModel.qualifications![index].id.toString();
//                     return Container(
//                       padding: EdgeInsets.all(10),
//                       margin: EdgeInsets.all(5),
//                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//                       child: ListTile(
//                         trailing: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             if (_downloadProgress.containsKey(widget.doctorModel.qualifications![index].id.toString()))
//                               SizedBox(
//                                 width: 30,
//                                 height: 30,
//                                 child: CircularProgressIndicator(
//                                   value: _downloadProgress[widget.doctorModel.qualifications![index].id.toString()],
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
//                                 ),
//                               ),
//                             IconButton(
//                               onPressed:
//                               _downloadProgress.containsKey(widget.doctorModel.qualifications![index].id.toString())
//                                   ? null
//                                   : () => downloadAndViewPdf(
//                                 widget.doctorModel.qualifications![index].pdf.toString(),
//                                 widget.doctorModel.qualifications![index].id.toString(),
//                               ),
//                               icon: Icon(
//                                 _downloadComplete[widget.doctorModel.qualifications![index].id.toString()] == true ? Icons.check_circle : Icons.picture_as_pdf,
//                                 color:
//                                 _downloadComplete[widget.doctorModel.qualifications![index].id.toString()] == true
//                                     ? Theme.of(context).primaryColor
//                                     : Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         title: Text("${widget.doctorModel.qualifications![index].type.display}"),
//                         subtitle: Padding(
//                           padding: const EdgeInsets.only(left: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text("${widget.doctorModel.qualifications![index].issuer}"),
//                               Row(
//                                 children: [
//                                   Icon(Icons.date_range_outlined),
//                                   Text(
//                                     " ${widget.doctorModel.qualifications![index].startDate} - ${widget.doctorModel.qualifications![index].endDate ?? "continue"}",
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               if (widget.doctorModel.qualifications!.isEmpty) Text("There are no qualifications"),
//               Divider(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoColumn(IconData icon, String value, String labelKey, BuildContext context) {
//     return Column(
//       children: [Icon(icon, color: Theme.of(context).primaryColor), Text(value, style: const TextStyle(fontWeight: FontWeight.bold)), Text(labelKey)],
//     );
//   }
//
//   Future<void> _showAppointmentDialog({required BuildContext context, required String title}) async {
//     final formKey = GlobalKey<FormState>();
//     String reason = 'I am sick.';
//     String description = 'I need some medical treatment.';
//     String note = 'No thing,Thanks.';
//     PatientModel patientModel = loadingPatientModel();
//
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return BlocListener<AppointmentCubit, AppointmentState>(
//           listener: (context, state) {
//             if (state is CreateAppointmentSuccess) {
//               Navigator.pop(context);
//               _fetchDoctorAvailability();
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('appointment booked successfully')));
//             } else if (state is AppointmentError) {
//               Navigator.pop(context);
//               _fetchDoctorAvailability();
//             }
//           },
//           child: AlertDialog(
//             content: SizedBox(
//               width: context.width,
//               child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const Gap(20),
//                       TextFormField(
//                         initialValue: reason,
//                         decoration: const InputDecoration(labelText: 'Reason*', hintText: 'Why are you booking this appointment?'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a reason';
//                           }
//                           return null;
//                         },
//                         onSaved: (value) => reason = value ?? '',
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: description,
//                         decoration: const InputDecoration(labelText: 'Description*', hintText: 'Describe your symptoms or concerns'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a description';
//                           }
//                           return null;
//                         },
//                         onSaved: (value) => description = value ?? '',
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: note,
//                         decoration: const InputDecoration(labelText: 'Note (Optional)', hintText: 'Any additional information'),
//                         onSaved: (value) => note = value ?? '',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//               BlocBuilder<AppointmentCubit, AppointmentState>(
//                 builder: (context, state) {
//                   if (state is AppointmentLoading) {
//                     return LoadingButton();
//                   }
//                   return ElevatedButton(
//                     onPressed: () async {
//                       if (formKey.currentState!.validate()) {
//                         formKey.currentState!.save();
//
//                         final selectedSlot = _availableSlots.firstWhere((slot) {
//                           final slotTime = TimeOfDay.fromDateTime(DateTime.parse(slot.startDate));
//                           return slotTime.hour == _selectedTime!.hour && slotTime.minute == _selectedTime!.minute;
//                         });
//
//                         final appointment = AppointmentCreateModel(
//                           reason: reason,
//                           description: description,
//                           note: note.isNotEmpty ? note : "No thing,Thanks.",
//                           doctorId: widget.doctorModel.id.toString(),
//                           patientId: patientModel.id!,
//                           previousAppointment: null,
//                           slotId: selectedSlot.id.toString(),
//                         );
//
//                         await context.read<AppointmentCubit>().createAppointment(appointmentModel: appointment);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                     ),
//                     child: const Text('Confirm', style: TextStyle(color: Colors.white)),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }