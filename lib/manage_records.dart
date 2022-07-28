// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:sms_uygulamasi/file_handling.dart';
import 'package:sms_uygulamasi/record.dart';

class MessengersRecords extends StatefulWidget {
  @override
  _MessengersRecordsState createState() => _MessengersRecordsState();
}

class _MessengersRecordsState extends State<MessengersRecords> {
  Widget _phoneTile(String name) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            top: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('Numara: $name'),
            trailing: IconButton(
              onPressed: () {
                current_number = name;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => Record()),
                  ),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kayıtlar'),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: List<Widget>.generate(messengers.length, (int index) {
            return _phoneTile(messengers[index]);
          }),
        ),
      ),
    );
  }
}
