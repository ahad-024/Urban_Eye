import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const Color purple = Color(0xFF7C3AED);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;

  Color get primaryText => Theme.of(context).colorScheme.onSurface;

  Color get secondaryText =>
      isDark ? const Color(0xFFB0B0B8) : const Color(0xFF6B6675);

  Color get topGlow =>
      isDark ? const Color(0xFF7137A8) : const Color(0xFFE9D5FF);

  Color get midGlow =>
      isDark ? const Color(0xFF2B1446) : const Color(0xFFF3E8FF);

  Color get lowerAmbient =>
      isDark ? const Color(0xFF0D0B12) : const Color(0xFFF8F7FC);

  Color get bottomBackground => isDark ? Colors.black : const Color(0xFFF8F7FC);

  Color get bentoCard => isDark ? const Color(0xE61A1A1D) : Colors.white;

  Color get innerCard =>
      isDark ? const Color(0xFF111114) : const Color(0xFFF3F1F6);

  Color get profileAvatar =>
      isDark ? const Color(0xFF29292C) : const Color(0xFFF0ECF5);

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.black.withValues(alpha: 0.075);

  Color get badgeBackground => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.045);

  Color get actionIcon => isDark
      ? Colors.white.withValues(alpha: 0.75)
      : Colors.black.withValues(alpha: 0.62);

  Color get mutedIcon => isDark
      ? Colors.white.withValues(alpha: 0.45)
      : Colors.black.withValues(alpha: 0.42);

  Color get dividerColor => isDark
      ? Colors.white.withValues(alpha: 0.055)
      : Colors.black.withValues(alpha: 0.065);

  Color get navBackground => isDark
      ? const Color(0xFF101012).withValues(alpha: 0.96)
      : Colors.white.withValues(alpha: 0.96);

  Color get navInactive => isDark
      ? Colors.white.withValues(alpha: 0.42)
      : Colors.black.withValues(alpha: 0.42);

  Color get navSelected => isDark ? Colors.white : const Color(0xFF17131D);

  Color get captureBackground => isDark ? midGlow : const Color(0xFFE9D5FF);

  Color get captureIcon => isDark ? Colors.white : const Color(0xFF5B21B6);

  int _currentIndex = 1;
  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Pending', 'Resolved'];

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ============================================================
  // LOAD REPORTS FROM DJANGO API
  // ============================================================

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final apiReports = await ApiClient.getReports();

      final reports = apiReports.map(_mapReport).toList();

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadError =
            'Could not load reports. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // NORMALIZE DJANGO REPORT FIELDS FOR THE UI
  // ============================================================

  Map<String, dynamic> _mapReport(Map<String, dynamic> item) {
    final rawIssue =
        (item['issue_type'] ??
                item['issueType'] ??
                item['title'] ??
                'Civic Issue')
            .toString();

    final issueType = _formatIssueType(rawIssue);

    final rawStatus = (item['status'] ?? 'pending').toString().toLowerCase();

    final String status;

    if (rawStatus == 'resolved') {
      status = 'Resolved';
    } else if (rawStatus == 'reviewing' || rawStatus == 'under_review') {
      status = 'Reviewing';
    } else {
      status = 'Pending';
    }

    final createdAt = DateTime.tryParse(
      (item['created_at'] ?? item['createdAt'] ?? item['date'] ?? '')
          .toString(),
    );

    final rawLocation =
        item['location'] ?? item['address'] ?? item['location_name'];

    String location = 'Location not available';

    if (rawLocation is String && rawLocation.trim().isNotEmpty) {
      location = rawLocation.trim();
    } else if (rawLocation is Map) {
      location =
          (rawLocation['address'] ??
                  rawLocation['name'] ??
                  rawLocation['location_name'] ??
                  '')
              .toString();

      if (location.isEmpty) {
        final latitude = rawLocation['latitude'] ?? rawLocation['lat'];
        final longitude = rawLocation['longitude'] ?? rawLocation['lng'];

        if (latitude != null && longitude != null) {
          location = '$latitude, $longitude';
        } else {
          location = 'Location not available';
        }
      }
    }

    final rawId = item['id'] ?? item['pk'] ?? '—';

    final confidence = _formatConfidence(
      item['confidence'] ?? item['confidence_score'],
    );

    return {
      ...item,
      'id': rawId.toString() == '—'
          ? '—'
          : '#UE-${rawId.toString().padLeft(5, '0')}',
      'title': '$issueType detected',
      'issueType': issueType,
      'location': location,
      'date': createdAt == null
          ? 'Date not available'
          : _formatReportDate(createdAt),
      'severity': _formatSeverity(item['severity']),
      'status': status,
      'confidence': confidence,
      'description': (item['description'] ?? 'No description provided.')
          .toString(),
      'icon': _iconForIssue(issueType),
    };
  }

  String _formatIssueType(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatSeverity(dynamic value) {
    final severity = (value ?? 'Unknown').toString().toLowerCase().trim();

    if (severity.isEmpty) return 'Unknown';

    return '${severity[0].toUpperCase()}${severity.substring(1)}';
  }

  String _formatConfidence(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '—';
    }

    final parsed = double.tryParse(value.toString());

    if (parsed == null) {
      final text = value.toString();
      return text.endsWith('%') ? text : '$text%';
    }

    final percent = parsed <= 1 && parsed > 0 ? parsed * 100 : parsed;

    final formatted = percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : percent.toStringAsFixed(1);

    return '$formatted%';
  }

  String _formatReportDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}, $hour:$minute $period';
  }

  IconData _iconForIssue(String value) {
    switch (value.toLowerCase()) {
      case 'pothole':
        return Icons.warning_amber_rounded;
      case 'garbage':
        return Icons.delete_outline_rounded;
      case 'street light':
        return Icons.lightbulb_outline_rounded;
      case 'road crack':
        return Icons.broken_image_outlined;
      case 'water overflow':
        return Icons.water_drop_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/reports');
        break;
      case 2:
        context.push('/capture');
        break;
      case 3:
        context.push('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filteredReports;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.16, 0.38, 0.66, 1.0],
                  colors: [
                    topGlow,
                    midGlow,
                    lowerAmbient,
                    bottomBackground,
                    bottomBackground,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -180,
            left: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                height: 370,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: topGlow.withValues(alpha: isDark ? 0.34 : 0.55),
                      blurRadius: 120,
                      spreadRadius: 38,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 270,
            right: -160,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: isDark ? 0.07 : 0.045),
                      blurRadius: 100,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: purple,
                    onRefresh: _loadReports,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 115),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 25),
                          _buildSummary(),
                          const SizedBox(height: 22),
                          _buildFilterBar(),
                          const SizedBox(height: 18),
                          _buildReportContent(filteredReports),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT CONTENT STATES
  // ============================================================

  Widget _buildReportContent(List<Map<String, dynamic>> filteredReports) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 65),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: purple,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Loading your reports...',
                style: TextStyle(color: secondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return _buildErrorState();
    }

    if (filteredReports.isEmpty) {
      return _buildEmptyState(
        message: _reports.isEmpty
            ? 'Your submitted reports will appear here.'
            : 'There are no reports in this category.',
      );
    }

    return Column(
      children: filteredReports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReportCard(report),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
      decoration: BoxDecoration(
        color: bentoCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 42, color: mutedIcon),
          const SizedBox(height: 16),
          Text(
            'Unable to load reports',
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryText, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.go('/home'),
          ),
          Text(
            'URBANEYE',
            style: TextStyle(
              color: primaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: profileAvatar,
                shape: BoxShape.circle,
                border: Border.all(color: cardBorder),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Reports',
          style: TextStyle(
            color: primaryText,
            fontSize: 31,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.9,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Track and manage your reported civic issues.',
          style: TextStyle(color: secondaryText, fontSize: 13.5, height: 1.45),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final total = _reports.length;

    final resolved = _reports
        .where((report) => report['status'] == 'Resolved')
        .length;

    final pending = _reports
        .where(
          (report) =>
              report['status'] == 'Pending' || report['status'] == 'Reviewing',
        )
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: bentoCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              value: total.toString().padLeft(2, '0'),
              label: 'Total',
              icon: Icons.layers_outlined,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              value: resolved.toString().padLeft(2, '0'),
              label: 'Resolved',
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              value: pending.toString().padLeft(2, '0'),
              label: 'Pending',
              icon: Icons.schedule_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: mutedIcon),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            color: primaryText,
            fontSize: 23,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: secondaryText, fontSize: 10.5)),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 48, color: dividerColor);
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: innerCard.withValues(alpha: isDark ? 0.90 : 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedFilter == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _selectedFilter = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: selected
                      ? (isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.055))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.055),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: selected
                          ? primaryText
                          : secondaryText.withValues(
                              alpha: isDark ? 0.65 : 0.75,
                            ),
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget _buildReportCard(Map<String, dynamic> report) {
    final title = (report['title'] ?? 'Civic issue').toString();
    final location = (report['location'] ?? 'Location not available')
        .toString();
    final date = (report['date'] ?? 'Date not available').toString();
    final severity = (report['severity'] ?? 'Unknown').toString();
    final status = (report['status'] ?? 'Pending').toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: purple.withValues(alpha: 0.08),
        onTap: () {
          context.push('/report-details', extra: report);
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bentoCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.055),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIssueIcon(report),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: mutedIcon,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(height: 1, color: dividerColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: mutedIcon,
                    size: 12.5,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondaryText, fontSize: 10.5),
                    ),
                  ),
                  _severityBadge(severity),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.30)
                        : Colors.black.withValues(alpha: 0.28),
                    size: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueIcon(Map<String, dynamic> report) {
    final icon = report['icon'] is IconData
        ? report['icon'] as IconData
        : _iconForIssue((report['issueType'] ?? '').toString());

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.045),
        ),
      ),
      child: Icon(icon, color: actionIcon, size: 21),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final resolved = status == 'Resolved';
    final reviewing = status == 'Reviewing';

    final badgeColor = resolved
        ? (isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.055))
        : reviewing
        ? purple.withValues(alpha: isDark ? 0.16 : 0.10)
        : (isDark
              ? Colors.white.withValues(alpha: 0.065)
              : Colors.black.withValues(alpha: 0.045));

    final dotColor = resolved
        ? (isDark
              ? Colors.white.withValues(alpha: 0.72)
              : Colors.black.withValues(alpha: 0.58))
        : reviewing
        ? purple
        : (isDark
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.black.withValues(alpha: 0.42));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: resolved
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.black.withValues(alpha: 0.62))
                  : reviewing
                  ? purple
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.62)
                        : Colors.black.withValues(alpha: 0.55)),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEVERITY BADGE
  // ============================================================

  Widget _severityBadge(String severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$severity severity',
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.53)
              : Colors.black.withValues(alpha: 0.52),
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 55),
      decoration: BoxDecoration(
        color: bentoCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: badgeBackground,
              shape: BoxShape.circle,
              border: Border.all(color: cardBorder),
            ),
            child: Icon(Icons.description_outlined, color: mutedIcon, size: 25),
          ),
          const SizedBox(height: 18),
          Text(
            _reports.isEmpty ? 'No reports yet' : 'No reports found',
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryText, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: navBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.58 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          _navItem(
            index: 1,
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
            label: 'Reports',
          ),
          _captureNavItem(),
          _navItem(
            index: 3,
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            label: 'Alerts',
          ),
          _navItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.0 : 0.94,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? activeIcon : icon,
                size: 21,
                color: selected ? navSelected : navInactive,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? navSelected : navInactive,
                fontSize: 8.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _captureNavItem() {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = 2);
        context.push('/capture');
      },
      child: Container(
        width: 49,
        height: 49,
        decoration: BoxDecoration(
          color: captureBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : purple.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: topGlow.withValues(alpha: isDark ? 0.24 : 0.18),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(Icons.camera_alt_outlined, color: captureIcon, size: 21),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.black.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(icon, color: primaryText, size: 19),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERED REPORTS
  // ============================================================

  List<Map<String, dynamic>> get _filteredReports {
    switch (_selectedFilter) {
      case 1:
        return _reports
            .where(
              (report) =>
                  report['status'] == 'Pending' ||
                  report['status'] == 'Reviewing',
            )
            .toList();

      case 2:
        return _reports
            .where((report) => report['status'] == 'Resolved')
            .toList();

      default:
        return _reports;
    }
  }
}
