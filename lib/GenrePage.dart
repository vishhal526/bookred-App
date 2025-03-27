import 'package:bookred/reuseable_methods/animated_book_carousel.dart';
import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:bookred/reuseable_methods/buildScrolltext.dart';
import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:bookred/All_API_List/call_genre_api.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:flutter/material.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({super.key});

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final BookService book = BookService();
  final Genre_Call genre = Genre_Call();
  final PageController _pageController = PageController(viewportFraction: 0.3);

  String? selectedGenreId;
  Future<List<dynamic>>? recommendedBooksFuture;
  Future<List<dynamic>>? fetchGenreFuture;

  @override
  void initState() {
    super.initState();
    recommendedBooksFuture = book.fetchRecommendedBooks();
    fetchGenreFuture = genre.fetchGenre();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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

            // Recommended Books
            FutureBuilder<List<dynamic>>(
              future: recommendedBooksFuture, // Use the cached future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 230,
                    child: ShimmerWidget(
                      height: 195.0,
                      width: 155,
                      isCircular: false,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  var originalBookList =
                      List<Map<String, dynamic>>.from(snapshot.data!);
                  return AnimatedBookCarousel(
                      originalBookList: originalBookList);
                }
                return const Center(child: Text('No books found.'));
              },
            ),

            FutureBuilder(
              future: fetchGenreFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                        height: 35,
                        child: ShimmerWidget(
                          height: 30.0,
                          width: 100,
                          isCircular: false, // Number of items
                        )),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  var genres = List<Map<String, dynamic>>.from(snapshot.data!);

                  // Initialize selectedGenreId directly if it's null and genres are available
                  selectedGenreId ??=
                      genres.isNotEmpty ? genres[0]["_id"] : null;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.0),
                      child: Row(
                        children: genres.map((genreItem) {
                          String name = genreItem["name"] ?? "Unknown Genre";
                          String id = genreItem["_id"];

                          // Check if this genre is selected
                          bool isSelected = selectedGenreId == id;

                          // Determine colors based on selection
                          Color backgroundColor =
                              isSelected ? Colors.black : Colors.transparent;
                          Color textColor =
                              isSelected ? Colors.white : Colors.grey;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGenreId =
                                    id; // Update selected genre ID
                              });
                            },
                            child: buildScrolltext(
                                name, backgroundColor, textColor),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No genre found.'));
              },
            ),
            FutureBuilder(
              future: selectedGenreId != null
                  ? genre.fetchBooksByGenre(selectedGenreId!)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error fetching books: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  var bookList =
                      List<Map<String, dynamic>>.from(snapshot.data!);
                  if (bookList.isEmpty) {
                    return const Center(child: Text('No books found.'));
                  }

                  // Display books in a GridView
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 25.0,
                        crossAxisSpacing: 50.0,
                        childAspectRatio: 130 / 200,
                      ),
                      itemCount: bookList.length,
                      itemBuilder: (context, index) {
                        var bookItem = bookList[index];
                        if (bookItem == null) {
                          return const SizedBox.shrink();
                        }
                        return buildImageWithText(
                            context,
                            bookItem,
                            300,
                            155
                            // bookItem["bookname"],
                            // bookItem["image"],
                            // bookItem["auhtor"]
                        );
                      },
                    ),
                  );
                }
                return const Center(child: Text('No books found.'));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
