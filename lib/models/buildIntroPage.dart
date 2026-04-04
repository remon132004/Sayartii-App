import 'package:flutter/material.dart';

class BuildPage extends StatelessWidget {
  final String urlImage;
  final String title;
  final String subtitle;

  const BuildPage(
      {super.key, required this.urlImage, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          urlImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(100.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
