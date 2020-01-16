import 'dart:convert';

import 'dart:io';

File f;
IOSink sink;

void fprint(str) {
  sink.write("$str");
}

main(List<String> args) {
  f = File('output/f_dom.dart');
  sink = f.openWrite();
  final fieldInput = File('res/props_mixin').readAsStringSync();
  var regex = RegExp(r'(\w+)\s+get\s+(\w+)\s+=>');
  var matches = regex.allMatches(fieldInput);

  final fields = matches.map((match) {
    final name = match.group(2);
    final type = name == 'children' ? 'dynamic' : match.group(1);
    return Field(type, name);
  }).toSet();
  fields.add(Field('Map<String, String>', 'style'));

  final params =
      fields.map((field) => '${field.type} ${field.name}').join(', ');
  final builder = fields
      .where((field) => field.name != 'children')
      .map((field) => '..${field.name}=${field.name}')
      .join(' ');

  final tagInput = File('res/dom').readAsStringSync();
  regex = RegExp(r'static\s+DomProps\s+(\w+)(\s)*\(');
  matches = regex.allMatches(tagInput);
  final tags = matches.map((match) => match.group(1)).toList();

  final content = tags.map((tag) {
    return '''
  static ReactElement $tag({$params}) {
    final props = Dom.$tag()$builder;
    return children == null ? props() : props(children);
  }''';
  }).toList();

  fprint("""
/// flutter-like style dom
import 'package:over_react/over_react.dart';

class FDom {
  FDom._();

${content.join("\n\n")}
}
""");
  sink.close();
}

class Field {
  Field(this.type, this.name);
  final String type;
  final String name;

  @override
  int get hashCode => name.hashCode;
}
