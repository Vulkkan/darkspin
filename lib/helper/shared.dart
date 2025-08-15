import 'package:flutter/material.dart';

const titleTextColor = Color.fromARGB(171, 0, 0, 0);

const appName = 'Darkspin';

const logoFont = 'CrystalRadio';
const textFont = 'Linotte';
// fontFamily: 'Linotte',
// fontFamily: 'CrystalRadio',
// fontFamily: 'Electroharmonix',

Text logoText(text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: logoFont,
      color: const Color.fromARGB(255, 255, 255, 255),
      fontSize: 35,
      // fontWeight: FontWeight.bold,
      letterSpacing: 1.2,

      shadows: [
        Shadow(
          blurRadius: 20,
          color: const Color.fromARGB(255, 0, 0, 0),
          offset: Offset(2, 5),
        ),
      ],
    ),
  );
}

Text titleText(text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: textFont,
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
  );
}

Text h2Text(text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'Linotte',
      color: const Color.fromARGB(255, 255, 255, 255),
      fontSize: 22,

      shadows: [
        Shadow(
          blurRadius: 20,
          color: const Color.fromARGB(255, 0, 0, 0),
          offset: Offset(2, 5),
        ),
      ],
    ),
  );
}

Text regularText(text) {
  return Text(
    text.toString(),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: 'Linotte',
      color: Colors.white,
    ),
  );
}

Text btnText(text) {
  return Text(
    text.toString(),
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontFamily: 'Linotte',
      color: Colors.white,
    ),
  );
}

Icon iconX(icon) {
  return Icon(
    icon,
    size: 40, 
    color: const Color.fromARGB(255, 255, 255, 255),

    shadows: [
        Shadow(
          blurRadius: 20,
          color: const Color.fromARGB(255, 0, 0, 0),
          offset: Offset(2, 5),
        ),
      ],
    );
}

ElevatedButton elevatedBtn(action, text) {
  return ElevatedButton(
    onPressed: action,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
      elevation: 5,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      )
    ),
    child: btnText('Select folder')
  );
}