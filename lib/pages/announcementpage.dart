import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegenet/services/batch.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:collegenet/pages/homepage.dart';
import 'package:collegenet/services/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

String cnt = "No notice";
final CollectionReference batchRef = Firestore.instance.collection("batch");

class AddAnnouncement extends StatefulWidget {
  final VoidCallback rebuild;
  final List<String> batchlist;
  AddAnnouncement({this.rebuild, this.batchlist});
  @override
  _AddAnnouncementState createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  String postid = Uuid().v4();
  TextEditingController contentControl = TextEditingController();
  TextEditingController captionControl = TextEditingController();
  TextEditingController targetControl = TextEditingController();
  bool isUploading = false, isLoading = false;
  String userId = currentUser.id,
      username = currentUser.username,
      college = currentUser.college;
  bool isEmptyTitle = false, isEmptyDes = false;
  List<Batch> batchlist = [Batch('UG2K19')];

  buildbatch() {
    List<String> list = widget.batchlist;
    // list.removeAt(0);
    batchlist.clear();
    for (var i = 1; i < list.length; i++) {
      // print(list[i]);
      batchlist.add(Batch(list[i]));
    }
    // print(batchlist[0].);
  }

  @override
  void initState() {
    super.initState();
    cnt = "No notice";
    buildbatch();
  }

  createPostInFirestore(
      {String caption,
      String content,
      String target,
      Timestamp nowtime,
      String batches}) async {
    await announcementRef.document(postid).setData({
      "postid": postid,
      "userId": userId,
      "username": username,
      "caption": caption,
      "content": content,
      "college": college,
      "target": target,
      "nowtime": nowtime,
      "batches": batches,
    });
    setState(() {
      postid = Uuid().v4();
      isUploading = false;
      captionControl.clear();
      contentControl.clear();
      targetControl.clear();
    });
    widget.rebuild();
    Navigator.pop(context);
  }

  handleUpload() async {
    setState(() {
      isUploading = true;
    });
    String batches = '', allbatches = '';
    bool allbatch = true;
    for (var item in batchlist) {
      allbatches += item.batch + ",";
      if (item.isSelected) {
        batches += item.batch + ",";
        allbatch = false;
      }
    }
    if (allbatch) batches = allbatches;

    Timestamp nowTime = Timestamp.now();
    createPostInFirestore(
      caption: captionControl.text,
      content: contentControl.text,
      target: targetControl.text,
      nowtime: nowTime,
      batches: batches,
    );
  }

  chooseBatch(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: 500,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        batchlist[index].isSelected =
                            !batchlist[index].isSelected;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Checkbox(
                              value: batchlist[index].isSelected,
                              onChanged: (s) {
                                batchlist[index].isSelected =
                                    !batchlist[index].isSelected;
                                setState(() {});
                              }),
                          Text(batchlist[index].batch),
                        ],
                      ),
                    );
                  },
                  itemCount: batchlist.length,
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return isUploading
        ? circularProgress()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff1a2639),
              title: Text(
                'Make Announcement',
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'SaucerBB',
                ),
              ),
              centerTitle: true,
            ),
            body: isLoading
                ? circularProgress()
                : Container(
                    width: double.infinity,
                    height: 900,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.cyan[100],
                          Colors.blue[100],
                          Colors.orange[300],
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 300.0,
                            child: TextField(
                              controller: captionControl,
                              keyboardType: TextInputType.emailAddress,
                              maxLines: null,
                              maxLength: 40,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.description),
                                labelText: "Caption",
                                hintText: "Max character limit: 30",
                                errorText: isEmptyTitle ||
                                        (captionControl.text.length > 30)
                                    ? (isEmptyTitle
                                        ? "You cannot leave caption blank"
                                        : "Caption size should be less than 30")
                                    : "",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 40.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 300.0,
                            // height: 100.0,
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              maxLines: null,
                              maxLength: 160,
                              controller: contentControl,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Foundation.clipboard_notes),
                                labelText: "Announcement Content",
                                hintText: "Max character limit: 160",
                                errorText: isEmptyDes ||
                                        (contentControl.text.length > 160)
                                    ? (isEmptyDes
                                        ? "You cannot leave content blank"
                                        : "Content size should be less than 160")
                                    : "",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 40.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          // RaisedButton(
                          //   onPressed: () {
                          //     chooseBatch(context);
                          //   },
                          //   child: Text('Choose Target Batches'),
                          // ),
                          Text(
                            'Choose Specific Target Batches',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text('*Optional'),
                              ),
                            ],
                          ),
                          Expanded(
                            // height: 400,
                            child: ClipRect(
                              child: ListView.builder(
                                itemBuilder: (ctx, index) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      batchlist[index].isSelected =
                                          !batchlist[index].isSelected;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: batchlist[index].isSelected,
                                            onChanged: (s) {
                                              batchlist[index].isSelected =
                                                  !batchlist[index].isSelected;
                                              setState(() {});
                                            }),
                                        Text(batchlist[index].batch),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: batchlist.length,
                              ),
                            ),
                          ),
                          Center(
                            child: ButtonTheme(
                              disabledColor: Colors.grey,
                              buttonColor: Colors.orange[100],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: RaisedButton(
                                onPressed: isUploading
                                    ? null
                                    : () {
                                        setState(() {
                                          isEmptyTitle =
                                              captionControl.text.isEmpty;
                                          isEmptyDes =
                                              contentControl.text.isEmpty;
                                        });
                                        bool isSubmit =
                                            !(isEmptyDes | isEmptyTitle);
                                        if (isSubmit) handleUpload();
                                      },
                                child: Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
  }
}
