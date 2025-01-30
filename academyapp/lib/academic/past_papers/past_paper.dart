import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


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

class DisplayPastPaperPdfScreen extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;


  const DisplayPastPaperPdfScreen({
    Key? key,
    required this.selectedClass,
    required this.selectedSubject,
  }) : super(key: key);

  @override
  _DisplayPastPaperPdfScreenState createState() => _DisplayPastPaperPdfScreenState();
}

class _DisplayPastPaperPdfScreenState extends State<DisplayPastPaperPdfScreen> {
  List<PdfMetadata> _pdfList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
   // _fetchPdfMetadata();
  }

  // Future<void> _fetchPdfMetadata() async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
  //         .collection('classes')
  //         .doc(widget.selectedClass)
  //         .collection('subjects')
  //         .doc(widget.selectedSubject)
  //         .collection('past_papers')
  //         .get();
  //
  //     if (snapshot.docs.isNotEmpty) {
  //       setState(() {
  //         _pdfList = snapshot.docs.map((doc) {
  //           try {
  //             return PdfMetadata.fromMap(doc.data());
  //           } catch (e) {
  //             print("Error creating PdfMetadata: $e");
  //             return null;
  //           }
  //         }).whereType<PdfMetadata>().toList(); // Filter out null values
  //         _isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching PDF metadata: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

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
      appBar: AppBar(title: Text('Select PDF')),
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

class PlatformPdfViewer extends StatefulWidget {
  final String pdfUrl;

  PlatformPdfViewer({required this.pdfUrl});

  @override
  _PlatformPdfViewerState createState() => _PlatformPdfViewerState();
}

class _PlatformPdfViewerState extends State<PlatformPdfViewer> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;
      final filename = 'document.pdf';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View PDF')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: localPath!),
    );
  }
}