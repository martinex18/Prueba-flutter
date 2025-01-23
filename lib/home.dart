import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/location.dart';
import 'package:myapp/poi.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller =
      Completer(); // Controlador del mapa

  static const LatLng ubixDefecto =
      LatLng(-10.901297563034179, -74.81125116338139); // ubicacion por defecto
  final List<Marker> markers = [];

  bool isLoading = false;
  String errorMsj = "";
  String buscar = "";

  @override
  void initState() {
    super.initState();
    _getUbiActual();
  }

  Future<void> _getUbiActual() async {
    setState(() => isLoading = true);
    try {
      // Se obtiene la ubicación actual
      // se declara la variable con final para que el valor que tome no cambie
      final actualPosition = await Location().getActualPosition();

      // Actualiza la posición del mapa y agrega un marcador
      _actualizarMapa(LatLng(actualPosition.latitude, actualPosition.longitude),
          "Ubicación actual");

      // Busca los POIs en base a la ubicación actual
      await _fetchPOIs(actualPosition.latitude, actualPosition.longitude);
    } catch (e) {
      setState(() => errorMsj = "Error al obtener ubicación: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPOIs(double lat, double lng) async {
    try {
      // Llama la funcion POI para obtener los lugares
      final lugares = await POI().fetchPOIs(lat, lng, buscar);

      setState(() {
        markers.removeWhere((marker) => marker.markerId.value != "actual");
        // Se filtran los lugares
        final lugaresFiltrados = lugares.where((lugar) {
          final types = lugar['types'] as List<dynamic>?; // Lista de categorías
          return types?.any((type) => type == buscar) ??
              false; // Coincide con el filtro
        }).toList();

        if (buscar.isNotEmpty && lugaresFiltrados.isEmpty) {
          setState(() => errorMsj =
              "No se encontraron lugares con la categoria: $buscar ");
          return;
        }
        errorMsj = "";

        // Actualiza la lista de marcadores
        for (var lugar in lugares) {
          markers.add(Marker(
            markerId: MarkerId(lugar['place_id']),
            position: LatLng(lugar['geometry']['location']['lat'],
                lugar['geometry']['location']['lng']),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: lugar['name'],
              snippet: lugar['types']?.firstWhere(
                      (type) => type != "point_of_interest",
                      orElse: () => "Sin categoría") ??
                  "Sin categoría",
            ),
          ));
        }
      });
    } catch (e) {
      setState(() => errorMsj = "Error al obtener lugares: $e");
    }
  }

  Future<void> _actualizarMapa(LatLng ubicacionNueva, String titulo) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: ubicacionNueva,
      zoom: 15,
    )));
    setState(() {
      markers.add(Marker(
        markerId: const MarkerId("actual"),
        position: ubicacionNueva,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: titulo,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(Colors.blue.value),
        title: TextField(
          decoration: const InputDecoration(
            hintText: "Buscar por categoria",
            icon: Icon(Icons.search),
          ),
          onChanged: (value) async {
            setState(() => buscar = value.toLowerCase().replaceAll(" ", "_"));
            if (value.isEmpty) {
              // Si el buscador está vacío, muestra todos los lugares
              final actualPosition = await Location().getActualPosition();
              await _fetchPOIs(actualPosition.latitude, actualPosition.longitude);
            }
          },
          onSubmitted: (value) async {
            setState(() => buscar = value.toLowerCase().replaceAll(" ", "_"));
            final actualPossitionPlaces = await Location().getActualPosition();
            await _fetchPOIs(actualPossitionPlaces.latitude,
                actualPossitionPlaces.longitude);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: ubixDefecto, zoom: 15),
            markers: Set<Marker>.of(markers),
            onMapCreated: (controller) => _controller.complete(controller),
          ),
          if (isLoading)
            const Center(
                child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 4,
            )),
          if (errorMsj.isNotEmpty)
            Center(
              child: Text(
                errorMsj,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getUbiActual,
        child: const Icon(Icons.location_searching),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
