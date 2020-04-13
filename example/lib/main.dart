import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rtmp/flutter_rtmp.dart';

void main() => runApp(FirstScreen());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class FirstScreen extends StatefulWidget {
  @override
  _FState createState() => _FState();
}

class _FState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: FirstWidget(),
    ));
  }
}

class FirstWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('Open stream'),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (c) => MyApp()));
        },
      ),
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  RtmpManager _manager;
  int count = 0;
  Timer _timer;
  AppLifecycleState oldState;
  String url = 'rtmp://63.32.87.150:1935/livestream/04e96cb8-7d56-11ea-9e4f-1387759d23f8';
  @override
  void initState() {
    super.initState();
    _manager = RtmpManager(onCreated: () {
      print("--- view did created ---");
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _manager.stopLive();
    _manager.dispose();
    _manager = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('STATE $state');
    if (AppLifecycleState.paused == state) {
      _manager.stopLive();
      print('STOPPED');
    } else if (AppLifecycleState.resumed == state &&
        oldState == AppLifecycleState.paused) {
      _manager.living(
          url:url);
      print('RESUMED');
    }
    oldState = state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              RtmpView(
                manager: _manager,
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _manager.living(
                            url:
                            url);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        _manager.pauseLive();
                        if (_timer != null) {
                          _timer.cancel();
                          _timer = null;
                        }
                        ;
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        _manager.stopLive();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.switch_camera),
                      onPressed: () {
                        _manager.switchCamera();
                      },
                    ),
                    Container(
                      child: Text(
                        "${count ~/ 60}:${count % 60}",
                        style: TextStyle(fontSize: 17, color: Colors.blue),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
