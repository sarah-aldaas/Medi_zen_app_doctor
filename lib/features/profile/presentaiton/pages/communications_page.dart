import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/communication_model.dart';

class CommunicationsPage extends StatefulWidget {
  const CommunicationsPage({super.key, required this.list});
  final List<CommunicationModel> list;

  @override
  State<CommunicationsPage> createState() => _CommunicationsPageState();
}

class _CommunicationsPageState extends State<CommunicationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text(
          'communicationsPage.title'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.language, color: AppColors.primaryColor),
          ),
        ],
      ),
      body:
      widget.list.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'communicationsPage.noCommunicationsFound'.tr(context),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'communicationsPage.addCommunicationPreferences'.tr(
                context,
              ),
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          final communication = widget.list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                    communication.preferred == true
                        ? Icons.check_circle
                        : Icons.language,
                    color:
                    communication.preferred == true
                        ? Colors.green
                        : Colors.blueGrey,
                    size: 28,
                  ),
                  title: Text(
                    communication.language?.display ??
                        'communicationsPage.unknownLanguage'.tr(
                          context,
                        ),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle:
                  communication.preferred == true
                      ? Text(
                    'communicationsPage.preferred'.tr(context),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      : null,
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
