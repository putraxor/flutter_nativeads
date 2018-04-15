import 'package:flutter/material.dart';
import 'package:flutter_nativeads/flutter_nativeads.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showAd = false;

  @override
  initState() {
    super.initState();
    setupNativeAd();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  setupNativeAd() async {
    await FlutterNativeads.setConfiguration(
      admobId: 'ca-app-pub-3940256099942544~3347511713',
      adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      testDeviceId: '37B699B4E6C1FC134B9A272DD9B71BD0',
    );

    await FlutterNativeads.initializeAd();
  }

  @override
  Widget build(BuildContext context) {
    final numbers = [];
    for (int i = 0; i < 100; i++) {
      numbers.add(i);
    }
    final items = numbers.map((index) {
      if (index == 3) {
        return showAd
            ? new AppInstalledAd()
            : new Container(child: new Text("AppInstalledAd not shown"));
      } else if (index == 7) {
        return showAd
            ? new ContentAd()
            : new Container(child: new Text("ContentAd not shown"));
      } else {
        return new ListTile(
          dense: true,
          leading: new CircleAvatar(child: new Text("$index")),
          title: new Text("Data Anu"),
          subtitle: new Text(
              "Konten Aplikasi $index lorem ipsum dolor sit amit lorem ipsum dolor sit amet"),
        );
      }
    }).toList();
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Native Ads'),
        ),
        body: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new RaisedButton(
                child: new Text("Load Ads"),
                onPressed: () {
                  setState(() {
                    showAd = !showAd;
                  });
                },
              ),
              new Container(
                height: 340.0,
                child: new ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return items.elementAt(index);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
