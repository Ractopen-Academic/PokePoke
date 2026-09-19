import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';

// ─── Pokémon type → colour map ────────────────────────────────────────────────
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

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final List<PokemonEntry> preloadedPokemon;
  const HomeScreen({super.key, required this.preloadedPokemon});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _bgController;

  List<PokemonEntry> _allPokemon = [];
  List<PokemonEntry> _filtered = [];
  final bool _loading = false;
  String _selectedType = 'All';
  int _navIndex = 0;

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
    _allPokemon = widget.preloadedPokemon;
    _filtered = _allPokemon;
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchCtrl.dispose();
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

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            SvgPicture.asset('assets/images/pokeball.svg',
                width: 36, height: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PokéPoke',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Gotta catch \'em all!',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Pokémon name or #ID…',
              hintStyle:
                  GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(Icons.search,
                  color: Colors.white38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _typeFilters.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final type = _typeFilters[i];
            final selected = _selectedType == type;
            final color =
                type == 'All' ? Colors.white : _typeColor(type);
            return GestureDetector(
              onTap: () => _selectType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : Colors.white12,
                  ),
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        _loading
            ? 'Loading Pokédex…'
            : '${_filtered.length} Pokémon found',
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_loading) return _buildShimmerGrid();
    if (_filtered.isEmpty) {
      return Center(
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
            const SizedBox(height: 16),
            Text('No Pokémon found',
                style: GoogleFonts.inter(color: Colors.white38)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => FadeInUp(
        delay: Duration(milliseconds: (i % 6) * 60),
        duration: const Duration(milliseconds: 400),
        child: _PokemonCard(pokemon: _filtered[i]),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                      horizontal: 16, vertical: 6),
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
                      const SizedBox(height: 3),
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
  late final AnimationController _hoverCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final primary = _typeColor(p.types.first);
    final secondary = p.types.length > 1
        ? _typeColor(p.types[1])
        : primary.withValues(alpha: 0.6);

    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) => _hoverCtrl.reverse(),
      onTapCancel: () => _hoverCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.85),
                secondary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: SvgPicture.asset(
                    'assets/images/pokeball.svg',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.formattedId,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.displayName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: p.types
                          .map((t) => _TypeChip(type: t))
                          .toList(),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CachedNetworkImage(
                        imageUrl: p.artworkUrl,
                        height: 90,
                        width: 90,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.white10,
                          highlightColor: Colors.white30,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white30,
                          size: 60,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
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
      builder: (context, child) {
        return CustomPaint(
          painter: _BgPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final orbs = [
      (0.15 + 0.05 * _sin(t * 2), 0.2 + 0.04 * _sin(t * 1.5),
          120.0, const Color(0xFFFF1C1C)),
      (0.8 + 0.04 * _sin(t * 1.8 + 1), 0.7 + 0.05 * _sin(t * 2.2),
          100.0, const Color(0xFF7C4DFF)),
      (0.5 + 0.06 * _sin(t * 1.2 + 2), 0.45 + 0.04 * _sin(t * 1.7),
          80.0, const Color(0xFF4FC3F7)),
    ];
    for (final (dx, dy, r, color) in orbs) {
      paint.shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * dx, size.height * dy),
        radius: r,
      ));
      canvas.drawCircle(
          Offset(size.width * dx, size.height * dy), r, paint);
    }
  }

  double _sin(double x) => (x % 1.0) < 0.5
      ? 4 * x * (0.5 - x) * 4
      : -4 * (x - 0.5) * (x - 1) * 4;

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
