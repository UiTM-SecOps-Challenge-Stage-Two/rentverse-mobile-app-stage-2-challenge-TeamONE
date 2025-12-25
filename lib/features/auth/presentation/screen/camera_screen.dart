import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _isTaking = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Kamera tidak tersedia');
      }

      CameraDescription front;
      try {
        front = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } catch (_) {
        front = cameras.first;
      }

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = 'Tidak bisa membuka kamera. Pastikan izin kamera aktif.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || _isTaking) return;
    setState(() => _isTaking = true);
    try {
      await _initFuture;
      final file = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop<File?>(File(file.path));
    } catch (_) {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _initError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.alertCircle,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _initError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop<File?>(null),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    )
                  : FutureBuilder(
                      future: _initFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            _controller != null) {


                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final aspect = _controller!.value.aspectRatio;

                              final height = constraints.maxHeight;
                              final width = height * (aspect == 0 ? 1 : aspect);
                              return Center(
                                child: SizedBox(


                                  width: width,
                                  height: height,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Gagal membuka kamera',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(LucideIcons.x, color: Colors.white),
                onPressed: () => Navigator.of(context).pop<File?>(null),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GestureDetector(
                  onTap: _isTaking ? null : _takePicture,
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: _isTaking
                        ? const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
