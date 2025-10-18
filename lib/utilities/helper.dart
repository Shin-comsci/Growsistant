double mapRangeClamp({
  required double value,
  required double inMin,
  required double inMax,
  double outMin = 0,
  double outMax = 100,
}) {
  final t = ((value - inMin) / (inMax - inMin)).clamp(0, 1);
  return outMin + (outMax - outMin) * t;
}

String statusFromPercent(double p, {double low=30, double high=70, String okLabel='OK', String highLabel='High', String lowLabel='Low'}) {
  if (p < low) return lowLabel;
  if (p > high) return highLabel;
  return okLabel;
}

double calculateHealthPercentage({
  required double current,
  required double upperThreshold,
  required double lowerThreshold,
  required double min,
  required double max,
}) {
  if (current > lowerThreshold && current < upperThreshold) {
    return 100;
  } else if (current <= lowerThreshold) {
    return ((current - min) / (lowerThreshold - min)) * 100;
  } else {
    return ((max - current) / (max - upperThreshold)) * 100;
  }
}
