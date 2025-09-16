import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerThumbnail extends StatelessWidget {
  final double borderRadius;
  const ShimmerThumbnail({super.key, this.borderRadius = 10.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}