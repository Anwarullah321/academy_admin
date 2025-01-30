import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:ui' as ui;


class PdfMetadata {
  final String downloadUrl;
  final String title;

  PdfMetadata({required this.downloadUrl, required this.title});

  factory PdfMetadata.fromMap(Map<String, dynamic> data) {
    String downloadUrl = data['downloadUrl'] ?? '';

    if (downloadUrl.isEmpty || Uri.tryParse(downloadUrl)?.hasAbsolutePath != true) {
      throw 'Invalid or missing download URL';
    }

    return PdfMetadata(
      downloadUrl: downloadUrl,
      title: data['title'] ?? 'Untitled',
    );
  }
}

class DisplayPdfScreen extends StatefulWidget {
  final String selectedSubject;
  final String selectedChapter;

  const DisplayPdfScreen({
    Key? key,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _DisplayPdfScreenState createState() => _DisplayPdfScreenState();
}

class _DisplayPdfScreenState extends State<DisplayPdfScreen> {
  List<PdfMetadata> _pdfList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPdfMetadata();
  }

  Future<void> _fetchPdfMetadata() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('etea_subjects')
          .doc(widget.selectedSubject)
          .collection('etea_chapters')
          .doc(widget.selectedChapter)
          .collection('etea_notes')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _pdfList = snapshot.docs.map((doc) {
            try {
              return PdfMetadata.fromMap(doc.data());
            } catch (e) {
              print("Error creating PdfMetadata: $e");
              return null;
            }
          }).whereType<PdfMetadata>().toList(); // Filter out null values
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching PDF metadata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformPdfViewer(pdfUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pdfList.isEmpty
          ? Center(child: Text('No PDFs found'))
          : ListView.builder(
        itemCount: _pdfList.length,
        itemBuilder: (context, index) {
          PdfMetadata pdf = _pdfList[index];
          return ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(pdf.title),
            trailing: IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () => _openPdf(context, pdf.downloadUrl),
            ),
          );
        },
      ),
    );
  }
}


class PlatformPdfViewer extends StatelessWidget {
  final String pdfUrl;

  PlatformPdfViewer({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View PDF')),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    final String viewerId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewerId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(pdfUrl)}'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return HtmlElementView(viewType: viewerId);
  }
}