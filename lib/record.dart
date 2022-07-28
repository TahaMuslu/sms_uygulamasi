// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, avoid_print, await_only_futures, unused_local_variable, must_be_immutable

import 'package:flutter/material.dart';
import 'package:sms_uygulamasi/file_handling.dart';

class Record extends StatefulWidget {
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
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
                deleteNumberFromRecord(name);
                Navigator.pop(context);
              },
              icon: Icon(Icons.delete),
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
          title: Text(current_number),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: List<Widget>.generate(
                    Records[messengers.indexOf(current_number)].length,
                    (int index) {
                  return _phoneTile(
                      Records[messengers.indexOf(current_number)][index]);
                }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    deleteRecord();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    // Navigator.pop(context);
                  },
                  child: Text(
                    "Kaydı Sil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
