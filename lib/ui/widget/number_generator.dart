
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NumberGenerator extends StatelessWidget {
  final int code;
  const NumberGenerator({
    Key? key,
    required this.code
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          Positioned(
            top: 110,
            right: 0,
            left: 0,
            child: Image.asset("assets/images/code_back.png")),
          Positioned(
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                  ),
                  width: 150,
                  height: 150,
                  child: QrImage(
                    data: "$code",
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Generated number",
                  style: TextStyle(fontSize: 22),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "$code",
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
