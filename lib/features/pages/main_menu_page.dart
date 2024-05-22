import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/pages/flutter_maps_page.dart';
import 'package:mvvm_playground/widgets/buttons.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              opacity: 0.5,
              image: AssetImage('assets/icons/images.jpeg'),
              fit: BoxFit.cover,
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Go Harvest'.toUpperCase(),
                style: textHeading.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: flatButton(
                  onTap: () {
                    print('sd');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FlutterMapPage(
                                  title: 'Harvest',
                                  isHistory: false,
                                )));
                  },
                  context: context,
                  title: 'Harvest',
                  backgroundColor: primaryColor,
                  icon: Icons.shopping_cart_rounded,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: flatButton(
                  context: context,
                  onTap: () {
                    print('sd');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FlutterMapPage(
                                  isHistory: true,
                                  title: 'History',
                                )));
                  },
                  title: 'History',
                  backgroundColor: primaryColor,
                  icon: Icons.timer_outlined,
                  color: Colors.white),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Version 0.1'),
            )
          ],
        ),
      ),
    );
  }
}
