import 'dart:collection';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// Manages a pool of VideoPlayerControllers to optimize memory and startup time.
/// Recycle 3 controllers: Previous, Current, Next.
class VideoPoolManager {
  static final VideoPoolManager _instance = VideoPoolManager._internal();
  factory VideoPoolManager() => _instance;
  VideoPoolManager._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  final int _maxPoolSize = 3;

  /// Gets a controller for the url. If it exists, returns it.
  /// If not, creates a new one, initializes it, and manages the pool size.
  Future<VideoPlayerController> getController(String url) async {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }

    // Clean up if pool is full
    if (_controllers.length >= _maxPoolSize) {
      // Simple FIFO eviction for now, or just random since we don't track usage timestamp perfectly here
      // Ideally we'd remove the one furthest from current index, but for this simplified pool:
      final keyToRemove = _controllers.keys.first; 
      await _disposeController(keyToRemove);
    }

    // Create new
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[url] = controller;
    
    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      debugPrint("Error initializing video: $e");
      _disposeController(url);
      rethrow;
    }

    return controller;
  }

  Future<void> _disposeController(String url) async {
    final controller = _controllers.remove(url);
    if (controller != null) {
      await controller.dispose();
    }
  }

  /// Call this when a page is definitely scrolled away from
  void releaseController(String url) {
    // In a strict pool, we might keep it alive for a bit. 
    // Here we trust the getController eviction logic.
  }
  
  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
