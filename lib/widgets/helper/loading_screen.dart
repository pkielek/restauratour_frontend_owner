import 'package:flutter/material.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          Container(
              alignment: Alignment.center,
              height: 0.5 * size.height,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                          height: 0.5 * size.height,
                          width: 0.5 * size.width,
                          child: const CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 6.0,
                          )),
                      Image.asset(
                        'images/logo.webp',
                        semanticLabel: 'Restaura TOUR Logo',
                        width: size.width * 0.33,
                        height: size.height * 0.33,
                      )
                    ],
                  ))),
          const SizedBox(height: 50),
          const Text("Trwa ładowanie...",
              style: boldBig)
        ])));
  }
}
