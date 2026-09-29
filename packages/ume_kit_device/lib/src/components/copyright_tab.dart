import 'package:flutter/material.dart';

class CopyrightTab extends StatelessWidget {
  const CopyrightTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => LicensePage(),
      ),
    );
  }
}
