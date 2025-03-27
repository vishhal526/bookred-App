import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/AuthorInfoPage.dart';
import 'package:bookred/UserBookPage.dart';
import 'package:bookred/reuseable_methods/FollowProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  User_Service user = User_Service();

  void RefreshLibPage() {
    getFollowedAuthor();
  }

  List<dynamic> libData = [
    {
      "_id": "1",
      "name": "Like Book",
      "image": Icon(
        Icons.favorite,
        color: Color(0xFFD0312D),
      )
    },
    {
      "_id": "2",
      "name": "BookMark",
      "image": Icon(
        Icons.bookmark,
        color: Color(0xFFD0312D),
      )
    },
    {
      "_id": "3",
      "name": "Read Books",
      "image": Icon(
        Icons.book,
        color: Color(0xFFD0312D),
      )
    },
  ];
  List<dynamic>? authorData = [];

  @override
  initState() {
    super.initState();
    getFollowedAuthor();
  }

  Future<void> getFollowedAuthor() async {
    var response = await user.GetFollowedAuthor();
    setState(() {
      authorData!.addAll(response);
    });
    print("Lib Data = ${libData}");
  }

  @override
  Widget build(BuildContext context) {
    final followProvider = Provider.of<FollowProvider>(context);

    if (followProvider.needsRefresh) {
      Future.microtask(() {
        RefreshLibPage();
        followProvider.reset();
      });
    }
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ✅ Align text to the left
        children: [
          Expanded(
            flex: 1,
            child: GridView.builder(
              shrinkWrap: true,
              // ✅ Allow GridView to only take needed space
              physics: NeverScrollableScrollPhysics(),
              // ✅ Prevent nested scrolling issue
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10, // ✅ Add spacing for better UI
                mainAxisSpacing: 10,
              ),
              itemCount: libData.length,
              itemBuilder: (context, index) {
                return buildLibData(libData[index]);
              },
            ),
          ),
          SizedBox(height: 20), // ✅ Keep spacing between GridView and Text
          Text(
            "Followed Author",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          Expanded(
            flex: 6,
            child: GridView.builder(
              shrinkWrap: true,
              // ✅ Allow GridView to only take needed space
              physics: NeverScrollableScrollPhysics(),
              // ✅ Prevent nested scrolling issue
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10, // ✅ Add spacing for better UI
                mainAxisSpacing: 10,
              ),
              itemCount: authorData!.length,
              itemBuilder: (context, index) {
                return buildLibData(authorData![index]);
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget buildLibData(Map<String, dynamic> libData) {
    Widget imageWidget;

    if (libData['image'] is Icon) {
      imageWidget = libData['image'];
    } else if (libData['image'] is String) {
      imageWidget = Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            libData['image'],
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      imageWidget = const SizedBox(); // Fallback in case it's neither
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => libData["_id"] == "1"
                    ? UserBookPage(bookdata: 1)
                    : libData["_id"] == "2"
                        ? UserBookPage(bookdata: 2)
                        : libData["_id"] == "3"
                            ? UserBookPage(bookdata: 3)
                            : AuthorInfopage(authorId: libData["_id"])));
      },
      child: Container(
        height: 100,
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageWidget,
            SizedBox(
                height: (libData['_id'] == "1" ||
                        libData['_id'] == "2" ||
                        libData['_id'] == "3")
                    ? 15
                    : 10),
            Text(libData['name']),
          ],
        ),
      ),
    );
  }
}
