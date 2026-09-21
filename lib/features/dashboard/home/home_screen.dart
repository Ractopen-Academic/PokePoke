import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';

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
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allPokemon.where((p) {
        final matchSearch =
            q.isEmpty || p.name.contains(q) || p.formattedId.contains(q);
        final matchType =
            _selectedType == 'All' || p.types.contains(_selectedType);
        return matchSearch && matchType;
      }).toList();
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildTypeFilter(),
                _buildSectionTitle(),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Pokémon name or #ID…',
              hintStyle:
                  GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
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
        height: 42,
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
                    horizontal: 14, vertical: 8),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/pokeball.svg',
                width: 56,
                height: 56,
                colorFilter: const ColorFilter.mode(
                    Colors.white24, BlendMode.srcIn)),
            const SizedBox(height: 12),
            Text('No Pokémon found',
                style:
                    GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
          ],
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
        // Last item = load-more footer (spans 2 cols via a trick with 1-col grid overlay isn't needed — just show in last slot)
        if (i == _filtered.length) {
          return _buildLoadMoreTile();
        }
        return FadeInUp(
          delay: Duration(milliseconds: (i % 8) * 50),
          duration: const Duration(milliseconds: 350),
          child: _PokemonCard(pokemon: _filtered[i]),
        );
      },
    );
  }

  Widget _buildLoadMoreTile() {
    if (!_hasMore) {
      return Center(
        child: Text('All caught!',
            style: GoogleFonts.inter(color: Colors.white24, fontSize: 12)),
      );
    }
    return GestureDetector(
      onTap: _loadingMore ? null : _loadMore,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFFF1C1C).withValues(alpha: 0.4)),
        ),
        child: _loadingMore
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFFF1C1C),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: Color(0xFFFF1C1C), size: 28),
                  const SizedBox(height: 6),
                  Text('Load 10 more',
                      style: GoogleFonts.inter(
                          color: const Color(0xFFFF1C1C),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text('#${_allPokemon.length + 1}–#${_allPokemon.length + 10}',
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 10)),
                ],
              ),
      ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      (Icons.catching_pokemon, 'Pokédex'),
      (Icons.favorite_border, 'Favourites'),
      (Icons.sports_kabaddi, 'Battle'),
      (Icons.person_outline, 'Profile'),
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
              final (icon, label) = items[i];
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
                      Icon(icon,
                          color: active
                              ? const Color(0xFFFF1C1C)
                              : Colors.white38,
                          size: 22),
                      const SizedBox(height: 2),
                      Text(label,
                          style: GoogleFonts.inter(
                              color: active
                                  ? const Color(0xFFFF1C1C)
                                  : Colors.white38,
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Pokemon Card ─────────────────────────────────────────────────────────────
class _PokemonCard extends StatefulWidget {
  final PokemonEntry pokemon;
  const _PokemonCard({required this.pokemon});

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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID
                    Text(p.formattedId,
                        style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
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
                    // Pokemon artwork — plain Image.network, no CachedNetworkImage
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: Image.network(
                          p.spriteUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.white12,
                              highlightColor: Colors.white30,
                              child: Container(
                                width: 78,
                                height: 78,
                                decoration: const BoxDecoration(
                                  color: Colors.white12,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, p0, p1) => const Icon(
                            Icons.catching_pokemon,
                            color: Colors.white38,
                            size: 48,
                          ),
                        ),
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
