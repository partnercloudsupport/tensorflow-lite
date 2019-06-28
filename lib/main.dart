import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() { runApp(new App()); }

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Tensorflow Lite',
      home: ObjectRecognition(),
    );
  }
}

class ObjectRecognition extends StatefulWidget {
  @override
  _ObjectRecognitionState createState() => _ObjectRecognitionState();
}

class _ObjectRecognitionState extends State<ObjectRecognition> {

  File _image;
  String label = "";

  @override
  void initState() {
    super.initState();
    loadTfModel();
  }

  @override
  void dispose() {
    disposeTflite();
    super.dispose();
  }

  Future<void> loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    ).then((res) => print("TFModel Loaded: $res!"));
  }

  Future<void> disposeTflite() async {
    await Tflite.close();
  }

  Future getImageAndDetect() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) return;
    setState(() {
      _image = imageFile;
    });
    
    await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    ).then((result) {
      print("Ran TfLite on Image");
      setLabel(result);
    });

  }

  void setLabel(List recognitions) {
    if(recognitions == null || recognitions.length == 0) {
      setState(() {
        label = "Nothing recognized";
      });
    }

    setState(() {
      label = "${recognitions[0]['label']}\n${recognitions[0]['confidence']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[

          Container(
            child: _image == null ? Center(child: Text("SELECT AN IMAGE", style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),),) : Image.file(_image),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 100.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(label, style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImageAndDetect,
        child: Icon(Icons.edit),
      ),
    );
  }
}