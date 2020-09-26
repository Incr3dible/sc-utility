import 'package:flutter/material.dart';

class ExpansionListTile extends StatelessWidget {
  final Widget trailing;
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final List<Widget> children;

  ExpansionListTile(
      {this.trailing, this.title, this.subtitle, this.leading, this.children});

  @override
  Widget build(BuildContext context) {
    return children != null
        ? ExpansionTile(
            childrenPadding: EdgeInsets.zero,
            title: title,
            trailing: trailing,
            subtitle: subtitle,
            leading: leading,
            children: children,
          )
        : ListTile(
            title: title,
            trailing: trailing,
            subtitle: subtitle,
            leading: leading,
          );
  }
}
