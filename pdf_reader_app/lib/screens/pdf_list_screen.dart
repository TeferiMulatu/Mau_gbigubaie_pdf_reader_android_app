import 'package:flutter/material.dart';
import 'package:pdf_reader_app/screens/pdf_viewer_screen.dart';
import 'package:pdf_reader_app/widgets/pdf_list_tile.dart';

class PDFListScreen extends StatelessWidget {
  const PDFListScreen({super.key});

  final List<Map<String, String>> pdfFiles = const [
    {'name': 'ጥራዝ 1', 'file': 'ጥራዝ1.pdf', 'description': ''},
    {'name': 'ጥራዝ 2', 'file': 'ጥራዝ2.pdf', 'description': ''},
    {'name': 'ጥራዝ 3', 'file': 'ጥራዝ3.pdf', 'description': ''},
    {'name': 'ጥራዝ 4', 'file': 'ጥራዝ4.pdf', 'description': ''},
    {'name': 'ጥራዝ 5', 'file': 'ጥራዝ5.pdf', 'description': ''},
    {'name': 'ጥራዝ 5(2)', 'file': 'ጥራዝ5(2).pdf', 'description': ''},
    {'name': 'ሲሳይ በገና', 'file': 'ሲሳይ_በገና.pdf', 'description': ''},
    {'name': 'ወረብ', 'file': 'ወረብ.pdf', 'description': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'መቅደላ አምባ ግቢ ጉባኤ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            tooltip: 'Info',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPDFInfo(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3949AB).withOpacity(0.10), // Indigo tint
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.book, color: Color(0xFF3949AB)),
                  SizedBox(width: 8),
                  Text(
                    'የመዝሙር ጥራዝ ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3949AB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap on any document to start reading',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: pdfFiles.length,
                  itemBuilder: (context, index) {
                    final pdf = pdfFiles[index];
                    return PdfListTile(
                      title: pdf['name']!,
                      description: pdf['description']!,
                      colorIndex: index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              pdfName: pdf['name']!,
                              pdfFile: pdf['file']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPDFInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('መረጃ'),
        content: const SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('መቅደላ አምባ ግቢ ጉባኤ'),
              SizedBox(height: 8),
              Text('• የመዝሙር ጥራዝ እና ሌሎች መጽሐፎች'),

              SizedBox(height: 8),
              Text('• Developed by ፡'),
              Text('• Teferi Mulatu And Abibo Eshetie'),
              Text('• contact :'),
              Text('• temu54321@gmail.com'),
              SizedBox(height: 16),
              Text('© 2018 ዓ.ም መ/አ/ዩ/ግ/ጉባኤ'),
            ],
          ),
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
