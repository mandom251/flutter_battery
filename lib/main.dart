import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter battery',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo battery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('new/battery');
  final String _statusValue="LOW";
  String _batteryLife = 'Unknown battery life.';
  String statusBattery="";
  double _startHeight=20;
  Future<void> _getBatteryLife() async {
    String batteryLife;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      if(_startHeight<=result){
        statusBattery=_statusValue;
      }else{
        statusBattery="";
      }
      batteryLife = 'Battery life at $result % .';
    } on PlatformException catch (e) {
      batteryLife = "Failed to get battery life: '${e.message}'.";
    } on Error catch(e){
      batteryLife = "Failed to get battery life: '$e'.";
    }

    setState(() {
      _batteryLife = batteryLife;
    });
  }

  Color getColor(){
     if(statusBattery==_statusValue){
       return Colors.red;
     }

     return Colors.white;

  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: getColor(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text( "$statusBattery${statusBattery!=""?" ":""}""${_startHeight.floor().toString()}",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Slider(
              value: _startHeight,
              min: 1,
              max: 100,
              onChanged: (newHeight) {
                setState(() {
                  _startHeight = newHeight;
                  _startHeight.toInt();
                  _getBatteryLife();
                });
              },
            ),
            ElevatedButton(
              onPressed: _getBatteryLife,
              child: const Text('Get Battery life'),
            ),
            Text(_batteryLife,
              style: Theme.of(context).textTheme.headline2,
            ),
          ],
        ),
      ),
    );
  }
}
