import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import '../../models/Niveau.dart';
import 'globals.dart' as globals;
import 'StartCamera.dart';
import '../../../Etudiant/models/utils.dart';

class GetLevels extends StatefulWidget {
  @override
  _GetLevelsState createState() => _GetLevelsState();
}

class _GetLevelsState extends State<GetLevels> {
  Future<List<Niveau>> niveaus;
  final niveausListKey = GlobalKey<_GetLevelsState>();

  @override
  void initState() {
    super.initState();
    niveaus = getNiveausList();
  }

  Future<List<Niveau>> getNiveausList() async {
    final response = await http.get(Uri.parse(
        Utils.RootUrl+"/mobile/niveau/" + globals.selectedSalle));

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Niveau> niveaus = items.map<Niveau>((json) {
      return Niveau.fromJson(json);
    }).toList();

    return niveaus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: niveausListKey,
      appBar: AppBar(
        title: Text('Niveau List'),
      ),
      body: Center(
        child: FutureBuilder<List<Niveau>>(
          future: niveaus,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // By default, show a loading spinner.
            if (!snapshot.hasData) return CircularProgressIndicator();
            // Render employee lists
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      data.nom_niveau,
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StartCamera()),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
