import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';

class DeleteServiceRequestDialog extends StatelessWidget {
  final String serviceId;
  final String patientId;
  final VoidCallback onConfirm;

  const DeleteServiceRequestDialog({
    super.key,
    required this.serviceId,
    required this.patientId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'deleteServiceRequestDialog.title'.tr(context),
        style:  TextStyle(fontWeight: FontWeight.bold,color: AppColors.primaryColor,fontSize: 20),
      ),
      content: Text('deleteServiceRequestDialog.content'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'deleteServiceRequestDialog.cancelButton'.tr(context),
            style:  TextStyle(color: AppColors.blackColor,fontSize: 15,fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),

            elevation: 3,
          ),
          child: Text('deleteServiceRequestDialog.deleteButton'.tr(context),     style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),),
        ),
      ],
    );
  }
}