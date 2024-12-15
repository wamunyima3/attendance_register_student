import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final double overlaySize;

  const ScannerOverlay({Key? key, this.overlaySize = 200.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: overlaySize,
                  width: overlaySize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: overlaySize,
            width: overlaySize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3.0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

