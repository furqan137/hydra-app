import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateAlbumDialog extends StatefulWidget {
  final void Function(String name) onCreate;
  const CreateAlbumDialog({required this.onCreate});

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF101B2B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Create album', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Vacation Photos',
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF192841),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0FB9B1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) widget.onCreate(name);
          },
          child: const Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
