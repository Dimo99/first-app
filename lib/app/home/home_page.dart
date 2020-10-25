import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_architecture_flutter_firebase/app/home/bar/bottom.dart';
import 'package:flushbar/flushbar.dart';
import 'package:starter_architecture_flutter_firebase/app/home/map/add_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/app/home/map/location_view.dart';
import 'package:starter_architecture_flutter_firebase/module/location.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, Location> map;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final databaseReference = FirebaseFirestore.instance;

  static Function addSnackbarDismiss;

  final Flushbar addSnackbar = Flushbar(
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
    flushbarPosition: FlushbarPosition.TOP,
    message: 'Click on the map to add location',
    icon: const Icon(Icons.info_outline, color: Colors.white),
    mainButton: FlatButton(
      onPressed: () {
        addSnackbarDismiss();
      },
      child: const Icon(Icons.close, color: Colors.white),
    ),
  );

  bool isAddLocationTurnedOn;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();

  GoogleMapController _mapController;
  BitmapDescriptor _markerIcon;

  @override
  void initState() {
    super.initState();
    _setMarkerIcon();
    map = <String, Location>{};
    isAddLocationTurnedOn = false;
    addSnackbarDismiss = () {
      addSnackbar.dismiss();
    };
    fetch();
  }

  Future<void> fetch() async {
    Map<String, Location> fetchMap = <String, Location>{};

    _markers.clear();
    _circles.clear();

    await databaseReference.collection("locations").get()
    .then((snapshot) {
      for (var doc in snapshot.docs) {
        Map<String, dynamic> fetchData = doc.data();
        fetchData['id'] = doc.id;
        fetchMap[doc.id] = Location.fromJson(fetchData);
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(
                double.parse(fetchData['x']),
                double.parse(fetchData['y'])
              ),
              onTap: () {
                onMarkerTap(doc.id);
              },
              icon: _markerIcon
            ),
          );
          final int red = ((255 * (100 - int.parse(fetchData['progressLevel']))) / 100).round();
          final int green = ((255 * (int.parse(fetchData['progressLevel']))) / 100).round();
          _circles.add(
            Circle(
              circleId: CircleId(doc.id),
              center: LatLng(
                double.parse(fetchData['x']),
                double.parse(fetchData['y'])
              ),
              strokeWidth: 0,
              radius: double.parse(fetchData['radius']),
              fillColor: Color.fromRGBO(red, green, 0, .2)),
          );
        });
      }
    });

    setState(() {
      map = fetchMap;
    });
  }


  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/trash.png');
  }


  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(42.674563, 23.330553),
              zoom: 16,
            ),
            onTap: (location) => onMapTap(location),
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: onIconTap,
        child: isAddLocationTurnedOn ? const Icon(Icons.remove) : const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const Bottom(
        fabLocation: FloatingActionButtonLocation.centerDocked,
        shape: CircularNotchedRectangle(),
      ),
    );
  }

  Future<void> onMarkerTap(String id) async {
    await Navigator.of(context).push<MaterialPageRoute>(
      MaterialPageRoute(builder: (context) => LocationView(location: map[id])),
    );
    await fetch();
  }

  Future<void> onMapTap(LatLng location) async {
    if (isAddLocationTurnedOn) {
      setState(() {
        isAddLocationTurnedOn = !isAddLocationTurnedOn;
      });
      await addSnackbar.dismiss();
      await Navigator.of(context).push<MaterialPageRoute>(
        MaterialPageRoute(builder: (context) => AddLocation(location: location)),
      );
      await fetch();
    }
  }

  void onIconTap() {
    setState(() {
      isAddLocationTurnedOn = !isAddLocationTurnedOn;
    });

    if (isAddLocationTurnedOn) {
      addSnackbar.show(context);
    } else {
      addSnackbar.dismiss();
    }
  }
}
