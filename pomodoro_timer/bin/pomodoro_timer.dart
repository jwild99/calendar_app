import 'package:pomodoro_timer/pomodoro_timer.dart' as pomodoro_timer;
import 'dart:async';



void startCountdown(int seconds) {
  Timer.periodic(Duration(seconds: 1), (Timer timer) {
    if (seconds > 0) {
      print('$seconds seconds left');
      seconds--;
    } else {
      print("Time's up!");
      timer.cancel();
    }
  });
  }


void main(List<String> arguments) {
  startCountdown(10);
}
