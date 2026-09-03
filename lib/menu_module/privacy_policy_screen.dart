import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/terms_provider.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TermsProvider>(context, listen: false).fetchPrivacyPolicy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8F8),
        elevation: 0,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A4A3A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF0A4A3A),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TermsProvider>(
          builder: (context, provider, child) {
            if (provider.isPrivacyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.privacyErrorMessage != null) {
              return Center(child: Text(provider.privacyErrorMessage!));
            }

            if (provider.privacySections.isEmpty) {
              return const Center(child: Text('No Privacy Policy found.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: provider.privacySections
                    .map((section) => _buildSection(section))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(TermsSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty)
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (section.title.isNotEmpty) const SizedBox(height: 8),
          if (section.desc.isNotEmpty)
            Text(
              section.desc,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
                fontStyle: FontStyle.normal,
              ),
            ),
          if (section.desc.isNotEmpty && section.points.isNotEmpty)
            const SizedBox(height: 8),
          if (section.points.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.points
                  .map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0, left: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '•  ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
