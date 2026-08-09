enum DewBubbleColor { blue, pink, yellow, green }

DewBubbleColor? dewBubbleColorFromToken(String? token) {
  return switch (token) {
    'B' => DewBubbleColor.blue,
    'P' => DewBubbleColor.pink,
    'Y' => DewBubbleColor.yellow,
    'G' => DewBubbleColor.green,
    _ => null,
  };
}

String dewBubbleColorToken(DewBubbleColor color) {
  return switch (color) {
    DewBubbleColor.blue => 'B',
    DewBubbleColor.pink => 'P',
    DewBubbleColor.yellow => 'Y',
    DewBubbleColor.green => 'G',
  };
}
