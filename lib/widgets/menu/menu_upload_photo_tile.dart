import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

class MenuUploadPhotoTile extends ConsumerWidget {
  const MenuUploadPhotoTile(
      {super.key,
      required this.photoUrl,
      required this.showUpload,
      required this.isMain});
  final String photoUrl;
  final VoidCallback showUpload;
  final bool isMain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aspectRatio = isMain ? 1.9 : 1.0;
    late Widget button;
    if (photoUrl.isNotEmpty) {
      button = InkWell(
          onTap: showUpload,
          child: Image.network(
            photoUrl,
            fit: BoxFit.fill,
          ));
    } else {
      button = OutlinedButton(
          style: const ButtonStyle(
              side: MaterialStatePropertyAll(
                  BorderSide(color: Colors.black, width: 3.0)),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder())),
          onPressed: showUpload,
          child: const Icon(
            Icons.photo,
            color: primaryColor,
            size: 96,
          ));
    }
    if (isMain) {
      return Tooltip(
        message: "Dodaj zdjęcie główne",
        child: AspectRatio(aspectRatio: aspectRatio, child: button),
      );
    }
    return Align(
      alignment: Alignment.topLeft,
      child: Tooltip(
          message: "Dodaj zdjęcie",
          child: SizedBox(width: 250, height: 250, child: button)),
    );
  }
}
