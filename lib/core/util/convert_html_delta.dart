import 'package:flutter/material.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart' as htmlParse;
import 'package:flutter_quill/quill_delta.dart' as quill;

class HtmlToDeltaConverter {
  static const _COLOR_PATTERN = r'color: rgb\((\d+), (\d+), (\d+)\);';

  static quill.Delta _parseInlineStyles(htmlDom.Element element) {
    var delta = quill.Delta();

    for (final node in element.nodes) {
      final attributes = _parseElementStyles(element);

      if (node is htmlDom.Text) {
        delta.insert(node.text, attributes);
      } else if (node is htmlDom.Element && node.localName == 'img') {
        final src = node.attributes['src'];
        if (src != null) {
          delta.insert({'image': src});
        }
      } else if (node is htmlDom.Element) {
        delta = delta.concat(_parseInlineStyles(node));
      }
    }

    return delta;
  }

  static Map<String, dynamic> _parseElementStyles(htmlDom.Element element) {
    Map<String, dynamic> attributes = {};

    if (element.localName == 'strong') attributes['bold'] = true;
    if (element.localName == 'em') attributes['italic'] = true;
    if (element.localName == 'u') attributes['underline'] = true;
    if (element.localName == 'del') attributes['strike'] = true;

    final style = element.attributes['style'];
    if (style != null) {
      final colorValue = _parseColorFromStyle(style);
      if (colorValue != null) attributes['color'] = colorValue;

      final bgColorValue = _parseBackgroundColorFromStyle(style);
      if (bgColorValue != null) attributes['background'] = bgColorValue;
    }

    return attributes;
  }

  static String? _parseColorFromStyle(String style) {
    if (RegExp(r'(^|\s)color:(\s|$)').hasMatch(style)) {
      return _parseRgbColorFromMatch(RegExp(_COLOR_PATTERN).firstMatch(style));
    }
    return null;
  }

  static String? _parseBackgroundColorFromStyle(String style) {
    if (RegExp(r'(^|\s)background-color:(\s|$)').hasMatch(style)) {
      return _parseRgbColorFromMatch(RegExp(_COLOR_PATTERN).firstMatch(style));
    }
    return null;
  }

  static String? _parseRgbColorFromMatch(RegExpMatch? colorMatch) {
    if (colorMatch != null) {
      try {
        final red = int.parse(colorMatch.group(1)!);
        final green = int.parse(colorMatch.group(2)!);
        final blue = int.parse(colorMatch.group(3)!);
        return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
      } catch (e) {
        debugPrintStack(label: e.toString());
      }
    }
    return null;
  }

  static quill.Delta htmlToDelta(String html) {
    final document = htmlParse.parse(html);
    var delta = quill.Delta();
    print(document.body?.nodes);
    for (final node in document.body?.nodes ?? []) {
      if (node is htmlDom.Element) {
        switch (node.localName) {
          case 'p':
            delta = delta.concat(_parseInlineStyles(node))..insert('\n');
            break;
          case 'br':
            delta.insert('\n');
            break;
        }
      }
    }

    return html.isNotEmpty ? delta : quill.Delta()
      ..insert('\n');
  }
}
