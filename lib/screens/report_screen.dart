import 'package:flutter/material.dart';
import '../models/birth_details.dart';

class ReportScreen extends StatefulWidget {
  final AstroReport report;

  const ReportScreen({super.key, required this.report});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final formattedDate = "${report.details.dob.day}/${report.details.dob.month}/${report.details.dob.year}";

    return Scaffold(
      backgroundColor: const Color(0xFF03001e),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF03001e),
              Color(0xFF1a052e),
              Color(0xFF03001e),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.details.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$formattedDate | ${report.details.place}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.amber),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Astro Report link copied to clipboard!'),
                            backgroundColor: Colors.amber,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Tab Bar Headers
              TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: Colors.amber,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Personality'),
                  Tab(text: 'Career'),
                  Tab(text: '2026 Forecast'),
                  Tab(text: 'Marriage'),
                ],
              ),

              // Tab Bar Body
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(report.textReports['personality'] as String),
                    _buildTabContent(report.textReports['career'] as String),
                    _buildTabContent(report.textReports['forecast_2026'] as String),
                    _buildTabContent(report.textReports['love_marriage'] as String),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB CONTENT ---

  Widget _buildTabContent(String content) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        _buildFormattedTextCard(content),
      ],
    );
  }

  Widget _buildFormattedTextCard(String content) {
    final List<Widget> children = [];
    final lines = content.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 10));
        continue;
      }

      if (line.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text(
              line.replaceFirst('### ', '').toUpperCase(),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      } else if (line.startsWith('#### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              line.replaceFirst('#### ', ''),
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ') || line.startsWith('* ')) {
        final cleanText = line.substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5.0, right: 8.0),
                  child: Icon(Icons.circle, size: 5, color: Colors.amber),
                ),
                Expanded(child: _buildRichText(cleanText)),
              ],
            ),
          ),
        );
      } else if (line.startsWith('---')) {
        children.add(
          Divider(
            color: Colors.amber.withOpacity(0.15),
            height: 16,
            thickness: 1,
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildRichText(line),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRichText(String text) {
    // Matches **bold** and *italic* (but not ** inside bold)
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    final List<InlineSpan> spans = [];
    final defaultStyle = TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4);

    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }
      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
        ));
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
