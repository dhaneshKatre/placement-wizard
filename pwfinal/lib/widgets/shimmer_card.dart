import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200],
        highlightColor: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
          ),
          title: Container(
            height: 20.0,
            color: Colors.grey[200],
          ),
          subtitle: Container(
            height: 10.0,
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
