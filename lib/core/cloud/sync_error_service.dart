import 'sync_error_models.dart';

class SyncErrorService {
  final List<SyncUserError> _recentErrors = [];
  SyncUserError? _latestError;

  SyncUserError? get latestError => _latestError;

  List<SyncUserError> get recentErrors => List.unmodifiable(_recentErrors);

  SyncUserError recordError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    return recordUserError(
      SyncUserError.fromException(
        error,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }

  SyncUserError recordUserError(SyncUserError error) {
    _latestError = error;
    _recentErrors.insert(0, error);
    if (_recentErrors.length > 20) {
      _recentErrors.removeRange(20, _recentErrors.length);
    }
    return error;
  }

  void clearLatestError() {
    _latestError = null;
  }

  void clearAllErrors() {
    _latestError = null;
    _recentErrors.clear();
  }
}
