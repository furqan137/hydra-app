import 'package:flutter/material.dart';

class CreateAlbumDialog extends StatefulWidget {
  final void Function(String name) onCreate;

  const CreateAlbumDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark
          ? colors.surface
          : colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Create album',
        style: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: _controller,
        style: TextStyle(
          color: colors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Vacation Photos',
          hintStyle: TextStyle(
            color: colors.onSurface.withOpacity(0.5),
          ),
          filled: true,
          fillColor: isDark
              ? colors.surfaceVariant
              : colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) widget.onCreate(name);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
