import 'dart:convert';

import 'dart:io';

final reactAttrs = [
  "children",
  "key",
  "ref",
];

final excludedAttrs = {
  "data-*",
  "ping",
  "dropZone",
  "itemProp",
  "buffered",
  "cite",
  "align",
  "formaction",
  "headers",
  "pubdate",
  "srcLang",
  "kind",
  "challenge",
  "keytype",
  "dirname",
  "summary",
  "scoped",
  "high",
  "low",
  "optimum",
  "language",
  "wrap",
  "ismap",
  "reversed",
  "autoSave",
};

final boolAttrs = {
  "hidden",
  "loop",
  "autoPlay",
  "controls",
  "disabled",
  "autoFocus",
  "required",
  "readOnly",
  "async",
  "defer",
  "checked",
  "autoComplete",
  "selected",
  "multiple",
  "seamless",
  "open",
  "noValidate"
};

final intAttrs = {
  "span",
  "cols",
  "rows",
  "start",
  "size",
};

final strAttrs = {
  "className",
  "id",
  "title",
};

final excludedEvent = {"onInvalid", "onSearch", "onSelect", "onMouseWheel"};

File f;
IOSink sink;

void fprint(str) {
  // print(str);
  sink.write("$str");
}

main(List<String> args) {
  f = File("f_dom.dart");
  sink = f.openWrite();
  final _attrMap = jsonDecode(File("attr.json").readAsStringSync()) as Map;
  final attrMap = _attrMap.map(
      (key, value) => MapEntry(key as String, (value as List).cast<String>()));
  final _eventMap = jsonDecode(File("event.json").readAsStringSync()) as Map;
  final eventMap = _eventMap.map(
      (key, value) => MapEntry(key as String, (value as List).cast<String>()));

  final funcs = attrMap.keys.map((tag) {
    return funTemplate(tag, attrMap[tag], eventMap);
  }).toList();
  final result = fileTemplate(funcs);
  fprint(result);
  sink.close();
}

String funTemplate(
  String tag,
  List<String> _attrs,
  Map<String, List<String>> eventMap,
) {
  final attrs = _attrs
      .where(
        (attr) => !excludedAttrs.contains(attr),
      )
      .toList();
  final attrParas = attrs.map(
    (attr) {
      if (attr == "style") {
        return "Map $attr";
      } else if (boolAttrs.contains(attr)) {
        return "bool $attr";
      } else if (intAttrs.contains(attr)) {
        return "int $attr";
      } else if (strAttrs.contains(attr)) {
        return "String $attr";
      } else {
        return "$attr";
      }
    },
  ).join(", ");
  final attrBuilders = attrs
      .map(
        (attr) => "..$attr=$attr",
      )
      .join(" ");
  final events = eventMap.values.expand((e) => e).toList();
  final eventParams = events
      .map(
        (event) => "Function(SyntheticEvent) $event",
      )
      .join(", ");
  final eventBuilders = events
      .where((event) => !excludedEvent.contains(event))
      .map(
        (event) => "..$event=$event",
      )
      .join(" ");
  return """  
  static ReactElement $tag({${reactAttrs.join(', ')}, $attrParas, $eventParams}){
    final props = Dom.$tag()$attrBuilders $eventBuilders;
    return children == null ? props() : props(children);
  }""";
}

String fileTemplate(List<String> content) {
  return """
/// flutter-like style dom
import 'package:over_react/over_react.dart';

abstract class FDom {
${content.join("\n\n")}
}
""";
}
