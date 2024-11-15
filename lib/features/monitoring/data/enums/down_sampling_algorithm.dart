import 'package:energy_manager_app/foundation/foundation.dart';

enum DownSamplingAlgorithm {
  none,
  lttb;

  String get label {
    switch (this) {
      case DownSamplingAlgorithm.none:
        return 'None'.hardCoded;
      case DownSamplingAlgorithm.lttb:
        return 'LTTB'.hardCoded;
    }
  }
}
