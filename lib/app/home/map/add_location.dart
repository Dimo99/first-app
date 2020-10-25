import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_architecture_flutter_firebase/module/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLocation extends StatefulWidget {

  final LatLng location;

  const AddLocation({
    @required this.location,
  }) : assert(location != null, 'location must not be null');

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {

  final databaseReference = FirebaseFirestore.instance;

  int polutionType;

  final TextEditingController radiusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    polutionType = 0;
    super.initState();
  }

  @override
  void dispose() {
    radiusController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.add_location),
            title: Text('${widget.location.latitude} , ${widget.location.longitude}'),
          ),
          ListTile(
            leading: Icon(Icons.restore_from_trash),
            title: DropdownButton(
              value: polutionType,
              items: [
                DropdownMenuItem(
                  child: Text("Undefined"),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("General Waste"),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text("Organic Waste"),
                  value: 2,
                ),
                DropdownMenuItem(
                    child: Text("Construction Waste"),
                    value: 3
                ),
                DropdownMenuItem(
                    child: Text("Household Waste"),
                    value: 4
                )
              ],
              onChanged: (int value) {
                setState(() {
                  polutionType = value;
                });
              },
              isExpanded: true,
            ),
          ),
          ListTile(
            leading: Icon(Icons.radio_button_unchecked),
            title: TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Radius in meters',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Description',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: addLocation,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> addLocation() async {
    final Location location = Location(
      x: widget.location.latitude.toString(),
      y: widget.location.longitude.toString(),
      type: polutionType.toString(),
      radius: radiusController.text,
      description: descriptionController.text,
    );

    await databaseReference.collection('locations').add({
      'x': location.x,
      'y': location.y,
      'type': location.type,
      'progressLevel': location.progressLevel,
      'radius': location.radius,
      'description': location.description,
    });

    Navigator.of(context).pop();
  }
}
