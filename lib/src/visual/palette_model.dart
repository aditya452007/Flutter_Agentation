import 'package:flutter/material.dart';

@immutable
class PaletteItem {
  const PaletteItem({required this.type, required this.icon, required this.label});

  final String type;
  final IconData icon;
  final String label;
}

const List<PaletteItem> kPaletteItems = <PaletteItem>[
  PaletteItem(type: 'Container', icon: Icons.crop_square_rounded, label: 'Box'),
  PaletteItem(type: 'Column', icon: Icons.view_column_rounded, label: 'Column'),
  PaletteItem(type: 'Row', icon: Icons.view_stream_rounded, label: 'Row'),
  PaletteItem(type: 'Stack', icon: Icons.layers_rounded, label: 'Stack'),
  PaletteItem(type: 'Card', icon: Icons.credit_card_rounded, label: 'Card'),
  PaletteItem(type: 'ListTile', icon: Icons.list_rounded, label: 'Tile'),
  PaletteItem(type: 'ElevatedButton', icon: Icons.smart_button_rounded, label: 'Button'),
  PaletteItem(type: 'OutlinedButton', icon: Icons.radio_button_unchecked_rounded, label: 'Outline'),
  PaletteItem(type: 'Text', icon: Icons.text_fields_rounded, label: 'Text'),
  PaletteItem(type: 'Icon', icon: Icons.emoji_emotions_rounded, label: 'Icon'),
  PaletteItem(type: 'Image', icon: Icons.image_rounded, label: 'Image'),
  PaletteItem(type: 'Chip', icon: Icons.label_rounded, label: 'Chip'),
  PaletteItem(type: 'Divider', icon: Icons.horizontal_rule_rounded, label: 'Divider'),
  PaletteItem(type: 'ListView', icon: Icons.view_list_rounded, label: 'List'),
  PaletteItem(type: 'GridView', icon: Icons.grid_view_rounded, label: 'Grid'),
  PaletteItem(type: 'TabBar', icon: Icons.tab_rounded, label: 'Tabs'),
  PaletteItem(type: 'AppBar', icon: Icons.web_asset_rounded, label: 'AppBar'),
  PaletteItem(type: 'BottomNavigationBar', icon: Icons.space_bar_rounded, label: 'NavBar'),
  PaletteItem(type: 'FloatingActionButton', icon: Icons.add_circle_rounded, label: 'FAB'),
  PaletteItem(type: 'SizedBox', icon: Icons.aspect_ratio_rounded, label: 'Space'),
];
