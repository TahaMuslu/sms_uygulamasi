// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, avoid_print, await_only_futures, unused_local_variable, must_be_immutable, non_constant_identifier_names, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sms_uygulamasi/file_handling.dart';

List<String> lastNumbers = [];
Future<void> getLastNumbers() async {
  String file_content = "";
  File file = File(await getFilePath('lastNumbers'));
  try {
    file_content = await file.readAsString();
  } catch (error) {
    file.create();
    file_content = await file.readAsString();
  }
  lastNumbers = file_content.split(';');
  lastNumbers.removeAt(lastNumbers.length - 1);
}

class LastNumbers extends StatefulWidget {
  @override
  _LastNumbersState createState() => _LastNumbersState();
}

class _LastNumbersState extends State<LastNumbers> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

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
            title: Text(name),
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
          title: Text("En Son Numaralar"),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: List<Widget>.generate(lastNumbers.length, (int index) {
            return _phoneTile(lastNumbers[index]);
          }),
        ),
      ),
    );
  }
}
