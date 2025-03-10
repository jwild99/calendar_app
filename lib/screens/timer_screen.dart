import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../const/constant.dart';


class TimerScreen extends StatefulWidget {
  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  int secondsRemaining = 0;
  int minutesRemaining = 25;
  Timer? countdownTimer;
  final formatter = NumberFormat("00");
  String message = "";

  void resetTimer() {
    countdownTimer?.cancel();
    setState(() {
      secondsRemaining = 0;
      minutesRemaining = 25;
      message = "";
    });
  }

  void beginTimer() {
    if (countdownTimer != null && countdownTimer!.isActive) {
      resetTimer();
    }
    setState(() {
      secondsRemaining = minutesRemaining * 60;
      message = "";
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          countdownTimer!.cancel();
          setState(() {
            message = "Time's up! Starting 5-minute break.";
            minutesRemaining = 5;
            secondsRemaining = minutesRemaining * 60;
          });
          beginTimer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${formatter.format(secondsRemaining ~/ 60)} : ${formatter.format(secondsRemaining % 60)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cardBackgroundColor,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 280),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBackgroundColor,
                  shape: CircleBorder(
                    side: BorderSide(color: cardBackgroundColor),
                  ),
                  padding: EdgeInsets.all(40.0),
                ),
                child: Text(
                  "Stop",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: beginTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBackgroundColor,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(40.0),
                ),
                child: Text(
                  "Start",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}


