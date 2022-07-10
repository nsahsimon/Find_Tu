import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RatingTile extends StatelessWidget {
  final double size;
  final int rating;
  RatingTile({this.size = 12.0, this.rating = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List<Icon>.generate(5, (i) {
          return (i <= rating - 1)
              ? Icon(Icons.star, color: Colors.orangeAccent, size: size)
              : Icon(Icons.star_border, color: Colors.grey, size: size);
        })
      ],
    );
  }
}

