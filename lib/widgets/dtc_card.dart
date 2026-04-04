import 'package:flutter/material.dart';

class DtcCard extends StatelessWidget {
  const DtcCard({
    super.key,
    required this.title,
    required this.code,
    required this.criticalLevel,
    this.icon,
  });

  final String title;
  final String code;
  final String criticalLevel;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      //s color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Divider(),
              Row(
                children: [
                  const Text(
                    "DTC code: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  icon
                      ?? Container(),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Text(
                    "Critical level: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black45),
                  ),
                  Text(
                    criticalLevel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
