import 'package:flutter/material.dart';

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
        title: Text("Communications"),
        actions: [Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.language),
        )],
      ),
      body: SingleChildScrollView(
        child: Column(children: List.generate(widget.list.length, (index){
          if(widget.list.isEmpty){
            return Center(
              child:Text("There are not any Communications."),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 5,
                  children: [
                    Icon(Icons.check),
                    Text(widget.list[index].language!.display),
                  if(widget.list[index].preferred!)
                    Text(" (preferred)")
                  ],
                ),
          ),
            ),
          );
        }),),
      ),
    );
  }
}
