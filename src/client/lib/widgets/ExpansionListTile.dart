import 'package:flutter/material.dart';

class ExpansionListTile extends StatefulWidget {
  final Widget trailing;
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final List<Widget> children;

  ExpansionListTile(
      {this.trailing, this.title, this.subtitle, this.leading, this.children});

  @override
  ExpansionListTileState createState() => ExpansionListTileState();
}

class ExpansionListTileState extends State<ExpansionListTile> {
  @override
  Widget build(BuildContext context) {
    return widget.children != null
        ? ExpansionTile(
            childrenPadding: EdgeInsets.zero,
            title: widget.title,
            trailing: widget.trailing,
            subtitle: widget.subtitle,
            leading: widget.leading,
            children: widget.children,
          )
        : ListTile(
            title: widget.title,
            trailing: widget.trailing,
            subtitle: widget.subtitle,
            leading: widget.leading,
          );
  }
}
