import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _movieCollection = Firestore.instance
      .collection("movie_to_vote"); // collection or table name
  final _textMovieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: _movieCollection.snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return ListView.builder(
                itemCount: snapshot.data.documents.length, // row length
                itemBuilder: (context, index) {
                  return _dbContent(snapshot
                      .data.documents[index]); //read each row of the table
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                _textMovieController.clear();
                return AlertDialog(
                  title: Text("Add new movie"),
                  content: TextField(
                    controller: _textMovieController,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Save"),
                      onPressed: () {
                        _movieCollection.document().setData({
                          // add data to the table
                          "name": _textMovieController
                              .text, // add data from text field
                          "votes": 0
                        }).whenComplete(() => Navigator.of(context).pop());
                      },
                    ),
                  ],
                );
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _dbContent(DocumentSnapshot data) {
    return ListTile(
      onTap: () {
        data.reference
            .updateData({"votes": data["votes"] + 1}); // update table row
      },
      onLongPress: () {
        DocumentSnapshot dataPress = data;
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              _textMovieController.clear();
              return AlertDialog(
                title: Text("Delete Movie"),
                content: Text(
                  dataPress['name'],
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Delete"),
                    onPressed: () {
                      dataPress.reference
                          .delete(); // delete data from table row
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      title: Text(data["name"]), // read data
      trailing: Text(
        data["votes"].toString(),
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
