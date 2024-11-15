import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueExtension<T> on AsyncValue<T> {
  R customWhen<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) {
    if (isRefreshing) return loading();

    return when(
      data: data,
      loading: loading,
      error: error,
    );
  }
}
