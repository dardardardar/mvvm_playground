import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/widgets/buttons.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Go Harvest'.toUpperCase(),
                  style: textHeading.copyWith(fontSize: 24),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              flatButton(
                  context: context,
                  title: 'Harvest',
                  backgroundColor: primaryColor,
                  icon: Icons.shopping_cart_rounded),
              SizedBox(
                height: 8,
              ),
              flatButton(
                  context: context,
                  onTap: () {},
                  title: 'History',
                  backgroundColor: primaryColor,
                  icon: Icons.timer_outlined)
            ],
          ),
        ),
      ),
    );
  }
}
