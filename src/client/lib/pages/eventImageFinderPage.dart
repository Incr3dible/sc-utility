import 'package:flutter/material.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/event/eventTools.dart';

class EventImageFinderPage extends StatefulWidget {
  @override
  EventImageFinderPageState createState() => EventImageFinderPageState();
}

class EventImageFinderPageState extends State<EventImageFinderPage> {
  bool isLoading = true;
  bool errorOccurred = false;

  @override
  void initState() {
    super.initState();

    searchForEvents();
  }

  void searchForEvents() async {
    await Future.delayed(Duration(milliseconds: 300));

    var count = await EventTools.uploadEventFiles();

    if (count == -1) {
      setState(() {
        errorOccurred = true;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Event Image Finder"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        body: errorOccurred
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.error,
                          size: 40,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        TranslationProvider.get("TID_UNKNOWN_ERROR"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ))
                  ],
                ),
              )
            : isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(TranslationProvider.get("TID_UPLOAD")),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.cloud_done,
                              size: 40,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            TranslationProvider.get("TID_EVENT_DESC"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: OutlineButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ))
                      ],
                    ),
                  ));
  }
}
