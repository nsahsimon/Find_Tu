import 'package:flutter/material.dart';
import 'package:find_tu/constants.dart';
class SearchMethodTile extends StatefulWidget {
  Function toggleSearchMethod;
  SearchMethodTile(this.toggleSearchMethod);

  @override
  SearchMethodTileState createState() => SearchMethodTileState();
}

class SearchMethodTileState extends State<SearchMethodTile> {
  bool searchBySubject = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(7.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState((){
                  searchBySubject = true;
                });
                widget.toggleSearchMethod();
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("By Subject" , style: TextStyle(color: !searchBySubject ? Colors.grey : appColor, fontSize: 20) ),
                    SizedBox(
                      height: 20
                    ),
                    SizedBox(
                        height: 3,
                        width: 100,
                        child: Container(
                          child: null,
                          color: searchBySubject ? appColor : Colors.transparent,
                        )
                    ),
                  ]
              ),
            ),
            GestureDetector(
              onTap: () {
                setState((){
                  searchBySubject = false;
                });
                widget.toggleSearchMethod();
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("By Name", style: TextStyle(color: !searchBySubject ? appColor : Colors.grey, fontSize: 20)),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        height: 3,
                        width: 100,
                        child: Container(
                          child: null,
                          color: searchBySubject ? Colors.transparent : appColor,
                        )
                    ),
                  ]
              ),
            )
          ]
      ),
    );
  }
}