//
// class GenrePage extends StatefulWidget {
//   const GenrePage({super.key});
//
//   @override
//   State<GenrePage> createState() => _GenrePageState();
// }
//
// class _GenrePageState extends State<GenrePage> {
//   BookService book = BookService();
//   String? selectedGenreId; // Store the ID of the selected genre
//   List<Map<String, dynamic>>? genreList; // Store fetched genres
//   final PageController _pageController = PageController(viewportFraction: 0.3);
//   Genre_Call genre = Genre_Call();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchGenres(); // Fetch genres once when initializing
//   }
//
//   Future<void> fetchGenres() async {
//     try {
//       print("Trying");
//       final fetchedGenres = await genre.fetchGenre();
//       setState(() {
//         genreList = List<Map<String, dynamic>>.from(fetchedGenres);
//         if (genreList!.isNotEmpty) {
//           selectedGenreId = genreList![0]
//               ["_id"]; // Assuming each genre has an ID field named "_id"
//         }
//         print("Genre List updated");
//       });
//     } catch (error) {
//       print("Error fetching genres: $error");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.only(bottom: 15, left: 20),
//               child: Text(
//                 "Most Reviewed",
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontFamily: "Poppins",
//                     fontSize: 17),
//               ),
//             ),
//             FutureBuilder<List<dynamic>>(
//               future: book.fetchRecommendedBooks(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return SizedBox(
//                     height: 230,
//                     child: ShimmerListView(
//                       height: 195.0,
//                       width: 155,
//                       isCircular: false,
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }
//                 if (snapshot.hasData && snapshot.data != null) {
//                   var originalBookList =
//                       List<Map<String, dynamic>>.from(snapshot.data!);
//                   return AnimatedBookCarousel(
//                       originalBookList: originalBookList);
//                 }
//                 return Center(child: Text('No books found.'));
//               },
//             ),
//             if (genreList != null && genreList!.isNotEmpty) ...[
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: genreList!.asMap().entries.map((entry) {
//                     int index = entry.key;
//                     var genreItem = entry.value;
//                     String name = genreItem["name"] ??
//                         "Unknown Genre"; // Provide default value
//                     String id =
//                         genreItem["_id"]; // Assuming each genre has an ID
//
//                     // Determine background color based on selection
//                     Color backgroundColor = selectedGenreId == id
//                         ? Colors.black
//                         : Colors.transparent;
//                     Color textColor =
//                         selectedGenreId == id ? Colors.white : Colors.black;
//
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedGenreId = id; // Update selected genre ID
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20.0),
//                         color: backgroundColor,
//                         child: Text(
//                           name,
//                           style: TextStyle(color: textColor),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ] else
//               Center(
//                 child: Text("No Genre List found"),
//               ),
//             FutureBuilder(
//               future: selectedGenreId != null
//                   ? genre.fetchBooksByGenre(selectedGenreId!)
//                   : Future.value([]),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return ShimmerListView(
//                     height: 195.0,
//                     width: 130.0, // Width for grid items
//                     isCircular: false, // Number of items
//                     isGrid: true,
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (snapshot.hasData && snapshot.data != null) {
//                   var bookList =
//                       List<Map<String, dynamic>>.from(snapshot.data!);
//                   if (bookList.isEmpty) {
//                     return Center(child: Text('No books found.'));
//                   }
//
//                   // Use GridView to display two books per row
//                   return Padding(
//                     padding: EdgeInsets.only(left: 25.0, right: 25, bottom: 20),
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 25.0,
//                         crossAxisSpacing: 50.0,
//                         childAspectRatio: 130 / 200,
//                       ),
//                       itemCount: bookList.length,
//                       itemBuilder: (context, index) {
//                         var bookItem = bookList[index];
//                         if (bookItem == null) {
//                           return SizedBox.shrink();
//                         }
//                         return buildImageWithText(bookItem, 300, 155);
//                       },
//                     ),
//                   );
//                 } else {
//                   return Center(child: Text('No books found.'));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
//
// class GenrePage extends StatefulWidget {
//   const GenrePage({super.key});
//
//   @override
//   State<GenrePage> createState() => _GenrePageState();
// }
//
// class _GenrePageState extends State<GenrePage> {
//   BookService book = BookService();
//   int? selectedGenreId; // Store the ID of the selected genre
//   List<Map<String, dynamic>>? genreList;
//   final PageController _pageController = PageController(viewportFraction: 0.3);
//   Genre_Call genre = Genre_Call();
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch genres once when initializing
//     genre.fetchGenre();
//   }
//
//   Future<void> fetchGenres() async {
//     try {
//       final fetchedGenres = await genre.fetchGenre();
//       setState(() {
//         genreList = List<Map<String, dynamic>>.from(fetchedGenres);
//         print("genreList updated");
//       });
//     } catch (error) {
//       // Handle error if needed
//       print("Error fetching genres: $error");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.only(bottom: 15, left: 20),
//             child: Text(
//               "Most Reviewd",
//               style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontFamily: "Poppins",
//                   fontSize: 17),
//             ),
//           ),
//           FutureBuilder(
//             future: book.fetchRecommendedBooks(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SizedBox(
//                   height: 230,
//                   child: ShimmerListView(
//                     height: 195.0,
//                     width: 155,
//                     isCircular: false, // Number of items
//                   ),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               }
//               if (snapshot.hasError ||
//                   snapshot.data == null ||
//                   snapshot.data!.isEmpty) {
//                 return Center(child: Text("No books found."));
//               }
//
//               var originalBookList =
//                   List<Map<String, dynamic>>.from(snapshot.data!);
//               return AnimatedBookCarousel(
//                 originalBookList: originalBookList,
//               );
//             },
//           ),
//           if (genreList != null && genreList!.isNotEmpty) ...[
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: genreList!.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   var genreItem = entry.value;
//                   String name = genreItem["name"];
//                   int id = genreItem["_id"]; // Assuming each genre has an ID
//
//                   // Determine background color based on selection
//                   Color backgroundColor =
//                       selectedGenreId == id ? Colors.black : Colors.transparent;
//                   Color textColor =
//                       selectedGenreId == id ? Colors.white : Colors.black;
//
//                   return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedGenreId = id; // Update selected genre ID
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20.0),
//                         color: backgroundColor,
//                         child: Text(
//                           name,
//                           style: TextStyle(color: textColor),
//                         ),
//                       ));
//                 }).toList(),
//               ),
//             ),
//           ],
//           // FutureBuilder(
//           //   future: genre.fetchGenre(),
//           //   builder: (context, snapshot) {
//           //     if (snapshot.connectionState == ConnectionState.waiting) {
//           //       return Center(child: CircularProgressIndicator());
//           //     }
//           //     if (snapshot.hasError) {
//           //       return Center(child: Text('Error: ${snapshot.error}'));
//           //     }
//           //     if (snapshot.hasData && snapshot.data != null) {
//           //       var genreList = List<Map<String, dynamic>>.from(snapshot.data!);
//           //       if (genreList.isEmpty) {
//           //         return Center(child: Text('No genres found.'));
//           //       }
//           //
//           //       return SingleChildScrollView(
//           //         scrollDirection: Axis.horizontal,
//           //         child: Row(
//           //           children: genreList.asMap().entries.map((entry) {
//           //             int index = entry.key;
//           //             var genreItem = entry.value;
//           //             String name = genreItem["name"];
//           //             String id = genreItem["_id"]; // Assuming each genre has an ID
//           //
//           //             // Determine background color based on selection
//           //             Color backgroundColor = selectedGenreId == id ? Colors.black : Colors.transparent;
//           //             Color textColor = selectedGenreId == id ? Colors.white : Colors.black;
//           //
//           //             return GestureDetector(
//           //               onTap: () {
//           //                 setState(() {
//           //                   selectedGenreId = id; // Update selected genre ID
//           //                 });
//           //               },
//           //               child: Container(
//           //                 padding: EdgeInsets.symmetric(horizontal: 20.0),
//           //                 color: backgroundColor,
//           //                 child: Text(
//           //                   name,
//           //                   style: TextStyle(color: textColor),
//           //                 ),
//           //               ),
//           //             );
//           //           }).toList(),
//           //         ),
//           //       );
//           //     } else {
//           //       return Center(child: Text('No genres found.'));
//           //     }
//           //   },
//           // ),
//           FutureBuilder(
//             future: selectedGenreId != null
//                 ? genre.fetchBooksByGenre(selectedGenreId!)
//                 : Future.value([]),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//               if (snapshot.hasData && snapshot.data != null) {
//                 var bookList = List<Map<String, dynamic>>.from(snapshot.data!);
//                 if (bookList.isEmpty) {
//                   return Center(child: Text('No books found.'));
//                 }
//
//                 // Use GridView to display two books per row
//                 return Padding(
//                   padding: EdgeInsets.only(left: 25.0, right: 25, bottom: 20),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 25.0,
//                       crossAxisSpacing: 50.0,
//                       childAspectRatio: 130 / 200,
//                     ),
//                     itemCount: bookList.length,
//                     itemBuilder: (context, index) {
//                       var bookItem = bookList[index];
//                       if (bookItem == null) {
//                         return SizedBox.shrink();
//                       }
//                       return buildImageWithText(bookItem, 300, 155);
//                     },
//                   ),
//                 );
//               } else {
//                 return Center(child: Text('No books found.'));
//               }
//             },
//           ),
//         ],
//       ),
//     ));
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }
