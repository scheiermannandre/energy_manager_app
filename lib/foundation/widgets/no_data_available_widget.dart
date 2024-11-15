import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';

class NoDataAvailableWidget extends StatelessWidget {
  const NoDataAvailableWidget({
    required this.onRefresh,
    super.key,
  });
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 64),
        Text('No data available'.hardCoded),
        ElevatedButton(
          onPressed: onRefresh,
          child: Text('Try again'.hardCoded),
        ),
      ].intersperse(const SizedBox(height: 16)),
    );
  }
}
