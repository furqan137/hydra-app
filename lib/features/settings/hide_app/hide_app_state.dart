class HideAppState {
  /// Whether app is hidden (fake dialer enabled)
  final bool isHidden;

  /// Secret dial code shown in settings (UX only)
  final String dialCode;

  /// Used for validation / UI feedback
  final bool isDialCodeValid;

  const HideAppState({
    this.isHidden = false,
    this.dialCode = '*#*#13710#*#*',
    this.isDialCodeValid = true,
  });

  HideAppState copyWith({
    bool? isHidden,
    String? dialCode,
    bool? isDialCodeValid,
  }) {
    return HideAppState(
      isHidden: isHidden ?? this.isHidden,
      dialCode: dialCode ?? this.dialCode,
      isDialCodeValid: isDialCodeValid ?? this.isDialCodeValid,
    );
  }
}
