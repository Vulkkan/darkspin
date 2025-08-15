import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Updater {
  static const String versionJsonUrl =
      "https://yourusername.github.io/update/version.json"; // CHANGE THIS

  /// Detect device ABI (armeabi-v7a or arm64-v8a)
  static Future<String> getDeviceAbi() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      List<String> abis = androidInfo.supportedAbis;

      if (abis.contains("arm64-v8a")) return "arm64-v8a";
      if (abis.contains("armeabi-v7a")) return "armeabi-v7a";
    } catch (_) {}
    return "armeabi-v7a"; // fallback
  }

  /// Check for updates from JSON manifest
  static Future<UpdateStatus> checkForUpdates() async {
    try {
      final abi = await getDeviceAbi();
      final currentVersion = (await PackageInfo.fromPlatform()).version;

      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode != 200) return UpdateStatus.noInternet();

      final data = json.decode(response.body);
      final latestVersion = data["latest_version"];
      final changelog = data["changelog"] ?? "";
      final downloadUrl = data["downloads"][abi] ?? "";

      if (latestVersion == null || downloadUrl.isEmpty) {
        return UpdateStatus.error("Invalid version.json format");
      }

      if (_isNewerVersion(latestVersion, currentVersion)) {
        return UpdateStatus.updateAvailable(
            latestVersion, changelog, downloadUrl);
      } else {
        return UpdateStatus.noUpdate();
      }
    } catch (e) {
      return UpdateStatus.noInternet();
    }
  }

  /// Compare two semantic version strings
  static bool _isNewerVersion(String latest, String current) {
    List<int> latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Open the update link
  static Future<void> openUpdateLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

class UpdateStatus {
  final bool hasUpdate;
  final String latestVersion;
  final String changelog;
  final String downloadUrl;
  final bool noInternet;
  final String errorMessage;

  UpdateStatus({
    required this.hasUpdate,
    required this.latestVersion,
    required this.changelog,
    required this.downloadUrl,
    required this.noInternet,
    required this.errorMessage,
  });

  factory UpdateStatus.updateAvailable(
      String latest, String changelog, String url) {
    return UpdateStatus(
      hasUpdate: true,
      latestVersion: latest,
      changelog: changelog,
      downloadUrl: url,
      noInternet: false,
      errorMessage: "",
    );
  }

  factory UpdateStatus.noUpdate() {
    return UpdateStatus(
      hasUpdate: false,
      latestVersion: "",
      changelog: "",
      downloadUrl: "",
      noInternet: false,
      errorMessage: "",
    );
  }

  factory UpdateStatus.noInternet() {
    return UpdateStatus(
      hasUpdate: false,
      latestVersion: "",
      changelog: "",
      downloadUrl: "",
      noInternet: true,
      errorMessage: "",
    );
  }

  factory UpdateStatus.error(String message) {
    return UpdateStatus(
      hasUpdate: false,
      latestVersion: "",
      changelog: "",
      downloadUrl: "",
      noInternet: false,
      errorMessage: message,
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// Future<void> checkForUpdates(BuildContext context) async {
//   try {
//     final response = await http.get(
//       Uri.parse("https://vulkkan.github.io/darkspin/version.json"),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       String latestVersion = data["latest_version"];
//       String downloadUrl = data["download_url"];

//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       String currentVersion = packageInfo.version;

//       if (_isNewerVersion(latestVersion, currentVersion)) {
//         _showUpdateDialog(context, latestVersion, downloadUrl);
//       } else {
//         _showSnackBar(context, "No updates available");
//       }
//     } else {
//       _showSnackBar(context, "Could not check for updates");
//     }
//   } catch (e) {
//     _showSnackBar(context, "Update check failed");
//   }
// }

// bool _isNewerVersion(String latest, String current) {
//   List<int> latestParts = latest.split('.').map(int.parse).toList();
//   List<int> currentParts = current.split('.').map(int.parse).toList();

//   for (int i = 0; i < latestParts.length; i++) {
//     if (latestParts[i] > currentParts[i]) return true;
//     if (latestParts[i] < currentParts[i]) return false;
//   }
//   return false;
// }

// void _showUpdateDialog(BuildContext context, String latestVersion, String url) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text("Update available"),
//       content: Text("Version $latestVersion is available."),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Later"),
//         ),
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(context);
//             if (await canLaunchUrl(Uri.parse(url))) {
//               await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//             }
//           },
//           child: const Text("Download"),
//         ),
//       ],
//     ),
//   );
// }

// void _showSnackBar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message)),
//   );
// }
