import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:markets_deliveryboy/src/models/DriverStatusResponce.dart';
import 'package:markets_deliveryboy/src/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  ValueNotifier<User> currentUser = new ValueNotifier(User());
  List<Order> orders = <Order>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<DriverStatusResponce> getProfileUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
      currentUser.value = User.fromJSON(json.decode(await prefs.get('current_user')));
      currentUser.value.auth = true;
    } else {
      currentUser.value.auth = false;
    }
    final String _apiToken = 'api_token=${currentUser.value.apiToken}';
    final String url = '${GlobalConfiguration().getValue('api_base_url')}drivers/profile/${currentUser.value.id}?$_apiToken';
    print("UPDATE:::${url}");
    final client = new http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    print("PROFILE:::${response.body}");
    return DriverStatusResponce.fromJson(json.decode(response.body));
  }

  Future<DriverStatusResponce> updateProfileUser(int id,bool duty_status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
      currentUser.value = User.fromJSON(json.decode(await prefs.get('current_user')));
      currentUser.value.auth = true;
    } else {
      currentUser.value.auth = false;
    }
    final String _apiToken = 'api_token=${currentUser.value.apiToken}';
    // var map = {"duty_status": duty_status?1:0, "api_token": _apiToken,"id":id};
    var map = new Map<String, dynamic>();
    map['duty_status'] = "${duty_status?1:0}";
    map['api_token'] = "${currentUser.value.apiToken}";
    map['id'] = "${id}";
    final String url = '${GlobalConfiguration().getValue('api_base_url')}drivers/profile/${id}';
    final client = new http.Client();
    final response = await client.post(
      Uri.parse(url),
      // headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: map,
    );
    print("PROFILE:::${response.body}");
    return DriverStatusResponce.fromJson(json.decode(response.body));
  }

  void listenForOrders({String message}) async {
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForOrdersHistory({String message}) async {
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(message: S.of(state.context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.of(state.context).order_refreshed_successfuly);
  }
}
