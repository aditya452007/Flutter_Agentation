import 'dart:convert';
import 'package:flutter_agnetation/src/context/context_model.dart';

class JsonExporter {
  const JsonExporter();

  Map<String, dynamic> toJson(ContextModel model) => model.toJson();

  String toJsonString(ContextModel model) => jsonEncode(toJson(model));
}
