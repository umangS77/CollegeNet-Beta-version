import 'package:collegenet/models/users.dart';
import 'package:collegenet/pages/announcementpage.dart';
import 'package:collegenet/pages/homepage.dart';
import 'package:collegenet/services/auth.dart';
import 'package:collegenet/services/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collegenet/widgets/announcementpost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/loading.dart';

QuerySnapshot snapshot;
String init = "";
int cnt = 0;
String pageName = "";
final CollectionReference batchRef = Firestore.instance.collection("batch");

class Announcements extends StatefulWidget {
  Announcements({
    this.auth,
    this.onSignedOut,
    this.user,
  });
  final AuthImplementation auth;
  final VoidCallback onSignedOut;
  final User user;
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  String college = currentUser.college, batch = '';
  bool isLoading = false;
  List<AnnouncementPost> posts = [];
  TextEditingController searchControl = TextEditingController();
  List<String> batchChoices = [];
  List<String> batchOptions = [];
  createDropdownItems() async {
    QuerySnapshot batchSnap = await batchRef.orderBy('batch').getDocuments();
    List<DocumentSnapshot> batchDocs = batchSnap.documents;
    batchChoices.clear();
    for (var i = 0; i < batchDocs.length; i++) {
      batchChoices.add(batchDocs[i].data['batch']);
    }
    batchOptions = batchChoices;
  }

  getAnnouncementPosts() async {
    setState(() {
      isLoading = true;
    });
    snapshot = await announcementRef
        .where("college", isEqualTo: currentUser.college)
        .orderBy('nowtime')
        .getDocuments();
    setState(() {
      isLoading = false;
      init = "";
    });
  }

  rebuildannouncements() {
    getAnnouncementPosts();
  }

  buildannouncementposts(String query) {
    posts.clear();
    query = query.toLowerCase();
    List<Widget> announcementposts = [];
    List<DocumentSnapshot> list = [], l = snapshot.documents, temp = [];
    for (var i = l.length - 1; i >= 0; i--) {
      // String docid = l[i].data['postid'];
      String val = l[i]
          .data['nowtime']
          .toDate()
          .add(new Duration(days: 7))
          .difference(DateTime.now())
          .toString();
      print(val);
      // print(DateTime.now());
      if (val.compareTo("0") < 0) {
        print("1 week before, not displaying");
      } else
        temp.add(l[i]);
    }
    l = temp;
    if (batch != "All Batches") {
      list.clear();
      String batches;
      for (var i = 0; i < l.length; i++) {
        batches = l[i].data['batches'].toString();
        // print(i.toString() + ":  " + batches);
        // print(l[i].da)
        if (batches.contains(batch)) {
          list.add(l[i]);
        }
      }
    } else {
      list = l;
    }
    for (var i = 0; i < list.length; i++) {
      posts.add(AnnouncementPost(
        caption: list[i].data['caption'],
        college: list[i].data['college'],
        content: list[i].data['content'],
        postid: list[i].data['postid'],
        userId: list[i].data['userId'],
        username: list[i].data['username'],
        target: list[i].data['target'],
        rebuild: rebuildannouncements,
        posttime: list[i].data['nowtime'],
      ));
    }
    announcementposts.clear();
    if (posts.length == 0) {
      announcementposts.add(SizedBox(
        height: 40,
      ));
      announcementposts.add(Center(
        child: Text(
          "No Results found for the query",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20.0,
          ),
        ),
      ));
    } else {
      announcementposts.add(SizedBox(
        height: 20,
      ));
    }
    for (var i = 0; i < posts.length; i++) {
      if (posts[i] != null) {
        announcementposts.add(posts[i]);
        // print(posts[i].caption);
      }
    }
    return Column(
      children: announcementposts,
    );
  }

  handlePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) => AddAnnouncement(
              rebuild: rebuildannouncements,
              batchlist: batchChoices,
            ));
  }

  Route _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddAnnouncement(
              rebuild: rebuildannouncements,
              batchlist: batchChoices,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.bounceInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    cnt = 0;
    createDropdownItems();
    getAnnouncementPosts();
    pageName = "College Announcements";
    batch = "All Batches";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe2ded3),
      appBar: AppBar(
        backgroundColor: Color(0xff1a2639),
        title: Text(
          pageName,
          style: TextStyle(
            fontFamily: 'Chelsea',
            // fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? circularProgress()
          : Container(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            items: batchOptions.map((String item) {
                              print('*******');
                              print(item);
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String selectedOption) {
                              setState(() {
                                this.batch = selectedOption;
                              });
                            },
                            value: batch,
                          ),
                        ),
                      ),
                      buildannouncementposts(init),
                    ],
                  )),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 28,
        ),
        backgroundColor: Colors.black,
        // foregroundColor: Color,
        onPressed: () {
          Navigator.of(context).push(_createRoute());
        },
      ),
    );
  }
}
