import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/annotation/feedback_field.dart';
import 'package:flutter_agnetation/src/exporter/clipboard_service.dart';
import 'package:flutter_agnetation/src/exporter/widgets/copy_button.dart';
import 'package:flutter_agnetation/src/overlay/activation_toggle.dart';
import 'package:flutter_agnetation/src/overlay/agentation_controller.dart';
import 'package:flutter_agnetation/src/overlay/info_panel.dart';
import 'package:flutter_agnetation/src/overlay/selection_highlight.dart';

/// Wraps a Flutter app and inserts Agentation chrome.
///
/// Usage: `AgentationOverlay.wrap(child: MaterialApp(...))`
class AgentationOverlay extends StatefulWidget {
  const AgentationOverlay({
    super.key,
    required this.child,
    this.controller,
  });

  factory AgentationOverlay.wrap({
    Key? key,
    required Widget child,
    AgentationController? controller,
  }) =>
      AgentationOverlay(key: key, controller: controller, child: child);

  final Widget child;
  final AgentationController? controller;

  @override
  State<AgentationOverlay> createState() => _AgentationOverlayState();
}

class _AgentationOverlayState extends State<AgentationOverlay> {
  late final AgentationController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = AgentationController();
      _ownsController = true;
    }
    _controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant AgentationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onChange);
      _controller.removeListener(_onChange);
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
    }
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          behavior: _controller.isEnabled.value
              ? HitTestBehavior.translucent
              : HitTestBehavior.deferToChild,
          onPointerDown: _controller.isEnabled.value
              ? (event) {
                  _controller.engine.selectAt(event.position);
                }
              : null,
          child: widget.child,
        ),
        if (_controller.isEnabled.value && _controller.selected.value != null)
          IgnorePointer(
            child: SelectionHighlight(
              bounds: _controller.selected.value!.bounds,
              label: _controller.selected.value!.facts.widgetType,
            ),
          ),
        if (_controller.isEnabled.value && _controller.selected.value != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ValueListenableBuilder(
                      valueListenable: _controller.selected,
                      builder: (context, sel, _) {
                        final facts = sel?.facts;
                        if (facts == null) return const SizedBox.shrink();
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InfoPanel(facts: facts),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: FeedbackField(manager: _controller.annotation),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: ValueListenableBuilder(
                                  valueListenable: _controller.annotation.current,
                                  builder: (context, intent, _) {
                                    final ctx = _controller.currentContext;
                                    return CopyButton(
                                      model: ctx,
                                      exporter: _controller.exporter,
                                      clipboard: const SystemClipboardService(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isEnabled,
              builder: (context, enabled, _) => ActivationToggle(
                isEnabled: enabled,
                onToggle: _controller.toggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }
}
