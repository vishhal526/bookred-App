import 'package:bookred/AccountInfoPage.dart';
import 'package:bookred/HomePage.dart';
import 'package:bookred/LoginPage.dart';
import 'package:bookred/ReviewPage.dart';
import 'package:bookred/SearchPage.dart';
import 'package:bookred/LibraryPage.dart';
import 'package:flutter/material.dart';
import 'package:bookred/All_API_List/API_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LibraryPageState> libPageKey = GlobalKey<LibraryPageState>();

  ApiConstants apiConstants = ApiConstants();
  late List<Widget> _pages;

  String? username;
  String? userId;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    loadUsername();
    _pages = [
      HomePage(),
      ReviewPage(),
      LibraryPage(
        key: libPageKey,
      ),
    ];
  }

  void loadUsername() async {
    String? fetchedUsername = await apiConstants.getUserNameFromPrefs();
    String? fetchedUserId = await apiConstants.getUserIdFromPrefs();
    String? fetchedUserphoto = await apiConstants.getUserPhotoFromPref();

    if (fetchedUsername! == null || fetchedUserId! == null) {
      print("\nKaha kuch bhai\n");
      logout(context);
    }

    // Now update state synchronously
    setState(() {
      username = fetchedUsername;
      userId = fetchedUserId;
      profilePicture = fetchedUserphoto;
    });
  }

  // Index to track the current page
  int _currentPageIndex = 0;
  int selectedIndex = 0;

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    print("Logout button presesed");

    // Remove user data
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.setBool('isLoggedIn', false);

    // Navigate to LoginPage and replace current route
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        // backgroundColor: Color(0x80FFFCC9), // To make the AppBar transparent
        backgroundColor: Color(0xFFFFFFFF),
        toolbarHeight: 75,
        // Adjust the height to your preference
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6.0,
                      spreadRadius: 3.0,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: SvgPicture.asset(
                        "assets/images/Option_img.svg",
                        width: 25.0,
                        height: 25.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                  child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Search On BookRed",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                      // TextField(
                      //   decoration: InputDecoration(
                      //     contentPadding: EdgeInsets.all(10),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(25),
                      //     ),
                      //     focusedBorder: InputBorder.none,
                      //     enabledBorder: InputBorder.none,
                      //     hintText: "Search On BookRed",
                      //     hintStyle: TextStyle(color: Colors.grey),
                      //   ),
                      // ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          children: [
            Container(
                height: 180,
                padding: EdgeInsets.only(top: 30, left: 10),
                child: Row(
                  children: [
                    (profilePicture != null && profilePicture!.isNotEmpty)
                        ? CircleAvatar(
                            radius: 28, // 🔥 Increased radius (default is 20)
                            backgroundImage: NetworkImage(profilePicture!),
                          )
                        : CircleAvatar(
                            radius: 28, // 🔥 Same increased radius
                            child: Icon(
                              Icons.person,
                              size: 30,
                              // 👈 Icon size should be <= radius for a good fit
                              color: Colors.black,
                            ),
                          ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      username ?? "Kya re bhik mangya",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                size: 30,
              ),
              title: Text(
                'Account Info',
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            account_Infopage(userId: userId)));
                loadUsername();
              },
            ),
            Divider(
              color: Color(0xFFA2A2A2),
            ),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                onTap: () => logout(context)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentPageIndex, // Keep track of the selected index
              children: _pages, // List of pages for each index
            ),
          ),

          // Bottom navigation bar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                // Blurred background
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 85),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                // Menu icons
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 120),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _currentPageIndex = 0;
                            selectedIndex = 0;
                          });
                        },
                        child: SvgPicture.asset(
                          selectedIndex == 0
                              ? "assets/images/Home_dark.svg"
                              : "assets/images/Home_light.svg",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _currentPageIndex = 1;
                            selectedIndex = 1;
                          });
                        },
                        child: SvgPicture.asset(
                          selectedIndex == 1
                              ? "assets/images/Genre_dark.svg"
                              : "assets/images/Genre_light.svg",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _currentPageIndex = 2;
                            selectedIndex = 2;
                          });
                        },
                        child: SvgPicture.asset(
                          selectedIndex == 2
                              ? "assets/images/Library_dark.svg"
                              : "assets/images/Library_light.svg",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
