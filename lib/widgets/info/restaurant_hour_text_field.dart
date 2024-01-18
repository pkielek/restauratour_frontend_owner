import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant/restaurant.dart';

class RestaurantHourTextField extends ConsumerWidget {
  const RestaurantHourTextField(
      {super.key,
      required this.day,
      required this.data,
      required this.isCloseTime});
  final RestaurantHour data;
  final int day;
  final bool isCloseTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 125,
      child: TextFormField(
        initialValue: isCloseTime? data.closeTime : data.openTime,
        maxLength: 5,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator:
            isCloseTime ? data.closeTimeValidator : data.openTimeValidator,
        onChanged: (time) => isCloseTime
            ? ref.read(InfoProvider().notifier).updateCloseTime(day, time)
            : ref.read(InfoProvider().notifier).updateOpenTime(day, time),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, height: 0.8),
        decoration: InputDecoration(
            isDense: true,
            labelStyle: const TextStyle(fontSize: 14, height: 0.8),
            counterText: "",
            labelText: isCloseTime ? "Do" : "Od",
            hintText: "HH:MM",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
