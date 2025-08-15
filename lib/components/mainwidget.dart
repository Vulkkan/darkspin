import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';
import '../helper/shared.dart';


//  ------------------- (TOP) APP TITLE-------------------  //
class AppNameOverlay extends StatelessWidget {
  const AppNameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 0, 0, 0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: logoText(appName),
      ),
    );
  }
}

Column likeShareSave(BuildContext context) {
  return Column(
    children: [
      const Spacer(),

      Column(
        children: [
          iconX(CupertinoIcons.heart_fill),
          // regularText(500)
        ],
      ),
      const SizedBox(height: 35),

      Column(
        children: [
          iconX(Icons.arrow_circle_right_rounded),
          // regularText(70)
        ],
      ),
      const SizedBox(height: 35),

      InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SettingsPage(),
              fullscreenDialog: true, // For modal style
            ),
          );
        },
        child: iconX(Icons.settings_rounded),
      ),
    ],
  );
}


//  ------------------- (BOTTOM) VIDEO TITLE-------------------  //
class CommentWithPublisher extends StatelessWidget {
  final String title;
  const CommentWithPublisher({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 40.0,
        ),
        child: Row(
          children: [
            iconX(Icons.person_4_rounded),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
    ],
  );
}
