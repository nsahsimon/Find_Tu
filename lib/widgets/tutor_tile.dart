import 'package:flutter/material.dart';
import 'package:find_tu/models/tutor.dart';
import 'package:find_tu/screens/chat_screen.dart';
import 'package:find_tu/widgets/rating_tiles.dart';

class TutorTile extends StatefulWidget {
  Tutor tutor;
  bool showRating;
  bool canDelete;
  Function? startLoading;
  Function? stopLoading;
  Function? onTap;
  TutorTile(this.tutor, {this.showRating = false, this.startLoading, this.stopLoading, this.onTap, this.canDelete = false});


  @override
  _TutorTileState createState() => _TutorTileState();
}

class _TutorTileState extends State<TutorTile> {

  Function get startLoading => widget.startLoading == null ? () {} :  widget.startLoading!;
  Function get stopLoading => widget.stopLoading == null ? () {} :  widget.stopLoading!;

  ImageProvider get profilePic => NetworkImage(widget.tutor.photoUrl ?? "");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: ListTile(
          leading: CircleAvatar(
            foregroundImage: profilePic,
            radius: 40,
            backgroundColor: Colors.grey,
            child:Icon(Icons.person, color: Colors.white,),
          ),
          title: Text("${widget.tutor.name}"),
          subtitle: Text("${widget.tutor.subjectList}"),
          tileColor: Colors.white,
          trailing: Container(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded(
                //   flex: 1,
                //   child: SizedBox(height: 1)
                // ),
                Flexible(
                  flex: 1,
                  child: widget.canDelete
                      ? IconButton(icon: const Icon(Icons.delete_forever_outlined, color: Colors.red), onPressed: (){/*Delete tutor*/},)
                      : Container(child: null),
                ),
                Flexible(
                  flex: 1,
                  child: widget.showRating
                    ? RatingTile(rating: widget.tutor!.userRating)
                      : Container(child: null),
                )
              ]
            ),
          ),
          onTap: () async{
            if(widget.onTap == null){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(widget.tutor!)));
            }else {
              await widget.onTap!();
            }
          },
        ),
      ),
    );
  }
}
