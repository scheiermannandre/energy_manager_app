import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:energy_manager_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingErrorWidget extends StatelessWidget {
  const LoadingErrorWidget({
    required this.onReload,
    required this.error,
    this.stackTrace,
    super.key,
  });
  final VoidCallback onReload;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64),
          Text(
            'An Error occurred. Please try again later.'.hardCoded,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: onReload,
            child: Text('Try again'.hardCoded),
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
  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(appStartUpProvider).showAlertDialogOnError(context);
            });
            return LoadingErrorWidget(
              error: error,
              stackTrace: stackTrace,
              onReload: onReload,
            );
          },
        ),
      ),
    );
  }
}
