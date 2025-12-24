class CreatePasswordState {
  final bool obscurePassword;
  final bool obscureConfirm;
  final double strength;

  CreatePasswordState({
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.strength = 0.0,
  });

  CreatePasswordState copyWith({
    bool? obscurePassword,
    bool? obscureConfirm,
    double? strength,
  }) {
    return CreatePasswordState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      strength: strength ?? this.strength,
    );
  }
}
