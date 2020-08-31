import 'package:flutter/material.dart';

class CustomWidgets {
  static Widget roundedListTile(ListTile listTile) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 2),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        child: listTile,
      ),
    );
  }
}
