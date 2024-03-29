// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'line.dart';
import 'animate_camera.dart';
import 'map_ui.dart';
import 'move_camera.dart';
import 'page.dart';
import 'perimeter_map_custom.dart';
import 'perimeter_map_centered.dart';
import 'perimeter_map_draggable.dart';
import 'place_symbol.dart';
import 'place_circle.dart';
import 'scrolling_map.dart';

final List<Page> _allPages = <Page>[
  MapUiPage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceSymbolPage(),
  LinePage(),
  PlaceCirclePage(),
  ScrollingMapPage(),
  PerimeterPage(),
  PerimeterPageV2(),
  PerimeterPageCustom()
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, Page page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MapboxMaps examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
              leading: _allPages[index].leading,
              title: Text(_allPages[index].title),
              onTap: () => _pushPage(context, _allPages[index]),
            ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}
