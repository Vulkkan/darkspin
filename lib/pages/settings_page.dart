import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../helper/shared.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentFolder;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFolder();
  }

  Future<void> _loadCurrentFolder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentFolder = prefs.getString('baseFolder');
    });
  }

  Future<void> _pickNewFolder() async {
    String? selectedDir = await FilePicker.platform.getDirectoryPath();

    if (selectedDir != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseFolder', selectedDir);

      setState(() {
        _currentFolder = selectedDir;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: btnText('Reels folder updated'),
          backgroundColor: const Color.fromARGB(255, 56, 73, 56),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Restart.restartApp();
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() => _checkingUpdate = true);

    try {
      final response = await http.get(Uri.parse(
          "https://YOUR_GITHUB_USERNAME.github.io/YOUR_SITE/version.json"));
      if (response.statusCode != 200) {
        throw Exception("Could not fetch version info");
      }

      final data = jsonDecode(response.body);
      String latestVersion = data['latestVersion'];
      String changelog = data['changelog'] ?? "";
      Map<String, dynamic> downloadUrls = data['downloadUrls'];

      // Detect ABI
      String abi;
      if (Platform.isAndroid) {
        abi = (Platform.version.contains('arm64')) ? 'arm64' : 'armeabi-v7a';
      } else {
        abi = 'armeabi-v7a'; // Fallback
      }

      String? downloadUrl = downloadUrls[abi];

      // Get current app version
      final packageInfo = await getPackageInfo();
      String currentVersion = packageInfo.version;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Update Available ($latestVersion)"),
            content: Text(changelog.isNotEmpty
                ? changelog
                : "A new version is available."),
            actions: [
              TextButton(
                child: const Text("Later"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Update"),
                onPressed: () {
                  Navigator.pop(context);
                  _openDownloadLink(downloadUrl);
                },
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No updates available.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _checkingUpdate = false);
    }
  }

  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _openDownloadLink(String? url) {
    if (url != null) {
      launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No download link available.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: h2Text('Settings'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            regularText('Change reels source'),
            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentFolder ?? 'Pick location',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Linotte',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _pickNewFolder,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: _checkingUpdate ? null : _checkForUpdates,
              child: Text(
                  _checkingUpdate ? "Checking..." : "Check for Updates"),
            ),

            const Spacer(),

            Center(
              child: Column(
                children: [
                  regularText('App by'),
                  Text(
                    'Spyder',
                    style: TextStyle(
                      fontFamily: 'Electroharmonix',
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black,
                          offset: Offset(2, 5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  regularText('victoriano.3996@gmail.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
