// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unnecessary_brace_in_string_interps, prefer_contains, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_uygulamasi/lastNumbers.dart';
import 'package:telephony/telephony.dart';

final telephony = Telephony.instance;

List<String> people = [];
List<List<String>> Records = [];
List<String> messengers = [];
String current_number = "";

Future<String> getFilePath(String fileName) async {
  Directory? externalDocumentsDirectory = await getExternalStorageDirectory();
  String? externalDocumentsPath = externalDocumentsDirectory?.path;
  String filePath = '$externalDocumentsPath/${fileName}.txt';
  return filePath;
}

Future<void> addLastNumber(String lastNumber) async {
  if (lastNumber != "") {
    List<String> last_numbers = [];
    String file_content = "";
    File file = File(await getFilePath('lastNumbers'));
    try {
      file_content = await file.readAsString();
    } catch (error) {
      await file.create();
      file_content = await file.readAsString();
    }
    last_numbers = file_content.split(';');
    last_numbers.removeAt(last_numbers.length - 1);
    if (!file_content.contains(lastNumber)) {
      print("girdi");
      last_numbers.add("Numara: " +
          lastNumber +
          "\nTarih: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}  ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
    } else {
      for (int i = 0; i < last_numbers.length; i++) {
        if (last_numbers[i].contains(lastNumber)) {
          last_numbers.removeAt(i);
          last_numbers.add("Numara: " +
              lastNumber +
              "\nTarih: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}  ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
        }
      }
    }
    file_content = "";
    for (int i = 0; i < last_numbers.length; i++) {
      file_content = file_content + last_numbers[i] + ";";
    }
    file.writeAsString(file_content);
  }
  await getLastNumbers();
}

Future<void> getMessengers() async {
  File file = File(await getFilePath('persons'));
  late String fileContent;
  try {
    fileContent = await file.readAsString();
    messengers = fileContent.split(';');
    messengers.removeAt(messengers.length - 1);
  } catch (e) {
    File file = File(await getFilePath('persons'));
    file.create();
  }
  SharedPreferences shrpfs = await SharedPreferences.getInstance();
  shrpfs.setStringList('messengers', messengers);
}

void saveRecord(String messenger) async {
  String file_content = "";
  for (int i = 0; i < people.length; i++) {
    if (messengers.indexOf(messenger) != -1) {
      if (!Records[messengers.indexOf(messenger)].contains(people[i]))
        file_content = file_content + people[i] + ";";
    } else {
      file_content = file_content + people[i] + ";";
    }
  }
  File file = File(await getFilePath(messenger));
  file.writeAsString(file_content, mode: FileMode.writeOnlyAppend);
  people.clear();
  getRecords();
}

void addNewMessenger(String number) async {
  if (messengers.indexOf(number) == -1 && number != "") {
    File file = File(await getFilePath('persons'));
    file.writeAsString(number + ";", mode: FileMode.writeOnlyAppend);
  }
  await getMessengers();
}

Future<void> getRecords() async {
  Records.clear();
  SharedPreferences shrpfs = await SharedPreferences.getInstance();

  for (int i = 0; i < messengers.length; i++) {
    List<String> currentRecord = [];
    File file = File(await getFilePath(messengers[i]));
    String fileContent = await file.readAsString();
    currentRecord = fileContent.split(';');
    currentRecord.removeAt(currentRecord.length - 1);
    Records.add(currentRecord);
    shrpfs.setStringList('Records[$i]', currentRecord);
  }
}

void cloneList(List<String> source, List<String> target) {
  target.clear();
  for (int i = 0; i < source.length; i++) {
    target.add(source[i]);
  }
}

void deleteRecord() async {
  File file = File(await getFilePath(current_number));
  file.delete();
  File file2 = File(await getFilePath('persons'));
  messengers.remove(current_number);
  String file_content = "";
  for (int i = 0; i < messengers.length; i++) {
    file_content = file_content + messengers[i] + ';';
  }
  file2.writeAsString(file_content);
  getRecords();
}

void deleteNumberFromRecord(String number) async {
  String file_content = "";
  List<String> numberList = Records[messengers.indexOf(current_number)];
  numberList.remove(number);
  for (int i = 0; i < numberList.length; i++) {
    file_content = file_content + numberList[i] + ';';
  }
  File file = File(await getFilePath(current_number));
  file.writeAsString(file_content, mode: FileMode.writeOnly);
  getRecords();
}
