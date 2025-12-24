import 'package:flutter/foundation.dart';

@immutable
class BiometricState {
  final bool isEnabled;
  final String? error;

  const BiometricState({
    this.isEnabled = false,
    this.error,
  });

  BiometricState copyWith({
    bool? isEnabled,
    String? error,
    bool clearError = false,
  }) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
