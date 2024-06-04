import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/pages/data_page.dart';
import 'package:mvvm_playground/widgets/buttons.dart';

int count = 1;

class DataSetPage extends StatefulWidget {
  const DataSetPage({super.key});

  @override
  State<DataSetPage> createState() => _DataSetPageState();
}

class _DataSetPageState extends State<DataSetPage> {
  String buttontext = 'Sync';
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
                  context: context,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DataPage(
                                  title: 'Trees',
                                  isHistory: false,
                                )));
                  },
                  title: 'Trees',
                  backgroundColor: primaryColor,
                  icon: Icons.timer_outlined,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: flatButton(
                  context: context,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DataPage(
                                  title: 'Routes',
                                  isHistory: false,
                                )));
                  },
                  title: 'Routes',
                  backgroundColor: primaryColor,
                  icon: Icons.timer_outlined,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: flatButton(
                  context: context,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DataPage(
                                  title: 'Users',
                                  isHistory: false,
                                )));
                  },
                  title: 'Users',
                  backgroundColor: primaryColor,
                  icon: Icons.timer_outlined,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: flatButton(
                  context: context,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DataPage(
                                  title: 'Histories',
                                  isHistory: false,
                                )));
                  },
                  title: 'Histories',
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
