import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _inputController = TextEditingController();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(15.978011, 120.539261),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};

  void _setMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("initial"),
          position: position,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _setMarker(
      const LatLng(15.978011, 120.539261),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _inputController,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_inputController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter address.")),
                    );
                    return;
                  }

                  final coordinates =
                      await _getCoordicates(_inputController.text);

                  if (coordinates == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Address not found."),
                      ),
                    );
                    return;
                  }

                  _goToPosition(
                    CameraPosition(
                      target: coordinates,
                      zoom: 14.4746,
                    ),
                  );

                  _setMarker(coordinates);
                },
                child: const Text("Locate"),
              ),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: _markers,
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _getCoordicates("dadadadada");
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<LatLng?> _getCoordicates(String query) async {
    try {
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      return LatLng(
        first.coordinates.latitude!,
        first.coordinates.longitude!,
      );
    } on PlatformException {
      return null;
    }
  }

  Future<void> _goToPosition(CameraPosition position) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
