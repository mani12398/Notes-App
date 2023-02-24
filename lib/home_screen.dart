import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/add_note.dart';
import 'package:notes_app/Dark%20Mode/change_theme_button_widget.dart';
import 'package:notes_app/view_note.dart';
import 'package:provider/provider.dart';

import 'Dark Mode/theme_provider.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference ref = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('Notes');

  List<Color> myColors = [
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.deepPurple,
    Colors.purple,
    Colors.cyan,
    Colors.teal,
    Colors.tealAccent,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final text = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'Dark Mode'
        : 'Light Mode';
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          children: [
            Text(
              "Notes",
              style: TextStyle(
                fontSize: 32.0,
                fontFamily: "lato",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 85,
            ),
            Text(
              '$text',
              style: TextStyle(
                fontSize: 15,
              ),
            )
          ],
        ),
        actions: [
          ChangeThemeButtonWidget(),
        ],
        elevation: 0.0,
        backgroundColor: Colors.green.shade800,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AddNote(),
            ),
          )
              .then((value) {
            setState(() {});
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green.shade800,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade800),
              accountName: Text(
                "${FirebaseAuth.instance.currentUser!.displayName}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                "${FirebaseAuth.instance.currentUser!.email}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              currentAccountPicture:
                  Image.network(FirebaseAuth.instance.currentUser!.photoURL!),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text(
                'Favourites',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: ref.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.docs.length == 0) {
              return Center(
                child: Text(
                  "You have no Saved Notes!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Random random = new Random();
                Color bg = myColors[random.nextInt(9)];
                Map? data = snapshot.data!.docs[index].data() as Map?;
                DateTime mydateTime = data!['Created'].toDate();
                String formattedTime =
                    DateFormat.yMMMd().add_jm().format(mydateTime);

                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => ViewNote(
                          data,
                          formattedTime,
                          snapshot.data!.docs[index].reference,
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: Card(
                    color: bg,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data['Title']}",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: "lato",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          //
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "lato",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text("Loading..."),
            );
          }
        },
      ),
    );
  }
}
