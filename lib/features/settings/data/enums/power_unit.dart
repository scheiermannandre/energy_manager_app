enum PowerUnit {
  watts,
  kilowatts;

  String get label {
    switch (this) {
      case PowerUnit.watts:
        return 'W';
      case PowerUnit.kilowatts:
        return 'kW';
    }
  }
}
