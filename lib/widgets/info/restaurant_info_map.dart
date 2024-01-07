import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_info.dart';
import 'package:utils/utils.dart';

class RestaurantInfoMap extends ConsumerWidget {
  const RestaurantInfoMap({super.key, required this.width});
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        color: Colors.grey.shade200,
        width: width,
        height: 400,
        child: const Loading("Trwa ładowanie mapy"));
    return ref.watch(restaurantMapProvider()).when(
        data: (mapData) {
          final location = mapData.results.first.geometry!.location;
          return SizedBox(
            width: width,
            height: 400,
            child: GoogleMap(
                markers: {
                  Marker(
                      markerId: MarkerId(""),
                      position: LatLng(location.lat, location.lng))
                },
                initialCameraPosition: CameraPosition(
                    zoom: 15.0, target: LatLng(location.lat, location.lng))),
          );
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container(
            color: Colors.grey.shade200,
            width: width,
            height: 400,
            child: const Loading("Trwa ładowanie mapy")));
  }
}
