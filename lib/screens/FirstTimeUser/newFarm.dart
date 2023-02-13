import 'dart:convert';
import 'package:farmadvisor/screens/models/farm.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmNameValidator {
  static validate(value) {
    return value.isEmpty ? 'phone can not be empty' : null;
  }
}

class LocationValidator {
  static validate(value) {
    return value.isEmpty ? 'country can not be empty' : null;
  }
}

class NewFarm extends StatefulWidget {
  const NewFarm({Key? key}) : super(key: key);

  @override
  State<NewFarm> createState() => _NewFarmState();
}

class _NewFarmState extends State<NewFarm> {
  final formKey = GlobalKey<FormState>();
  bool formValid = false;

  @override
  Widget build(BuildContext context) {
    Farm farm = Farm(name: '', location: '', id: '');

    Future save() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? 0;
      var res = await http.post(
          Uri.parse("https://quaint-kerchief-crab.cyclic.app/farm"),
          headers: {
            'Authorization': 'Bearer $token',
            "content-type": "application/json",
          },
          body: json.encode({
            'name': farm.name,
            'location': farm.location,
          }));
      final id = Farm.fromJson(json.decode(res.body)).id;
      prefs.setString('farmId', id);
      print(res.statusCode);

      // print(Farm.fromJson(json.decode(res.body)).id);
      if (res.statusCode != 400 &&
          res.statusCode != 404 &&
          res.statusCode != 401 &&
          res.statusCode != 500) {
        context.go("/fieldHome");
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "NEW FARM",
            style: TextStyle(
              color: Color.fromARGB(95, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 165, 176, 172),
            ),
            onPressed: () {
              context.go('/home');
            },
          )),
      body: Container(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15),
                  child: Text("create new farm",
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 22, 60, 41))),
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                padding: EdgeInsets.only(left: 8, right: 8),
                child: TextFormField(
                  key: ValueKey('name'),
                  controller: TextEditingController(text: farm.name),
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {
                    farm.name = value;
                  },
                  validator: (value) => FarmNameValidator.validate(value),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Farm name",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                padding: EdgeInsets.only(left: 8, right: 8),
                child: TextFormField(
                  key: ValueKey('location'),
                  controller: TextEditingController(text: farm.location),
                  onChanged: (value) {
                    farm.location = value;
                  },
                  validator: (value) => LocationValidator.validate(value),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "location",
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        save();
                      }
                    },
                    child: Text('Create'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 22, 60, 41),
                      onPrimary: Colors.white,
                      minimumSize: Size(140, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
