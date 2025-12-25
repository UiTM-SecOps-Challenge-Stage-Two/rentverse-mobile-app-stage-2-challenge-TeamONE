


String? makeDeviceAccessibleUrl(String? url) {
  if (url == null || url.isEmpty) return null;





  final lower = url.toLowerCase();
  if (lower.startsWith('http://127.0.0.1') ||
      lower.startsWith('http://localhost')) {
    return url.replaceFirst(
      RegExp(r'http://(127\.0\.0\.1|localhost)', caseSensitive: false),
      'http://10.0.2.2',
    );
  }




  try {
    return Uri.parse(url).toString();
  } catch (_) {
    return Uri.encodeFull(url);
  }
}
