import 'package:bookred/All_API_List/call_author_api.dart';
import 'package:bookred/AuthorAboutTab.dart';
import 'package:bookred/AuthorBookTab.dart';
import 'package:bookred/LibraryPage.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthorInfopage extends StatefulWidget {
  final String authorId;

  const AuthorInfopage({
    Key? key,
    required this.authorId,
  }) : super(key: key);

  @override
  State<AuthorInfopage> createState() => _AuthorInfopageState();
}

class _AuthorInfopageState extends State<AuthorInfopage>
    with SingleTickerProviderStateMixin {
  AuthorService author = AuthorService();
  final GlobalKey<LibraryPageState> lib = GlobalKey<LibraryPageState>();

  late TabController _tabController;

  Map<String, dynamic>? authorData;

  bool isLoading = true;
  bool isFollowed = false;

  int _currentIndex = 0;
  int? followers;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    getAuthorData();
  }

  void getAuthorData() async {
    var response = await author.AuthorById(widget.authorId);
    setState(() {
      authorData = response;
      followers = authorData!["follower"];
      isFollowed = authorData!["isfollowed"];
      isLoading = false;
    });
  }

  void updatefollowing(int follower, bool isfollowed, String authorID) async {
    int updatedvalue =
        await author.FollowAuthor(authorID, isfollowed, follower);
    setState(() {
      followers = updatedvalue;
      isFollowed = !isFollowed;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(19),
        child: Column(
          children: [
            isLoading
                ? buildLoadingShimmer()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        maxRadius: 75,
                        backgroundImage: NetworkImage(
                          authorData!["image"],
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Author Name
                          Text(
                            authorData!["name"],
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600),
                          ),

                          //Author Actual Name
                          authorData!["actualName"] != null
                              ? Text(
                                  authorData!["actualName"],
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600),
                                )
                              : Container(),

                          SizedBox(
                            height: 20,
                          ),

                          //Follower count
                          Text(
                            "$followers Followers",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Poppins",
                            ),
                          ),

                          SizedBox(
                            height: 5,
                          ),

                          //BookList count
                          Text(
                            "${authorData!["listedbooks"]} Listed Books",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Poppins",
                            ),
                          ),

                          GestureDetector(
                              onTap: () {
                                updatefollowing(followers!, isFollowed,
                                    authorData!["_id"].toString());
                                lib.currentState?.RefreshLibPage();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 12),
                                decoration: BoxDecoration(
                                    color: isFollowed
                                        ? Color(0xFF1A1D32)
                                        : Colors.white,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  isFollowed ? "Following " : "Follow",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isFollowed
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
            PreferredSize(
              preferredSize: const Size.fromHeight(45.0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "About"),
                  Tab(text: "Listed Books"),
                ],
                labelColor: Colors.black,
                labelStyle:
                    const TextStyle(fontFamily: "Poppins", fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.grey,
                      ),
                    )
                  : IndexedStack(
                      index: _currentIndex,
                      children: [
                        authorData!['about'] != null
                            ? AuthorAboutTab(about: authorData!['about'])
                            : const Center(
                                child: Text('No summary available.')),
                        AuthorBookTab(Id: authorData!["_id"])
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadingShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShimmerWidget(height: 230.0, width: 155.0, isCircular: true),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            children: [
              ShimmerWidget(
                  height: 25.0, width: double.infinity, isCircular: false),
              const SizedBox(height: 10),
              ShimmerWidget(
                  height: 25.0, width: double.infinity, isCircular: false),
            ],
          ),
        ),
      ],
    );
  }
}
