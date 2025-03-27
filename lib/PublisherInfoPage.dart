import 'package:bookred/All_API_List/call_author_api.dart';
import 'package:bookred/All_API_List/call_publisher_api.dart';
import 'package:bookred/AuthorAboutTab.dart';
import 'package:bookred/AuthorBookTab.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublisherInfopage extends StatefulWidget {
  final String publisherId;

  const PublisherInfopage({
    Key? key,
    required this.publisherId,
  }) : super(key: key);

  @override
  State<PublisherInfopage> createState() => _PublisherInfopageState();
}

class _PublisherInfopageState extends State<PublisherInfopage>
    with SingleTickerProviderStateMixin {
  PublisherService publisher = PublisherService();

  late TabController _tabController;

  Map<String, dynamic>? publisherData;

  bool isLoading = true;

  int _currentIndex = 0;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    getPublisherData();
  }

  void getPublisherData() async {
    var response = await publisher.PublisherById(widget.publisherId);
    print('Publisher response: $response');

    setState(() {
      publisherData = response;
      isLoading = false;
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
                          publisherData!["logo"],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //publisher Name
                            Text(
                              publisherData!["name"],
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600),
                            ),

                            SizedBox(
                              height: 20,
                            ),

                            //Follower count
                            Text(
                              "Country - ${publisherData!["country"]}",
                              maxLines: 2,
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
                              "${publisherData!["listedbooks"]} Listed Books",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Poppins",
                              ),
                            ),

                            Text(
                              "Established Year - ${publisherData!["establishedYear"]}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
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
                        publisherData!['description'] != null
                            ? AuthorAboutTab(
                                about: publisherData!['description'])
                            : const Center(
                                child: Text('No summary available.')),
                        AuthorBookTab(
                            Id: publisherData!["_id"], isAuthor: false)
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
