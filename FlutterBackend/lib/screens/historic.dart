import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CustomTimestamp {
  final double temperature;
  final double humidity;
  final String time;

  CustomTimestamp({
    required this.temperature,
    required this.humidity,
    required this.time,
  });

  DateTime get formattedTime {
    final timeParts = time.split(':');
    if (timeParts.length == 3) {
      final hours = int.tryParse(timeParts[0]);
      final minutes = int.tryParse(timeParts[1]);
      final seconds = int.tryParse(timeParts[2]);
      if (hours != null && minutes != null && seconds != null) {
        final now = DateTime.now();
        final currentTime = DateTime(
            now.year, now.month, now.day, now.hour, now.minute, now.second);
        final timeDifference =
            Duration(hours: hours, minutes: minutes, seconds: seconds);
        final formattedTime = currentTime.subtract(timeDifference);
        return formattedTime;
      }
    }
    return DateTime.now();
  }

  factory CustomTimestamp.fromMap(Map<dynamic, dynamic> map) {
    double temperature = 0.0;
    double humidity = 0.0;

    if (map['Temperature'] != null) {
      temperature = double.tryParse(map['Temperature'].toString()) ?? 0.0;
    }

    if (map['Humidity'] != null) {
      humidity = double.tryParse(map['Humidity'].toString()) ?? 0.0;
    }

    return CustomTimestamp(
      temperature: temperature,
      humidity: humidity,
      time: map['Time'] ?? '',
    );
  }
}

class TimestampScreen extends StatefulWidget {
  @override
  _TimestampScreenState createState() => _TimestampScreenState();
}

class _TimestampScreenState extends State<TimestampScreen> {
  late DatabaseReference _databaseReference;
  List<CustomTimestamp> _timestamps = [];

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref();
    _fetchTimestamps();
  }

  void _fetchTimestamps() {
    _databaseReference.child('Data').child('Timestamp').onValue.listen(
      (event) {
        try {
          var dataSnapshot = event.snapshot;
          var timestampData = dataSnapshot.value as Map<dynamic, dynamic>?;
          if (timestampData != null) {
            var timestamps = timestampData.entries.map((entry) {
              var key = entry.key as String;
              var value = entry.value as Map<dynamic, dynamic>;
              return CustomTimestamp.fromMap(value);
            }).toList();

            timestamps.sort((a, b) => b.formattedTime.compareTo(a
                .formattedTime)); // Sort timestamps in descending order based on time

            setState(() {
              _timestamps = timestamps;
            });
          }
        } catch (error, stackTrace) {
          print('Error: $error');
          print('Stack Trace: $stackTrace');
        }
      },
      onError: (error) {
        print('Stream error: $error');
      },
      onDone: () {
        print('Stream closed');
      },
    );
  }

  void _clearHistory() {
    setState(() {
      _timestamps.clear();
    });
    _databaseReference.child('Data').child('Timestamp').remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timestamps'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _timestamps.length,
        itemBuilder: (context, index) {
          //var timestamp = _timestamps[index];
          var timestamp = _timestamps.reversed.toList()[index];
          String fanStatus;
          String lampStatus;

          if (timestamp.temperature < 27) {
            fanStatus = 'OFF';
            lampStatus = 'ON';
          } else if (timestamp.temperature <= 45) {
            fanStatus = 'ON';
            lampStatus = 'ON';
          } else {
            fanStatus = 'ON';
            lampStatus = 'OFF';
          }
          return ListTile(
            title: Text('Temperature: ${timestamp.temperature}°C'),
            subtitle: Text('Humidity: ${timestamp.humidity}%'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Time: ${timestamp.time}'),
                Text('FAN: $fanStatus'),
                Text('LAMP: $lampStatus'),
              ],
            ),
          );
        },
      ),
    );
  }
}
