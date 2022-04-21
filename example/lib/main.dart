import 'package:flutter/material.dart';
import 'package:flutter_3d_model_viewer/flutter_3d_model_viewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Model Viewer")),
        body: const Flutter3DModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          src: 'etc/assets/Astronaut.glb',
          // a bundled asset file
          alt: "A 3D model of an astronaut",
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
