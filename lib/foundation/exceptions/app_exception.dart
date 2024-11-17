// ignore_for_file: lines_longer_than_80_chars

import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
class AppException with _$AppException implements Exception {
  const factory AppException.unexpected() = UnexpectedAppException;
  const factory AppException.network() = NetworkAppException;
  const factory AppException.timeout() = TimeoutAppException;
  const factory AppException.versionOutdated() = VersionOutdatedAppException;
}

extension AppExceptionDetails on AppException {
  AppExceptionData get data {
    return when(
      unexpected: () => AppExceptionData(
        title: 'Unexpected Error'.hardCoded,
        message:
            'Something went wrong. We have been notified and are working on. In the meantime please try again.'
                .hardCoded,
      ),
      network: () => AppExceptionData(
        title: 'No Internet Connection'.hardCoded,
        message:
            'It seems you are not connected to the internet. Please check your connection and try again.'
                .hardCoded,
      ),
      timeout: () => AppExceptionData(
        title: 'Timeout Error'.hardCoded,
        message:
            'It took too long to load your data. It might be that your network is too slow or our Servers experience issues. We are working on it. In the meantime please try again later.'
                .hardCoded,
      ),
      versionOutdated: () => AppExceptionData(
        title: 'App Version Outdated'.hardCoded,
        message:
            'There was a problem with the data. Please update the app and try again.'
                .hardCoded,
      ),
    );
  }
}

class AppExceptionData {
  AppExceptionData({required this.message, required this.title});

  final String message;
  final String title;

  @override
  String toString() => 'title: $title -> message: $message)';
}
