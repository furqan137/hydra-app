import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/vault_file.dart';

class VaultPickerScreen extends StatefulWidget {
  final String albumId;

  const VaultPickerScreen({
    super.key,
    required this.albumId,
  });

  @override
  State<VaultPickerScreen> createState() => _VaultPickerScreenState();
}

class _VaultPickerScreenState extends State<VaultPickerScreen> {
  final List<VaultFile> _vaultFiles = [];
  final Set<int> _selectedIndexes = {};

  bool _loading = true;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _loadVaultFiles();
  }

  // ================= LOAD VAULT FILES =================

  Future<void> _loadVaultFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('vault_files'); // ✅ CORRECT KEY

    if (raw == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final List decoded = jsonDecode(raw);

    final files = decoded
        .map<VaultFile>((e) => VaultFile.fromJson(e))
        .where((v) => v.file.existsSync())
        .toList();

    if (!mounted) return;

    setState(() {
      _vaultFiles
        ..clear()
        ..addAll(files);
      _loading = false;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF050B18),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                child: Row(
                  children: [
                    const Text(
                      'Select from Vault',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                      _selectedIndexes.isEmpty ? null : _onDone,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: _selectedIndexes.isEmpty
                              ? Colors.white38
                              : const Color(0xFF0FB9B1),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // ================= CONTENT =================
              Expanded(
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0FB9B1),
                  ),
                )
                    : _vaultFiles.isEmpty
                    ? const Center(
                  child: Text(
                    'No files in vault',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                    ),
                  ),
                )
                    : GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 24),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _vaultFiles.length,
                  itemBuilder: (_, index) {
                    final vaultFile = _vaultFiles[index];
                    final selected =
                    _selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () => _toggle(index),
                      child: Stack(
                        children: [
                          _thumbnail(vaultFile, selected),
                          if (selected)
                            const Positioned(
                              top: 6,
                              right: 6,
                              child: Icon(
                                Icons.check_circle,
                                color:
                                Color(0xFF0FB9B1),
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= THUMBNAIL =================

  Widget _thumbnail(VaultFile vaultFile, bool selected) {
    final imageProvider = vaultFile.type == VaultFileType.video &&
        vaultFile.thumbnailPath != null &&
        File(vaultFile.thumbnailPath!).existsSync()
        ? FileImage(File(vaultFile.thumbnailPath!))
        : FileImage(vaultFile.file);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: selected
              ? const Color(0xFF0FB9B1)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: vaultFile.type == VaultFileType.video
          ? const Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.videocam,
            size: 18,
            color: Colors.white70,
          ),
        ),
      )
          : null,
    );
  }

  // ================= ACTIONS =================

  void _toggle(int index) {
    setState(() {
      _selectedIndexes.contains(index)
          ? _selectedIndexes.remove(index)
          : _selectedIndexes.add(index);
    });
  }

  void _onDone() {
    final selectedFiles =
    _selectedIndexes.map((i) => _vaultFiles[i]).toList();

    Navigator.pop(context, selectedFiles); // ✅ RETURN VaultFile list
  }
}
