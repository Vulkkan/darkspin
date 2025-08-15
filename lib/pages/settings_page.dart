import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../helper/shared.dart';
import '../helper/updater.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentFolder;

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
      // Pass back the folder to parent
      // Navigator.pop(context, selectedDir);
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
              padding: const EdgeInsets.only(
                top: 2, bottom: 2, left: 10, right: 10
              ),
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
                        fontFamily: 'Linotte'
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

            // UPDATER
            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Checking for updates...")),
                );

                final status = await Updater.checkForUpdates();

                if (status.noInternet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No internet connection.")),
                  );
                } else if (status.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${status.errorMessage}")),
                  );
                } else if (status.hasUpdate) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Update Available (${status.latestVersion})"),
                      content: Text(status.changelog.isNotEmpty
                          ? status.changelog
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
                            Updater.openUpdateLink(status.downloadUrl);
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
              },
              child: const Text("Check for Updates"),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     checkForUpdates(context);
            //   },
            //   child: const Text("Check for updates"),
            // ),
            const SizedBox(height: 300),

            Center(
              child: Column(
                children: [
                  regularText('App by'),
                  Text(
                    'Spyder',
                    style: TextStyle(
                      fontFamily: 'Electroharmonix',
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: const Color.fromARGB(255, 0, 0, 0),
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
