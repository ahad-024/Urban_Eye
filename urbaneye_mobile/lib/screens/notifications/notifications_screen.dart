import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color success = Color(0xFF63D39A);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF8B9CFF);

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? errorMessage;

  final Set<String> readIds = {};
  final Set<String> deletedIds = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  Color _primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryText(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFB0B0B8)
          : const Color(0xFF6B6675);

  Color _card(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF18181B)
          : Colors.white.withValues(alpha: 0.94);

  Color _border(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);

  Color _unreadCard(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF20152D)
          : const Color(0xFFF4EAFE);

  int get unreadCount => notifications.where((n) {
        final id = n['id'].toString();
        return !readIds.contains(id);
      }).length;

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final reports = await ApiClient.getReports();

      if (!mounted) return;

      final loaded = <Map<String, dynamic>>[];

      for (final report in reports) {
        final id = (report['id'] ?? '').toString();

        if (id.isEmpty || deletedIds.contains(id)) {
          continue;
        }

        final issueType = _formatIssue(
          report['issue_type'] ??
              report['issue'] ??
              report['title'] ??
              'Civic issue',
        );

        final status = (report['status'] ?? 'pending')
            .toString()
            .toLowerCase();

        final isResolved = status == 'resolved';

        loaded.add({
          'id': id,
          'title': isResolved
              ? 'Report Resolved'
              : 'Report Submitted',
          'message': isResolved
              ? 'Your $issueType report has been marked as resolved.'
              : 'Your $issueType report is recorded in UrbanEye.',
          'time': _formatTime(
            report['created_at'] ??
                report['updated_at'] ??
                report['date'],
          ),
          'icon': isResolved
              ? LucideIcons.checkCircle2
              : LucideIcons.fileText,
          'color': isResolved ? success : info,
          'report': report,
        });
      }

      loaded.sort((a, b) {
        final reportA =
            a['report'] as Map<String, dynamic>;
        final reportB =
            b['report'] as Map<String, dynamic>;

        final dateA = DateTime.tryParse(
              (reportA['created_at'] ??
                      reportA['updated_at'] ??
                      '')
                  .toString(),
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final dateB = DateTime.tryParse(
              (reportB['created_at'] ??
                      reportB['updated_at'] ??
                      '')
                  .toString(),
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateB.compareTo(dateA);
      });

      setState(() {
        notifications = loaded;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String _formatIssue(dynamic value) {
    return value
        .toString()
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Date unavailable';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    final difference = DateTime.now().difference(
      date.toLocal(),
    );

    if (difference.isNegative) return 'Just now';
    if (difference.inMinutes < 1) return 'Just now';

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF181221),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  void _markAsRead(String id) {
    setState(() => readIds.add(id));
  }

  void _markAllAsRead() {
    setState(() {
      readIds.addAll(
        notifications.map((n) => n['id'].toString()),
      );
    });

    _showSnackBar('All notifications marked as read');
  }

  void _deleteNotification(int index) {
    final notification = notifications[index];
    final id = notification['id'].toString();

    setState(() {
      notifications.removeAt(index);
      deletedIds.add(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Notification removed',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF181221),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: purpleLight,
          onPressed: () {
            if (!mounted) return;

            setState(() {
              deletedIds.remove(id);
              notifications.insert(
                index.clamp(0, notifications.length),
                notification,
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    if (notifications.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          'Clear notifications?',
          style: TextStyle(
            color: _primaryText(dialogContext),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'This removes notifications from this screen. Your actual reports will not be deleted.',
          style: TextStyle(
            color: _secondaryText(dialogContext),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _secondaryText(dialogContext),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      deletedIds.addAll(
        notifications.map((n) => n['id'].toString()),
      );
      notifications.clear();
    });

    _showSnackBar('Notifications cleared');
  }

  void _showNotificationMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        decoration: BoxDecoration(
          color: _isDark(sheetContext)
              ? const Color(0xFF121016)
              : const Color(0xFFF9F6FB),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification options',
              style: TextStyle(
                color: _primaryText(sheetContext),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (unreadCount > 0)
              ListTile(
                leading: const Icon(
                  LucideIcons.checkCheck,
                  color: purpleLight,
                ),
                title: Text(
                  'Mark all as read',
                  style: TextStyle(
                    color: _primaryText(sheetContext),
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _markAllAsRead();
                },
              ),
            ListTile(
              leading: const Icon(
                LucideIcons.trash2,
                color: danger,
              ),
              title: Text(
                'Clear all notifications',
                style: TextStyle(
                  color: _primaryText(sheetContext),
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _clearAllNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      body: Stack(
        children: [
          const _NotificationsBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _topButton(
            LucideIcons.arrowLeft,
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  'URBANEYE',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (notifications.isNotEmpty)
            _topButton(
              LucideIcons.moreVertical,
              _showNotificationMenu,
            )
          else
            const SizedBox(width: 46),
        ],
      ),
    );
  }

  Widget _topButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: _card(context),
      shape: CircleBorder(
        side: BorderSide(color: _border(context)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: purpleLight),
      );
    }

    if (errorMessage != null && notifications.isEmpty) {
      return _messageState(
        icon: LucideIcons.wifiOff,
        title: 'Could not load activity',
        message:
            'Check your connection and make sure the UrbanEye backend is running.',
        actionLabel: 'Try Again',
        onAction: _loadNotifications,
      );
    }

    if (notifications.isEmpty) {
      return _messageState(
        icon: LucideIcons.bellOff,
        title: 'No notifications',
        message:
            'Your report activity will appear here when you submit a civic issue.',
        actionLabel: 'Back to Home',
        onAction: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      );
    }

    return RefreshIndicator(
      color: purpleLight,
      onRefresh: _loadNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _summaryCard(),
          const SizedBox(height: 26),
          Row(
            children: [
              Text(
                'Recent activity',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: const TextStyle(
                      color: purpleLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          ...List.generate(
            notifications.length,
            _notificationCard,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Some activity may be outdated. Pull down to refresh.',
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(
              alpha: _isDark(context) ? 0.08 : 0.05,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF4C1D95),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              LucideIcons.bell,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay updated',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unreadCount > 0
                      ? 'You have $unreadCount unread ${unreadCount == 1 ? 'notification' : 'notifications'}.'
                      : 'You are all caught up.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            const Icon(
              LucideIcons.circle,
              color: purpleLight,
              size: 10,
            ),
        ],
      ),
    );
  }

  Widget _notificationCard(int index) {
    final notification = notifications[index];
    final id = notification['id'].toString();
    final isRead = readIds.contains(id);
    final color = notification['color'] as Color;
    final icon = notification['icon'] as IconData;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: danger,
          borderRadius: BorderRadius.circular(19),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => _deleteNotification(index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: () {
              _markAsRead(id);
              final report = notification['report'];

              if (report is Map<String, dynamic>) {
                context.push('/report-details', extra: report);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isRead
                    ? _card(context)
                    : _unreadCard(context),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isRead
                      ? _border(context)
                      : purple.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'].toString(),
                                style: TextStyle(
                                  color: _primaryText(context),
                                  fontSize: 12.5,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: purpleLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification['message'].toString(),
                          style: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 10.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock3,
                              color: _secondaryText(context),
                              size: 11,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              notification['time'].toString(),
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _card(context),
                shape: BoxShape.circle,
                border: Border.all(color: _border(context)),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.08),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 38,
                color: purpleLight,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 11,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 25),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryText(context),
                side: BorderSide(color: _border(context)),
                backgroundColor: _card(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsBackground extends StatelessWidget {
  const _NotificationsBackground();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.20, 0.52, 1.0],
            colors: isDark
                ? const [
                    Color(0xFF4B286E),
                    Color(0xFF21102F),
                    Color(0xFF0D0B12),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFEFE3F8),
                    Color(0xFFF6F0FA),
                    Color(0xFFFAF8FC),
                    Color(0xFFF8F7FC),
                  ],
          ),
        ),
      ),
    );
  }
}
