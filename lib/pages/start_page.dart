import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/shared.dart';


class SplashScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final String? baseFolderPath;

  const SplashScreen({
    super.key,
    required this.onContinue,
    this.baseFolderPath,
  });

  Future<void> _pickFolder(BuildContext context) async {
    String? selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseFolder', selectedDir);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: btnText('Reels folder set to: $selectedDir'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // h2Text('Welcome to'),
            Image.asset(
              'assets/images/icon.png', 
              width: 100,
            ),
            
            logoText(appName),
            // const SizedBox(height: 10),

            regularText('Select a folder containing your reels'),
            const SizedBox(height: 60),
            
            ElevatedButton(
              onPressed: () => _pickFolder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                elevation: 5,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: btnText('Select folder')
            ),

            const SizedBox(height: 20),
            regularText('Then'),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                elevation: 5,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: btnText('Select folder')
            ),
          ],
        ),
      ),
    );
  }
}