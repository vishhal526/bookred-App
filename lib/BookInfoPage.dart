import 'package:bookred/All_API_List/call_book_api.dart';
import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/AuthorInfoPage.dart';
import 'package:bookred/BookCommentsTab.dart';
import 'package:bookred/BookDetailTab.dart';
import 'package:bookred/BookSummaryTab.dart';
import 'package:bookred/reuseable_methods/shimmer_loader.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/material.dart';

class BookInfoPage extends StatefulWidget {
  final String id;
  final String name;
  final String author;
  final String img;

  const BookInfoPage(
      {Key? key,
      required this.id,
      required this.img,
      required this.name,
      required this.author})
      : super(key: key);

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage>
    with SingleTickerProviderStateMixin {
  final BookService bookService = BookService();
  final User_Service userService = User_Service();

  late bool isLiked = false;
  bool isbookmark = false;
  late bool isDisliked = false;
  late bool isLoading = true;
  bool isProcessingLike = false;
  bool? isread;
  Map<String, dynamic>? bookData;
  Color? shadowColor;

  late TabController _tabController;
  int _currentIndex = 0;

  Future<void> getShadowColor(String image) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(image));
    setState(() {
      shadowColor = paletteGenerator.dominantColor?.color ?? Colors.transparent;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    getShadowColor(widget.img);
    fetchBookData();
  }

  Future<void> fetchBookData() async {
    try {
      final response = await bookService.bookById(widget.id);

      if (response != null && mounted) {
        final book = response['book'] ?? {};
        // final image = book['image']?.toString() ?? '';

        setState(() {
          bookData = Map<String, dynamic>.from(book);
          isLiked = response['isLiked'] ?? false;
          isDisliked = response['isDisliked'] ?? false;
          isbookmark = response['isbookmarked'];
          isread = response['isread'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching book data: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> toggleLike() async {
    if (bookData == null) return;

    final likedata = await bookService.likeBook(widget.id, !isLiked);
    if (likedata != null && mounted) {
      setState(() {
        bookData!['like'] = likedata['like'] ?? bookData!['like'];
        bookData!['dislike'] = likedata['dislike'] ?? bookData!['dislike'];
        isLiked = !isLiked;
        if (isLiked) isDisliked = false;
      });
    }
  }

  Future<void> toggleDislike() async {
    if (bookData == null) return;

    final dislikeData = await bookService.dislikeBook(widget.id, !isDisliked);
    if (dislikeData != null && mounted) {
      setState(() {
        bookData!['dislike'] = dislikeData['dislike'] ?? bookData!['dislike'];
        bookData!['like'] = dislikeData['like'] ?? bookData!['like'];
        isDisliked = !isDisliked;
        if (isDisliked) isLiked = false;
      });
    }
  }

  Future<void> updatebookmark(bool isBookmarked) async {
    bool response = await bookService.AddToBookmark(widget.id, isBookmarked);

    setState(() {
      isbookmark = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Loading variable = $isLoading");
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 19.0,),
            child: GestureDetector(
              onTap: () {
                updatebookmark(isbookmark);
              },
              child: isbookmark
                  ? Icon(
                      Icons.bookmark,
                      color: Color(0xFFD0312D),
                      size: 25,
                    )
                  : Icon(
                      Icons.bookmark_border,
                      size: 25,
                    ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          isLoading
              ? buildLoadingShimmer()
              : bookData != null
                  ? buildBookInfo()
                  : const Center(child: Text('No book data found.')),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: PreferredSize(
              preferredSize: const Size.fromHeight(45.0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Summary"),
                  Tab(text: "Details"),
                  Tab(text: "Reviews"),
                ],
                labelColor: Colors.black,
                labelStyle:
                    const TextStyle(fontFamily: "Poppins", fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
              ),
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
                : bookData != null
                    ? IndexedStack(
                        index: _currentIndex,
                        children: [
                          bookData!['synopsis'] != null
                              ? BookSummaryTab(
                                  bookId: widget.id,
                                  isread: isread!,
                                  summary: bookData!['synopsis'])
                              : const Center(
                                  child: Text('No summary available.')),
                          BookDetailTab(
                            isbn: bookData!['isbn'] ?? '',
                            language: bookData!['language'] ?? '',
                            pages: bookData!['pages'] ?? 0,
                            position: bookData!['series']?['position'] ?? 'N/A',
                            publicationDate: bookData!['publicationDate'] ?? '',
                            publisher: bookData!['publisher'] ?? '',
                            rating: bookData!['rating']?['average'] ?? 0.0,
                            seriesName: bookData!['series']?['name'] ?? '',
                            translator: (bookData!['translators'] is List &&
                                    bookData!['translators'].isNotEmpty)
                                ? bookData!['translators'][0]['name'].toString()
                                : 'N/A',
                          ),
                          BookCommentsTab(bookId: widget.id),
                        ],
                      )
                    : const Center(child: Text('No book data found.')),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 19.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(height: 230.0, width: 155.0, isCircular: false),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget buildBookInfo() {
    final likes = bookData!['like'] ?? 0;
    final dislikes = bookData!['dislike'] ?? 0;
    final genre =
        (bookData!['genre'] as List?)?.map((g) => g.toString()).toList() ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Book Image
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: (shadowColor ?? Colors.transparent).withAlpha(100),
                  blurRadius: 15.0,
                  spreadRadius: -30,
                  offset: const Offset(0, 50),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.img.isNotEmpty
                    ? widget.img
                    : 'https://via.placeholder.com/90x120',
                height: 230.0,
                width: 155.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 230.0,
                  width: 155.0,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          //Book Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Book Genre
                if (genre.isNotEmpty)
                  SizedBox(
                    height: 27,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: genre.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2.5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 5),

                //Book Name
                Text(
                  widget.name.isNotEmpty ? widget.name : 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                //Book Author
                Row(
                  children: [
                    Text(
                      widget.author.isNotEmpty ? widget.author : 'Unknowm',
                      style:
                          const TextStyle(fontSize: 15, fontFamily: "Poppins"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthorInfopage(
                                      authorId: bookData!["authors"][0]
                                          ["id"])));
                        },
                        child: Icon(
                          Icons.info,
                          color: Color(0xFF1A1D32),
                        )
                        // Text("$"),
                        )
                  ],
                ),
                const SizedBox(height: 15),

                //Like button
                buildLikeDislikeRow(
                  icon: isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  label: "$likes Likes",
                  isActive: isLiked,
                  onTap: toggleLike,
                ),
                const SizedBox(height: 10),

                //Dislike Button
                buildLikeDislikeRow(
                  icon: isDisliked
                      ? Icons.thumb_down
                      : Icons.thumb_down_alt_outlined,
                  label: "$dislikes Dislikes",
                  isActive: isDisliked,
                  onTap: toggleDislike,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLikeDislikeRow({
    required IconData icon,
    required String label,
    required bool isActive,
    required Future<void> Function() onTap, // ✅ Correct type
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: isProcessingLike
              ? null
              : () async {
                  setState(() => isProcessingLike = true);
                  await onTap(); // ✅ No error now
                  setState(() => isProcessingLike = false);
                },
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF1A1D32) : null,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 15, fontFamily: "Poppins")),
      ],
    );
  }
}
