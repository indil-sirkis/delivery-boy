import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC with ChangeNotifier {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    firebaseMessaging.requestPermission( alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,);
    configureFirebase(firebaseMessaging);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null && settingRepo.setting.value.appName != '' && settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 41;
        progress?.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress?.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    });
  }

  void configureFirebase(FirebaseMessaging _firebaseMessaging) {
    try {
      FirebaseMessaging.onMessage.listen(notificationOnMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(notificationOnLaunch);
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages', arguments: 1);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  void notificationOnLaunch(RemoteMessage message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message.data['google.message_id']) {
        if (message.data['data']['id'] == "orders") {
          await settingRepo.saveMessageId(message.data['google.message_id']);
          settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages', arguments: 1);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  void notificationOnMessage(RemoteMessage message) async {
    Fluttertoast.showToast(
      msg: message.data['notification']['title'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
//      backgroundColor: Theme.of(state.context).backgroundColor,
//      textColor: Theme.of(state.context).hintColor,
      timeInSecForIosWeb: 5,
    );
  }
}
