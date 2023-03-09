import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'auth_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String token = '';
  String details="";
  
  Future<Map<String,dynamic>> getEndPointData(String url)async{
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {}
    }
    return {};
  }

  Future<Map<String, dynamic>> postEndpointDataWithBody(String endpoint, dynamic body) async {
    print("Posting data for Endpoint $endpoint");
    print("Body $body");
    var url = Uri.parse(endpoint);

    final response = await http
        .post(
          url,
          body: body,
        )
        .timeout(Duration(minutes: 1));

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {}
    }

    return {};
  }

  void getProfileInfo()async{
    String url="https://www.googleapis.com/oauth2/v3/userinfo?access_token=$token";
    print("token $token");
    final Map<String, dynamic> data =
    await getEndPointData(url);
    if(data.isNotEmpty) {
      setState(() {
        if (data.isNotEmpty) {
          details = data["name"];
        }
      });
    }

  }

  void _tryLogin() async {
    String url =
        '''https://accounts.google.com/o/oauth2/v2/auth?scope=email&response_type=code&url=https://www.googleapis.com/oauth2/v4/token&redirect_uri=com.example.oauth:/oauth2redirect&client_id=286775533293-dfosnuvsq9hp79konvf21dhcf2sjs118.apps.googleusercontent.com''';
    String result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return InAppWebViewScreen(
        url: url,
      );
    }));

    final Map<String, dynamic> data =
        await postEndpointDataWithBody("https://www.googleapis.com/oauth2/v4/token", {
      "client_id": "286775533293-dfosnuvsq9hp79konvf21dhcf2sjs118.apps.googleusercontent.com",
      "code": result.trim(),
      "grant_type": "authorization_code",
      "redirect_uri": "com.example.oauth:/oauth2redirect"
    });
    setState(() {
      if (data.isNotEmpty) {
        token = data["access_token"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            token == ''
                ? Text(
                    'Oauth2.0',
                  )
                : TextButton(
                    onPressed: getProfileInfo,
                    child: const Text("Click here to get profile info\n from access token")),
            Text(details),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tryLogin,
        tooltip: 'Increment',
        child: const Icon(Icons.login),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
