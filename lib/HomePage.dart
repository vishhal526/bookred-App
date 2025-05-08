import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/SearchPage.dart';
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

  BookService book = BookService();
  User_Service user = User_Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: RefreshIndicator(
        color: Colors.blue,
        // Customize color
        backgroundColor: Colors.white,
        // Background behind loader
        strokeWidth: 3,
        // Thickness of the indicator
        displacement: 80,
        // Distance from top
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              //Continue Reading Text
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
                      child:
                          SvgPicture.asset("assets/images/Right_arrow_img.svg"),
                    )
                  ],
                ),
              ),

              //Continue Reading Book Data
              FutureBuilder(
                future: user.GetCurrentlyReadingBook(),
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
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19.0),
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    var bookdata = Map<String, dynamic>.from(snapshot.data!);
                    if (bookdata["currentlyReading"] == null) {
                      return Container(
                          padding: EdgeInsets.symmetric(horizontal: 19),
                          // height: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  height: 230,
                                  width: 155,
                                  color: Colors.black26,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPage()));
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Text(
                                "Currently You are not Reading any book",
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 25, fontFamily: "Poppins"),
                              ))
                            ],
                          ));
                    }
                    return Container(
                      child: Text("data"),
                    );
                  } else {
                    return Container(
                        height: 200,
                        child: Center(child: Text('No books found.')));
                  }
                },
              ),

              //Recommandation Text
              Padding(
                padding:
                    EdgeInsets.only(left: 19.0, right: 19, top: 35, bottom: 15),
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
                      child:
                          SvgPicture.asset("assets/images/Right_arrow_img.svg"),
                    )
                  ],
                ),
              ),

              //Recommandation Book Data
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
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25, bottom: 20),
                      // Adjust padding as needed
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // Prevents scroll conflict with parent
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two books per row
                            mainAxisSpacing: 30.0, // Spacing between rows
                            crossAxisSpacing: 50.0,
                            childAspectRatio: .65),
                        itemCount: bookList.length,
                        itemBuilder: (context, index) {
                          var bookItem = bookList[index]; // Get the book data

                          if (bookItem == null) {
                            return SizedBox.shrink();
                          }

                          return buildImageWithText(context, bookItem, 300, 160,
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
