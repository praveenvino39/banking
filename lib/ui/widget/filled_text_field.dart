import 'package:flutter/material.dart';

class FilledTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? textController;
  const FilledTextField({Key? key, this.label, this.textController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null
            ? Text(
                label ?? "",
                style: const TextStyle(color: Colors.white),
              )
            : const SizedBox(),
        label != null
            ? const SizedBox(
                height: 10,
              )
            : const SizedBox(),
        TextFormField(
          controller: textController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xff2E2B5F),
          ),
        ),
      ],
    );
  }
}
