// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Torchpage extends StatefulWidget {
  const Torchpage({Key? key}) : super(key: key);

  @override
  _TorchpageState createState() => _TorchpageState();
}

class _TorchpageState extends State<Torchpage> {
  late CameraController _controller;
  bool _isFlashlightOn = false;
  bool _isSOSActive = false;
  Timer? _sosTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.low);
    await _controller.initialize();

    setState(() {
      _isFlashlightOn = false;
    });
  }

  void _toggleFlashlight() {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (_isFlashlightOn) {
      _controller.setFlashMode(FlashMode.off);
    } else {
      _controller.setFlashMode(FlashMode.torch);
    }

    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
    });
  }

  void _toggleSOS() {
    if (_isSOSActive) {
      _stopSOS();
    } else {
      _startSOS();
    }
    setState(() {
      _isSOSActive = !_isSOSActive;
    });
  }

  void _startSOS() {
    const Duration sosDuration = Duration(milliseconds: 400);
    int sosCounter = 0;

    _sosTimer = Timer.periodic(sosDuration, (Timer timer) {
      if (!_isSOSActive || sosCounter >= 6) {
        _stopSOS();
        return;
      }

      if (sosCounter % 2 == 0) {
        _controller.setFlashMode(FlashMode.torch);
      } else {
        _controller.setFlashMode(FlashMode.off);
      }

      sosCounter++;
    });
  }

  void _stopSOS() {
    if (_sosTimer != null && _sosTimer!.isActive) {
      _sosTimer!.cancel();
    }

    _controller.setFlashMode(FlashMode.off);
    setState(() {
      _isSOSActive = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 220),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                minimumSize: Size(80, 250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: _toggleFlashlight,
              child: Image.asset(
                _isFlashlightOn
                    ? 'lib/images/torch_on.png'
                    : 'lib/images/torch_off.png',
                height: 80,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                minimumSize: Size(110, 110),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: _toggleSOS,
              child: Text(
                'SOS',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 200),
            Text(
              'Designed By Tushar Suryavanshi',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }
}
