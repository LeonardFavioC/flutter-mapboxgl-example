// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl_example/services/current_location.dart';

import 'page.dart';

class PerimeterPage extends Page {
  PerimeterPage() : super(const Icon(Icons.cloud_circle), 'Perimeter map draggable');
  // map with perimeter draggable
  @override
  Widget build(BuildContext context) {
    return const PerimeterBody();
  }
}

class PerimeterBody extends StatefulWidget {
  const PerimeterBody();

  @override
  State<StatefulWidget> createState() => PerimeterBodyState();
}

class PerimeterBodyState extends State<PerimeterBody> {
  PerimeterBodyState();

  var location = new Location();
  static LocationData currentLocation;

  static final CameraPosition _kInitialPosition =  CameraPosition(
    target: LatLng(0, 0), // latitude and longitude should be from current position
    zoom: 12.0,
  );

  MapboxMapController mapController;
  CameraPosition _position = _kInitialPosition;
  bool _isMoving = false;
  bool drawing = false;
  var error = '';
  bool _compassEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  String _styleString = MapboxStyles.MAPBOX_STREETS;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  Circle currentCircle;

  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.Tracking;

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation ().then((_location) {
      setState(() {
        currentLocation =  _location;
      });
    });
  }

  void _onMapChanged() {
    _position = mapController.cameraPosition;

    setState(() {
      _extractMapInfo();
      infoCircle();
    });
  }

  infoCircle() {
    // should be current circle position when circle moved, but save first position.
    var _circle = mapController.circles;
    if(_circle.isNotEmpty) {
      return currentCircle = _circle.first;
    } else {
      return currentCircle = null;
    }
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  void onAdd() {
    var _circles = mapController.circles;
    setState(() {
      drawing = true;
    });
    if(_circles.isEmpty) {
    mapController.addCircle(
      CircleOptions(
          geometry: LatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
          circleColor: "#81bdf1",
          draggable: true,
          circleRadius: 90,
          circleOpacity: .7),
      );
    }
  }

  void onRemove() {
    var _circles = mapController.circles;
    if(_circles.isNotEmpty) {
      mapController.clearCircles();
    }
    setState(() {
      drawing = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    MapboxMap mapboxMap;
    if (currentLocation != null) {
      mapboxMap = MapboxMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 11.0,
        ),
        trackCameraPosition: true,
        compassEnabled: _compassEnabled,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: _styleString,
        rotateGesturesEnabled: _rotateGesturesEnabled,
        scrollGesturesEnabled: _scrollGesturesEnabled,
        tiltGesturesEnabled: _tiltGesturesEnabled,
        zoomGesturesEnabled: _zoomGesturesEnabled,
        myLocationEnabled: _myLocationEnabled,
        myLocationTrackingMode: _myLocationTrackingMode,
        onMapClick: (point, latLng) async {
          print("${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
          List features = await mapController.queryRenderedFeatures(point, [],null);
          if (features.length>0) {
            print(features[0]);
          }
        },
        onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        }
      );
    }
    final List<Widget> columnChildren = <Widget>[
      Center(
        child: SizedBox(
          height: 200.0,
          child: mapboxMap != null ? mapboxMap : Column(),
        ),
      ),
    ];
    if (mapController != null) {
      columnChildren.add(
        Container(
          child: Column(
            children: <Widget>[
              Text('camera bearing: ${_position.bearing}'),
              Text(
                  'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                  '${_position.target.longitude.toStringAsFixed(4)}'),
              Text('camera zoom: ${_position.zoom}'),
              Text('camera tilt: ${_position.tilt}'),
              Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
              Text(currentCircle != null ? currentCircle.options.geometry.latitude.toStringAsFixed(4): "Perimeter empty"),
            ],
          ),
        ),
      );
    }
    columnChildren.add(
      GestureDetector(
            onTap: onAdd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Icon(Icons.add),
                Text('Add')
              ]
            ),
          ),
    );
    columnChildren.add(
      GestureDetector(
            onTap: onRemove,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Icon(Icons.close),
                Text('Remove')
              ]
            ),
          ),
    );
    columnChildren.add(
      Text(drawing ? 'Move the circle' : '', style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      )
    );
    final List<Widget> loading = <Widget>[
        Center(
          child: Text('Cargando'),
        ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: currentLocation != null ? columnChildren : loading,
    );
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
    setState(() {});
  }
}
