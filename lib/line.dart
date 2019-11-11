// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/services/current_location.dart';
import 'package:location/location.dart';

import 'page.dart';

class LinePage extends Page {
  LinePage() : super(const Icon(Icons.share), 'Line');

  @override
  Widget build(BuildContext context) {
    return const LineBody();
  }
}

class LineBody extends StatefulWidget {
  const LineBody();

  @override
  State<StatefulWidget> createState() => LineBodyState();
}

class LineBodyState extends State<LineBody> {
  LineBodyState();

  static final LatLng center = const LatLng(0, 0);
  LocationData currentLocation; 

  MapboxMapController controller;
  int _lineCount = 0;
  Line _selectedLine;
  @override
  void initState()  {
    super.initState();
    fetchCurrentLocation().then((_location) {
      setState(() {
        currentLocation =  _location;
      });
    }); 
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onLineTapped.add(_onLineTapped);
  }

  @override
  void dispose() {
    controller?.onLineTapped?.remove(_onLineTapped);
    super.dispose();
  }

  void _onLineTapped(Line line) {
    if (_selectedLine != null) {
      _updateSelectedLine(
        const LineOptions(
          lineWidth: 28.0,
        ),
      );
    }
    setState(() {
      _selectedLine = line;
    });
    _updateSelectedLine(
      LineOptions(
          // linecolor: ,
          ),
    );
  }

  void _updateSelectedLine(LineOptions changes) {
    controller.updateLine(_selectedLine, changes);
  }

  void _add() {
    controller.addLine(
      LineOptions(
        geometry: [
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(currentLocation.latitude + 0.05, currentLocation.longitude + 0.05),
          LatLng(currentLocation.latitude + 0.015, currentLocation.longitude + 0.015),
          LatLng(currentLocation.latitude + 0.025, currentLocation.longitude + 0.025),
        ],
        lineColor: "#ff0000",
        lineWidth: 14.0,
        lineOpacity: 0.5,
      ),
    );
    setState(() {
      _lineCount += 1;
    });
  }

  void _remove() {
    controller.removeLine(_selectedLine);
    setState(() {
      _selectedLine = null;
      _lineCount -= 1;
    });
  }


  Future<void> _changeAlpha() async {
    double current = _selectedLine.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedLine(
      LineOptions(lineOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _toggleVisible() async {
    double current = _selectedLine.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }
    _updateSelectedLine(
      LineOptions(lineOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  currentLocation != null ? Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: MapboxMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 11.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('add'),
                          onPressed: (_lineCount == 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedLine == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change alpha'),
                          onPressed:
                              (_selectedLine == null) ? null : _changeAlpha,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (_selectedLine == null) ? null : _toggleVisible,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ) : Center(
          child: Text('Cargando'),
        );
  }
}
