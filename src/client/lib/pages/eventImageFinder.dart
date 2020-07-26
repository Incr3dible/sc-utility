import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';

class EventImageFinderPage extends StatefulWidget {
  @override
  EventImageFinderPageState createState() => EventImageFinderPageState();
}

class EventImageFinderPageState extends State<EventImageFinderPage> {
  bool isLoading = true;

  @override
  void initState(){
    super.initState();

    addEventImage();
  }

  void addEventImage() async {
    await ApiClient.addEventImage("Clash Royale", "test.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Event Image Finder"),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Uploading images... (10/32)"),
                    )
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_done,
                      size: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Thank you!"),
                    )
                  ],
                ),
              ));
  }
}
