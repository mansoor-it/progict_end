// الحل الثالث: دالة ذكية شاملة للألوان
import 'package:flutter/material.dart';

class ColorHelper {
  // خريطة شاملة للألوان مع أسمائها بالعربية والإنجليزية
  static final Map<String, Color> _colorMap = {
    // الألوان الأساسية
    'red': Colors.red,
    'أحمر': Colors.red,
    'blue': Colors.blue,
    'أزرق': Colors.blue,
    'green': Colors.green,
    'أخضر': Colors.green,
    'yellow': Colors.yellow,
    'أصفر': Colors.yellow,
    'orange': Colors.orange,
    'برتقالي': Colors.orange,
    'purple': Colors.purple,
    'بنفسجي': Colors.purple,
    'pink': Colors.pink,
    'وردي': Colors.pink,
    'brown': Colors.brown,
    'بني': Colors.brown,
    'black': Colors.black,
    'أسود': Colors.black,
    'white': Colors.white,
    'أبيض': Colors.white,
    'grey': Colors.grey,
    'gray': Colors.grey,
    'رمادي': Colors.grey,
    
    // ألوان متقدمة
    'golden': const Color(0xFFFFD700),
    'gold': const Color(0xFFFFD700),
    'ذهبي': const Color(0xFFFFD700),
    'silver': const Color(0xFFC0C0C0),
    'فضي': const Color(0xFFC0C0C0),
    'navy': const Color(0xFF000080),
    'كحلي': const Color(0xFF000080),
    'maroon': const Color(0xFF800000),
    'عنابي': const Color(0xFF800000),
    'olive': const Color(0xFF808000),
    'زيتوني': const Color(0xFF808000),
    'lime': Colors.lime,
    'ليموني': Colors.lime,
    'cyan': Colors.cyan,
    'سماوي': Colors.cyan,
    'teal': Colors.teal,
    'أزرق مخضر': Colors.teal,
    'indigo': Colors.indigo,
    'نيلي': Colors.indigo,
    'violet': const Color(0xFF8A2BE2),
    'بنفسجي فاتح': const Color(0xFF8A2BE2),
    'turquoise': const Color(0xFF40E0D0),
    'فيروزي': const Color(0xFF40E0D0),
    'coral': const Color(0xFFFF7F50),
    'مرجاني': const Color(0xFFFF7F50),
    'salmon': const Color(0xFFFA8072),
    'سلموني': const Color(0xFFFA8072),
    'khaki': const Color(0xFFF0E68C),
    'كاكي': const Color(0xFFF0E68C),
    'beige': const Color(0xFFF5F5DC),
    'بيج': const Color(0xFFF5F5DC),
    'ivory': const Color(0xFFFFFFF0),
    'عاجي': const Color(0xFFFFFFF0),
    'crimson': const Color(0xFFDC143C),
    'قرمزي': const Color(0xFFDC143C),
    'scarlet': const Color(0xFFFF2400),
    'قرمزي فاتح': const Color(0xFFFF2400),
    
    // درجات مختلفة
    'light blue': Colors.lightBlue,
    'أزرق فاتح': Colors.lightBlue,
    'dark blue': const Color(0xFF00008B),
    'أزرق غامق': const Color(0xFF00008B),
    'sky blue': const Color(0xFF87CEEB),
    'أزرق سماوي': const Color(0xFF87CEEB),
    'light green': Colors.lightGreen,
    'أخضر فاتح': Colors.lightGreen,
    'dark green': const Color(0xFF006400),
    'أخضر غامق': const Color(0xFF006400),
    'forest green': const Color(0xFF228B22),
    'أخضر غابات': const Color(0xFF228B22),
    'light red': const Color(0xFFFFCCCB),
    'أحمر فاتح': const Color(0xFFFFCCCB),
    'dark red': const Color(0xFF8B0000),
    'أحمر غامق': const Color(0xFF8B0000),
  };
  
  /// دالة شاملة لتحويل اسم اللون أو رمزه إلى Color
  static Color getColor(String colorValue) {
    if (colorValue.isEmpty) return Colors.grey;
    
    // التحقق من رمز الألوان الست عشرية
    if (_isHexColor(colorValue)) {
      return _parseHexColor(colorValue);
    }
    
    // البحث في خريطة الألوان
    String normalizedName = colorValue.toLowerCase().trim();
    if (_colorMap.containsKey(normalizedName)) {
      return _colorMap[normalizedName]!;
    }
    
    // محاولة البحث الجزئي
    for (String key in _colorMap.keys) {
      if (key.contains(normalizedName) || normalizedName.contains(key)) {
        return _colorMap[key]!;
      }
    }
    
    // إذا لم يتم العثور على اللون، إرجاع رمادي
    return Colors.grey;
  }
  
  /// التحقق من كون النص رمز لون ست عشري
  static bool _isHexColor(String value) {
    if (value.startsWith('#')) {
      value = value.substring(1);
    }
    return RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value) || 
           RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(value);
  }
  
  /// تحويل رمز الألوان الست عشرية إلى Color
  static Color _parseHexColor(String hexColor) {
    try {
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }
      if (hexColor.length == 6) {
        hexColor = 'FF' + hexColor; // إضافة قناة الشفافية
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
  
  /// تحويل Color إلى رمز ست عشري
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  /// الحصول على جميع الألوان المتاحة
  static List<String> getAvailableColors() {
    return _colorMap.keys.toList();
  }
  
  /// إضافة لون جديد إلى الخريطة
  static void addColor(String name, Color color) {
    _colorMap[name.toLowerCase()] = color;
  }
}

