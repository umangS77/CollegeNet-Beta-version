import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegenet/pages/homepage.dart';
import 'package:collegenet/services/loading.dart';
import 'package:collegenet/widgets/collegelist.dart';
import 'package:collegenet/widgets/newcollege.dart';
import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';

final collegesRef = Firestore.instance.collection('Colleges');

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String username, college = 'IIIT-H', batch = 'UG2k15';
  bool register = false, isloading = false, uniqueName = true;
  QuerySnapshot snapshot;
  List<String> collegeList = [
    'IIIT-H',
    'IIT-B',
    'IIIT-D',
    'IIT-HYD',
    'BITS PILANI',
    'BITS HYDERABAD',
    'BITS GOA',
    'IIT-KGP',
    'IIT-D',
    'IIT-K',
    'IIT-M',
    'IIT-G',
    'IIT-R',
  ];
  List<String> batchList = [
    'UG2k15',
    'UG2K16',
    'UG2K17',
    'UG2K18',
    'UG2K19',
    'UG2K20',
    'PG2K18',
    'PG2K19',
    'PG2K20',
  ];
  int index = 0;

  submit() async {
    _formKey.currentState.save();
    await usernamelist(username);
    print(username);
    if (uniqueName) {
      var data = [username, college, batch];
      Navigator.pop(context, data);
    }
  }

  getcollegelist() async {
    setState(() {
      isloading = true;
    });
    QuerySnapshot listcol = await collegesRef.orderBy('Name').getDocuments();
    List<DocumentSnapshot> colsnap = listcol.documents;
    collegeList.clear();
    for (var i = 0; i < colsnap.length; i++) {
      collegeList.add(colsnap[i].data['Name']);
    }
    college = collegeList.first;
    setState(() {
      isloading = false;
    });
  }

  gotoregister() {
    if (register) {
      Navigator.push(context, _newCollegeRoute());
      setState(() {
        register = false;
      });
    }
  }

  Route _chooseCollegeRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CollegeList(
              collegelist: collegeList,
              collegeName: (name) {
                Navigator.pop(context);
                getcollegelist();
                if (name != 'Register Your College') {
                  setState(() {
                    college = name;
                  });
                } else {
                  setState(() {
                    register = true;
                  });
                  print(register);

                  gotoregister();
                }
              },
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

  Route _newCollegeRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegisterCollege(
              collegelist: collegeList,
              collegeName: (name) {
                setState(() {
                  college = name;
                });
              },
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

  buildusername() async {
    snapshot = await usersRef.getDocuments();
  }

  usernamelist(String name) async {
    setState(() {
      uniqueName = true;
    });

    List<DocumentSnapshot> usernames = snapshot.documents;
    for (var i = 0; i < usernames.length; i++) {
      if (usernames[i].data['username'] == name) {
        setState(() {
          uniqueName = false;
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    buildusername();
    getcollegelist();
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.push(context, _newCollegeRoute());
    return Scaffold(
      backgroundColor: Color(0xffe2ded3),
      appBar: AppBar(
        backgroundColor: Color(0xff1a2639),
        automaticallyImplyLeading: false,
        title: Text(
          'Set Up your Profile',
          style: TextStyle(
            fontFamily: 'Chelsea',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            onSaved: (val) => username = val,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be at least 3 characters",
                            ),
                            maxLength: 14,
                          ),
                          if (!uniqueName)
                            Text(
                              'Username is already in use',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          if (!uniqueName)
                            SizedBox(
                              height: 12.0,
                            ),
                          RaisedButton(
                            onPressed: () {
                              isloading
                                  ? circularProgress()
                                  : Navigator.push(
                                      context, _chooseCollegeRoute());
                            },
                            child: Text('Choose College'),
                          ),
                          Text(college),
                          // DropdownButton<String>(
                          //   items: collegeList.map((String item) {
                          //     return DropdownMenuItem<String>(
                          //       value: item,
                          //       child: Text(item),
                          //     );
                          //   }).toList(),
                          //   onChanged: (String selectedOption) {
                          //     setState(() {
                          //       this.college = selectedOption;
                          //     });
                          //   },
                          //   value: college,
                          // ),
                          DropdownButton<String>(
                            items: batchList.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String selectedOption) {
                              setState(() {
                                this.batch = selectedOption;
                              });
                            },
                            value: batch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
