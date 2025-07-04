import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../base/widgets/loading_page.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PhotoViewController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController()
      ..outputStateStream.listen((state) {
        setState(() => _scale = state.scale ?? 1.0);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw),
            onPressed: _rotateImage,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetImage,
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.heroTag ?? widget.imageUrl,
                child: PhotoView(
                  imageProvider: NetworkImage(widget.imageUrl),
                  controller: _controller,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  loadingBuilder: (_, __) =>  Center(
                    child: LoadingButton(isWhite: true),
                  ),
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                'Zoom: ${_scale.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    _controller.scale = _controller.scale! * 1.5;
  }

  void _zoomOut() {
    _controller.scale = _controller.scale! * 0.8;
  }

  void _rotateImage() {
    _controller.rotation = _controller.rotation + 90;
  }

  void _resetImage() {
    _controller.reset();
  }

  void _handleDoubleTap() {
    if (_scale > 1.5) {
      _resetImage();
    } else {
      _zoomIn();
    }
  }
}