import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoadingErrorWidget extends HookWidget {
  const LoadingErrorWidget({
    required this.onReload,
    required this.error,
    this.stackTrace,
    super.key,
  });
  final VoidCallback onReload;
  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64),
          Text('An Error occurred while loading Data'.hardCoded),
          ElevatedButton(
            onPressed: onReload,
            child: Text('Try again'.hardCoded),
          ),
          ExpansionPanelList(
            elevation: 0,
            expansionCallback: (int index, bool isExpandedValue) {
              isExpanded.value = isExpandedValue;
            },
            children: [
              ExpansionPanel(
                canTapOnHeader: true,
                highlightColor: Colors.transparent,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Center(child: Text('Show Details'.hardCoded));
                },
                body: Column(
                  children: [
                    Text('Error: $error'.hardCoded),
                    if (stackTrace != null)
                      Text('Stacktrace: $stackTrace'.hardCoded),
                  ],
                ),
                isExpanded: isExpanded.value,
              ),
            ],
          ),
        ].intersperse(const SizedBox(height: 16)),
      ),
    );
  }
}

class AppStartUpLoadingErrorWidget extends StatelessWidget {
  const AppStartUpLoadingErrorWidget({
    required this.onReload,
    required this.error,
    this.stackTrace,
    super.key,
  });
  final VoidCallback onReload;
  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LoadingErrorWidget(
          error: error,
          stackTrace: stackTrace,
          onReload: onReload,
        ),
      ),
    );
  }
}
