
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class InAppWebViewScreen extends StatefulWidget {
  final String url;

  const InAppWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  _InAppWebViewScreenState createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();

  late final WebViewController controller;


  double progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url),
      );
    controller.setUserAgent("random");
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (navigation){
        final currentUrl = navigation.url;
        if (currentUrl.startsWith('com.example.oauth')){
         String? code= Uri.parse(currentUrl).queryParameters["code"];
         print(code);
         Navigator.of(context).pop(code);
         // String body='''code=$code&
         // client_id=286775533293-vfiveqfoqoin3irq1eg77lv73ogdnbn3.apps.googleusercontent.com&
         //     redirect_uri=http://127.0.0.1:9004&
         //     grant_type=authorization_code''';
         // List<int> list = utf8.encode(body);
         // Uint8List bytes = Uint8List.fromList(list);
         // controller.loadRequest(Uri.parse("https://oauth2.googleapis.com/token"),method: LoadRequestMethod.post,headers: {"Content-Type":"application/x-www-form-urlencoded"},body:
         // bytes);
         return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;

      }
    ));
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,

            title: Text("Login"),
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: controller,

                    ),
                  ],
                ),
              ),
            ])));
  }
}
