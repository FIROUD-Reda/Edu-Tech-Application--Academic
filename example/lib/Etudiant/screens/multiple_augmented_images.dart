import 'dart:typed_data';

import 'package:arcore_flutter_plugin_example/Etudiant/screens/scanne_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../models/etudiant_data.dart';
import '../models/utils.dart';

class MultipleAugmentedImagesPage extends StatefulWidget {
  @override
  _MultipleAugmentedImagesPageState createState() =>
      _MultipleAugmentedImagesPageState();
}

class _MultipleAugmentedImagesPageState
    extends State<MultipleAugmentedImagesPage> {
  ArCoreController arCoreController;
  int ind = -1;
  int counter = 0;
  Map<String, ArCoreAugmentedImage> augmentedImagesMap = Map();
  Map<String, Uint8List> bytesMap = Map();
  EtudiantDataProvider etudiantDataProvider;
  EtudiantData etudiantData;

  // ignore: avoid_init_to_null, non_constant_identifier_names
  String NameObject = "";
  @override
  void initState() {
    initData();
    super.initState();
  }

// initialisation de la liste de donnees
  Future<void> initData() async {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ScanneList()),
          (Route<dynamic> route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Multiple augmented images'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh',
              iconSize: 40,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => MultipleAugmentedImagesPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ), //IconButton
          ],
          leading: IconButton(
            onPressed: (() {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ScanneList()),
                (Route<dynamic> route) => false,
              );
            }),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(
            Icons.delete,
          ),
          backgroundColor: Colors.green,
          onPressed: () {
            if (ind != -1) {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: Row(
                    children: <Widget>[
                      Text(
                        'Voulez vous supprimmer ce modele ?\n\n il faut actualiser la page\n pour afficher ce modele',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.delete,
                          ),
                          onPressed: () {
                            arCoreController.removeNodeWithIndex(ind);
                            Navigator.pop(context);
                            ind = -1;
                          })
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

// creation de vue AR et chargement des images
  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController.onTrackingImage = _handleOnTrackingImage;
    loadMultipleImage();
  }

// chargement des images on utilisant les liens
  loadMultipleImage() async {
    for (var asset in Utils.distantImages) {
      final ByteData bytes =
          await NetworkAssetBundle(Uri.parse(asset.imageLink)).load("");
      bytesMap[asset.modeleName] = bytes.buffer.asUint8List();
    }
    arCoreController.loadMultipleAugmentedImage(bytesMap: bytesMap);
  }

// evenement de detection de l'image
  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.name)) {
      augmentedImagesMap[augmentedImage.name] = augmentedImage;
      _addModel(augmentedImage);
    }
  }

// ajoute du modele correspondant au image detecter a la scene ou vue AR
  Future _addModel(ArCoreAugmentedImage augmentedImage) async {
    for (var asset in Utils.distantImages) {
      if (asset.modeleName == augmentedImage.name) {
        if (NameObject != "" && NameObject != asset.modeleName) {
          arCoreController.removeNodeWithIndex(ind);
        }
        NameObject = asset.modeleName;
        ind = augmentedImage.index;
        final node = ArCoreReferenceNode(
          scale: vector.Vector3.all(0.15),
          name: asset.modeleName,
          objectUrl: asset.modelLink,
        );

        arCoreController.addArCoreNodeToAugmentedImage(node, ind);
      }
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
