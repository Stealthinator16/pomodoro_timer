import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'college_data.dart';

class CampusViewer extends StatefulWidget {
  final College college;
  final int unlockedPhotoCount;

  const CampusViewer({
    super.key,
    required this.college,
    required this.unlockedPhotoCount,
  });

  @override
  State<CampusViewer> createState() => _CampusViewerState();
}

class _CampusViewerState extends State<CampusViewer> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final college = widget.college;
    final colors = Theme.of(context).colorScheme;
    final visibleCount = widget.unlockedPhotoCount;

    return Scaffold(
      appBar: AppBar(title: Text(college.name)),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: visibleCount,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: college.photoUrl(index + 1),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 48,
                                color: colors.onSurface.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text('Photo not available',
                                style: TextStyle(
                                    color: colors.onSurface
                                        .withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Page indicator dots
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                visibleCount,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
