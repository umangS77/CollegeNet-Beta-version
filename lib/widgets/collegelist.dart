import 'package:flutter/material.dart';

class CollegeList extends StatefulWidget {
  final List<String> collegelist;
  final Function(String) collegeName;
  CollegeList({this.collegelist, this.collegeName});
  @override
  _CollegeListState createState() => _CollegeListState();
}

class _CollegeListState extends State<CollegeList> {
  String selectedValue = '';
  @override
  void initState() {
    super.initState();
    selectedValue = widget.collegelist.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose College'),
        ),
        body: ListView.builder(
          itemBuilder: (ctx, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  selectedValue = widget.collegelist[index];
                });
                widget.collegeName(widget.collegelist[index]);
                // Navigator.pop(context);
              },
              child: Container(
                color: (selectedValue == widget.collegelist[index])
                    ? Colors.green
                    : null,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(child: Text(widget.collegelist[index])),
                ),
              ),
            );
          },
          itemCount: widget.collegelist.length,
        ));
  }
}
