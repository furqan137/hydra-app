import 'package:flutter/material.dart';
import '../albums_controller.dart';

class AlbumsTopBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final void Function(AlbumSortType sort) onSortChanged;
  final void Function(AlbumViewType view) onViewChanged;
  final VoidCallback onCreateAlbum;

  const AlbumsTopBar({
    super.key,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onViewChanged,
    required this.onCreateAlbum,
  });

  @override
  State<AlbumsTopBar> createState() => _AlbumsTopBarState();
}

class _AlbumsTopBarState extends State<AlbumsTopBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          /// BACK (only in search mode)
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _closeSearch,
            ),

          /// TITLE / SEARCH FIELD
          Expanded(
            child: _isSearching ? _searchField() : _title(),
          ),

          /// SEARCH ICON
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _openSearch,
            ),

          /// MENU
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _openMenu(context),
            ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _title() {
    return const Text(
      'Albums',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search albums…',
        hintStyle: const TextStyle(color: Colors.white54),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () {
            _searchController.clear();
            widget.onSearchChanged('');
          },
        )
            : null,
      ),
      onChanged: widget.onSearchChanged,
    );
  }

  // ================= ACTIONS =================

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    setState(() => _isSearching = false);
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlbumsMenuSheet(
        onSortChanged: widget.onSortChanged,
        onViewChanged: widget.onViewChanged,
        onCreateAlbum: widget.onCreateAlbum,
      ),
    );
  }
}

// ================= MENU SHEET =================
class _AlbumsMenuSheet extends StatelessWidget {
  final void Function(AlbumSortType) onSortChanged;
  final void Function(AlbumViewType) onViewChanged;
  final VoidCallback onCreateAlbum;

  const _AlbumsMenuSheet({
    required this.onSortChanged,
    required this.onViewChanged,
    required this.onCreateAlbum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF101B2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            context,
            Icons.sort_by_alpha,
            'Sort A–Z',
                () => onSortChanged(AlbumSortType.nameAsc),
          ),
          _item(
            context,
            Icons.sort,
            'Sort Z–A',
                () => onSortChanged(AlbumSortType.nameDesc),
          ),
          const Divider(color: Colors.white24),
          _item(
            context,
            Icons.view_list,
            'List View',
                () => onViewChanged(AlbumViewType.list),
          ),
          _item(
            context,
            Icons.grid_view,
            'Grid View',
                () => onViewChanged(AlbumViewType.grid),
          ),
          const Divider(color: Colors.white24),
          _item(
            context,
            Icons.add,
            'Create Album',
            onCreateAlbum,
            highlight: true,
          ),
        ],
      ),
    );
  }

  // ✅ CONTEXT IS NOW PASSED SAFELY
  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool highlight = false,
      }) {
    return ListTile(
      onTap: () {
        Navigator.pop(context); // ✅ NOW VALID
        onTap();
      },
      leading: Icon(
        icon,
        color: highlight ? const Color(0xFF0FB9B1) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: highlight ? Colors.white : Colors.white70,
          fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

