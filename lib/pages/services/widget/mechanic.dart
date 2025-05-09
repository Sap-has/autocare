import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String _googleApiKey = 'YOUR_GOOGLE_API_KEY';

class MechanicsMap extends StatefulWidget {
  const MechanicsMap({super.key});
  @override
  _MechanicsMapState createState() => _MechanicsMapState();
}

class _MechanicsMapState extends State<MechanicsMap> {
  LatLng? _current;
  final Set<Marker> _markers = {};
  late GoogleMapController _ctrl;

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  Future<void> _initLocationAndFetch() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        // user denied, you could show a dialog explaining why you need it
        return;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      // permissions are permanently denied, open app settings:
      await Geolocator.openAppSettings();
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _current = LatLng(pos.latitude, pos.longitude);
    await _fetchNearbyMechanics();
    setState(() {});
  }


  Future<void> _fetchNearbyMechanics() async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${_current!.latitude},${_current!.longitude}'
            '&radius=3000&type=car_repair&key=$_googleApiKey'
    );
    final resp = await http.get(url);
    final data = json.decode(resp.body) as Map<String, dynamic>;
    (data['results'] as List).forEach((place) {
      final loc = place['geometry']['location'];
      final id = place['place_id'] as String;
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['vicinity'],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _current!,
          zoom: 14,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        onMapCreated: (c) => _ctrl = c,
      ),
    );
  }
}
