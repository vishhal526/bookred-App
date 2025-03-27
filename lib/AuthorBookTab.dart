import 'package:bookred/All_API_List/call_publisher_api.dart';
import 'package:bookred/BookInfoPage.dart';
import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bookred/All_API_List/call_author_api.dart';

class AuthorBookTab extends StatefulWidget {
  final String Id;
  bool isAuthor = true;

  AuthorBookTab({
    Key? key,
    required this.Id,
    this.isAuthor = true,
  }) : super(key: key);

  @override
  State<AuthorBookTab> createState() => _AuthorBookTabState();
}

class _AuthorBookTabState extends State<AuthorBookTab> {
  AuthorService author = AuthorService();
  PublisherService publisher = PublisherService();

  late Future<List<Map<String, dynamic>>> futureBooks;

  @override
  void initState() {
    super.initState();
    print("Hi there is author = ${widget.isAuthor}");
    futureBooks = getBooksByAuthor(widget.Id);
  }

  Future<List<Map<String, dynamic>>> getBooksByAuthor(String authorId) async {
    var response = await widget.isAuthor! ? author.BookByAuthor(authorId) : publisher.BookByPublisher(authorId);
    print("\nResponse = $response");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show shimmer loader while waiting
          return buildShimmerGrid();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No books found'));
        }

        var books = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two books per row
            mainAxisSpacing: 30.0, // Spacing between rows
            crossAxisSpacing: 50.0,
            childAspectRatio: .65, // Adjust height/width ratio
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            var book = books[index];

            return GestureDetector(
              onTap: () {
                print("\nBook data in Author Data ${books[index]}");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookInfoPage(
                            id: books[index]["_id"],
                            img: books[index]["image"],
                            name: books[index]["bookname"],
                            author: books[index]["author"])));
              },
              child: buildImageWithText(context, book, 245, 160)
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.3),
              //         blurRadius: 6,
              //         offset: Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       // Book Image
              //       Container(
              //         height: 150,
              //         width: double.infinity,
              //         decoration: BoxDecoration(
              //           borderRadius:
              //               BorderRadius.vertical(top: Radius.circular(12)),
              //           image: DecorationImage(
              //             image: NetworkImage(book['image'] ?? ''),
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Text(
              //           book['bookname'] ?? 'Unknown Title',
              //           maxLines: 2,
              //           overflow: TextOverflow.ellipsis,
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            );
          },
        );
      },
    );
  }

  // Shimmer placeholder while loading
  Widget buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: 6, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 10,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
