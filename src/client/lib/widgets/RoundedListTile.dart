import 'package:flutter/material.dart';

class RoundedListTile extends StatelessWidget {
  final Widget trailing;
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final bool enabled;
  final Function onTap;
  final Function onLongPress;

  RoundedListTile(
      {this.trailing,
      this.title,
      this.subtitle,
      this.leading,
      this.enabled,
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 2),
      child: Card(
        margin: EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        child: ListTile(
            title: title,
            trailing: trailing,
            subtitle: subtitle,
            leading: leading,
            enabled: enabled ?? true,
            onTap: onTap,
            onLongPress: onLongPress),
      ),
    );
  }
}
