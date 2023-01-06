import 'package:flutter/material.dart';

Widget space({double? width, double? height}) {
  return SizedBox(
    width: width ?? 20,
    height: height ?? 20,
  );
}


showLoading(BuildContext context){
  showDialog(context: context, builder: (context) =>  WillPopScope(onWillPop: ()async =>false ,child: Material(color: Colors.black.withAlpha(100),child: const Center(child: CircularProgressIndicator()),)));
}