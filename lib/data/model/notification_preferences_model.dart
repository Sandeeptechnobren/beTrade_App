/// DTO for the `/notificationPreferences` response.
///
/// Backend shape:
/// ```
/// {
///   "section": "Discover & Trends",
///   "items": [
///     {"title": "...", "description": "...", "status": "active|inactive"}
///   ]
/// }
/// ```
class NotificationSection {
  final String section;
  final List<NotificationItem> items;

  NotificationSection({
    required this.section,
    required this.items,
  });

  factory NotificationSection.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return NotificationSection(
      section: json['section'] ?? '',
      items: rawItems
          .whereType<Map>()
          .map((e) => NotificationItem.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;

  /// Derived from the `status` field. `"active"` → `true`, anything else → `false`.
  final bool isActive;

  NotificationItem({
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    return NotificationItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isActive: rawStatus == 'active',
    );
  }

  NotificationItem copyWith({bool? isActive}) {
    return NotificationItem(
      title: title,
      description: description,
      isActive: isActive ?? this.isActive,
    );
  }
}
