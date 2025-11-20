import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VectorBackground extends StatelessWidget {
  const VectorBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      child: SvgPicture.asset(
        'assets/icons/vector_background.svg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
      ),
    );
  }
}
