# APP FLUTTER.

## Descripción.
La aplicación muestra un mapa utilizando Google Maps. Se puede ver la ubicación, los POIs cercanos y filtrar por medio de la categoría.

## Tecnologías usadas.
1. Dart - Como lenguaje de programación.
2. Flutter - Como framework.

## Paquetes.
1. google_maps_flutter:
   Versión: ^2.10.0

2. geolocator:
   Versión: ^10.0.0

3. http:
   Versión: ^1.3.0

## Estructura.
1. main.dart: Archivo principal de la
   app.

2. home.dart: Tiene la lógica para
   mostrar el mapa y la
   búsqueda de los POIs.

3. location.dart:
   Comsigue la ubicación actual con los
   permisos utilizando geolocator.

4. poi.dart: Llama a la API de
   Google Places para obtener lugares
   cercanos segun las características.
