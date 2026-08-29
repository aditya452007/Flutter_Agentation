import 'package:flutter/foundation.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';
import 'package:flutter_agnetation/src/context/visual_changes.dart';

class LayoutController extends ChangeNotifier {
  LayoutController();

  final ValueNotifier<List<VisualPlacement>> placements = ValueNotifier<List<VisualPlacement>>(<VisualPlacement>[]);
  final ValueNotifier<double> wireframeOpacity = ValueNotifier<double>(0);
  final ValueNotifier<String> purpose = ValueNotifier<String>('');

  void addPlacement(String componentType, RectInfo relativeRect, {String? purpose}) {
    final entry = VisualPlacement(componentType: componentType, relativeRect: relativeRect, purpose: purpose ?? this.purpose.value);
    placements.value = List<VisualPlacement>.from(placements.value)..add(entry);
    notifyListeners();
  }

  void clearPlacements() {
    placements.value = <VisualPlacement>[];
    notifyListeners();
  }

  void setWireframeOpacity(double v) {
    wireframeOpacity.value = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setPurpose(String v) {
    purpose.value = v;
    notifyListeners();
  }

  List<VisualChanges> toVisualChanges() {
    final list = <VisualChanges>[];
    if (wireframeOpacity.value > 0) {
      list.add(VisualWireframe(opacity: wireframeOpacity.value, purpose: purpose.value.isEmpty ? null : purpose.value));
    }
    list.addAll(placements.value);
    return list;
  }

  @override
  void dispose() {
    placements.dispose();
    wireframeOpacity.dispose();
    purpose.dispose();
    super.dispose();
  }
}
