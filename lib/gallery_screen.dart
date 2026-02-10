import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'campus_viewer.dart';
import 'college_data.dart';
import 'storage_service.dart';

class GalleryScreen extends StatelessWidget {
  final StorageService storage;

  const GalleryScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final todaySessions = storage.todaySessions();
    final totalSessions = storage.totalSessions();
    final streak = storage.currentStreak();

    final unlocked = getUnlockedColleges(totalSessions);
    final nextCollege = getNextLock(totalSessions);

    // Sort cards: unlocked (highest rank first), then locked (nearest unlock first)
    final unlockedSorted = List<College>.from(unlocked)
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final lockedSorted = kColleges
        .where((c) => totalSessions < c.sessionsToUnlock)
        .toList()
      ..sort((a, b) => a.sessionsToUnlock.compareTo(b.sessionsToUnlock));
    final allCards = [...unlockedSorted, ...lockedSorted];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Gallery')),
      body: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Today', value: '$todaySessions', colors: colors),
                _StatChip(label: 'Total', value: '$totalSessions', colors: colors),
                _StatChip(
                  label: 'Streak',
                  value: '$streak ${streak == 1 ? 'day' : 'days'}',
                  colors: colors,
                ),
              ],
            ),
          ),
          // Progress toward next unlock
          if (nextCollege != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalSessions / nextCollege.sessionsToUnlock,
                      minHeight: 8,
                      backgroundColor: colors.onSurface.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(colors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalSessions/${nextCollege.sessionsToUnlock} sessions \u2014 ${nextCollege.name} next!',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          if (nextCollege == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'All campuses unlocked! \u{1f389}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Divider(height: 1),
          // College grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: allCards.length,
              itemBuilder: (context, index) {
                final college = allCards[index];
                final isUnlocked = totalSessions >= college.sessionsToUnlock;
                final unlockedPhotos = college.unlockedPhotoCount(totalSessions);
                return _CollegeCard(
                  college: college,
                  isUnlocked: isUnlocked,
                  totalSessions: totalSessions,
                  unlockedPhotoCount: unlockedPhotos,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Campus names are used for motivational purposes only. '
              'This app is not affiliated with or endorsed by any listed institution.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _StatChip({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }
}

class _CollegeCard extends StatelessWidget {
  final College college;
  final bool isUnlocked;
  final int totalSessions;
  final int unlockedPhotoCount;

  const _CollegeCard({
    required this.college,
    required this.isUnlocked,
    required this.totalSessions,
    required this.unlockedPhotoCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final remaining = college.sessionsToUnlock - totalSessions;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isUnlocked ? 2 : 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (isUnlocked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CampusViewer(
                  college: college,
                  unlockedPhotoCount: unlockedPhotoCount,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                      'Complete $remaining more session${remaining == 1 ? '' : 's'} to unlock!'),
                  duration: const Duration(seconds: 2),
                ),
              );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: isUnlocked
                  ? CachedNetworkImage(
                      imageUrl: college.photoUrl(1),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: colors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: colors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.school,
                            size: 40,
                            color: colors.primary.withValues(alpha: 0.5)),
                      ),
                    )
                  : Container(
                      color: colors.onSurface.withValues(alpha: 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline,
                              size: 32,
                              color: colors.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 6),
                          Text(
                            '$remaining session${remaining == 1 ? '' : 's'} to go',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          college.name,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? colors.onSurface
                                : colors.onSurface.withValues(alpha: 0.4),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? colors.primary.withValues(alpha: 0.15)
                              : colors.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${college.rank}',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isUnlocked
                                ? colors.primary
                                : colors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isUnlocked)
                    Text(
                      '$unlockedPhotoCount/${college.photoCount} photos',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
