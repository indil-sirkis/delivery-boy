import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersHistoryWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersHistoryWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersHistoryWidgetState createState() => _OrdersHistoryWidgetState();
}

class _OrdersHistoryWidgetState extends StateMVC<OrdersHistoryWidget> {
  OrderController _con;

  _OrdersHistoryWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrdersHistory();
    super.initState();
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
              iconColor: Colors.white,
              labelColor: Colors.white),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshOrdersHistory,
        child: ListView(
          shrinkWrap: true,
          primary: true,
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
                      return OrderItemWidget(expanded: index == 0 ? true : false, order: _order);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 20);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
