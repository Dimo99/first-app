import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/module/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationView extends StatefulWidget {
  final Location location;

  const LocationView({
    @required this.location,
  }) : assert(location != null, 'Location must not be null');

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  PersistentBottomSheetController _controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, String> wasteType = {'0':'Undefined','1':'General Waste', '2': 'Organic Waste', '3':'Construction Waste', '4': 'Household Waste'};

  final databaseReference = FirebaseFirestore.instance;

  int value;
  int red;
  int green;

  @override
  void initState() {
    value = int.parse(widget.location.progressLevel);
    red = ((255 * (100 - value)) / 100).round();
    green = ((255 * value) / 100).round();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.add_location),
            title: Text('Coordinates'),
            subtitle: Text('${widget.location.x} , ${widget.location.y}'),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart_rounded),
            title: Text('Progress'),
            subtitle: Text(value.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setProgress(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore_from_trash),
            title: Text('Waste Type'),
            subtitle: Text(wasteType[widget.location.type]),
          ),
          ListTile(
            leading: const Icon(Icons.radio_button_unchecked),
            title: Text('Radius'),
            subtitle: Text(widget.location.radius),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('Description'),
            subtitle: Text(widget.location.description),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blueAccent,
      //   onPressed: addLocation,
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void setProgress() {
    final _formKey = GlobalKey<FormState>();

    _controller = _scaffoldKey.currentState.showBottomSheet<int>(
      (context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Slider(
                  value: value.toDouble(),
                  activeColor: Color.fromRGBO(red, green, 0, .6),
                  inactiveColor: Color.fromRGBO(red, green, 0, .2),
                  min: 0.0,
                  max: 100.0,
                  divisions: 100,
                  onChanged: (val) => changeProgress(val.round()),
                ),
                RaisedButton(
                    color: Color.fromRGBO(red, green, 0, 1),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (value > double.parse(widget.location.progressLevel)) {
                          try {
                            await databaseReference.collection('locations').doc(widget.location.id).update({
                              'progressLevel': value.toString(),
                            });
                          } catch (e) {
                            print(e.toString());
                          }
                          Navigator.pop(context);
                        }
                      }
                    }
                ),
              ],
            ),
          ),
        );
      },
      elevation: 10,
    );
  }

  void changeProgress(int val) {
    _controller.setState(() {
      value = val;
      red = ((255 * (100 - value)) / 100).round();
      green = ((255 * value) / 100).round();
    });
    setState(() {
      value = val;
    });
  }
}
