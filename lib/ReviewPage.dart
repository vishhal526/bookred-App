import 'package:bookred/AuthorPage.dart';
import 'package:bookred/GenrePage.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int ?_currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose of the controller when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
          child: PreferredSize(
            preferredSize: const Size.fromHeight(45.0),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Genre"),
                Tab(text: "Author"),
              ],
              labelColor: Colors.black,
              labelStyle: const TextStyle(fontFamily: "Poppins", fontSize: 14),
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              GenrePage(),
              Authorpage(),
            ],
          ),
        ),
      ],
    ));
    //     Column(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.only(left: 20, right: 20,bottom: 25),
    //       child: PreferredSize(
    //         preferredSize: Size.fromHeight(45.0),
    //         // Set a height for the TabBar
    //         child: TabBar(
    //           controller: _tabController,
    //           tabs: [
    //             Tab(text: "Genre"),
    //             Tab(text: "Author"),
    //           ],
    //           labelColor: Colors.black,
    //           labelStyle: TextStyle(fontFamily: "Poppins", fontSize: 14),
    //           indicatorSize: TabBarIndicatorSize.tab,
    //           unselectedLabelColor: Colors.grey,
    //           indicatorColor: Colors.black,
    //         ),
    //       ),
    //     ),
    //     Expanded(
    //       child: TabBarView(
    //         controller: _tabController, // Pass the controller here
    //         children: [
    //           GenrePage(),
    //           Center(
    //             child: Text("Author data"),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // ));
  }
}
