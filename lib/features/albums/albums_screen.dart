import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'albums_controller.dart';
import 'albums_state.dart';
import 'album_detail_screen.dart';
import 'widgets/album_card.dart';
import 'widgets/create_album_dialog.dart';
import 'widgets/albums_top_bar.dart';
import '../../../data/models/album_model.dart';

import 'widgets/album_grid_card.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlbumsState(),
      child: const _AlbumsScreenBody(),
    );
  }
}

class _AlbumsScreenBody extends StatefulWidget {
  const _AlbumsScreenBody();

  @override
  State<_AlbumsScreenBody> createState() => _AlbumsScreenBodyState();
}

class _AlbumsScreenBodyState extends State<_AlbumsScreenBody> {
  late final AlbumsController controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = AlbumsController(context.read<AlbumsState>());
  }

  // ================= CREATE =================

  void _showCreateAlbumDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateAlbumDialog(
        onCreate: (name) {
          controller.createAlbum(name);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlbumsState>(
      builder: (context, state, _) {
        final List<Album> albums = _searchQuery.isEmpty
            ? state.albums
            : controller.searchAlbums(_searchQuery);

        return Scaffold(
          backgroundColor: Colors.transparent,

          floatingActionButton: albums.isNotEmpty
              ? FloatingActionButton(
            backgroundColor: const Color(0xFF0FB9B1),
            onPressed: _showCreateAlbumDialog,
            child: const Icon(Icons.add, color: Colors.white),
          )
              : null,

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF050B18),
                  Color(0xFF0FB9B1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  /// ✅ TOP BAR (INLINE SEARCH)
                  AlbumsTopBar(
                    onSearchChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSortChanged: controller.sortAlbums,
                    onViewChanged: controller.changeView,
                    onCreateAlbum: _showCreateAlbumDialog,
                  ),

                  /// ================= CONTENT =================
                  Expanded(
                    child: albums.isEmpty
                        ? _emptyState()
                        : state.viewType == AlbumViewType.list
                        ? _listView(albums)
                        : _gridView(albums),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= LIST VIEW =================

  Widget _listView(List<Album> albums) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return AlbumCard(
          album: album,
          onTap: () => _openAlbum(album),
        );
      },
    );
  }

  // ================= GRID VIEW =================

  Widget _gridView(List<Album> albums) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.72, // ✅ FIXED RATIO
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return AlbumGridCard(
          album: album,
          onTap: () => _openAlbum(album),
          onRename: () => controller.renameAlbum(context, album),
          onDelete: () => controller.deleteAlbum(context, album),
        );
      },
    );
  }


  // ================= OPEN =================

  void _openAlbum(Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumDetailScreen(album: album),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No albums yet',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0FB9B1),
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            onPressed: _showCreateAlbumDialog,
            child: const Text(
              'Create Album',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SEARCH =================

class AlbumSearchDelegate extends SearchDelegate {
  final AlbumsController controller;

  AlbumSearchDelegate(this.controller);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = controller.searchAlbums(query);
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = controller.searchAlbums(query);
    return _buildList(results);
  }

  Widget _buildList(List<Album> albums) {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(albums[i].name),
      ),
    );
  }
}
