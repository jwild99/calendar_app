import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../const/constant.dart';
import 'package:google_fonts/google_fonts.dart';


class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  int secondsRemaining = 0;
  int minutesRemaining = 25;
  int numberOfPomodoros = 0;
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
          numberOfPomodoros++;
          countdownTimer!.cancel();
          setState(() {
            if(numberOfPomodoros < 4){
            message = "Time's up! Starting 5-minute break.";
            minutesRemaining = 5;
            secondsRemaining = minutesRemaining * 60;
            }
            else{
              numberOfPomodoros = 0;
              message = "You've completed 4 pomodoros, enjoy a longer break";
              minutesRemaining = 30;
              secondsRemaining = minutesRemaining * 60;
            }
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
      backgroundColor: const Color.fromARGB(255, 72, 161, 82),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${formatter.format(secondsRemaining ~/ 60)} : ${formatter.format(secondsRemaining % 60)}",
                style: GoogleFonts.teko(
                  color: Colors.white,
                  fontSize: 55,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/tomatotimer.png',
            width: 600.0,
            height: 240.0,
          ),
          SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.teko(
              color: cardBackgroundColor,
              fontSize: 30,
              letterSpacing: 5,
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(500.0),
                    side: BorderSide(color: cardBackgroundColor),
                  ),
                  padding: EdgeInsets.all(40.0),
                ),
                child: Text(
                  "Stop",
                  style: GoogleFonts.teko(
                    color: Colors.white,
                    fontSize: 30,
                    letterSpacing: 5,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: beginTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(500.0),
                    ),
                  padding: EdgeInsets.all(40.0),
                ),
                child: Text(
                  "Start",
                  style: GoogleFonts.teko(
                    color: Colors.white,
                    fontSize: 30,
                    letterSpacing: 5,
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
      backgroundColor: const Color.fromARGB(255, 24, 48, 20),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text("Pomodoro Timer"), // Or your custom title
        ],
      ),
    );
  }
}


