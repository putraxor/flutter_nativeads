import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterNativeads {
  static const MethodChannel _channel =
      const MethodChannel('flutter_nativeads/method_channel');

  ///Set native ads key configuration
  static Future<String> setConfiguration({
    @required String admobId,
    @required String adUnitId,
    String testDeviceId,
  }) async {
    return await _channel.invokeMethod("setConfiguration", {
      "admobId": admobId,
      "adUnitId": adUnitId,
      "testDeviceId": testDeviceId
    });
  }

  ///initialize mobile ads
  static Future<String> initializeAd() async {
    return await _channel.invokeMethod("initializeAd");
  }

  ///Native call to clickAd
  static Future<String> clickAd(String id) async {
    return await _channel.invokeMethod("clickAd", {"id": int.parse(id)});
  }

  ///Native call to startAdImpression
  static Future<String> startAdImpression(String id) async {
    return await _channel
        .invokeMethod("startAdImpression", {"id": int.parse(id)});
  }

  ///Native call to destroyAd
  static Future<String> destroyAd(String id) async {
    return await _channel.invokeMethod("destroyAd", {"id": int.parse(id)});
  }

  ///Native call to loadNativeAppInstalledAd
  static Future<NativeAppInstallAd> loadNativeAppInstallAd() async {
    final map =
        await _channel.invokeMethod("loadAds", {"type": "NativeAppInstallAd"});
    return new NativeAppInstallAd.fromMap(map);
  }

  ///Native call to loadNativeAppInstalledAd
  static Future<NativeContentAd> loadNativeContentAd() async {
    final map =
        await _channel.invokeMethod("loadAds", {"type": "NativeContentAd"});
    return new NativeContentAd.fromMap(map);
  }
} //end plugin

///
///
///
///NativeAppInstalledAd class
class NativeAppInstallAd {
  String id, headline, body, cta, icon, price, rating;

  NativeAppInstallAd.fromMap(Map<String, String> map) {
    id = map['id'];
    headline = map['headline'];
    body = map['body'];
    cta = map['cta'];
    icon = map['icon'];
    price = map['price'];
    rating = map['rating'];
  }
}

///
///
///
///NativeContentAd class
class NativeContentAd {
  String id, headline, body, cta, logo, advertiser;

  NativeContentAd.fromMap(Map<String, String> map) {
    id = map['id'];
    headline = map['headline'];
    body = map['body'];
    cta = map['cta'];
    logo = map['logo'];
    advertiser = map['advertiser'];
  }
}

///
///
/// Widget for AppInstalledAd
class AppInstalledAd extends StatefulWidget {
  @override
  _AppInstalledAdState createState() => new _AppInstalledAdState();
}

class _AppInstalledAdState extends State<AppInstalledAd> {
  Future<NativeAppInstallAd> future;
  NativeAppInstallAd ad;

  @override
  void initState() {
    super.initState();
    setState(() {
      future = FlutterNativeads.loadNativeAppInstallAd();
    });
  }

  @override
  void dispose() {
    if (ad != null) {
      FlutterNativeads.destroyAd(ad.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.hasError) {
            ad = snapshot.data;
            final adsChip = new Positioned(
              right: 6.0,
              top: 6.0,
              child: new Container(
                child: new Text(
                  " Ad ",
                  style: new TextStyle(color: Colors.white, fontSize: 10.0),
                ),
                color: Colors.orangeAccent,
              ),
            );
            FlutterNativeads.startAdImpression(ad.id);
            return new Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                new Card(
                  child: new ListTile(
                    dense: true,
                    leading: new Image.network(ad.icon),
                    title: new Text('${ad.headline} ${ad.price}'),
                    subtitle: new Text(ad.body),
                    onTap: () => FlutterNativeads.clickAd(ad.id),
                  ),
                ),
                adsChip,
              ],
            );
          }
        }
        return new Container();
      },
    );
  }
}

///
///
/// Widget for ContentAd
class ContentAd extends StatefulWidget {
  @override
  _ContentAdState createState() => new _ContentAdState();
}

class _ContentAdState extends State<ContentAd> {
  Future<NativeContentAd> future;
  NativeContentAd ad;

  @override
  void initState() {
    super.initState();
    setState(() {
      future = FlutterNativeads.loadNativeContentAd();
    });
  }

  @override
  void dispose() {
    if (ad != null) {
      FlutterNativeads.destroyAd(ad.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.hasError) {
            ad = snapshot.data;
            final adsChip = new Positioned(
              right: 6.0,
              top: 6.0,
              child: new Container(
                child: new Text(
                  " Ad ",
                  style: new TextStyle(color: Colors.white, fontSize: 10.0),
                ),
                color: Colors.orangeAccent,
              ),
            );
            FlutterNativeads.startAdImpression(ad.id);
            return new Stack(
              children: <Widget>[
                new ListTile(
                  dense: true,
                  leading: new Image.network(ad.logo),
                  title: new Text('${ad.headline}'),
                  subtitle: new Text(ad.body),
                  onTap: () => FlutterNativeads.clickAd(ad.id),
                ),
                adsChip,
              ],
            );
          }
        }
        return new Container();
      },
    );
  }
}
