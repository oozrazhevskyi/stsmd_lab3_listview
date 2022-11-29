import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "package:lw3_listview/models/country.dart";

import 'dart:async';
import "dart:convert";

void main() {
  runApp(const MyApp());
}

Future<List<Country>> fetchCountries(http.Client client) async {
  try {
    final response = await client
        .get(Uri.parse('http://192.168.1.105:5000/countries'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return parseCountries(response.body);
    } else {
      return Future.error("statusCode not 200");
    }
  } on Exception catch (e) {
    return Future.error(e.toString());
  }
}

List<Country> parseCountries(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Country>((json) => Country.fromJson(json)).toList();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter ListView Demo'),
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
  Future<List<Country>> _myData = fetchCountries(http.Client());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _myData = fetchCountries(http.Client());
                  });
                },
                child: const Text(
                  "Refresh",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              FutureBuilder<List<Country>>(
                future: _myData,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      List<Country> countries = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: countries.length,
                        itemBuilder: ((context, index) {
                          Country currentCountry = countries[index];
                          return Container(
                            height: 50,
                            color: Colors.green[100 + (200 * (index % 2))],
                            child: Center(
                              child: Text(
                                  "Capital of ${currentCountry.name} is ${currentCountry.capital}"),
                            ),
                          );
                        }),
                      );
                    } else {
                      return const Text("Error",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ));
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
              ),
            ],
          ),
        ));
  }
}
