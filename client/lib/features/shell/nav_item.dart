import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.route,
    required this.icon,
    this.matchPrefix = false,
  });

  final String label;
  final String route;
  final IconData icon;
  final bool matchPrefix;
}
