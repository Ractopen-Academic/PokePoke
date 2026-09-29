import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pokepoke/core/services/favourite_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/features/dashboard/home/widgets/pokemon_detail_sheet.dart';
import 'package:shimmer/shimmer.dart';

class FavouriteScreen extends StatefulWidget {
  final List<PokemonEntry> allPokemon;
  final Map<String, Color> typeColors;
  final VoidCallback? onExplore;
  final void Function(String type)? onSelectType;

  const FavouriteScreen({
    super.key,
    required this.allPokemon,
    required this.typeColors,
    this.onExplore,
    this.onSelectType,
  });

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  Color _typeColor(String type) =>
      widget.typeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavouriteService.favouritesNotifier,
      builder: (context, favIds, _) {
        final favPokemon = widget.allPokemon
            .where((p) => favIds.contains(p.id))
            .toList();

        final q = _searchCtrl.text.toLowerCase().trim();
        final cleanId = q.replaceAll('#', '');
        final targetId = int.tryParse(cleanId);
        final filtered = favPokemon.where((p) {
          return q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.formattedId.toLowerCase().contains(q) ||
              (targetId != null && p.id == targetId);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFFF3B56), size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'FAVOURITES',
                    style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B56).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF3B56).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${favPokemon.length} SAVED',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF3B56),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (favPokemon.isNotEmpty) ...[
              // Search in favourites
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: GoogleFonts.inter(color: Colors.white),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search favourites…',
                      hintStyle: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white38, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                    ),
                  ),
                ),
              ),

              // Count label
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: Text(
                  '${filtered.length} of ${favPokemon.length} shown',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // Main Content Area
            Expanded(
              child: favPokemon.isEmpty
                  ? _buildEmptyState(context)
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No favourites match "$q"',
                            style: GoogleFonts.inter(
                                color: Colors.white38, fontSize: 13),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.05,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            return _FavouriteCard(
                              key: ValueKey(p.id),
                              pokemon: p,
                              typeColor: _typeColor,
                              onSelectType: widget.onSelectType,
                              onTap: () {
                                PokemonDetailSheet.show(
                                  context,
                                  pokemon: p,
                                  typeColors: widget.typeColors,
                                  onSelectType: widget.onSelectType,
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/pokeball.svg',
                  width: 90,
                  height: 90,
                  colorFilter: const ColorFilter.mode(
                      Colors.white10, BlendMode.srcIn),
                ),
                const Icon(
                  Icons.favorite_border,
                  size: 44,
                  color: Color(0xFFFF3B56),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'NO FAVOURITES YET',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart icon on any Pokémon card or inside the detail view to build your personal dream team!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            NeoPopTiltedButton(
              isFloating: true,
              onTapUp: () {
                widget.onExplore?.call();
              },
              color: const Color(0xFFFF3B56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.catching_pokemon,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'EXPLORE POKÉDEX',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  final PokemonEntry pokemon;
  final Color Function(String) typeColor;
  final void Function(String type)? onSelectType;
  final VoidCallback onTap;

  const _FavouriteCard({
    super.key,
    required this.pokemon,
    required this.typeColor,
    this.onSelectType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = pokemon;
    final primary = typeColor(p.types.first);
    final secondary = p.types.length > 1
        ? typeColor(p.types[1])
        : primary.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
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
            // Watermark
            Positioned(
              right: -18,
              bottom: -18,
              child: Opacity(
                opacity: 0.12,
                child: SvgPicture.asset('assets/images/pokeball.svg',
                    width: 90, height: 90),
              ),
            ),
            // Sprite
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: p.spriteSize,
                height: p.spriteSize,
                child: CachedNetworkImage(
                  imageUrl: p.spriteUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  placeholder: (context, url) => Shimmer.fromColors(
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
                  ),
                  errorWidget: (_, p0, p1) => Icon(
                    Icons.catching_pokemon,
                    color: Colors.white38,
                    size: p.spriteSize * 0.55,
                  ),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      // Remove favourite button
                      GestureDetector(
                        onTap: () {
                          FavouriteService.toggleFavourite(p.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Color(0xFFFF3B56),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    p.displayName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: p.types.map((t) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelectType?.call(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  // Height tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.formattedHeight,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
