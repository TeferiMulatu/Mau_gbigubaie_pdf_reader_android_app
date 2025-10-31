import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdfx/pdfx.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfName;
  final String pdfFile;

  const PDFViewerScreen({
    super.key,
    required this.pdfName,
    required this.pdfFile,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool isLoading = true;
  String? errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      // Asset-based loading works across platforms and preserves internal links/outline
      // No explicit pre-load required; the viewer will stream from assets
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.pdfName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showPDFInfo();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading PDF...',
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF3949AB)),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _loadPDF();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _AndroidPdfxViewer(assetPath: 'assets/pdfs/${widget.pdfFile}'),
    );
  }

  void _showPDFInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document: ${widget.pdfName}'),
            const SizedBox(height: 8),
            Text('File: ${widget.pdfFile}'),
            const SizedBox(height: 8),
            const Text('©2018 ዓ.ም በ መ/አ/ዩ/ግ/ጉባኤ መዝሙር ክፍል የተዘጋጀ መተግበሪያ'),
            
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AndroidPdfxViewer extends StatefulWidget {
  final String assetPath;
  const _AndroidPdfxViewer({required this.assetPath});

  @override
  State<_AndroidPdfxViewer> createState() => _AndroidPdfxViewerState();
}

class _AndroidPdfxViewerState extends State<_AndroidPdfxViewer> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  String? _error;
  int _current = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final bytes = await rootBundle.load(widget.assetPath);
      final docFuture = PdfDocument.openData(bytes.buffer.asUint8List());
      final ctrl = PdfControllerPinch(document: docFuture, initialPage: 1);
      setState(() {
        _controller = ctrl;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'PDF not found or unreadable: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _controller == null) {
      return Center(child: Text(_error ?? 'PDF not found'));
    }
    _total = _controller!.pagesCount ?? _total;
    return Stack(
      children: [
        PdfViewPinch(
          controller: _controller!,
          scrollDirection: Axis.vertical,
          padding: 0,
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          onPageChanged: (page) {
            setState(() {
              _current = page;
              _total = _controller!.pagesCount ?? _total;
            });
          },
          onDocumentLoaded: (doc) {
            setState(() {
              _total = _controller!.pagesCount ?? 0;
              _current = 1;
            });
          },
        ),
        if (_total > 0)
          Positioned(
            right: 4,
            top: 72,
            bottom: 72,
            child: SizedBox(
              width: 24,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final trackH = constraints.maxHeight;
                  const thumbH = 28.0;
                  final ratio = (_total <= 1) ? 0.0 : (_current - 1) / (_total - 1);
                  final thumbTop = (trackH - thumbH) * ratio;
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (details) {
                      final localY = (details.localPosition.dy)
                          .clamp(0.0, trackH - thumbH);
                      final r = trackH <= thumbH ? 0.0 : localY / (trackH - thumbH);
                      final target = (1 + r * (_total - 1)).round().clamp(1, _total);
                      setState(() {
                        _current = target;
                      });
                      _controller!.animateToPage(
                        pageNumber: target,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: thumbTop,
                          child: Container(
                            width: 12,
                            height: thumbH,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3949AB).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}


