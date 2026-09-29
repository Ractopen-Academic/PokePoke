import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/core/services/cache_service.dart';
import 'package:pokepoke/core/services/favourite_service.dart';
import 'package:pokepoke/features/dashboard/favourite/favourite_screen.dart';
import 'package:pokepoke/features/dashboard/home/widgets/pokemon_detail_sheet.dart';

// ─── Type → colour ───────────────────────────────────────────────────────────
const Map<String, Color> _typeColors = {
  'fire': Color(0xFFFF6B35),
  'water': Color(0xFF4FC3F7),
  'grass': Color(0xFF66BB6A),
  'electric': Color(0xFFFFD600),
  'psychic': Color(0xFFEC407A),
  'ice': Color(0xFF80DEEA),
  'dragon': Color(0xFF7C4DFF),
  'dark': Color(0xFF546E7A),
  'fairy': Color(0xFFF48FB1),
  'fighting': Color(0xFFFF7043),
  'poison': Color(0xFFAB47BC),
  'ground': Color(0xFFD4A574),
  'flying': Color(0xFF90CAF9),
  'bug': Color(0xFF8BC34A),
  'rock': Color(0xFFBCAAA4),
  'ghost': Color(0xFF7986CB),
  'steel': Color(0xFF90A4AE),
  'normal': Color(0xFFBDBDBD),
};

Color _typeColor(String type) => _typeColors[type] ?? const Color(0xFFBDBDBD);

