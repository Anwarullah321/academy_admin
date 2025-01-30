class PdfMetadata {
  final String downloadUrl;
  final String title;

  PdfMetadata({required this.downloadUrl, required this.title});

  factory PdfMetadata.fromMap(Map<String, dynamic> data) {
    String downloadUrl = data['downloadUrl'] ?? '';

    // Check if downloadUrl is empty or not a valid absolute URL
    if (downloadUrl.isEmpty || Uri.tryParse(downloadUrl)?.hasAbsolutePath != true) {
      throw 'Invalid or missing download URL';
    }

    return PdfMetadata(
      downloadUrl: downloadUrl,
      title: data['title'] ?? 'Untitled',
    );
  }
}
