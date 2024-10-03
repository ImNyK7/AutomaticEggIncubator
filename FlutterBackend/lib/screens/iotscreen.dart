import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IOTScreen extends StatefulWidget {
  const IOTScreen({Key? key}) : super(key: key);

  @override
  _IOTScreenState createState() => _IOTScreenState();
}

class _IOTScreenState extends State<IOTScreen> {
  bool value = false;
  bool values = false;
  final dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Failed to initialize Firebase: $e');
    }
  }

  void onUpdate() {
    setState(() {
      value = !value;
    });
  }

  void onUpdate2() {
    setState(() {
      values = !values;
    });
  }

  void writeData() {
    //dbRef.child("Data").set({"Temperature:": 0, "Humidity:": 0});
    dbRef.child("LightStates").set({"switch": !value});
  }

  void writeData2() {
    dbRef.child("FanStates").set({"switch": !values});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: dbRef.child("Data").onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data?.snapshot.value! != null) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.egg, size: 40),
                        Text(
                          "Egg Incubator",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.egg, size: 40)
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Temperature",
                              style: TextStyle(
                                  fontSize: 35, fontWeight: FontWeight.bold, color: Colors.yellow),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              ((snapshot.data!.snapshot.value
                                          as Map?)?["Temperature:"]
                                      .toString() ??
                                  'N/A') + '°C',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 50),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Humidity",
                          style: TextStyle(
                              fontSize: 35, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Text(
                          ((snapshot.data!.snapshot.value as Map?)?["Humidity:"]
                                  .toString() ??
                              'N/A') + '%',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  // SizedBox(
                  //   height: 60,
                  // ),
                  // FloatingActionButton.extended(
                  //   onPressed: () {
                  //     onUpdate2();
                  //     writeData2();
                  //   },
                  //   label: values ? Text("Fan ON") : Text("Fan OFF"),
                  //   elevation: 20,
                  //   backgroundColor:
                  //       values ? Colors.blueAccent : Colors.white60,
                  //   icon: values
                  //       ? Icon(Icons.wind_power_rounded)
                  //       : Icon(Icons.wind_power_outlined),
                  // ),
                  // SizedBox(
                  //   height: 50,
                  // ),
                  // FloatingActionButton.extended(
                  //     onPressed: () {
                  //       writeData();
                  //       onUpdate();
                  //     },
                  //     label: value ? Text("Lamp OFF") : Text("Lamp ON"),
                  //     elevation: 20,
                  //     backgroundColor:
                  //         value ? Colors.white60 : Colors.yellowAccent,
                  //     icon: value
                  //         ? Icon(Icons.wb_incandescent_outlined)
                  //         : Icon(Icons.wb_incandescent)),
                  // SizedBox(
                  //   height: 20,
                  // ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
