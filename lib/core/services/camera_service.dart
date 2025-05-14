import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; 

abstract class CameraService {



  Future<bool> initializeController();



  CameraController? getController();





  Future<void> stopImageStream();


  Future<void> disposeController();



  ValueNotifier<CameraValue?> get cameraValueNotifier;


  Future<void> setFlashMode(FlashMode mode);


  Future<void> startImageStream(void Function(CameraImage image) onAvailable);
}

class CameraServiceImpl implements CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool? _isControllerInitialized;
  final ValueNotifier<CameraValue?> _cameraValueNotifier = ValueNotifier(null);

  @override
  ValueNotifier<CameraValue?> get cameraValueNotifier => _cameraValueNotifier;

  @override
  CameraController? getController() => _controller;

  @override
  Future<bool> initializeController() async {
    if (_isControllerInitialized == true) return true;
    _isControllerInitialized = null;
    _cameraValueNotifier.value = null;

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      await _controller?.dispose();

      _controller = CameraController(
        backCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _controller!.addListener(() {
        if (_controller != null) {
          _cameraValueNotifier.value = _controller!.value;
        }
      });

      await _controller!.initialize();
      _isControllerInitialized = true;
      print("Camera Controller Initialized");

      return true;
    } catch (e) {
      print("Error initializing camera controller: $e");
      await _controller?.dispose();
      _controller = null;
      _isControllerInitialized = false;
      _cameraValueNotifier.value = null;
      return false;
    }
  }

  @override
  Future<void> stopImageStream() async {
    if (_isControllerInitialized != true ||
        _controller == null ||
        !_controller!.value.isStreamingImages) return;
    try {
      print("Stopping image stream (called via service)...");
      await _controller!.stopImageStream();
    } catch (e) {
      print("Error stopping image stream: $e");
    }
  }

  @override
  Future<void> disposeController() async {
    print("Disposing camera controller...");
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        try {
          await _controller!.stopImageStream();
        } catch (e) {
          print("Error stopping stream during dispose: $e");
        }
      }
      await _controller!.dispose();
    }
    _controller = null;
    _isControllerInitialized = null;
    _cameraValueNotifier.value = null;
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.setFlashMode(mode);
        print("Flash mode set to $mode");
      } catch (e) {
        print("Error setting flash mode: $e");
      }
    } else {
      print("Camera controller not initialized, cannot set flash mode.");
    }
  }

  @override
  Future<void> startImageStream(void Function(CameraImage image) onAvailable) async {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        !_controller!.value.isStreamingImages) {
      try {
        await _controller!.startImageStream(onAvailable);
        print("Image stream started by service.");
      } catch (e) {
        print("Error starting image stream in service: $e");
      }
    } else if (_controller == null || !_controller!.value.isInitialized) {
      print("Camera not initialized, cannot start stream.");
    } else if (_controller!.value.isStreamingImages) {
      print("Image stream already running.");
    }
  }
}
