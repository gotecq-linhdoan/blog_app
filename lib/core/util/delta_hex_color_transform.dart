import 'dart:ui';

List<dynamic> deltaHexColorToRGB({required List<dynamic> deltaJson}) {
  for (var d in deltaJson) {
    if (d is Map<String, dynamic> &&
        d.containsKey('attributes') &&
        d['attributes'] is Map<String, dynamic>) {
      var attributes = d['attributes'];
      attributes.forEach((key, value) {
        if (value is String && value.startsWith('#FF')) {
          try {
            String hexColor = value.replaceAll('#', '0x');
            var color = Color(int.parse(hexColor));
            attributes[key] = 'rgb(${color.red},${color.green},${color.blue})';
          } catch (e) {
            attributes[key] = value;
          }
        }
      });
    }
  }
  return deltaJson;
}
