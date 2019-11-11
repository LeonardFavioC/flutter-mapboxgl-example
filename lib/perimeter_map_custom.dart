// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl_example/services/current_location.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';

import 'page.dart';

class PerimeterPageCustom extends Page {
  PerimeterPageCustom() : super(const Icon(Icons.add_location), 'Perimeter map customized');
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

  var location = new Location();
  static LocationData currentLocation; 

  static final CameraPosition _kInitialPosition =  CameraPosition(
    target: LatLng(0, 0), // latitude and longitude should be from current position
    zoom: 12.0,
  );
  bool drawing = false;
  List<LatLng> points = [];
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
  void initState() {
    super.initState();
    fetchCurrentLocation().then((_location) {
      setState(() {
        currentLocation =  _location;
      });
    }); 
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();

    });
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

  void onMapClick(LatLng point) {
    this.points.add(point);
    if(drawing) {
      if(this.points.length <= 2) {
        mapController.addCircle(
        CircleOptions(
            geometry: point,
            circleColor: "#FF0000"),
      ); 
      } else {
        mapController.clearLines();
        mapController.addLine(
          LineOptions(
            geometry: this.points,
            lineColor: "#ff0000",
            lineWidth: 6.0,
            lineOpacity: 0.7,
          ),
        );
      }
    }
  }

  void onAdd() {
    onClear();
    setState(() {
      drawing = true;
    });
  }

  void onSave() {
    var firstLat = points.first.latitude.toStringAsFixed(3);
    var lastLat = points.last.latitude.toStringAsFixed(3);
    var firstLon = points.first.longitude.toStringAsFixed(3);
    var lastLon = points.last.longitude.toStringAsFixed(3);
    if(firstLat == lastLat && firstLon == lastLon ) {
      Toast.show("Saved!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, textColor: Colors.red);
    setState(() {
      drawing = false;
    });
    } else {
      Toast.show("Check if last point is equal to first", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, textColor: Colors.red);
    }
  }

  void onClear() {
    setState(() {
      drawing = false;
    });
    mapController.clearCircles();
    mapController.clearLines();
    points.clear();
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
          onMapClick(latLng);
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
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Container(
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
        ),
      );
    }
    columnChildren.add(
      GestureDetector(
            onTap: drawing ? onSave : onAdd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Icon(drawing ? Icons.save : Icons.add),
                Text(drawing ? 'Save' : 'Add')
              ] 
            ),
          ),
    );columnChildren.add(
      GestureDetector(
            onTap: onClear,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Icon(Icons.delete),
                Text('Clear')
              ] 
            ),
          ),
    );
    columnChildren.add(
      Text(drawing ? 'Click on map  for create perimeter' : '', style: TextStyle(
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