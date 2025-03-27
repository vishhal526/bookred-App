import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:flutter/material.dart';

class BookSummaryTab extends StatefulWidget {
  final String summary;
  final String bookId;
  final bool isread;

  const BookSummaryTab(
      {Key? key, required this.summary, required this.isread, required this.bookId})
      : super(key: key);

  @override
  State<BookSummaryTab> createState() => _BookSummaryTabState();
}

class _BookSummaryTabState extends State<BookSummaryTab> {
  BookService book = BookService();
  bool isread = false;

  @override
  void initState() {
    super.initState();
    isread = widget.isread;
  }

  Future<void> AddToReadList(bool isRead) async {
    bool response = await book.AddToReadList(widget.bookId, isRead);
    setState(() {
      isread = response;
    });
  }

  Future<void> refreshData() async {
    setState(() {});
    print("Library Page data refreshed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                // decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 2),borderRadius: BorderRadius.circular(10)),
                child: Text(
                  widget.summary,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  AddToReadList(isread);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  decoration: BoxDecoration(
                      color: isread ? Color(0xFF1A1D32) : Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    isread
                        ? "Added to Read List"
                        : "Have you Read this book",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        color: isread
                            ? Colors.white
                            : Colors.black,
                        fontSize: 17),
                  ),
                ),
              ),
              SizedBox(height: 25 ,)
            ],
          ),
        ));
  }
}
