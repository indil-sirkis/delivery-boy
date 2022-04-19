import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets_deliveryboy/src/models/DriverStatusResponce.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  OrderController _con;
  bool status = false;

  DriverStatusResponce driverStatusResponce;

  _OrdersWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrders();
    _con.getProfileUser().then((value) {
      driverStatusResponce = value;
      setState(() {
        status = driverStatusResponce.data.dutyStatus;
      });
    });
    super.initState();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("I understand",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w500)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info, color: Colors.amber),
          SizedBox(
            width: 10,
          ),
          Text(
            "Confirmation",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w500),
          )
        ],
      ),
      content: Text(
        "You can't go OFF-DUTY while a deliver is in progress.",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertMessageDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Confirm",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
      onPressed: () {
        setState(() {
          status = !status;
        });
        updateDuty(status);
        Navigator.pop(context);
      },
    );

    // set up the button
    Widget noButton = TextButton(
      child: Text("Dismiss",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Row(
        children: [
          Text(
            "Confirmation",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
          )
        ],
      ),
      content: Text(
        "Would you please confirm if you want to go OFF-DUTY?",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      actions: [
        okButton,
        noButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Colors.white),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).orders,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3,color: Colors.white)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor),
        ],
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("OFF DUTY",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black54)),
              Switch(
                  value: status,
                  onChanged: (value) {
                    print("VALUE : $value");
                    if (!status) {
                      if (driverStatusResponce != null) {
                        if(driverStatusResponce.data.available) {
                          Fluttertoast.showToast(
                              msg: "You are ON-DUTY now",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            status = !status;
                          });
                          updateDuty(status);
                        }else{
                          setState(() {
                            status = false;
                          });
                          Fluttertoast.showToast(
                              msg: "Profile not verified",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      }
                    } else {
                      // setState(() {status = true;});
                      if (_con.orders.length > 0) {
                        showAlertDialog(context);
                      } else {
                        showAlertMessageDialog(context);
                      }
                    }
                  },
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.redAccent.shade100),
              Text("ON DUTY",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black54)),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _con.refreshOrders,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                children: <Widget>[
                  _con.orders.isEmpty
                      ? EmptyOrdersWidget()
                      : ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.orders.length,
                          itemBuilder: (context, index) {
                            var _order = _con.orders.elementAt(index);
                            return OrderItemWidget(
                                expanded: index == 0 ? true : false,
                                order: _order);
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 20);
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateDuty(duty_status) {
    if (driverStatusResponce != null) {
      _con
          .updateProfileUser(driverStatusResponce.data.id, duty_status)
          .then((value) {
        DriverStatusResponce driverStatusResponce = value;
        setState(() {
          status = driverStatusResponce.data.dutyStatus;
        });
      });
    }
  }
}
