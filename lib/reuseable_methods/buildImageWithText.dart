import 'dart:ui' as ui;
import 'package:bookred/AuthorInfoPage.dart';
import 'package:bookred/BookInfoPage.dart';
import 'package:bookred/LibraryPage.dart';
import 'package:flutter/material.dart';

Widget buildImageWithText(BuildContext context, Map<String, dynamic> bookdata,
    double height, double width,
    {bool IsGrid = false, bool isAuthor = false}) {
  final GlobalKey<LibraryPageState> libPageKey = GlobalKey<LibraryPageState>();
  String imageUrl = bookdata['image'] ??
      "https://via.placeholder.com/150"; // Default empty string if null
  String name =
      isAuthor ? bookdata["name"] : bookdata['bookname'] ?? 'Unknown Book';
  String author = isAuthor ? "" : bookdata['author'];

  return Stack(
    children: [
      GestureDetector(
        onTap: () {
          print(
              "Book Name = $name Image Link = $imageUrl Author Name = $author");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => isAuthor
                    ? AuthorInfopage(
                        authorId: bookdata["_id"],
                      )
                    : BookInfoPage(
                        id: bookdata['_id'],
                        img: imageUrl,
                        name: name,
                        author: author)),
          );
        },
        child: Container(
          height: height, // Set height conditionally for grid
          width: width, // Set width conditionally for grid
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  height: height,
                  width: width,
                  fit: BoxFit
                      .cover, // Ensures the image covers the area correctly
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 3),
                    child: Container(
                      width: width, // Matches the width of the parent container
                      color: Colors.black38, // Semi-transparent overlay
                      padding: EdgeInsets.all(12), // Padding for text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name, // Book name
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins", // Custom font
                            ),
                          ),
                          Text(
                            author, // Author name
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: "Poppins", // Custom font
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}
