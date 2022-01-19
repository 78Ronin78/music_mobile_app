import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:music_mobile_app/components/zoom_button.dart';
import 'package:latlong/latlong.dart';
import 'concert.dart';

class GMap extends StatefulWidget {
  GMap({Key key}) : super(key: key);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[
      Marker(
        width: 60.0,
        height: 60.0,
        point: currentLatLng,
        builder: (ctx) => Container(
          child: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 50,
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Карта',
          style: TextStyle(fontFamily: 'HelveticaNeue'),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            children: [
              Flexible(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(
                      currentLatLng.latitude,
                      currentLatLng.longitude,
                    ),
                    zoom: 16.0,
                    onTap: (LatLng value) {
                      setState(() {
                        currentLatLng = value;
                      });
                    },
                    plugins: [
                      ZoomButtonsPlugin(),
                    ],
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      tileProvider: NonCachingNetworkTileProvider(),
                    ),
                    ZoomButtonsPluginOption(
                      minZoom: 4,
                      maxZoom: 19,
                      mini: true,
                      padding: 10,
                      alignment: Alignment.bottomRight,
                    ),
                    MarkerLayerOptions(markers: markers)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
