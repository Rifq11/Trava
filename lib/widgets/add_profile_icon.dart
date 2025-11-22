import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddProfileIcon extends StatelessWidget {
  final double size;

  const AddProfileIcon({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/add_icon.svg',
      width: size,
      height: size,
    );
  }
}
