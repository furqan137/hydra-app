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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
    isDark ? const Color(0xFF050B18) : Colors.white;
    final textColor =
    isDark ? Colors.white : const Color(0xFF111827);
    final iconColor =
    isDark ? Colors.white : const Color(0xFF374151);

    return Container(
      color: backgroundColor, // ✅ EXPLICIT BACKGROUND
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: _closeSearch,
            ),

          Expanded(
            child: _isSearching
                ? _searchField(
              textColor: textColor,
              hintColor: textColor.withOpacity(0.5),
              iconColor: iconColor,
            )
                : _title(textColor),
          ),

          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: iconColor),
              onPressed: _openSearch,
            ),

          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.more_vert, color: iconColor),
              onPressed: () => _openMenu(context),
            ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _title(Color textColor) {
    return Text(
      'Albums',
      style: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _searchField({
    required Color textColor,
    required Color hintColor,
    required Color iconColor,
  }) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search albums…',
        hintStyle: TextStyle(color: hintColor),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: iconColor.withOpacity(0.7)),
          onPressed: () {
            _searchController.clear();
            widget.onSearchChanged('');
            setState(() {});
          },
        )
            : null,
      ),
      onChanged: (v) {
        widget.onSearchChanged(v);
        setState(() {});
      },
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface, // ✅ follows theme
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(context, Icons.sort_by_alpha, 'Sort A–Z',
                  () => onSortChanged(AlbumSortType.nameAsc)),
          _item(context, Icons.sort, 'Sort Z–A',
                  () => onSortChanged(AlbumSortType.nameDesc)),

          Divider(color: colors.onSurface.withOpacity(0.12)),

          _item(context, Icons.view_list, 'List View',
                  () => onViewChanged(AlbumViewType.list)),
          _item(context, Icons.grid_view, 'Grid View',
                  () => onViewChanged(AlbumViewType.grid)),

          Divider(color: colors.onSurface.withOpacity(0.12)),

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

  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool highlight = false,
      }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      leading: Icon(
        icon,
        color: highlight
            ? colors.primary
            : colors.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: highlight
              ? colors.onSurface
              : colors.onSurface.withOpacity(0.7),
          fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
