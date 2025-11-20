import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TravaLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const TravaLogo({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  const TravaLogo.size({
    super.key,
    required double size,
    this.color,
  })  : width = size * 3,
        height = size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/trava_logo.svg',
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
