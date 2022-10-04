// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/SignUp.dart';
import 'package:demo/login_page.dart';
import 'package:demo/navbar.dart';
import 'package:demo/receipes/receipeform.dart';
import 'package:demo/receipeview.dart';
import 'package:demo/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'Model.dart';
import 'package:clock/clock.dart';
import 'package:demo/search.dart';

class HomePage extends StatefulWidget {
  String userId;
  HomePage(this.userId);
  // const HomePage({Key? key , required String UserId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  List<ReceipeModel> receipes = <ReceipeModel>[];

  String get userId => widget.userId; //to take value from string-widget->userId

  getreceipe(String query) async {
    String url =
        "https://api.edamam.com/search?q=$query&app_id=cac09239&app_key=2a0165b7a3909e97cc9cecf161d66653";
    http.Response response = await http.get(Uri.parse(url));
    Map data = jsonDecode(response.body);

    data["hits"].forEach((element) {
      ReceipeModel receipeModel = new ReceipeModel();
      receipeModel = ReceipeModel.fromMap(element["recipe"]);
      receipes.add(receipeModel);

      setState(() {
        isLoading = false;
      });
      // log(receipes.toString());
    });

    receipes.forEach((receipes) {
      print(receipes.label);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getreceipe("LADOO");
  }

  bool nothomepagebool = true;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      drawer: navbar(userId),
      appBar: AppBar(
        title: Text(
          "Kitchen Diaries",
          style: GoogleFonts.balooPaaji2(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 195, 155, 254),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => receipeform(userId),
                ),
              );
            },
            icon: Icon(Icons.food_bank_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 195, 155, 254),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          if ((searchController.text).replaceAll(" ", "") ==
                              "") {
                            print("Blank search");
                            
                          } else {
                            // getreceipe(searchController.text);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      search(searchController.text , "${widget.userId}"),
                                ));
                          }
                        },
                        child: Icon(Icons.search)),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Receipe",
                        border: InputBorder.none,
                      ),
                    ))
                  ],
                ),
              ),
              Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.restaurant_menu,
                      size: 100,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Search the favourite receipe",
                      style: GoogleFonts.balooPaaji2(
                        fontSize: 15,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("You are Craving For . . .",
                        style: GoogleFonts.balooPaaji2(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      height: 50,
                    ),
                  ])),
              SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("userreceipes")
                            // .doc("${widget.userId}").collection("ReceipeImage")
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (!snapshot.hasData) {
                            return (const Center(
                              child: Text("No Images "),
                            ));
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  
                                  QueryDocumentSnapshot x =
                                      snapshot.data!.docs[index];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => receipeview(
                                                receipes[index].url),
                                          ));
                                    },
                                    child: Card(
                                        margin: EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 0.0,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                x['Receipe Image'],
                                                height: 300,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.black26,
                                                  ),
                                                  child: Text(
                                                    snapshot.data!.docs[index]
                                                        ['Receipe Name'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  )),
                                              right: 0,
                                              left: 0,
                                              bottom: 0,
                                            ),
                                            Positioned(
                                              right: 0,
                                              height: 30,
                                              width: 80,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .local_fire_department,
                                                          size: 20),
                                                      Text(
                                                        snapshot
                                                            .data!
                                                            .docs[index][
                                                                'Receipe Calories']
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  );
                                },
                              ),
                            );
                          }
                        }),
                    Container(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: receipes.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  // customBorder: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(20),
                                  // ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              receipeview(receipes[index].url),
                                        ));
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0.0,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 300,
                                              receipes[index].image),
                                        ),
                                        Positioned(
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.black26,
                                              ),
                                              child: Text(
                                                receipes[index].label,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                              )),
                                          right: 0,
                                          left: 0,
                                          bottom: 0,
                                        ),
                                        Positioned(
                                          right: 0,
                                          height: 30,
                                          width: 80,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .local_fire_department,
                                                      size: 20),
                                                  Text(
                                                    receipes[index]
                                                        .calories
                                                        .toString()
                                                        .substring(0, 4),
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                                // color: Colors.red;
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}