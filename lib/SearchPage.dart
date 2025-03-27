import 'dart:ui';
import 'package:bookred/All_API_List/call_author_api.dart';
import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:bookred/All_API_List/call_publisher_api.dart';
import 'package:bookred/AuthorInfoPage.dart';
import 'package:bookred/BookInfoPage.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  BookService book = BookService();
  AuthorService author = AuthorService();
  PublisherService publisher = PublisherService();

  TextEditingController? searchText = TextEditingController();

  int searchCategory = 1;
  int hasSearched = 0;

  List<dynamic>? books = [];
  List<dynamic>? authors = [];
  List<dynamic>? publishers = [];
  List<dynamic>? sourceList = [];
  List<dynamic>? filteredList = [];

  @override
  initState() {
    super.initState();
    getSourceList();
  }

  Future<void> getSourceList() async {
    books = await book.fetchallBooks();
    print("\nBook List = $books");
    authors = await author.getAllAuthor();
    publishers = await publisher.getAllPublisher();
    if (searchCategory == 1) {
      setState(() {
        print("Source List is Updated");
        sourceList = books;
      });
      print("Sourcelist = $sourceList");
    } else if (searchCategory == 2) {
      setState(() {
        sourceList = publishers;
      });
    } else if (searchCategory == 3) {
      setState(() {
        sourceList = authors;
      });
    }
  }

  void filterList(String userInput) {
    setState(() {
      hasSearched = 1;
      print("Source List = $sourceList");
      filteredList = sourceList!
          .where((item) => item[searchCategory == 1 ? 'bookname' : 'name']
              .toLowerCase()
              .contains(userInput.toLowerCase()))
          .toList();
    });
    print("Filtered List = $filteredList");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: SafeArea(
          child: Container(
            height: 55,
            // padding: EdgeInsets.only(top: 015,bottom: 15),
            decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
            ),
            child: TextField(
              controller: searchText,
              onChanged: (searchtext) {
                filterList(searchtext.toString());
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                prefixIcon: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            title: Text(
                              "Search Based on",
                              style: TextStyle(fontFamily: "Poppins"),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildOption(context, 'Books', Icons.book, () {
                                  setState(() {
                                    searchCategory = 1;
                                    getSourceList();
                                    hasSearched = 0;
                                  });
                                  Navigator.pop(context);
                                  // Do something for Books
                                  print('Books selected');
                                }),
                                Divider(),
                                _buildOption(
                                    context, 'Publishers', Icons.business, () {
                                  setState(() {
                                    searchCategory = 2;
                                    getSourceList();
                                    hasSearched = 0;
                                  });
                                  Navigator.pop(context);
                                  // Do something for Publishers
                                  print('Publishers selected');
                                }),
                                Divider(),
                                _buildOption(context, 'Authors', Icons.person,
                                    () {
                                  setState(() {
                                    searchCategory = 3;
                                    getSourceList();
                                    hasSearched = 0;
                                  });
                                  Navigator.pop(context);
                                  // Do something for Authors
                                  print('Authors selected');
                                }),
                              ],
                            ),
                          );
                        });
                  },
                  child: Icon(Icons.menu),
                ),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: "Search On BookRed",
                hintStyle: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (hasSearched == 0 || searchText!.text.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Read what you Love",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text("Search for Books, Author, Publisher",
                        style: TextStyle(fontFamily: "Poppins", fontSize: 12))
                  ],
                  // child: Text(
                  //     "\n"),
                ),
              ),
            )
          else if (filteredList == null || filteredList!.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(fontFamily: "Poppins"),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredList!.length,
                itemBuilder: (context, index) {
                  final item = filteredList![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => searchCategory == 1
                                ? BookInfoPage(
                                    id: filteredList![index]["_id"],
                                    img: filteredList![index]["image"],
                                    name: filteredList![index]["bookname"]
                                        as String,
                                    author: filteredList![index]["author"]
                                        as String,
                                  )
                                : searchCategory == 2
                                    ? Container()
                                    : AuthorInfopage(
                                        authorId: filteredList![index]["_id"],)),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundImage: NetworkImage(
                            item[searchCategory != 2 ? 'image' : 'logo']),
                      ),
                      title:
                          Text(item[searchCategory == 1 ? 'bookname' : 'name']),
                      minTileHeight: 70,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(text),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
