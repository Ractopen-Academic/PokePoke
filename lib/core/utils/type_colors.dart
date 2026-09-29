import 'package:flutter/material.dart';

// Shared Pokémon type → colour map used across all screens
const Map<String, Color> kTypeColors = {
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

Color typeColor(String type) => kTypeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);
