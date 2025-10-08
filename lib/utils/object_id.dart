import 'dart:math';

class ObjectId {
  static final Random _random = Random();
  static int _counter = _random.nextInt(0xFFFFFF);
  static final int _pid = _random.nextInt(0xFFFF);
  static final String _machineId = _generateMachineId();

  static String _generateMachineId() {
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }

  static String _getTimestamp() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .toRadixString(16)
        .padLeft(8, '0');
  }

  static String _getIncrement() {
    _counter = (_counter + 1) & 0xFFFFFF;
    return _counter.toRadixString(16).padLeft(6, '0');
  }

  String toHexString() {
    final timestamp = _getTimestamp();
    final machineId = _machineId;
    final processId = _pid.toRadixString(16).padLeft(4, '0');
    final increment = _getIncrement();

    return '$timestamp$machineId$processId$increment';
  }
}
