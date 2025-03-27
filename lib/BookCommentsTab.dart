import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:flutter/material.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';

class BookCommentsTab extends StatefulWidget {
  final String bookId;

  const BookCommentsTab({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  State<BookCommentsTab> createState() => _BookCommentsTabState();
}

class _BookCommentsTabState extends State<BookCommentsTab> {
  TextEditingController commentController = TextEditingController();
  BookService bookService = BookService();

  List<dynamic>? comments;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() => isLoading = false);

    comments = await bookService.GetComments(widget.bookId);

    print("\nComment $comments");

    setState(() => isLoading = false);
  }

  void sendComment() async {
    print("Comment function got = ${commentController.text}");

    if (commentController.text.trim().isEmpty) return;

    print("went to add comment function");

    bool response =
        await bookService.AddComments(widget.bookId, commentController.text);

    print("\nResponse from the add comment is $response");

    if (response) {
      commentController.clear();
      fetchComments();
    } else {
      print("Error: $response");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? ShimmerLoaderList()
                // Center(
                //         child: CircularProgressIndicator(
                //           strokeWidth: 2,
                //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //           backgroundColor: Colors.grey,
                //         ),
                //       )
                : comments == null || comments!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Be the First to comment on this Book",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              // physics: NeverScrollableScrollPhysics(),
                              itemCount: comments!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: comments![index]['user'] != null &&
                                          comments![index]['user']
                                                  ['profilePicture'] !=
                                              null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              comments![index]['user']
                                                  ['profilePicture']),
                                        )
                                      : CircleAvatar(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.black,
                                          ), // Default icon when no profile picture
                                        ),
                                  title: Text(comments![index]['comment']),
                                  subtitle: Text(
                                      "By ${comments![index]['user'] != null ? comments![index]['user']['username'] : 'Unknown User'}"),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 19),
            child: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Enter your Comment",
                hintStyle: TextStyle(
                    fontSize: 15, fontFamily: "Poppins", color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 0.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // commentController.text = '';
                    sendComment();
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ShimmerLoaderList() {
    return Column(
      children: List.generate(10, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              ShimmerWidget(height: 20.0, width: 15.0, isCircular: true),
              const SizedBox(width: 10.0), // spacing between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      height: 10.0,
                      width: double.infinity,
                      isCircular: false,
                    ),
                    const SizedBox(height: 5.0),
                    ShimmerWidget(
                      height: 10.0,
                      width: double.infinity,
                      isCircular: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
