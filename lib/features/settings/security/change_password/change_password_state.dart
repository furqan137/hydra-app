class ChangePasswordState {
  final bool obscureOld;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool loading;

  const ChangePasswordState({
    this.obscureOld = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.loading = false,
  });

  ChangePasswordState copyWith({
    bool? obscureOld,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? loading,
  }) {
    return ChangePasswordState(
      obscureOld: obscureOld ?? this.obscureOld,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      loading: loading ?? this.loading,
    );
  }
}
