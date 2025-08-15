import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../components/mainwidget.dart';
import '../components/videoplayer.dart';

class Reels extends StatefulWidget {
  final String baseFolderPath;

  const Reels({super.key, required this.baseFolderPath});

  @override
  ReelsState createState() => ReelsState();
}

class ReelsState extends State<Reels> with WidgetsBindingObserver {
  List<File> videoFiles = [];
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVideosFromFolder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadVideosFromFolder();
    }
  }

  Future<void> _loadVideosFromFolder() async {
    // Permissions
    var status = await Permission.storage.request();
    if (!status.isGranted) return;
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    // Directory
    final dir = Directory(widget.baseFolderPath);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    // List + filter
    final files = await dir
        .list(recursive: true)
        .where((f) =>
            f is File &&
            ['.mp4', '.mov', '.mkv', '.webm']
                .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .map((f) => f as File)
        .toList();

    // Sort by modified date (newest first)
    files.sort((a, b) =>
        b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    if (files.isEmpty) {
      setState(() {
        videoFiles = [];
      });
      return;
    }

    // Ensure first video is ready before building
    await _initControllerWithPlay(0, files);

    // Preload second if exists
    if (files.length > 1) {
      _initController(files, 1);
    }

    setState(() {
      videoFiles = files;
    });
  }

  Future<void> _initControllerWithPlay(int index, List<File> files) async {
    if (_controllers.containsKey(index) || index < 0 || index >= files.length) return;

    final controller = VideoPlayerController.file(files[index]);
    await controller.initialize();
    controller.setLooping(true);
    _controllers[index] = controller;
    if (index == _currentIndex) controller.play();
  }

  Future<void> _initController(List<File> files, int index) async {
    if (_controllers.containsKey(index) || index < 0 || index >= files.length) return;

    final controller = VideoPlayerController.file(files[index]);
    await controller.initialize();
    controller.setLooping(true);
    _controllers[index] = controller;
  }

  void _disposeController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.dispose();
      _controllers.remove(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Play current
    _controllers[index]?.play();

    // Pause others
    _controllers[index - 1]?.pause();
    _controllers[index + 1]?.pause();

    // Preload neighbors
    _initController(videoFiles, index - 1);
    _initController(videoFiles, index + 1);

    // Dispose far-away
    _disposeController(index - 3);
    _disposeController(index + 3);
  }

  @override
  Widget build(BuildContext context) {
    if (videoFiles.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Loading...", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    Positioned buildPosLikeComment() {
      return Positioned(
        bottom: 100,
        right: 10,
        width: 50,
        height: 260,
        child: likeShareSave(context),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: PreloadPageView.builder(
        scrollDirection: Axis.vertical,
        controller: PreloadPageController(),
        preloadPagesCount: 2,
        itemCount: videoFiles.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          final videoFile = videoFiles[index];
          final videoName = p.basename(videoFile.path);
          final shortName = videoName.length > 20
              ? '${videoName.substring(0, 20)}...'
              : videoName;

          return Stack(
            children: [
              Container(color: Colors.black),
              Videoplayer(controller: _controllers[index]),
              AppNameOverlay(),
              CommentWithPublisher(title: shortName),
              buildPosLikeComment(),
            ],
          );
        },
      ),
    );
  }
}