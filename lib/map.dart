import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final List<String> cityNames ;

  const MapScreen({super.key, required this.cityNames});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> cityCoordinates = [];
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    //List<String> cityNames = ['Paris', 'Lyon', 'Marseille', 'Amman', 'Toulouse'];
    final coordinates = await getCityCoordinates(widget.cityNames);
    setState(() {
      cityCoordinates = coordinates;
    });
  }

  Future<List<LatLng>> getCityCoordinates(List<String> cityNames) async {
    List<LatLng> coordinates = [];
    for (var cityName in cityNames) {
      final coords = await geocodeCity(cityName);
      if (coords != null) {
        coordinates.add(coords);
      }
    }
    return coordinates;
  }

  Future<LatLng?> geocodeCity(String cityName) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$cityName&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Car Map', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8), // Espace entre les textes
            Text('خريطة السيارات', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(33.8869, 9.5375), // Centre de la France
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: cityCoordinates.map((coords) {
              return Marker(
                width: 40.0,
                height: 40.0,
                point: coords,
                child: Image.asset(
                  'assets/images/car.png',
                  width: 40.0,
                  height: 40.0,
                ),
              );
            }).toList(),
          ),

        ],
      ),
    );
  }
}
