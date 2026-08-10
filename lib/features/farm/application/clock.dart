abstract class Clock {
  int get nowMs;
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  int get nowMs => DateTime.now().millisecondsSinceEpoch;
}
