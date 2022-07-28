// ignore_for_file: unused_field, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print, use_build_context_synchronously, prefer_final_fields, depend_on_referenced_packages, empty_catches

import 'dart:async';
import 'dart:ui';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_uygulamasi/file_handling.dart';
import 'package:sms_uygulamasi/lastNumbers.dart';
import 'package:sms_uygulamasi/manage_records.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

onBackgroundMessage(SmsMessage message) async {
  await getMessengers();
  SharedPreferences tempShrs = await SharedPreferences.getInstance();
  List<String> tempMessengers = tempShrs.getStringList('messengers') ?? [];
  await addLastNumber(message.address ?? "");
  if (tempMessengers.contains(message.address)) {
    String addr = message.address ?? "null";
    Workmanager().registerOneOffTask("1", "sendSmsTask", inputData: {
      'message': message.body,
      'number': message.address,
      'index': tempMessengers.indexOf(addr).toString()
    });
  }
  print("hellob");
}

onMessage(SmsMessage message) async {
  await getMessengers();
  SharedPreferences tempShrs = await SharedPreferences.getInstance();
  List<String> tempMessengers = tempShrs.getStringList('messengers') ?? [];
  await addLastNumber(message.address ?? "");
  if (tempMessengers.contains(message.address)) {
    String addr = message.address ?? "null";
    print("gdsgsddgsds");
    Workmanager().registerOneOffTask("1", "sendSmsTask", inputData: {
      'message': message.body,
      'number': message.address,
      'index': tempMessengers.indexOf(addr).toString()
    });
  }
  print("hellof");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().cancelAll();
  await getMessengers();
  await getRecords();
  await getLastNumbers();
  Workmanager().initialize(callbackDispatcher);
  await initializeService();
  final bool? result = await telephony.requestPhoneAndSmsPermissions;
  if (result != null && result) {
    telephony.listenIncomingSms(
        onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  telephony.listenIncomingSms(
      onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "SMS Yönetim Uygulaması",
      content: 'Mesajar Dinleniyor...',
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "sendSmsTask":
        print("sendSmsTask was executed. inputData = $inputData");
        SharedPreferences shrdpf = await SharedPreferences.getInstance();
        List<String> tempList =
            shrdpf.getStringList('Records[${inputData!["index"]}]') ?? [];
        for (int i = 0; i < tempList.length; i++) {
          try {
            BackgroundSms.sendMessage(
                phoneNumber: tempList[i], message: inputData['message']);
          } catch (error) {}
        }
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controllerPeople, _controllerPerson;
  List<String> _people = [];

  @override
  void initState() {
    super.initState();
    _controllerPeople = TextEditingController();
    _controllerPerson = TextEditingController();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _people.remove(name)),
              ),
              Text(
                name,
                textScaleFactor: 1,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await getRecords();
                        getMessengers();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessengersRecords(),
                          ),
                        );
                      },
                      child: Text(
                        'Kayıtları Düzenle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await getRecords();
                        getMessengers();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LastNumbers(),
                          ),
                        );
                      },
                      child: Text(
                        'Son Numaraları Gör',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        appBar: AppBar(
          title: Text('Maxifi SMS Forwarder'),
        ),
        body: ListView(
          children: [
            Divider(
              thickness: 1.0,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                autofocus: false,
                controller: _controllerPerson,
                decoration:
                    const InputDecoration(labelText: 'Mesajın Geleceği Numara'),
                keyboardType: TextInputType.text,
                onChanged: (String value) => setState(() {}),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: TextField(
                autofocus: false,
                controller: _controllerPeople,
                decoration: const InputDecoration(
                    labelText: 'Mesajın Ulaştırılacağı Kişiler'),
                keyboardType: TextInputType.text,
                onChanged: (String value) => setState(() {}),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _controllerPeople.text.isEmpty
                    ? null
                    : () => setState(() {
                          _people.add(_controllerPeople.text.toString());
                          _controllerPeople.clear();
                        }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await FlutterContactPicker.requestPermission();
                  try {
                    final PhoneContact contact =
                        await FlutterContactPicker.pickPhoneContact();
                    String number = contact.phoneNumber!.number ?? "";
                    number = number.replaceAll('(', "");
                    number = number.replaceAll(')', "");
                    number = number.replaceAll(' ', "");
                    number = number.replaceAll('-', "");
                    if (!number.startsWith("+90")) {
                      if (number.startsWith('0')) {
                        number = "+9$number";
                      } else if (number.startsWith("9")) {
                        number = "+$number";
                      } else {
                        number = "+90$number";
                      }
                    }
                    _people.add(number);
                  } catch (e) {
                    build(context);
                  }
                  setState(() {});
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Icon(Icons.contacts),
                  Container(width: 110),
                  Text('Rehberden Seç'),
                ]),
              ),
            ),
            Divider(
              thickness: 1.0,
            ),
            if (_people.isEmpty)
              const SizedBox(height: 0)
            else
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        List<Widget>.generate(_people.length, (int index) {
                      return _phoneTile(_people[index]);
                    }),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    FocusScope.of(context).unfocus();
                    people.clear();
                    cloneList(_people, people);
                    addNewMessenger(_controllerPerson.text.toString());
                    saveRecord(_controllerPerson.text.toString());
                    _controllerPerson.clear();
                    _people.clear();
                  });
                },
                child: Text('Kayıt Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
