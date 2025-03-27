import 'dart:io';
import 'package:bookred/All_API_List/API_constants.dart';
import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/EmailVerifyPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class account_Infopage extends StatefulWidget {
  final String? userId;

  const account_Infopage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<account_Infopage> createState() => _AccountInfopageState();
}

class _AccountInfopageState extends State<account_Infopage> {
  ApiConstants apiConstants = ApiConstants();
  AuthService auth = AuthService();
  User_Service user = User_Service();

  final ImagePicker _picker = ImagePicker();

  bool isUsernameEditing = false;
  bool isEmailEditing = false;
  late TextEditingController usernameController;
  late TextEditingController emailController;

  String? username;
  String? userId;
  String? email;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    // getSavedPreference(); // Load saved username when the widget initializes
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void toggleUsernameEdit() {
    setState(() {
      isUsernameEditing = !isUsernameEditing;
    });
  }

  void toggleEmailEdit() {
    setState(() {
      isEmailEditing = !isEmailEditing;
    });
  }

  void uploadpfp(File pfp) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await user.UploadProfilePicture(pfp);
    Navigator.pop(context);
    loadUserInfo();
  }

  void deletepfp() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Call the delete function
    await user.deleteProfilePicture();

    // Close the loading dialog
    Navigator.pop(context);
    loadUserInfo();
  }

  void nameUpdate(String updatedname) async {
    if (username != updatedname) {
      int response = await auth.checkUserExist(username: updatedname);

      if (response == 1) {
        print("Check user response == 1");
        SnackBar(
          content: Text('Username is taken'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          // Makes it float above other widgets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } else if (response == -1) {
        print("Check user response == -1");
        SnackBar(
          content: Text('An Error Occured while changing username'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          // Makes it float above other widgets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } else {
        print("Check user response == 0");
        int newName = await auth.changeUsername(updatedname);

        if (newName == 1) {
          print("Change username response == 1");
          // 1. Show SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Name updated'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2), // Optional: how long it shows
            ),
          );

          // 2. Update username in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username',
              updatedname); // Replace with your actual updated name variable

          // 3. Reload username
          loadUserInfo(); // This assumes you already have this function in place

          // 4. Toggle edit mode
          toggleUsernameEdit();
        }
      }
    } else {
      toggleUsernameEdit();
    }
  }

  void emailUpdate(String updatedemail) async {
    if (email != updatedemail) {
      int response = await auth.checkUserExist(email: updatedemail);

      if (response == 1) {
        print("Check user response == 1");
        SnackBar(
          content: Text('Email is Already use for another account'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          // Makes it float above other widgets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } else if (response == -1) {
        print("Check user response == -1");
        SnackBar(
          content: Text('An Error Occured while changing username'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          // Makes it float above other widgets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } else {
        print("Check user response == 0");
        int newName = await auth.changeUsername(updatedemail);

        if (newName == 1) {
          print("Change username response == 1");
          // 1. Show SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Name updated'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2), // Optional: how long it shows
            ),
          );

          // 2. Update username in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email',
              updatedemail); // Replace with your actual updated name variable

          // 3. Reload username
          loadUserInfo(); // This assumes you already have this function in place

          // 4. Toggle edit mode
          toggleEmailEdit();
        }
      }
    } else {
      toggleEmailEdit();
    }
  }

  void loadUserInfo() async {
    String? fetchedUsername = await apiConstants.getUserNameFromPrefs();
    String? fetchedUserId = await apiConstants.getUserIdFromPrefs();
    String? fetchedUserphoto = await apiConstants.getUserPhotoFromPref();
    String? fetchedUseremail = await apiConstants.getEmailFromPrefs();

    print("Username - $fetchedUsername");
    print("UserId - $fetchedUserId");

    // Now update state synchronously
    setState(() {
      username = fetchedUsername;
      usernameController = TextEditingController(text: username);
      email = fetchedUseremail;
      emailController = TextEditingController(text: email);
      userId = fetchedUserId;
      profilePicture = fetchedUserphoto;
    });
    print("Username = $username");
    print("Username = $userId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Info"),
      ),
      body: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Profile Picture
          Center(
            child: profilePic(profilePicture!),
          ),
          SizedBox(height: 30),

          // Username
          Container(
            width: double.infinity,
            color: Color(0xFFF0F2F5),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Username Text
                Text(
                  "Username",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),

                //Update or View Username
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isUsernameEditing
                        ? Expanded(
                            child: TextFormField(
                              controller: usernameController,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          )
                        : Text(
                            username!,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 15,
                            ),
                          ),
                    IconButton(
                      icon: Icon(isUsernameEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        if (isUsernameEditing) {
                          nameUpdate(usernameController.text);
                          print("New username: ${usernameController.text}");
                        }
                        !isUsernameEditing ? toggleUsernameEdit() : null;
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),

          //Password
          Container(
            width: double.infinity,
            color: Color(0xFFF0F2F5),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Username Text
                Text(
                  "Password",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),

                //Update or View Username
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "************",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailVerifyPage(
                                      isforgot: true,
                                    )));
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),

          //Email
          Container(
            width: double.infinity,
            color: Color(0xFFF0F2F5),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Email Text
                Text(
                  "Email",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),

                //Update or View Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      email ?? "no email bruh",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EmailVerifyPage(isforgot: false)));
                        loadUserInfo();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget profilePic(String? img) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // Profile Picture
          Container(
            child: (img != null && img.isNotEmpty)
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(img!),
                  )
                : CircleAvatar(
                    radius: 60,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
          ),

          //Button to Update or Delete
          Positioned(
            left: 80,
            top: 80,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFF1A1D32)),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          width: double.maxFinite,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25),
                            ),
                            color: Colors.black,
                          ),
                          // color: Color(0xFF1A1D32),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Close Button
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),

                                  //Profile picture Text
                                  Text(
                                    "Profile Photo",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),

                                  //Delete Profile Picture Button
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              title: Text(
                                                "Remove profile photo?",
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    //Cancel
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Poppins"),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),

                                                    //Delete
                                                    GestureDetector(
                                                      onTap: () async {
                                                        deletepfp();
                                                        Navigator.pop(
                                                            context); // Close the alert dialog first
                                                      },
                                                      child: Text(
                                                        "Remove",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Poppins"),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    child: img != null
                                        ? Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                          )
                                        : null,
                                  )
                                ],
                              ),

                              //Select from Gallery or Camera
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Camera Button
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                width: 2, color: Colors.grey)),
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Camera",
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),

                                  //Gallery Button
                                  GestureDetector(
                                    onTap: () async {
                                      final XFile? selectedPic =
                                          await _picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (selectedPic != null) {
                                        File convertedFile =
                                            File(selectedPic.path);
                                        uploadpfp(convertedFile);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.grey)),
                                          child: Icon(
                                            Icons.photo,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      });
                },
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
