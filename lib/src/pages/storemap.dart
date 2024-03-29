import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:markets_deliveryboy/src/models/market.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/map_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';

class StoreMapWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  StoreMapWidget({Key key, this.routeArgument, this.parentScaffoldKey})
      : super(key: key);

  @override
  _StoreMapWidgetState createState() => _StoreMapWidgetState();
}

class _StoreMapWidgetState extends StateMVC<StoreMapWidget> {
  MapController _con;

  _StoreMapWidgetState() : super(MapController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.currentOrder = widget.routeArgument?.param as Order;
    if (_con.currentOrder.productOrders[0].product.market.latitude != null) {
      // user select a market
      print(_con.currentOrder.deliveryAddress.toMap().toString());
      _con.getStoreLocation();
    } else {
      _con.getCurrentLocation();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        leading: _con.currentOrder?.deliveryAddress?.latitude == null
            ? new IconButton(
                icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
                onPressed: () =>
                    widget.parentScaffoldKey.currentState.openDrawer(),
              )
            : IconButton(
                icon: new Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          S.of(context).store_addresses,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3,color: Theme.of(context).primaryColor)),
        ),
      ),
      body: Stack(
        fit: StackFit.loose,
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          _con.cameraPosition == null
              ? CircularLoadingWidget(height: 0)
              : GoogleMap(
                  mapToolbarEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: _con.cameraPosition,
                  markers: Set.from(_con.allMarkers),
                  onMapCreated: (GoogleMapController controller) {
                    _con.mapController.complete(controller);
                  },
                  onCameraMove: (CameraPosition cameraPosition) {
                    _con.cameraPosition = cameraPosition;
                  },
                  onCameraIdle: () {
                    _con.getOrdersOfArea();
                  },
                  polylines: _con.polylines,
                ),
          Positioned(
            right: 10,
            child: Padding(
              padding: EdgeInsets.only(bottom: 130),
              child: ElevatedButton(
                onPressed: () {
                  launch("http://maps.google.com/maps?saddr=${_con.currentAddress.latitude},${_con.currentAddress.longitude}&daddr=${_con.currentOrder.productOrders[0].product.market.latitude},${_con.currentOrder.productOrders[0].product.market.longitude}");
                },
                child: Icon(
                  Icons.assistant_navigation,
                  color: Colors.blue,
                  size: 30,
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          Container(
            height: 95,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _con.currentOrder?.orderStatus?.id == '5'
                    ? Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.2)),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 32,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).hintColor.withOpacity(0.1)),
                        child: Icon(
                          Icons.update,
                          color: Theme.of(context).hintColor.withOpacity(0.8),
                          size: 30,
                        ),
                      ),
                SizedBox(width: 15),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              S.of(context).order_id +
                                  "#${_con.currentOrder.id}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              _con.currentOrder.productOrders[0].product.market.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(_con.currentOrder.dateTime),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Helper.getPrice(
                              Helper.getTotalOrdersPrice(_con.currentOrder),
                              context,
                              style: Theme.of(context).textTheme.headline4),
                          Text(
                            S.of(context).items +
                                    ':' +
                                    _con.currentOrder.productOrders?.length
                                        ?.toString() ??
                                0,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
