import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Line icons from the design mockups (24 viewBox, stroke 1.8, round caps).
abstract final class AppIcons {
  static const Map<String, String> _shapes = {
    // Navigation and actions
    'home_tab': '<path d="M3 11 12 4l9 7"/><path d="M5 10v10h5v-6h4v6h5V10"/>',
    'list': '<path d="M8 6h13M8 12h13M8 18h13"/><circle cx="3.5" cy="6" r="1"/><circle cx="3.5" cy="12" r="1"/><circle cx="3.5" cy="18" r="1"/>',
    'pie': '<path d="M21 12a9 9 0 1 1-9-9v9z"/><path d="M15 3.5A9 9 0 0 1 20.5 9H15z"/>',
    'bars': '<path d="M5 20V12M10 20V6M15 20v-9M20 20V4"/>',
    'plus': '<path d="M12 5v14M5 12h14"/>',
    'close': '<path d="M6 6l12 12M18 6 6 18"/>',
    'check': '<path d="m5 12 5 5 9-10"/>',
    'chevron_left': '<path d="m15 6-6 6 6 6"/>',
    'chevron_right': '<path d="m9 6 6 6-6 6"/>',
    'arrow_down': '<path d="M12 5v14M6 13l6 6 6-6"/>',
    'arrow_up_right': '<path d="M7 17 17 7M8 7h9v9"/>',
    'swap': '<path d="M4 8h14l-3-3M20 16H6l3 3"/>',
    'calendar': '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M3 10h18M8 3v4M16 3v4"/>',
    'note': '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
    'backspace': '<path d="M9 5h11v14H9l-6-7z"/><path d="m12 9 5 6M17 9l-5 6"/>',
    'search': '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
    'filter': '<path d="M3 5h18l-7 8v6l-4 2v-8z"/>',
    'trash': '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
    'copy': '<rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"/>',
    'settings': '<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
    'sync': '<path d="M20 11a8 8 0 0 0-14.3-4.9L4 8"/><path d="M4 3v5h5"/><path d="M4 13a8 8 0 0 0 14.3 4.9L20 16"/><path d="M20 21v-5h-5"/>',
    'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
    'target': '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4"/><circle cx="12" cy="12" r=".6"/>',
    'trend': '<path d="M3 17l6-6 4 4 8-8"/><path d="M14 7h7v7"/>',
    'repeat': '<path d="M17 2l4 4-4 4"/><path d="M3 11V9a3 3 0 0 1 3-3h15"/><path d="M7 22l-4-4 4-4"/><path d="M21 13v2a3 3 0 0 1-3 3H3"/>',
    'warning': '<path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17h.01"/>',
    'logout': '<path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3"/><path d="M10 17l-5-5 5-5M5 12h11"/>',
    'cloud_off': '<path d="M3 3l18 18"/><path d="M8.5 6.2A6 6 0 0 1 17.7 10H18a4 4 0 0 1 2.1 7.4M15 18H7a5 5 0 0 1-1.6-9.7"/>',
    'server': '<rect x="3" y="4" width="18" height="7" rx="2"/><rect x="3" y="13" width="18" height="7" rx="2"/><path d="M7 7.5h.01M7 16.5h.01"/>',
    // Accounts
    'card': '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M3 10h18"/>',
    'credit_card': '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M3 10h18M7 15h4"/>',
    'cash_note': '<rect x="3" y="6" width="18" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/>',
    'bank': '<path d="M4 10h16M6 10v8M10 10v8M14 10v8M18 10v8M3 20h18M12 3l9 5H3z"/>',
    'piggy': '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4"/><circle cx="12" cy="12" r=".6"/>',
    'invest': '<path d="M3 17l6-6 4 4 8-8"/><path d="M14 7h7v7"/>',
    // Categories (keys match the server's default category icons)
    'cart': '<path d="M3 4h2l2.4 11h11L21 8H6.2M8 20a1.3 1.3 0 1 0 2.6 0a1.3 1.3 0 1 0-2.6 0M16 20a1.3 1.3 0 1 0 2.6 0a1.3 1.3 0 1 0-2.6 0"/>',
    'cafe': '<path d="M4 9h13v5a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5zM17 11h1.5a2.5 2.5 0 0 1 0 5H17M8 3v3M12 3v3"/>',
    'transport': '<path d="M7 3h10a3 3 0 0 1 3 3v12H4V6a3 3 0 0 1 3-3zM4 11h16M8 21v-3M16 21v-3"/>',
    'bus': '<path d="M7 3h10a3 3 0 0 1 3 3v12H4V6a3 3 0 0 1 3-3zM4 11h16M8 21v-3M16 21v-3"/>',
    'taxi': '<path d="M5 11l2-5h10l2 5M4 11h16v6H4zM7 17v2M17 17v2M7.5 14h.01M16.5 14h.01M10 3h4"/>',
    'fuel': '<path d="M4 21V5a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v16M3 21h12M4 10h10M14 7l3 3v7a2 2 0 0 0 4 0V9l-3-3"/>',
    'home': '<path d="M3 11 12 4l9 7M5 10v10h14V10"/>',
    'key': '<circle cx="8" cy="15" r="4"/><path d="M11 12l9-9M16 7l3 3M14 9l2 2"/>',
    'utilities': '<path d="M13 2 4 14h7l-1 8 9-12h-7z"/>',
    'phone': '<path d="M9.5 2.5h5a2.5 2.5 0 0 1 2.5 2.5v14a2.5 2.5 0 0 1-2.5 2.5h-5A2.5 2.5 0 0 1 7 19V5a2.5 2.5 0 0 1 2.5-2.5zM11 18.5h2"/>',
    'subscription': '<path d="M17 2l4 4-4 4M3 11V9a3 3 0 0 1 3-3h15M7 22l-4-4 4-4M21 13v2a3 3 0 0 1-3 3H3"/>',
    'health': '<path d="M20.8 6.6a5 5 0 0 0-8.8-2 5 5 0 0 0-8.8 2c-.9 3.6 2.3 7.3 8.8 12.4 6.5-5.1 9.7-8.8 8.8-12.4z"/>',
    'clothes': '<path d="M8 3 3 6l2 4 2-1v12h10V9l2 1 2-4-5-3a4 4 0 0 1-8 0z"/>',
    'fun': '<path d="M4 6h16v4a2 2 0 0 0 0 4v4H4v-4a2 2 0 0 0 0-4zM14 6v2M14 11v2M14 16v2"/>',
    'gift': '<path d="M4 11h16v10H4zM3 7h18v4H3zM12 7v14"/>',
    'education': '<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2zM4 19a2 2 0 0 1 2-2h13"/>',
    'other': '<path d="M5 12h.01M12 12h.01M19 12h.01"/>',
    'more': '<path d="M5 12h.01M12 12h.01M19 12h.01"/>',
    'uncategorized': '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.3-1 .8-1 1.5M12 17h.01"/>',
    'salary': '<path d="M3 8h18v12H3zM8 8V5h8v3M3 13h18"/>',
    'freelance': '<path d="M14 4l6 6-10 10H4v-6zM12 6l6 6"/>',
    'interest': '<path d="M19 5 5 19M7 5a2 2 0 1 0 0 4a2 2 0 1 0 0-4M17 15a2 2 0 1 0 0 4a2 2 0 1 0 0-4"/>',
    'cashback': '<path d="M3 6h18v12H3zM12 9.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5"/>',
    'wifi': '<path d="M5 12.5a10 10 0 0 1 14 0M8.5 16a5 5 0 0 1 7 0M12 19.5h.01"/>',
    'music': '<path d="M9 18V5l11-2v13M6 15a3 3 0 1 0 0 6a3 3 0 1 0 0-6M17 13a3 3 0 1 0 0 6a3 3 0 1 0 0-6"/>',
    'sport': '<path d="M6 8v8M18 8v8M3 10v4M21 10v4M6 12h12"/>',
  };

  static bool has(String? name) => name != null && _shapes.containsKey(name);

  static String svg(String name, {double stroke = 1.8}) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" '
      'stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round">${_shapes[name] ?? _shapes['other']}</svg>';
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 22, this.color, this.stroke = 1.8});

  final String name;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFFEEF1F6);
    return SvgPicture.string(
      AppIcons.svg(name, stroke: stroke),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
