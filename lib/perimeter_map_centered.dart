// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl_example/services/current_location.dart';
import 'page.dart';

class PerimeterPageV2 extends Page {
  PerimeterPageV2() : super(const Icon(Icons.location_searching), 'Perimeter map centered');
  // map with perimenter centered, static.

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

  static final CameraPosition _kInitialPosition =  CameraPosition(
    target: LatLng(0, 0), // latitude and longitude should be from current position
    zoom: 12.0,
  );

  LocationData currentLocation; 
  MapboxMapController mapController;
  CameraPosition _position = _kInitialPosition;
  bool _isMoving = false;
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

  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.Tracking;

  @override
  void initState()  {
    super.initState();
    fetchCurrentLocation().then((_location) {
      setState(() {
        currentLocation =  _location;
      });
    }); 
  }

  void _onMapChanged() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;

    if (_isMoving) {     
      _updateSelectedCircle(
        CircleOptions(
            geometry: LatLng(
              _position.target.latitude,
              _position.target.longitude
            ),
          ),
      );    
    }

    setState(() {
      _extractMapInfo();

    });
  }


  void _updateSelectedCircle(CircleOptions changes) {
    var _circle = mapController.circles.first;
    _circle != null ? mapController.updateCircle(_circle, changes): null;
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
    if(_circles.isEmpty) {
      mapController.addCircle(
        CircleOptions(
            geometry: LatLng(
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            circleColor: "#81bdf1",
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
          child: mapboxMap != null ? mapboxMap : Center(),
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