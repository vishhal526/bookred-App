import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double height; // Required height
  final double width; // Required width
  final double borderRadius; // Border radius for non-circular items
  final bool isCircular; // Flag for circular items
  final int itemCount; // Number of shimmer items
  final Color baseColor; // Base color for shimmer effect
  final Color highlightColor; // Highlight color for shimmer effect
  final bool isGrid; // Show shimmer as GridView
  final bool isList; // Show shimmer as ListView
  final int gridCrossAxisCount; // Number of columns for GridView

  // Constructor
  ShimmerWidget({
    required this.height,
    required this.width,
    this.borderRadius = 10.0,
    this.isCircular = false,
    this.itemCount = 4,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.isGrid = false,
    this.isList = false,
    this.gridCrossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      // GridView Shimmer
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: GridView.builder(
          itemCount: itemCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCrossAxisCount,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) => buildShimmerItem(),
        ),
      );
    } else if (isList) {
      // Horizontal ListView Shimmer
      return SizedBox(
        height: height,
        child: ListView.builder(
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 19.0 : 7.0,
              right: index == itemCount - 1 ? 19.0 : 7.0,
            ),
            child: buildShimmerItem(),
          ),
        ),
      );
    } else {
      // Single Shimmer Container
      return buildShimmerItem();
    }
  }

  // Shimmer Container Builder
  Widget buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: isCircular
          ? Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
        ),
      )
          : Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
