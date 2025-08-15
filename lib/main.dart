import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/videos_page.dart';
import 'pages/start_page.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // statusBarIconBrightness: Brightness.light
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Widget? startPage;
  bool isLoading = true;
  String? baseFolderPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _decideStartPage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns to app, re-check folder for videos
    if (state == AppLifecycleState.resumed) {
      _decideStartPage();
    }
  }

  Future<void> _decideStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    bool seenSplash = prefs.getBool('seenSplash') ?? false;
    baseFolderPath = prefs.getString('baseFolder');

    // Use saved folder or default
    if (baseFolderPath == null || baseFolderPath!.isEmpty) {
      baseFolderPath = "/storage/emulated/0/Movies/ReelsGun";
      await prefs.setString('baseFolder', baseFolderPath!);
    }

    Directory reelsFolder = Directory(baseFolderPath!);
    if (!(await reelsFolder.exists())) {
      await reelsFolder.create(recursive: true);
    }

    bool hasVideos = _checkForVideos(reelsFolder);

    if (!hasVideos || !seenSplash) {
      startPage = SplashScreen(
        baseFolderPath: baseFolderPath,
        onContinue: () async {
          await prefs.setBool('seenSplash', true);
          setState(() {
            startPage = Reels(baseFolderPath: baseFolderPath!);
          });
        },
      );
    } else {
      startPage = Reels(baseFolderPath: baseFolderPath!);
    }

    setState(() {
      isLoading = false;
    });
  }

  bool _checkForVideos(Directory folder) {
    try {
      return folder
          .listSync(recursive: true)
          .where((f) =>
              f is File &&
              ['.mp4', '.mov', '.mkv', '.webm']
                  .any((ext) => f.path.toLowerCase().endsWith(ext)))
          .isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelsGun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : startPage,
    );
  }
}