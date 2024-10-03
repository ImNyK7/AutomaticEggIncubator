import 'package:flutter/material.dart';
import 'package:incubator_flutter_backend/screens/historic.dart';
import 'package:incubator_flutter_backend/screens/iotscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    IOTScreen(),
    TimestampScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/iotscreen': (BuildContext context) => IOTScreen(),
        '/historicscreen': (BuildContext context) => TimestampScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          items: <Widget>[
            Icon(Icons.home, size: 40,),
            Icon(Icons.history, size: 40,),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          index: _currentIndex,
          animationCurve: Curves.easeInOut,
          height: 50,
          backgroundColor: Colors.grey.shade900,
          color: Colors.grey.shade800,
          buttonBackgroundColor: Colors.grey.shade700,
          
          animationDuration: Duration(milliseconds: 300),
        ),
        body: _screens[_currentIndex],
      ),
    );
  }
}
