import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';
import '../repository/settings_repository.dart' as sett;

class MapController extends ControllerMVC {
  Order currentOrder;
  List<Order> orders = <Order>[];
  List<Marker> allMarkers = <Marker>[];
  Address currentAddress;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  MapsUtil mapsUtil = new MapsUtil();
  double taxAmount = 0.0;
  double subTotal = 0.0;
  double deliveryFee = 0.0;
  double total = 0.0;
  Completer<GoogleMapController> mapController = Completer();

  void listenForNearOrders(Address myAddress, Address areaAddress) async {
    print('listenForOrders');
    final Stream<Order> stream = await getNearOrders(myAddress, areaAddress);
    stream.listen(
        (Order _order) {
          setState(() {
            orders.add(_order);
          });
          Helper.getOrderMarker(_order.deliveryAddress.toMap()).then((marker) {
            setState(() {
              allMarkers.add(marker);
            });
          });
        },
        onError: (a) {},
        onDone: () {
          calculateSubtotal();
        });
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      setState(() {
        if (currentAddress.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(40, 3),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress.latitude, currentAddress.longitude),
            zoom: 14.4746,
          );
        }
      });
      if (!currentAddress.isUnknown()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void getOrderLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(currentOrder.deliveryAddress.latitude, currentOrder.deliveryAddress.longitude),
          zoom: 14.4746,
        );
      });
      if (!currentAddress.isUnknown()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
        sett.setCurrentLocation().then((_currentAddress) {
          setState(() {
            sett.myAddress.value = _currentAddress;
            currentAddress = _currentAddress;
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }
  void getStoreLocation() async {
    try {
      // currentAddress = sett.myAddress.value;
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(currentOrder.productOrders[0].product.market.latitude), double.parse(currentOrder.productOrders[0].product.market.longitude)),
          zoom: 14.4746,
        );
      });
      Helper.getStoreMarker(currentOrder.productOrders[0].product.market.toMap()).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
      final GoogleMapController controller = await mapController.future;

      sett.setCurrentLocation().then((_currentAddress) {
        setState(() {
          sett.myAddress.value = _currentAddress;
          currentAddress = _currentAddress;
          getStoreDirectionSteps();
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((_currentAddress) {
      setState(() {
        sett.myAddress.value = _currentAddress;
        currentAddress = _currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
        zoom: 14.4746,
      )));
    });
  }

  void getOrdersOfArea() async {
    setState(() {
      orders = <Order>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearOrders(currentAddress, areaAddress);
      } else {
        listenForNearOrders(currentAddress, currentAddress);
      }
    });
  }

  void getDirectionSteps() async {
    currentAddress = sett.myAddress.value;
    mapsUtil
        .get("origin=" +
            currentAddress.latitude.toString() +
            "," +
            currentAddress.longitude.toString() +
            "&destination=" +
            currentOrder.deliveryAddress.latitude.toString() +
            "," +
            currentOrder.deliveryAddress.longitude.toString() +
            "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
      if (res != null) {
        List<LatLng> _latLng = res as List<LatLng>;
        _latLng?.insert(0, new LatLng(currentAddress.latitude, currentAddress.longitude));
        setState(() {
          polylines
              .add(new Polyline(visible: true, polylineId: new PolylineId(currentAddress.hashCode.toString()), points: _latLng, color: config.Colors().mainColor(0.8), width: 6));
        });
      }
    });
  }

  void getStoreDirectionSteps() async {
    currentAddress = sett.myAddress.value;
    print("CURRENT::${sett.setting.value?.googleMapsKey}:::${currentAddress.latitude}::::${currentOrder.productOrders[0].product.market.latitude}");
    mapsUtil
        .get("origin=" +
            currentAddress.latitude.toString() +
            "," +
            currentAddress.longitude.toString() +
            "&destination=" +
        currentOrder.productOrders[0].product.market.latitude +
            "," +
        currentOrder.productOrders[0].product.market.longitude +
            "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
      print("CURRENT_RES::${res}");
      if (res != null) {
        List<LatLng> _latLng = res as List<LatLng>;
        _latLng?.insert(0, new LatLng(currentAddress.latitude, currentAddress.longitude));
        setState(() {
          polylines
              .add(new Polyline(visible: true, polylineId: new PolylineId(currentAddress.hashCode.toString()), points: _latLng, color: config.Colors().mainColor(0.8), width: 6));
        });
      }
    },onError: (error){
          print(error);
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    currentOrder.productOrders?.forEach((product) {
      subTotal += product.quantity * product.price;
    });
    deliveryFee = currentOrder.productOrders?.elementAt(0)?.product?.market?.deliveryFee ?? 0;
    taxAmount = (subTotal + deliveryFee) * currentOrder.tax / 100;
    total = subTotal + taxAmount + deliveryFee;

    taxAmount = subTotal * currentOrder.tax / 100;
    total = subTotal + taxAmount;
    setState(() {});
  }

  Future refreshMap() async {
    setState(() {
      orders = <Order>[];
    });
    listenForNearOrders(currentAddress, currentAddress);
  }
}
