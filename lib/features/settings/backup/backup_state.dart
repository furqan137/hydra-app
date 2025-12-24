class BackupState {
  final bool isProcessing;

  const BackupState({this.isProcessing = false});

  BackupState copyWith({bool? isProcessing}) {
    return BackupState(
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
