import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Abstraction over hit-testing. In V1 the engine walks by geometry,
/// but we still call hitTest to keep the pipeline consistent and allow
/// faking in tests.

abstract class HitTestAdapter {
  HitTestResult hitTest(Offset globalOffset);
}

/// Default adapter that delegates to [WidgetsBinding].
class FlutterHitTestAdapter implements HitTestAdapter {
  const FlutterHitTestAdapter();

  @override
  HitTestResult hitTest(Offset globalOffset) {
    final result = HitTestResult();
    // ignore: deprecated_member_use, reason: hitTestInView requires viewId; simple hitTest suffices for V1 walk
    WidgetsBinding.instance.hitTest(result, globalOffset);
    return result;
  }
}
