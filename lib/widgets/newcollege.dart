import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegenet/pages/setupusername.dart';
import 'package:collegenet/services/loading.dart';
import 'package:flutter/material.dart';

class RegisterCollege extends StatefulWidget {
  final List<String> collegelist;
  final Function(String) collegeName;
  RegisterCollege({this.collegeName, this.collegelist});
  @override
  _RegisterCollegeState createState() => _RegisterCollegeState();
}

class _RegisterCollegeState extends State<RegisterCollege> {
  TextEditingController collegeCont = TextEditingController();
  TextEditingController collegeurlCont = TextEditingController();
  bool isUploading = false, duplicate = false;
  List<String> collegeurl = ['abc'];
  String college;

  buildcollegedata() async {
    QuerySnapshot listcollegeurl =
        await collegesRef.orderBy('Name').getDocuments();
    List<DocumentSnapshot> colsnap = listcollegeurl.documents;
    collegeurl.clear();
    for (var i = 0; i < colsnap.length; i++) {
      collegeurl.add(colsnap[i].data['url']);
    }
  }

  bool checkforduplicates() {
    setState(() {
      duplicate = false;
    });
    for (var i = 0; i < collegeurl.length; i++) {
      if (collegeurl[i] == collegeCont.text.toLowerCase()) {
        setState(() {
          duplicate = true;
          college = widget.collegelist[i];
        });
        break;
      }
    }
    return duplicate;
  }

  addCollege() async {
    setState(() {
      isUploading = true;
    });
    String url = collegeurlCont.text;
    if (!collegeurlCont.text.startsWith('http')) {
      if (!collegeurlCont.text.startsWith('www')) {
        url = 'www.' + url;
      }
      url = 'https://' + url;
    }
    url = url.toLowerCase();
    await collegesRef.add({
      'Name': collegeCont.text,
      'url': collegeurlCont.text,
    });
    setState(() {
      isUploading = false;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    buildcollegedata();
  }

  @override
  Widget build(BuildContext context) {
    return isUploading
        ? circularProgress()
        : Scaffold(
            appBar: AppBar(
              title: Text('Register college'),
              centerTitle: true,
            ),
            body: Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(225, 95, 27, .3),
                            blurRadius: 5,
                            offset: Offset(4, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: collegeCont,
                          decoration: InputDecoration(
                            labelText: 'College Name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (duplicate)
                      Text('This College is already registered as $college!'),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(225, 95, 27, .3),
                            blurRadius: 5,
                            offset: Offset(4, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: collegeurlCont,
                          decoration: InputDecoration(
                            labelText: 'College Website',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (!checkforduplicates()) {
                          widget.collegeName(collegeCont.text);
                          addCollege();
                        }
                      },
                      child: Center(child: Text('Submit')),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
