import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agnetation/src/annotation/feedback_popup.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';
import 'package:flutter_agnetation/src/exporter/clipboard_service.dart';
import 'package:flutter_agnetation/src/overlay/agentation_controller.dart';
import 'package:flutter_agnetation/src/overlay/circle_toggle.dart';
import 'package:flutter_agnetation/src/overlay/layout_palette.dart';
import 'package:flutter_agnetation/src/overlay/pill_toolbar.dart';
import 'package:flutter_agnetation/src/overlay/selection_highlight.dart';
import 'package:flutter_agnetation/src/overlay/wireframe_overlay.dart';
import 'package:flutter_agnetation/src/visual/palette_model.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

/// Wraps an app and inserts Agentation chrome — circle → pill, hover, popup, history.
class AgentationOverlay extends StatefulWidget {
  const AgentationOverlay({super.key, required this.child, this.controller});

  factory AgentationOverlay.wrap({Key? key, required Widget child, AgentationController? controller}) =>
      AgentationOverlay(key: key, controller: controller, child: child);

  final Widget child;
  final AgentationController? controller;

  @override
  State<AgentationOverlay> createState() => _AgentationOverlayState();
}

class _AgentationOverlayState extends State<AgentationOverlay> {
  late final AgentationController _controller;
  bool _ownsController = false;
  Offset? _dragOffset;
  int _lastHoverMs = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AgentationController();
    _ownsController = widget.controller == null;
    _controller.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _showHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => ValueListenableBuilder(
        valueListenable: _controller.history.entries,
        builder: (context, entries, _) {
          if (entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No annotations yet. Tap a widget while inspecting.', style: TextStyle(color: Colors.white)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
            itemBuilder: (context, index) {
              final e = entries[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('${e.id}', style: const TextStyle(fontSize: 12, color: Colors.black))),
                title: Text(e.facts.widgetType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text(e.note, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  onPressed: () => _controller.removeEntry(e.id),
                  tooltip: 'Delete',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleCopy() async {
    final md = _controller.exportAll();
    if (md.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to copy — annotate a widget first')));
      return;
    }
    await const SystemClipboardService().copy(md);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${md.split('## Annotation').length - 1} annotation(s)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final directionality = Directionality.maybeOf(context);
    final isEnabled = _controller.isEnabled.value;
    final isExpanded = _controller.isExpanded.value;
    final pending = _controller.pendingPopupFor.value;
    final count = _controller.history.entries.value.length;
    final isPaused = _controller.isPaused.value;
    final isVisible = _controller.isVisible.value;
    final isLayoutMode = _controller.isLayoutMode.value;
    final wireframeOpacity = _controller.layout.wireframeOpacity.value;
    final placements = _controller.layout.placements.value;

    final stack = Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.keyL): VoidCallbackIntent(() => _controller.toggleLayout()),
        LogicalKeySet(LogicalKeyboardKey.escape): VoidCallbackIntent(() {
          if (_controller.pendingPopupFor.value != null) {
            _controller.cancelPopup();
          } else if (isLayoutMode) {
            _controller.toggleLayout();
          } else if (isExpanded) {
            _controller.collapse();
          }
        }),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(onInvoke: (i) => i.callback()),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              WireframeOverlay(
                opacity: isLayoutMode ? wireframeOpacity : 0,
                child: DragTarget<PaletteItem>(
                  onAcceptWithDetails: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final size = box.size;
                    final local = box.globalToLocal(details.offset);
                    final relative = Rect.fromLTWH(
                      (local.dx / size.width * 100).clamp(0, 100).toDouble(),
                      (local.dy / size.height * 100).clamp(0, 100).toDouble(),
                      30,
                      20,
                    );
                    _controller.layout.addPlacement(
                      details.data.type,
                      RectInfo(x: relative.left, y: relative.top, width: relative.width, height: relative.height),
                    );
                  },
                  builder: (context, candidate, rejected) => MouseRegion(
                    onHover: isEnabled && !isPaused && !isLayoutMode
                        ? (e) {
                            final now = DateTime.now().millisecondsSinceEpoch;
                            if (now - _lastHoverMs < 16) return;
                            _lastHoverMs = now;
                            _controller.onHover(e.position);
                          }
                        : null,
                    onExit: (_) => _controller.clearHover(),
                    child: Listener(
                      behavior: isEnabled ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
                      onPointerDown: isEnabled && !isPaused && !isLayoutMode
                          ? (event) => _controller.selectAt(event.position)
                          : null,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
              ...placements.map(
                (p) => Positioned(
                  left: MediaQuery.of(context).size.width * p.relativeRect.x / 100,
                  top: MediaQuery.of(context).size.height * p.relativeRect.y / 100,
                  width: MediaQuery.of(context).size.width * p.relativeRect.width / 100,
                  height: MediaQuery.of(context).size.height * p.relativeRect.height / 100,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF6366F1), width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFF6366F1).withOpacity(0.08),
                      ),
                      child: Center(child: Text(p.componentType, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<SelectionResult?>(
                valueListenable: _controller.hovered,
                builder: (context, hovered, _) {
                  final selected = _controller.selected.value;
                  if (!isEnabled || !isVisible || isPaused || hovered == null || hovered.bounds == null || hovered.element == selected?.element) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    left: hovered.bounds!.x,
                    top: hovered.bounds!.y,
                    width: hovered.bounds!.width,
                    height: hovered.bounds!.height,
                    child: IgnorePointer(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF3B82F6).withOpacity(0.08),
                            ),
                          ),
                          Positioned(
                            top: -16,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hovered.facts.widgetType,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<SelectionResult?>(
                valueListenable: _controller.selected,
                builder: (context, selected, _) {
                  if (!isEnabled || !isVisible || selected == null || selected.bounds == null) return const SizedBox.shrink();
                  return SelectionHighlight(bounds: selected.bounds, label: selected.facts.widgetType);
                },
              ),
              if (pending != null && pending.bounds != null)
                Positioned(
                  left: _popupLeft(pending, context),
                  top: _popupTop(pending, context),
                  child: SafeArea(
                    child: SizedBox(
                      width: 300,
                      child: FeedbackPopup(
                        onAdd: (note) => _controller.addAnnotation(note),
                        onCancel: () => _controller.cancelPopup(),
                      ),
                    ),
                  ),
                ),
              if (isLayoutMode)
                Positioned(
                  left: 16,
                  top: 80,
                  child: SafeArea(
                    child: LayoutPalette(onClose: () => _controller.toggleLayout()),
                  ),
                ),
              if (isLayoutMode)
                Positioned(
                  left: 16,
                  top: 500,
                  child: SafeArea(
                    child: Material(
                      color: const Color(0xCC0A0A0A),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.layers_outlined, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('Wireframe', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('${(wireframeOpacity * 100).round()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                              Slider(
                                value: wireframeOpacity,
                                min: 0,
                                max: 1,
                                activeColor: const Color(0xFF6366F1),
                                inactiveColor: Colors.white24,
                                onChanged: (v) => _controller.layout.setWireframeOpacity(v),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Purpose (e.g. landing hero)',
                                  hintStyle: TextStyle(color: Colors.white54, fontSize: 11),
                                  filled: true,
                                  fillColor: Color(0x14FFFFFF),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0x14FFFFFF))),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                onChanged: (v) => _controller.layout.setPurpose(v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              _buildDraggableToggle(
                isEnabled: isEnabled,
                isExpanded: isExpanded,
                count: count,
                isPaused: isPaused,
                isVisible: isVisible,
                isLayoutMode: isLayoutMode,
              ),
            ],
          ),
        ),
      ),
    );

    if (directionality == null) {
      return Directionality(textDirection: TextDirection.ltr, child: stack);
    }
    return stack;
  }

  Widget _buildDraggableToggle({required bool isEnabled, required bool isExpanded, required int count, required bool isPaused, required bool isVisible, required bool isLayoutMode}) {
    final toggle = isExpanded
        ? PillToolbar(
            count: count,
            isPaused: isPaused,
            isVisible: isVisible,
            isLayoutMode: isLayoutMode,
            onCopy: _handleCopy,
            onClear: () => _controller.clearHistory(),
            onTogglePause: () => _controller.togglePause(),
            onToggleVisibility: () => _controller.toggleVisibility(),
            onHistory: _showHistorySheet,
            onToggleLayout: () => _controller.toggleLayout(),
            onCollapse: () {
              _controller.collapse();
              _controller.disable();
            },
          )
        : CircleToggle(
            count: count,
            onTap: () {
              if (!isEnabled) _controller.enable();
              _controller.expand();
            },
          );

    if (isExpanded) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width < 560 ? MediaQuery.of(context).size.width - 32 : 560),
              child: toggle,
            ),
          ),
        ),
      );
    }

    if (_dragOffset == null) {
      return Positioned(
        right: 24,
        bottom: 24,
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              setState(() {
                _dragOffset = details.globalPosition - const Offset(20, 20);
              });
            },
            onPanEnd: (_) => _autoDock(),
            child: toggle,
          ),
        ),
      );
    }
    return Positioned(
      left: _dragOffset!.dx,
      top: _dragOffset!.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            _dragOffset = _dragOffset! + details.delta;
          });
        },
        onPanEnd: (_) => _autoDock(),
        child: toggle,
      ),
    );
  }

  void _autoDock() {
    if (_dragOffset == null) return;
    final size = MediaQuery.of(context).size;
    final dx = _dragOffset!.dx;
    final isLeft = dx < size.width / 2;
    setState(() {
      _dragOffset = Offset(
        isLeft ? -12 : size.width - 40 + 12,
        _dragOffset!.dy.clamp(40.0, size.height - 80),
      );
    });
  }

  double _popupLeft(dynamic pending, BuildContext context) {
    final bounds = pending.bounds as dynamic;
    final x = bounds.x as double;
    final w = bounds.width as double;
    final screenW = MediaQuery.of(context).size.width;
    var left = x + w + 12;
    if (left + 300 > screenW - 16) {
      left = (x - 300 - 12).clamp(16.0, screenW - 316);
    }
    return left;
  }

  double _popupTop(dynamic pending, BuildContext context) {
    final bounds = pending.bounds as dynamic;
    final y = bounds.y as double;
    final screenH = MediaQuery.of(context).size.height;
    var top = y;
    if (top + 160 > screenH - 80) {
      top = y - 160;
    }
    return top.clamp(16.0, screenH - 200);
  }
}
