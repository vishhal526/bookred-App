import 'package:bookred/All_API_List/call_author_api.dart';
import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookred/All_API_List/call_book_api.dart';

class Authorpage extends StatefulWidget {
  const Authorpage({super.key});

  @override
  State<Authorpage> createState() => _AuthorpageState();
}

class _AuthorpageState extends State<Authorpage> {
  final BookService book = BookService();
  final AuthorService author = AuthorService();
  late PageController _pageController;

  List<Map<String, dynamic>> authors = [];
  String? selectedAuthorId;
  List<Map<String, dynamic>> currentBooks = [];
  bool _isLoadingAuthors = true;
  bool _isLoadingBooks = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.4);
    _loadAuthors();
  }

  Future<void> RefreshAuthorPage() async {
    setState(() {
      _isLoadingAuthors = true;
      _isLoadingBooks = false;
      authors.clear();
      currentBooks.clear();
    });
    await _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    try {
      final authorList = await author.RandomAuthor();
      if (authorList.isNotEmpty) {
        authors = List<Map<String, dynamic>>.from(authorList);
        selectedAuthorId = authors[0]['_id'];
        await _handleAuthorChange(selectedAuthorId!);
      }
    } catch (e) {
      print('Error loading authors: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAuthors = false;
        });
      }
    }
  }

  Future<void> _handleAuthorChange(String newAuthorId) async {
    if (selectedAuthorId == newAuthorId) return;

    setState(() {
      selectedAuthorId = newAuthorId;
      _isLoadingBooks = true;
    });

    try {
      final newBooks = await author.BookByAuthor(newAuthorId);
      setState(() {
        currentBooks = List<Map<String, dynamic>>.from(newBooks);
        _isLoadingBooks = false;
      });
    } catch (e) {
      setState(() => _isLoadingBooks = false);
      print('Error loading books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: RefreshAuthorPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Needed for refresh even if list is short
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 15, left: 20),
                child: const Text(
                  "Most Reviewed",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(
                height: 230,
                child: _isLoadingAuthors
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ShimmerWidget(
                              height: 195.0,
                              width: 155,
                              isCircular: false,
                            ),
                          );
                        },
                      )
                    : (authors.isNotEmpty
                        ? AnimatedBookCarousel(
                            originalAuthorList: authors,
                            isAuthor: true,
                            pageController: _pageController,
                            onPageChanged: (index) {
                              if (index != _currentPage) {
                                _currentPage = index;
                                String newAuthorId = authors[index]['_id'];
                                _handleAuthorChange(newAuthorId);
                              }
                            },
                          )
                        : const Center(child: Text('No Author found.'))),
              ),
              SizedBox(height: 20),
              _buildBookGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookGrid() {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentBooks.isEmpty) {
      return const Center(child: Text('No books found.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 25.0,
          crossAxisSpacing: 50.0,
          childAspectRatio: 130 / 200,
        ),
        itemCount: currentBooks.length,
        itemBuilder: (context, index) {
          final bookItem = currentBooks[index];
          return buildImageWithText(
            context,
            bookItem,
            300,
            155,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// =================== Carousel Widget ==========================
class AnimatedBookCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> originalAuthorList;
  final bool isAuthor;
  final PageController? pageController;
  final Function(int)? onPageChanged;

  const AnimatedBookCarousel({
    Key? key,
    required this.originalAuthorList,
    this.isAuthor = false,
    this.pageController,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _AnimatedBookCarouselState createState() => _AnimatedBookCarouselState();
}

class _AnimatedBookCarouselState extends State<AnimatedBookCarousel> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.pageController ??
        PageController(
          viewportFraction: 0.38,
          initialPage: 1, // Start from the actual first item
        );

    // Make absolutely sure the first page is correct
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpToPage(1);
      }
    });
  }

  @override
  void dispose() {
    // Clean up if we created the controller (optional but good practice)
    if (widget.pageController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authorList = [
      widget.originalAuthorList.last,
      ...widget.originalAuthorList,
      widget.originalAuthorList.first,
    ];

    if (authorList.isEmpty) {
      return const Center(child: Text('No authors found.'));
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _controller,
        physics: BouncingScrollPhysics(),
        itemCount: authorList.length,
        onPageChanged: (int currentPage) async {
          // Loop behavior
          if (currentPage == 0) {
            await _controller.animateToPage(
              authorList.length - 2,
              duration: const Duration(milliseconds: 40),
              curve: Curves.easeInOut,
            );
          } else if (currentPage == authorList.length - 1) {
            await _controller.animateToPage(
              1,
              duration: const Duration(milliseconds: 40),
              curve: Curves.easeInOut,
            );
          }

          // Notify parent with the correct index
          if (widget.onPageChanged != null) {
            int actualIndex;
            if (currentPage == 0) {
              actualIndex = widget.originalAuthorList.length - 1;
            } else if (currentPage == authorList.length - 1) {
              actualIndex = 0;
            } else {
              actualIndex = currentPage - 1;
            }

            widget.onPageChanged!(actualIndex);
          }
        },
        itemBuilder: (context, index) {
          final author = authorList[index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double value = _controller.position.haveDimensions
                  ? _controller.page! - index
                  : 0.0;

              value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);

              return Transform.scale(
                scale: value,
                child: buildImageWithText(
                  context,
                  author,
                  217,
                  143,
                  isAuthor: widget.isAuthor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}



// class AnimatedBookCarousel extends StatelessWidget {
//   final List<Map<String, dynamic>> originalAuthorList;
//   final bool isAuthor;
//   final PageController? pageController;
//   final Function(int)? onPageChanged;
//
//   AnimatedBookCarousel({
//     Key? key,
//     required this.originalAuthorList,
//     this.isAuthor = false,
//     this.pageController,
//     this.onPageChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var authorList = [
//       originalAuthorList.last,
//       ...originalAuthorList,
//       originalAuthorList.first,
//     ];
//     if (authorList.isEmpty) {
//       return const Center(child: Text('No authors found.'));
//     }
//
//     final PageController effectiveController = pageController ??
//         PageController(viewportFraction: 0.38, initialPage: 1);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (effectiveController.hasClients) {
//         effectiveController.jumpToPage(1);
//       }
//     });
//
//
//     // final PageController effectiveController = pageController ??
//     //     PageController(viewportFraction: 0.38, initialPage: 1);
//     //
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   if (effectiveController.hasClients) {
//     //     effectiveController.jumpToPage(1);
//     //   }
//     // });
//
//     return SizedBox(
//       height: 220,
//       child: PageView.builder(
//         controller: effectiveController,
//         physics: BouncingScrollPhysics(),
//         itemCount: authorList.length,
//         // onPageChanged: onPageChanged,
//         onPageChanged: (int currentPage) async {
//           if (currentPage == 0) {
//             await effectiveController.animateToPage(
//               authorList.length - 2,
//               duration: Duration(milliseconds: 40),
//               curve: Curves.easeInOut,
//             );
//           } else if (currentPage == authorList.length - 1) {
//             await effectiveController.animateToPage(
//               1,
//               duration: Duration(milliseconds: 40),
//               curve: Curves.easeInOut,
//             );
//           }
//           if (onPageChanged != null) {
//             int actualIndex;
//             if (currentPage == 0) {
//               actualIndex = originalAuthorList.length - 1;
//             } else if (currentPage == authorList.length - 1) {
//               actualIndex = 0;
//             } else {
//               actualIndex = currentPage - 1;
//             }
//             onPageChanged!(actualIndex);
//           }
//         },
//         itemBuilder: (context, index) {
//           final author = authorList[index];
//
//           return AnimatedBuilder(
//             animation: effectiveController,
//             builder: (context, child) {
//               double value = effectiveController.position.haveDimensions
//                   ? effectiveController.page! - index
//                   : 0.0;
//
//               value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
//
//               return Transform.scale(
//                 scale: value,
//                 child: buildImageWithText(
//                   context,
//                   author,
//                   217,
//                   143,
//                   isAuthor: isAuthor,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
