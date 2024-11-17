import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUI<T> on AsyncValue<T> {
  Future<bool?> showAlertDialogOnError(BuildContext context) async {
    if (!isRefreshing && hasError) {
      // automatically close the dialog after 10 seconds
      // this was actually necessary to prevent the dialog from being shown over
      // and over again, when the user is not closing it.
      // this especially necessary when streaming data up to the ui.
      Future.delayed(10.seconds, () {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      });
      final exceptionData = _errorMessage(error);
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(exceptionData.title),
            content: Text(exceptionData.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'.hardCoded),
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  AppExceptionData _errorMessage(Object? error) {
    if (error is AppException) {
      return AppExceptionData(
        title: error.data.title,
        message: error.data.message,
      );
    } else {
      return AppExceptionData(
        title: 'Error'.hardCoded,
        message: error.toString(),
      );
    }
  }

  R customWhen<R>({
    required R Function(T data) data,
    required R Function(Object? error, StackTrace? stackTrace) error,
    required R Function() loading,
  }) {
    if (isReloading || isRefreshing) {
      return loading();
    }
    return when(
      data: data,
      error: error,
      loading: loading,
    );
  }
}
