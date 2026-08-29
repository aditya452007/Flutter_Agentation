import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/visual/palette_model.dart';

class LayoutPalette extends StatelessWidget {
  const LayoutPalette({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC0A0A0A),
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 320,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x14FFFFFF)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    const Icon(Icons.view_quilt_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Palette', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18), onPressed: onClose, tooltip: 'Close'),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x14FFFFFF)),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2),
                  itemCount: kPaletteItems.length,
                  itemBuilder: (context, index) {
                    final item = kPaletteItems[index];
                    return LongPressDraggable<PaletteItem>(
                      data: item,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 1.5)),
                          child: Icon(item.icon, color: Colors.white, size: 24),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x14FFFFFF))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 20),
                            const SizedBox(height: 4),
                            Text(item.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
