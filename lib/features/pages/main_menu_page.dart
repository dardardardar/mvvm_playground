import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: primaryColor,
          child: Column(
            children: [Text('Go Harvest')],
          ),
        ),
      ),
    );
  }
}
