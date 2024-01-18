import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RestaurantInfoMap extends ConsumerWidget {
  const RestaurantInfoMap(
      {super.key, required this.width, required this.lat, required this.lng});
  final double lat;
  final double lng;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      height: 400,
      child: GoogleMap(
          markers: {
            Marker(markerId: const MarkerId(""), position: LatLng(lat, lng))
          },
          initialCameraPosition:
              CameraPosition(zoom: 15.0, target: LatLng(lat, lng))),
    );
  }
}
