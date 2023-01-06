import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  final Function() onPress;
  final String title;
  const FilledButton({Key? key, required this.onPress, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPress,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            const Color(
              0xff3E3E3E,
            ),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
