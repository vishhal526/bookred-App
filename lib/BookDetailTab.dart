import 'package:bookred/PublisherInfoPage.dart';
import 'package:flutter/material.dart';

class BookDetailTab extends StatefulWidget {
  final String? translator;
  final int rating;
  final String publicationDate;
  final String language;
  final String seriesName;
  final int position;
  final List publisher;
  final int pages;
  final String isbn;

  const BookDetailTab(
      {Key? key,
      required this.rating,
      required this.translator,
      required this.isbn,
      required this.language,
      required this.pages,
      required this.position,
      required this.publicationDate,
      required this.publisher,
      required this.seriesName})
      : super(key: key);

  @override
  State<BookDetailTab> createState() => _BookDetailTabState();
}

class _BookDetailTabState extends State<BookDetailTab> {
  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(widget.publicationDate);
    String formattedDate =
        "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(19.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              List(name: "Series Name", data: widget.seriesName),
              Divider(),
              List(name: "Book Part", data: widget.position.toString()),
              Divider(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Publishers:",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                    ),
                    SizedBox(height: 10),

                    // Loop through publishers and create a Text widget for each
                    ...widget.publisher.map<Widget>((pub) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        // spacing between names
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                pub["name"],
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PublisherInfopage(
                                                  publisherId: pub["id"])));
                                },
                                child: Icon(
                                  Icons.info,
                                  color: Color(0xFF1A1D32),
                                )
                                // Text("$"),
                                )
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Divider(),
              List(name: "Language", data: widget.language),
              Divider(),
              List(name: "Pages", data: widget.pages.toString()),
              Divider(),
              List(name: "ISBN Number", data: widget.isbn),
              Divider(),
              List(name: "Publication Date", data: formattedDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget List({required String name, required String data}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$name:",
            style: TextStyle(fontFamily: "Poppins", fontSize: 12),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            data,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}
