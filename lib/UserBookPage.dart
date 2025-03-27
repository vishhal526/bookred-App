import 'package:bookred/All_API_List/API_constants.dart';
import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/BookInfoPage.dart';
import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserBookPage extends StatefulWidget {
  final int bookdata;

  const UserBookPage({
    Key? key,
    required this.bookdata,
  }) : super(key: key);

  @override
  State<UserBookPage> createState() => _UserBookPageState();
}

class _UserBookPageState extends State<UserBookPage> {
  ApiConstants api = ApiConstants();
  User_Service user = User_Service();

  late Future<List<Map<String, dynamic>>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = getLikedBooks();
  }

  Future<List<Map<String, dynamic>>> getLikedBooks() async {
    String? userid = await api.getUserIdFromPrefs();
    var response = await widget.bookdata == 1 ? user.GetLikedBooks(userid!) : widget.bookdata == 2 ? user.GetBookmarkedBooks(userid!) : user.GetReadBooks(userid!);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(19.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65, // Adjust height/width ratio
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  var book = books[index];

                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookInfoPage(
                                    id: books[index]["_id"],
                                    img: books[index]["image"],
                                    name: books[index]["bookname"],
                                    author: books[index]["author"])));
                      },
                      child: buildImageWithText(context, book, 300, 160));
                },
              );
            },
          ),
        ));
  }

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
