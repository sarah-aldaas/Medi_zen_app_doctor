// import 'package:flutter/material.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// class NotificationSettingsPage extends StatefulWidget {
//   const NotificationSettingsPage({super.key});
//
//   @override
//   _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
// }
//
// class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
//   bool _generalNotifications = true;
//   bool _sound = false;
//   bool _vibrate = true;
//   bool _specialOffers = false;
//   bool _promoDiscounts = false;
//   bool _payments = true;
//   bool _cashback = false;
//   bool _appUpdates = true;
//   bool _newServiceAvailable = false;
//   bool _newTipsAvailable = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//             "notificationSettings.title".tr(context),
//             style: TextStyle(fontWeight: FontWeight.bold)
//         ),
//       ),
//       body: ListView(
//         children: <Widget>[
//           _buildSwitchTile(
//             context,
//             value: _generalNotifications,
//             onChanged: (v) => setState(() => _generalNotifications = v),
//             icon: Icons.notifications_active,
//             titleKey: "notificationSettings.options.general",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _sound,
//             onChanged: (v) => setState(() => _sound = v),
//             icon: Icons.volume_up,
//             titleKey: "notificationSettings.options.sound",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _vibrate,
//             onChanged: (v) => setState(() => _vibrate = v),
//             icon: Icons.vibration,
//             titleKey: "notificationSettings.options.vibrate",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _specialOffers,
//             onChanged: (v) => setState(() => _specialOffers = v),
//             icon: Icons.local_offer,
//             titleKey: "notificationSettings.options.specialOffers",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _promoDiscounts,
//             onChanged: (v) => setState(() => _promoDiscounts = v),
//             icon: Icons.discount,
//             titleKey: "notificationSettings.options.promoDiscounts",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _payments,
//             onChanged: (v) => setState(() => _payments = v),
//             icon: Icons.payment,
//             titleKey: "notificationSettings.options.payments",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _cashback,
//             onChanged: (v) => setState(() => _cashback = v),
//             icon: Icons.monetization_on,
//             titleKey: "notificationSettings.options.cashback",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _appUpdates,
//             onChanged: (v) => setState(() => _appUpdates = v),
//             icon: Icons.system_update,
//             titleKey: "notificationSettings.options.appUpdates",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _newServiceAvailable,
//             onChanged: (v) => setState(() => _newServiceAvailable = v),
//             icon: Icons.new_releases,
//             titleKey: "notificationSettings.options.newService",
//           ),
//           _buildSwitchTile(
//             context,
//             value: _newTipsAvailable,
//             onChanged: (v) => setState(() => _newTipsAvailable = v),
//             icon: Icons.lightbulb_outline,
//             titleKey: "notificationSettings.options.newTips",
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSwitchTile(
//       BuildContext context, {
//         required bool value,
//         required ValueChanged<bool> onChanged,
//         required IconData icon,
//         required String titleKey,
//       }) {
//     return SwitchListTile(
//       activeColor: Theme.of(context).primaryColor,
//       title: Text(titleKey.tr(context)),
//       value: value,
//       onChanged: onChanged,
//       secondary: Icon(
//         icon,
//         size: 20,
//         color: value ? Theme.of(context).primaryColor : null,
//       ),
//     );
//   }
// }