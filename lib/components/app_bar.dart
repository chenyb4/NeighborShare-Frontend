import 'package:flutter/material.dart';
import 'package:aad_hybrid/configs/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "NeighborShare",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: themeColor,
    );
  }
}
