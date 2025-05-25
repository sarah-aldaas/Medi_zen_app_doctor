import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String email = 'mayasha@gmail.com';
  String phone = '+1.415.110.000';
  String city = 'San Francisco, CA';
  String country = 'USA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leadingWidth: 100,
        toolbarHeight: 70,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade400, // Color of the line
            height: 1.0,
          ),
        ),
        title: Text("Edit profile", style: TextStyle(fontSize: 16, color: Colors.grey)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              spacing: 20,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  child: Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                ),
                SizedBox(height: 20),
                TextFormField(initialValue: email, decoration: InputDecoration(labelText: 'Your Email'), enabled: false),
                TextFormField(initialValue: phone, decoration: InputDecoration(labelText: 'Your Phone'), keyboardType: TextInputType.phone),
                TextFormField(initialValue: city, decoration: InputDecoration(labelText: 'City')),
                TextFormField(initialValue: country, decoration: InputDecoration(labelText: 'Country')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
