class TextSanitizer {
  TextSanitizer._();

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
