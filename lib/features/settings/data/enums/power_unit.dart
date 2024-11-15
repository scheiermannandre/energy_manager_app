import 'package:energy_manager_app/foundation/foundation.dart';

enum PowerUnit {
  watts,
  kilowatts;

  String get label {
    switch (this) {
      case PowerUnit.watts:
        return 'W'.hardCoded;
      case PowerUnit.kilowatts:
        return 'kW'.hardCoded;
    }
  }
}
