
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
    preferredSize: Size(MediaQuery.of(context).size.width, 56),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions:  [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 20),child: Text("Logout"),),
            ],
          )
        ],
      ),
    );
  }
}
