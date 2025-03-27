import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:flutter/material.dart';

class AnimatedBookCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> originalBookList;
  final PageController? pageController; // ✅ Added

  AnimatedBookCarousel({
    Key? key,
    required this.originalBookList,
    this.pageController, // ✅ Added
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (originalBookList.isEmpty) {
      return Center(child: Text('No books found.'));
    }

    var bookList = [
      originalBookList.last,
      ...originalBookList,
      originalBookList.first,
    ];

    // ✅ Use passed controller or fallback to new one
    final PageController effectiveController = pageController ??
        PageController(viewportFraction: 0.38, initialPage: 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (effectiveController.hasClients) {
        effectiveController.jumpToPage(1);
      }
    });

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: effectiveController,
        physics: BouncingScrollPhysics(),
        itemCount: bookList.length,
        itemBuilder: (context, index) {
          var book = bookList[index];

          return AnimatedBuilder(
            animation: effectiveController,
            builder: (context, child) {
              double value = 1.0;

              if (effectiveController.position.haveDimensions) {
                value = effectiveController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.3, 1.0);
              } else {
                value = (1 -
                    ((effectiveController.initialPage - index).abs() * 0.3))
                    .clamp(0.3, 1.0);
              }

              return Transform.scale(
                scale: value,
                child: buildImageWithText(
                  context,
                  book,
                  217,
                  143,
                ),
              );
            },
          );
        },
        onPageChanged: (int currentPage) async {
          if (currentPage == 0) {
            await effectiveController.animateToPage(
              bookList.length - 2,
              duration: Duration(milliseconds: 40),
              curve: Curves.easeInOut,
            );
          } else if (currentPage == bookList.length - 1) {
            await effectiveController.animateToPage(
              1,
              duration: Duration(milliseconds: 40),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }
}
