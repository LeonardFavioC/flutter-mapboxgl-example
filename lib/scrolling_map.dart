// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/services/current_location.dart';

import 'page.dart';

class ScrollingMapPage extends Page {
  ScrollingMapPage() : super(const Icon(Icons.map), 'Scrolling map');

  @override
  Widget build(BuildContext context) {
    return const ScrollingMapBody();
  }
}

class ScrollingMapBody extends StatefulWidget {
  const ScrollingMapBody();

  @override
  State<StatefulWidget> createState() => ScrollingMapBodyState();
}

class ScrollingMapBodyState extends State<ScrollingMapBody> {
  ScrollingMapBodyState();

  LocationData center;

 @override
  void initState() {
    super.initState();
    fetchCurrentLocation().then((_location) {
      setState(() {
        center =  _location;
      });
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return center != null ? ListView(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text('This map consumes all touch events.'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: MapboxMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(center.latitude, center.longitude),
                        zoom: 11.0,
                      ),
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Text('This map doesn\'t consume the vertical drags.'),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child:
                      Text('It still gets other gestures (e.g scale or tap).'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: MapboxMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(center.latitude, center.longitude),
                        zoom: 11.0,
                      ),
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => ScaleGestureRecognizer(),
                        ),
                      ].toSet(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ) : Center(
      child: Text('Cargando'),
    );
  }

  void onMapCreated(MapboxMapController controller) {
    controller.addSymbol(SymbolOptions(
        geometry: LatLng(
          center.latitude,
          center.longitude,
        ),
        iconImage: "airport-15"));
    controller.addLine(
      LineOptions(
        geometry: [
          LatLng(center.latitude, center.longitude),
          LatLng(center.latitude + 0.05, center.longitude + 0.05),
          LatLng(center.latitude + 0.015, center.longitude + 0.015),
          LatLng(center.latitude + 0.025, center.longitude + 0.025),
        ],
        lineColor: "#ff0000",
        lineWidth: 7.0,
        lineOpacity: 0.5,
      ),
    );
  }
}
