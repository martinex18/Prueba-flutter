import 'dart:convert';
import 'package:http/http.dart' as http;

class POI {
  static const String api =
      "AIzaSyB4S-LVPmPQ-keHw-RjVuvWt8dgU33Vzj8";
  static const String apiUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  Future<List<dynamic>> fetchPOIs(double lat, double lng, String filtro) async {
    final String tipo = filtro.isNotEmpty ? filtro : "Sin descripcion";
    final Uri url = Uri.parse(
        "$apiUrl?location=$lat,$lng&radius=1000&type=$tipo&key=$api");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List places = data['results'] ?? [];
      return places;
    } else {
      throw Exception("Error en la API: ${response.reasonPhrase}");
    }
  }
}
