import 'package:bookred/MainPage.dart';
import 'package:bookred/reuseable_methods/buildImageWithText.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> refreshData() async {
    setState(() {});
    print("Home Page data refreshed");
  }

  final Mainpage mainPage = Mainpage();
  BookService book = BookService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: RefreshIndicator(
        color: Colors.blue, // Customize color
        backgroundColor: Colors.white, // Background behind loader
        strokeWidth: 3, // Thickness of the indicator
        displacement: 80, // Distance from top
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 19.0, right: 19),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Continue reading",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              fontSize: 17)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: SvgPicture.asset(
                          "assets/images/Right_arrow_img.svg"),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                future: book.fetchRecommendedBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 230,
                      child: ShimmerWidget(
                        height: 195.0,
                        isList: true,
                        width: 155,
                        isCircular: false, // Number of items
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    var bookList =
                    List<Map<String, dynamic>>.from(snapshot.data!);
                    if (bookList.isEmpty) {
                      return Container(
                          height: 200,
                          child: Center(child: Text('No books found.')));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bookList.asMap().entries.map((entry) {
                          int index =
                              entry.key; // Get index of the current book
                          var bookItem = entry.value; // Get the book data

                          if (bookItem == null) {
                            return SizedBox.shrink();
                          }

                          // Apply left padding only to the first item
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 19.0 : 7.0,
                              // More padding for the first item
                              right: index == bookList.length - 1
                                  ? 19.0
                                  : 7.0, // Regular padding for the rest
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildImageWithText(
                                    context, bookItem, 233, 155
                                  // bookItem["bookname"],
                                  // bookItem["image"],
                                  // bookItem["auhtor"]
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Container(
                        height: 200,
                        child: Center(child: Text('No books found.')));
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 19.0, right: 19, top: 35, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: Text("Recommendations",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 17))),
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                          "assets/images/Right_arrow_img.svg"),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                future: book.fetchRecommendedBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerWidget(
                      height: 195.0,
                      width: 130.0, // Width for grid items
                      isCircular: false, // Number of items
                      isGrid: true,
                    );
                    // return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    var bookList =
                    List<Map<String, dynamic>>.from(snapshot.data!);
                    if (bookList.isEmpty) {
                      return Center(child: Text('No books found.'));
                    }

                    // Use GridView to display two books per row
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25, bottom: 20),
                      // Adjust padding as needed
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // Prevents scroll conflict with parent
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two books per row
                            mainAxisSpacing:
                            30.0, // Spacing between rows
                            crossAxisSpacing: 50.0,
                            childAspectRatio: .65),
                        itemCount: bookList.length,
                        itemBuilder: (context, index) {
                          var bookItem =
                          bookList[index]; // Get the book data

                          if (bookItem == null) {
                            return SizedBox.shrink();
                          }

                          return buildImageWithText(
                              context, bookItem, 300, 160,
                              IsGrid: true);
                        },
                      ),
                    );
                  } else {
                    return Center(child: Text('No books found.'));
                  }
                },
              ),
            ],
          ),
        ),
      ),

    );
  }
}


