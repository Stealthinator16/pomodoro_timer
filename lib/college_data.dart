import 'dart:math';

const kBasePhotoUrl =
    'https://raw.githubusercontent.com/Stealthinator16/campus-photos/main';

class College {
  final int rank;
  final String name;
  final String slug;
  final int sessionsToUnlock;
  final int photoCount;

  const College({
    required this.rank,
    required this.name,
    required this.slug,
    required this.sessionsToUnlock,
    this.photoCount = 3,
  });

  String photoUrl(int index) => '$kBasePhotoUrl/$slug/$index.jpg';

  /// Threshold for unlocking the i-th photo (0-based index).
  int photoThreshold(int photoIndex) {
    if (photoIndex <= 0) return sessionsToUnlock;
    final step = max(1, sessionsToUnlock ~/ 10);
    return sessionsToUnlock + photoIndex * step;
  }

  /// How many photos are viewable at the given session count.
  int unlockedPhotoCount(int totalSessions) {
    int count = 0;
    for (int i = 0; i < photoCount; i++) {
      if (totalSessions >= photoThreshold(i)) count++;
    }
    return count;
  }
}

const List<College> kColleges = [
  College(rank: 1, name: 'IIT Bombay', slug: 'iit-bombay', sessionsToUnlock: 260, photoCount: 4),
  College(rank: 2, name: 'IIT Delhi', slug: 'iit-delhi', sessionsToUnlock: 230, photoCount: 5),
  College(rank: 3, name: 'IIT Madras', slug: 'iit-madras', sessionsToUnlock: 200, photoCount: 5),
  College(rank: 4, name: 'IIT Kanpur', slug: 'iit-kanpur', sessionsToUnlock: 175, photoCount: 4),
  College(rank: 5, name: 'IIT Kharagpur', slug: 'iit-kharagpur', sessionsToUnlock: 150, photoCount: 4),
  College(rank: 6, name: 'IIT Roorkee', slug: 'iit-roorkee', sessionsToUnlock: 130, photoCount: 4),
  College(rank: 7, name: 'IIT Guwahati', slug: 'iit-guwahati', sessionsToUnlock: 112, photoCount: 5),
  College(rank: 8, name: 'IIT Hyderabad', slug: 'iit-hyderabad', sessionsToUnlock: 96, photoCount: 4),
  College(rank: 9, name: 'IIT BHU Varanasi', slug: 'iit-bhu', sessionsToUnlock: 82, photoCount: 4),
  College(rank: 10, name: 'IIT Indore', slug: 'iit-indore', sessionsToUnlock: 70, photoCount: 4),
  College(rank: 11, name: 'IIT (ISM) Dhanbad', slug: 'iit-dhanbad', sessionsToUnlock: 58, photoCount: 5),
  College(rank: 12, name: 'NIT Trichy', slug: 'nit-trichy', sessionsToUnlock: 48, photoCount: 4),
  College(rank: 13, name: 'NIT Surathkal', slug: 'nit-surathkal', sessionsToUnlock: 38),
  College(rank: 14, name: 'NIT Warangal', slug: 'nit-warangal', sessionsToUnlock: 30, photoCount: 5),
  College(rank: 15, name: 'NIT Calicut', slug: 'nit-calicut', sessionsToUnlock: 23, photoCount: 5),
  College(rank: 16, name: 'NIT Rourkela', slug: 'nit-rourkela', sessionsToUnlock: 17, photoCount: 5),
  College(rank: 17, name: 'NIT Allahabad (MNNIT)', slug: 'nit-allahabad', sessionsToUnlock: 12),
  College(rank: 18, name: 'NIT Jaipur', slug: 'nit-jaipur', sessionsToUnlock: 8),
  College(rank: 19, name: 'NIT Nagpur', slug: 'nit-nagpur', sessionsToUnlock: 5, photoCount: 5),
  College(rank: 20, name: 'NIT Durgapur', slug: 'nit-durgapur', sessionsToUnlock: 2, photoCount: 5),
];

List<College> getUnlockedColleges(int totalSessions) {
  return kColleges.where((c) => totalSessions >= c.sessionsToUnlock).toList();
}

College? getNextLock(int totalSessions) {
  // Find the locked college closest to being unlocked
  final locked = kColleges.where((c) => totalSessions < c.sessionsToUnlock).toList();
  if (locked.isEmpty) return null;
  locked.sort((a, b) => a.sessionsToUnlock.compareTo(b.sessionsToUnlock));
  return locked.first;
}

List<College> getNewlyUnlocked(int previousTotal, int newTotal) {
  return kColleges
      .where((c) => c.sessionsToUnlock > previousTotal && c.sessionsToUnlock <= newTotal)
      .toList();
}
