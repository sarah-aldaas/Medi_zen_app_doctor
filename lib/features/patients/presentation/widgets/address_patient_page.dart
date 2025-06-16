import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/address_model.dart';
import '../../../../base/theme/app_color.dart';

class AddressPatientPage extends StatelessWidget {
  const AddressPatientPage({super.key, required this.list});

  final List<AddressModel> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primaryColor,
        ),
        title: Text(
          'Address',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body:
          list.isEmpty
              ? Center(child: Text("There are not any addresses"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final address = list[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  address.type?.display ?? '',

                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              address.use?.display ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              address.text ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${address.line}, ${address.district}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${address.city}, ${address.state}, ${address.postalCode}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              address.country ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (address.startDate != null ||
                                address.endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: Text(
                                  '${address.startDate != null ? 'From'
                                          ': ${address.startDate}' : ''}'
                                  '${address.endDate != null ? 'to: ${address.endDate}' : ' continue'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