// ─── Home Screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final List<PokemonEntry> preloadedPokemon;
  const HomeScreen({super.key, required this.preloadedPokemon});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final AnimationController _bgController;

  List<PokemonEntry> _allPokemon = [];
  List<PokemonEntry> _filtered = [];
  String _selectedType = 'All';
  int _navIndex = 0;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _searchingOnline = false;
  String? _onlineSearchError;

  static const List<String> _typeFilters = [
    'All', 'fire', 'water', 'grass', 'electric',
    'psychic', 'dragon', 'fighting', 'poison', 'ghost',
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _allPokemon = List.from(widget.preloadedPokemon);
    _applyFilter();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    final cleanId = q.replaceAll('#', '');
    final targetId = int.tryParse(cleanId);

    setState(() {
      _onlineSearchError = null;
      _filtered = _allPokemon.where((p) {
        final matchSearch = q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.formattedId.toLowerCase().contains(q) ||
            (targetId != null && p.id == targetId);
        final matchType =
            _selectedType == 'All' || p.types.contains(_selectedType);
        return matchSearch && matchType;
      }).toList();
    });
  }

  Future<void> _searchOnline() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty || _searchingOnline) return;

    setState(() {
      _searchingOnline = true;
      _onlineSearchError = null;
    });

    final found = await PokemonService.fetchSinglePokemon(query);

    if (!mounted) return;

    if (found != null) {
      setState(() {
        if (!_allPokemon.any((p) => p.id == found.id)) {
          _allPokemon.add(found);
          _allPokemon.sort((a, b) => a.id.compareTo(b.id));
        }
        _searchingOnline = false;
        _onlineSearchError = null;
      });
      await CacheService.savePokemon(
          _allPokemon.map((p) => p.toMap()).toList());
      _applyFilter();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF262640),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF66BB6A), size: 18),
              const SizedBox(width: 8),
              Text(
                'Indexed ${found.displayName} (${found.formattedId})!',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() {
        _searchingOnline = false;
        _onlineSearchError =
            'No Pokémon found with name or ID "$query" on PokéAPI.';
      });
    }
  }

  void _selectType(String type) {
    setState(() => _selectedType = type);
    _applyFilter();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final updated = await PokemonService.fetchMore(
      offset: _allPokemon.length,
      existing: _allPokemon,
    );
    if (mounted) {
      setState(() {
        _allPokemon = updated;
        _hasMore = updated.length > _allPokemon.length ||
            updated.last.id < 1025;
        _loadingMore = false;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          _AnimatedBg(controller: _bgController),
          SafeArea(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return FavouriteScreen(
          allPokemon: _allPokemon,
          typeColors: _typeColors,
          onExplore: () => setState(() => _navIndex = 0),
        );
      case 2:
        return _buildPlaceholderTab(
          'BATTLE ARENA',
          'Battle mode coming soon in a future update!',
          Icons.sports_kabaddi,
        );
      case 3:
        return _buildPlaceholderTab(
          'TRAINER PROFILE',
          'Trainer profile & achievements coming soon!',
          Icons.person_outline,
        );
      case 0:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTypeFilter(),
            _buildSectionTitle(),
            Expanded(child: _buildGrid()),
          ],
        );
    }
  }

  Widget _buildPlaceholderTab(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            NeoPopTiltedButton(
              isFloating: true,
              onTapUp: () => setState(() => _navIndex = 0),
              color: const Color(0xFFFF1C1C),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'BACK TO POKÉDEX',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            SvgPicture.asset('assets/images/pokeball.svg',
                width: 34, height: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PokéPoke',
                    style: GoogleFonts.pressStart2p(
                        color: Colors.white, fontSize: 13)),
                Text("Gotta catch 'em all!",
                    style: GoogleFonts.inter(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(color: Colors.white),
            onSubmitted: (_) => _searchOnline(),
            decoration: InputDecoration(
              hintText: 'Search Pokémon name or #ID…',
              hintStyle:
                  GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white38, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _applyFilter();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.travel_explore,
                              color: Color(0xFFFFCC00), size: 18),
                          tooltip: 'Search Online',
                          onPressed: _searchOnline,
                        ),
                      ],
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 11),
            ),
          ),
        ),
      ),
    );
  }

  // ── Type filter chips ────────────────────────────────────────────────────────
  Widget _buildTypeFilter() {
    return FadeInDown(
      delay: const Duration(milliseconds: 150),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _typeFilters.length,
          separatorBuilder: (_, i) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final type = _typeFilters[i];
            final selected = _selectedType == type;
            final color =
                type == 'All' ? Colors.white : _typeColor(type);
            return GestureDetector(
              onTap: () => _selectType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: selected ? color : Colors.white12),
                ),
                child: Text(
                  type == 'All'
                      ? 'All'
                      : type[0].toUpperCase() + type.substring(1),
                  style: GoogleFonts.inter(
                    color: selected
                        ? (color == Colors.white
                            ? Colors.black
                            : Colors.white)
                        : Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Text(
        '${_filtered.length} Pokémon found',
        style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── Grid ────────────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    if (_filtered.isEmpty) {
      final isSearching = _searchCtrl.text.trim().isNotEmpty;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/pokeball.svg',
                width: 60,
                height: 60,
                colorFilter: const ColorFilter.mode(
                    Colors.white24, BlendMode.srcIn),
              ),
              const SizedBox(height: 14),
              Text(
                isSearching
                    ? 'No local match for "${_searchCtrl.text.trim()}"'
                    : 'No Pokémon found',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isSearching) ...[
                const SizedBox(height: 8),
                Text(
                  'Search PokeAPI directly to find, fetch, and permanently index this Pokémon!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                if (_onlineSearchError != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _onlineSearchError!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                NeoPopTiltedButton(
                  isFloating: true,
                  onTapUp: _searchOnline,
                  color: const Color(0xFF6C5CE7),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: _searchingOnline
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SEARCHING POKEAPI...',
                                style: GoogleFonts.pressStart2p(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.travel_explore,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Search Online for "${_searchCtrl.text.trim()}"',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Total items = filtered pokemon + load-more footer
    final itemCount = _filtered.length + 1;

    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,   // slightly wider so cards aren't too tall
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i == _filtered.length) {
          return _buildLoadMoreTile();
        }
        final p = _filtered[i];
        return FadeIn(
          key: ValueKey(p.id),
          duration: const Duration(milliseconds: 250),
          child: _PokemonCard(
            key: ValueKey(p.id),
            pokemon: p,
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreTile() {
    if (!_hasMore) {
      return Center(
        child: Text('— All caught! —',
            style: GoogleFonts.pressStart2p(
                color: Colors.white24, fontSize: 7)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF1C1C).withValues(alpha: 0.3)),
      ),
      child: _loadingMore
          ? const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Color(0xFFFF1C1C)),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${_allPokemon.length + 1}–#${_allPokemon.length + 10}',
                    style: GoogleFonts.inter(
                        color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  // NeoPoP tilted button for the 3D press feel
                  NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: _loadMore,
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: Color(0xFFFF1C1C),
                      plunkColor: Color(0xFF8B0000),
                      shadowColor: Color(0x44FF1C1C),
                      showShimmer: true,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Text(
                        'Load 10 more',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavouriteService.favouritesNotifier,
      builder: (context, favs, _) {
        final items = [
          (Icons.catching_pokemon, 'Pokédex', 0),
          (Icons.favorite_border, 'Favourites', favs.length),
          (Icons.sports_kabaddi, 'Battle', 0),
          (Icons.person_outline, 'Profile', 0),
        ];

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF16213E),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final (icon, label, badgeCount) = items[i];
                  final active = _navIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _navIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFF1C1C).withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                icon,
                                color: active
                                    ? const Color(0xFFFF1C1C)
                                    : Colors.white38,
                                size: 22,
                              ),
                              if (badgeCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B56),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Text(
                                      '$badgeCount',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              color: active
                                  ? const Color(0xFFFF1C1C)
                                  : Colors.white38,
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Pokemon Card ─────────────────────────────────────────────────────────────
class _PokemonCard extends StatefulWidget {
  final PokemonEntry pokemon;
  const _PokemonCard({super.key, required this.pokemon});

  @override
  State<_PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<_PokemonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final primary = _typeColor(p.types.first);
    final secondary = p.types.length > 1
        ? _typeColor(p.types[1])
        : primary.withValues(alpha: 0.5);

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: () {
        PokemonDetailSheet.show(
          context,
          pokemon: p,
          typeColors: _typeColors,
        );
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.9),
                secondary.withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Watermark pokeball
              Positioned(
                right: -18,
                bottom: -18,
                child: Opacity(
                  opacity: 0.12,
                  child: SvgPicture.asset('assets/images/pokeball.svg',
                      width: 90, height: 90),
                ),
              ),
              // Pokemon artwork — responsive size anchored to bottom-right
              Positioned(
                right: 0,
                bottom: 0,
                child: SizedBox(
                  width: p.spriteSize,
                  height: p.spriteSize,
                  child: Image.network(
                    p.spriteUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.white12,
                        highlightColor: Colors.white30,
                        child: Container(
                          width: p.spriteSize,
                          height: p.spriteSize,
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, p0, p1) => Icon(
                      Icons.catching_pokemon,
                      color: Colors.white38,
                      size: p.spriteSize * 0.55,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID and Favourite button
                    Row(
                      children: [
                        Text(
                          p.formattedId,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        ValueListenableBuilder<Set<int>>(
                          valueListenable: FavouriteService.favouritesNotifier,
                          builder: (context, favs, _) {
                            final isFav = favs.contains(p.id);
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FavouriteService.toggleFavourite(p.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isFav
                                      ? const Color(0xFFFF3B56).withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  size: 13,
                                  color: isFav
                                      ? const Color(0xFFFF3B56)
                                      : Colors.white60,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Name
                    Text(p.displayName,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    // Type chips
                    Wrap(
                      spacing: 4,
                      children: p.types
                          .map((t) => _TypeChip(type: t))
                          .toList(),
                    ),
                    const Spacer(),
                    // Height badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.straighten,
                              size: 10, color: Colors.white60),
                          const SizedBox(width: 3),
                          Text(
                            p.formattedHeight,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Type chip ────────────────────────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style: GoogleFonts.inter(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Animated background ──────────────────────────────────────────────────────
class _AnimatedBg extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => CustomPaint(
        painter: _BgPainter(controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  double _wave(double x) =>
      (x % 1.0) < 0.5 ? 4 * x * (0.5 - x) * 4 : -4 * (x - 0.5) * (x - 1) * 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final orbs = [
      (0.15 + 0.05 * _wave(t * 2), 0.2 + 0.04 * _wave(t * 1.5),
          110.0, const Color(0xFFFF1C1C)),
      (0.8 + 0.04 * _wave(t * 1.8 + 1), 0.7 + 0.05 * _wave(t * 2.2),
          90.0, const Color(0xFF7C4DFF)),
      (0.5 + 0.06 * _wave(t * 1.2 + 2), 0.45 + 0.04 * _wave(t * 1.7),
          70.0, const Color(0xFF4FC3F7)),
    ];
    for (final (dx, dy, r, color) in orbs) {
      paint.shader = RadialGradient(colors: [
        color.withValues(alpha: 0.16),
        color.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(
          center: Offset(size.width * dx, size.height * dy), radius: r));
      canvas.drawCircle(
          Offset(size.width * dx, size.height * dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
