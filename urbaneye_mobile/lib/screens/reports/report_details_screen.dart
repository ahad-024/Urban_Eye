import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  // ============================================================
  // DESIGN SYSTEM
  // ============================================================

  static const Color purple = Color(0xFF7C3AED);

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  Color _primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryText(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFB0B0B8)
          : const Color(0xFF6B6675);

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? const Color(0xE61A1A1D) : Colors.white;

  Color _profileAvatar(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF29292C)
          : const Color(0xFFF0ECF5);

  Color _cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);

  Color _badgeBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.045);

  Color _actionIcon(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.75)
          : Colors.black.withValues(alpha: 0.60);

  Color _topGlow(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF7137A8)
          : const Color(0xFFE9D5FF);

  Color _midGlow(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF2B1446)
          : const Color(0xFFF3E8FF);

  Color _lowerAmbient(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF0D0B12)
          : const Color(0xFFF8F7FC);

  Color _imageSurface(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF171419)
          : const Color(0xFFF0ECF5);

  Color _mapSurface(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF121015)
          : const Color(0xFFF4F0F8);

  Color _bottomButtonBackground(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF111114);

  Color _bottomButtonForeground(BuildContext context) =>
      _isDark(context) ? Colors.black : Colors.white;

  // ============================================================
  // DATA HELPERS
  // ============================================================

  String get issueTitle {
    return (report['title'] ??
            report['issueType'] ??
            report['issue_type'] ??
            'Civic Issue')
        .toString();
  }

  String get issueType {
    return (report['issueType'] ??
            report['issue_type'] ??
            issueTitle)
        .toString()
        .replaceAll('_', ' ');
  }

  String get location {
    final value = report['location'] ??
        report['address'] ??
        report['location_name'];

    if (value is Map) {
      final address = value['address'] ??
          value['name'] ??
          value['formatted_address'];

      if (address != null && address.toString().trim().isNotEmpty) {
        return address.toString();
      }
    }

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    final latitude = report['latitude'];
    final longitude = report['longitude'];

    if (latitude != null && longitude != null) {
      return 'Lat: $latitude, Long: $longitude';
    }

    return 'Location not available';
  }

  // ============================================================
  // DATE AND TIME — USER'S DEVICE TIMEZONE
  // ============================================================

  String get date {
    // Prefer the actual Django timestamp fields.
    final value = report['created_at'] ??
        report['createdAt'] ??
        report['date'];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Recently';
    }

    final parsed = DateTime.tryParse(value.toString());

    if (parsed == null) {
      return value.toString();
    }

    // Converts a UTC timestamp (for example, ending in Z or +00:00)
    // into the timezone configured on the user's device/browser.
    final local = parsed.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    // Display the time in 12-hour format with AM/PM.
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/${local.year} · $hour:$minute $period';
  }

  String get severity {
    return (report['severity'] ?? 'Not assessed')
        .toString()
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (match) => match.group(0)!.toUpperCase(),
        );
  }

  String get status {
    final value = (report['status'] ?? 'Pending').toString();

    return value
        .replaceAll('_', ' ')
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (match) => match.group(0)!.toUpperCase(),
        );
  }

  String get confidence {
    final value = report['confidence'];

    if (value == null) {
      return 'Not available';
    }

    if (value is num) {
      if (value <= 1) {
        return '${(value * 100).round()}%';
      }

      return '${value.round()}%';
    }

    final text = value.toString();

    if (text.endsWith('%')) {
      return text;
    }

    final numericValue = double.tryParse(text);

    if (numericValue != null) {
      if (numericValue <= 1) {
        return '${(numericValue * 100).round()}%';
      }

      return '${numericValue.round()}%';
    }

    return text;
  }

  String get reportId {
    return (report['id'] ??
            report['reportId'] ??
            report['report_id'] ??
            'N/A')
        .toString();
  }

  String get description {
    final value = report['description'];

    if (value == null || value.toString().trim().isEmpty) {
      return 'No description was provided for this civic issue.';
    }

    return value.toString();
  }

  // ============================================================
  // REPORTER NAME
  // ============================================================

  String get reportedBy {
    final candidates = [
      report['reportedBy'],
      report['reported_by'],
      report['reporter_name'],
      report['user_name'],
      report['created_by'],
      report['user'],
      report['reporter'],
    ];

    for (final candidate in candidates) {
      final name = _extractReporterName(candidate);

      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    return 'Unknown reporter';
  }

  String? _extractReporterName(dynamic value) {
    if (value == null || value is num) {
      return null;
    }

    if (value is Map) {
      final firstName = value['first_name']?.toString().trim() ?? '';
      final lastName = value['last_name']?.toString().trim() ?? '';
      final fullName = '$firstName $lastName'.trim();

      if (fullName.isNotEmpty) {
        return fullName;
      }

      for (final key in [
        'name',
        'full_name',
        'username',
        'email',
      ]) {
        final candidate = value[key]?.toString().trim();

        if (candidate != null &&
            candidate.isNotEmpty &&
            int.tryParse(candidate) == null) {
          return candidate;
        }
      }

      return null;
    }

    if (value is String) {
      final name = value.trim();

      if (name.isEmpty || int.tryParse(name) != null) {
        return null;
      }

      return name;
    }

    return null;
  }

  // ============================================================
  // IMAGE
  // ============================================================

  String get imagePath {
    return (report['image'] ??
            report['imagePath'] ??
            report['image_path'] ??
            '')
        .toString();
  }

  IconData get issueIcon {
    final value = '${issueType.toLowerCase()} ${issueTitle.toLowerCase()}';

    if (value.contains('pothole')) {
      return Icons.warning_amber_rounded;
    }

    if (value.contains('garbage') ||
        value.contains('waste') ||
        value.contains('trash')) {
      return Icons.delete_outline_rounded;
    }

    if (value.contains('road crack') ||
        value.contains('road_crack') ||
        value.contains('crack')) {
      return Icons.gesture_rounded;
    }

    if (value.contains('street light') ||
        value.contains('street_light') ||
        value.contains('light')) {
      return Icons.lightbulb_outline_rounded;
    }

    if (value.contains('water') || value.contains('overflow')) {
      return Icons.water_drop_outlined;
    }

    return Icons.report_problem_outlined;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor(context),
                  _lowerAmbient(context),
                  _backgroundColor(context),
                ],
              ),
            ),
          ),
          Positioned(
            top: -130,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _topGlow(context).withValues(
                    alpha: isDark ? 0.20 : 0.32,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _topGlow(context).withValues(
                        alpha: isDark ? 0.18 : 0.22,
                      ),
                      blurRadius: 130,
                      spreadRadius: 45,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -160,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _midGlow(context).withValues(
                    alpha: isDark ? 0.18 : 0.30,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _midGlow(context).withValues(
                        alpha: isDark ? 0.16 : 0.22,
                      ),
                      blurRadius: 130,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 28),
                  _buildHeading(context),
                  const SizedBox(height: 22),
                  _buildImagePreview(context),
                  const SizedBox(height: 18),
                  _buildIssueCard(context),
                  const SizedBox(height: 16),
                  _buildAnalysisCard(context),
                  const SizedBox(height: 16),
                  _buildLocationCard(context),
                  const SizedBox(height: 16),
                  _buildInformationCard(context),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(context),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(context),
                  const SizedBox(height: 25),
                  _buildBackButton(context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _iconButton(
          context,
          icon: Icons.arrow_back_rounded,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/reports');
            }
          },
        ),
        const SizedBox(width: 14),
        Text(
          'URBANEYE',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _profileAvatar(context),
            border: Border.all(color: _cardBorder(context)),
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 21,
            color: _actionIcon(context),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADING
  // ============================================================

  Widget _buildHeading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Details',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Report ',
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 14,
              ),
            ),
            Flexible(
              child: Text(
                '#$reportId',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      height: 225,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _imageSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.25 : 0.08,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildReportImage(context),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _smallBadge(
              context,
              icon: Icons.auto_awesome_rounded,
              label: 'AI ANALYZED',
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: _smallBadge(
              context,
              icon: issueIcon,
              label: issueTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportImage(BuildContext context) {
    if (imagePath.isEmpty) {
      return _imagePlaceholder(context);
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(context),
      );
    }

    try {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(context),
      );
    } catch (_) {
      return _imagePlaceholder(context);
    }
  }

  Widget _imagePlaceholder(BuildContext context) {
    final isDark = _isDark(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF29222F), Color(0xFF111014)]
              : const [Color(0xFFF4EEFA), Color(0xFFE9E4EF)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              issueIcon,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.65)
                  : purple.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 10),
            Text(
              'Report Image',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.65)
                    : const Color(0xFF4D4657),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ISSUE CARD
  // ============================================================

  Widget _buildIssueCard(BuildContext context) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Detected Issue',
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _iconContainer(context, icon: issueIcon, color: purple),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issueTitle,
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issueType,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(context, status),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANALYSIS CARD
  // ============================================================

  Widget _buildAnalysisCard(BuildContext context) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.auto_awesome_rounded,
            title: 'AI Analysis',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  label: 'Confidence',
                  value: confidence,
                  icon: Icons.verified_rounded,
                  accent: purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  context,
                  label: 'Severity',
                  value: severity,
                  icon: Icons.priority_high_rounded,
                  accent: _severityColor(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  context,
                  label: 'Class',
                  value: issueType,
                  icon: issueIcon,
                  accent: purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor() {
    final value = severity.toLowerCase();

    if (value.contains('high')) {
      return const Color(0xFFEF4444);
    }

    if (value.contains('medium')) {
      return const Color(0xFFF59E0B);
    }

    if (value.contains('low')) {
      return const Color(0xFF22C55E);
    }

    return purple;
  }

  // ============================================================
  // LOCATION CARD
  // ============================================================

  Widget _buildLocationCard(BuildContext context) {
    return _card(
      context,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
            child: _sectionTitle(
              context,
              icon: Icons.location_on_outlined,
              title: 'Location',
            ),
          ),
          Container(
            height: 175,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _mapSurface(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPatternPainter(
                      isDark: _isDark(context),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: purple.withValues(alpha: 0.14),
                    ),
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: purple,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _isDark(context)
                          ? Colors.black.withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isDark(context)
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Text(
                      'REPORTED LOCATION',
                      style: TextStyle(
                        color: _isDark(context)
                            ? Colors.white
                            : const Color(0xFF242126),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: purple,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard(BuildContext context) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Information',
          ),
          const SizedBox(height: 16),
          _infoRow(context, label: 'Report ID', value: '#$reportId'),
          _divider(context),
          _infoRow(context, label: 'Submitted', value: date),
          _divider(context),
          _infoRow(context, label: 'Reported by', value: reportedBy),
        ],
      ),
    );
  }

  // ============================================================
  // DESCRIPTION CARD
  // ============================================================

  Widget _buildDescriptionCard(BuildContext context) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.description_outlined,
            title: 'Description',
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS TIMELINE
  // ============================================================

  Widget _buildStatusTimeline(BuildContext context) {
    final currentStatus = status.toLowerCase();
    final isResolved = currentStatus.contains('resolved');

    final isReviewing = currentStatus.contains('review') ||
        currentStatus.contains('progress') ||
        currentStatus.contains('in progress');

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.timeline_rounded,
            title: 'Status Timeline',
          ),
          const SizedBox(height: 20),
          _timelineItem(
            context,
            title: 'Report Submitted',
            subtitle: 'Issue successfully submitted',
            completed: true,
            active: false,
            isLast: false,
          ),
          _timelineItem(
            context,
            title: 'AI Analysis',
            subtitle: 'Image analysis information',
            completed: true,
            active: false,
            isLast: false,
          ),
          _timelineItem(
            context,
            title: 'Under Review',
            subtitle: isReviewing
                ? 'Report is currently being reviewed'
                : 'Awaiting civic authority review',
            completed: isReviewing || isResolved,
            active: isReviewing,
            isLast: false,
          ),
          _timelineItem(
            context,
            title: isResolved ? 'Resolved' : 'Resolution',
            subtitle: isResolved
                ? 'Issue has been resolved'
                : 'Waiting for resolution',
            completed: isResolved,
            active: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool completed,
    required bool active,
    required bool isLast,
  }) {
    final isDark = _isDark(context);

    final completedColor = isDark ? Colors.white : purple;

    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.12);

    final connectorColor = isDark
        ? Colors.white.withValues(alpha: completed ? 0.13 : 0.07)
        : Colors.black.withValues(alpha: completed ? 0.12 : 0.06);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? purple
                        : completed
                            ? completedColor
                            : inactiveColor,
                  ),
                  child: completed
                      ? Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: isDark ? Colors.black : Colors.white,
                        )
                      : active
                          ? const Icon(
                              Icons.more_horiz_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: connectorColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/reports');
          }
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: _bottomButtonForeground(context),
          size: 19,
        ),
        label: Text(
          'Back to Reports',
          style: TextStyle(
            color: _bottomButtonForeground(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _bottomButtonBackground(context),
          foregroundColor: _bottomButtonForeground(context),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE CARD
  // ============================================================

  Widget _card(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.18 : 0.055,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 7, color: purple),
        const SizedBox(width: 7),
        Icon(icon, size: 18, color: purple),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ICON CONTAINER
  // ============================================================

  Widget _iconContainer(
    BuildContext context, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  // ============================================================
  // METRIC
  // ============================================================

  Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _badgeBackground(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 17),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _cardBorder(context),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(BuildContext context, String value) {
    final normalized = value.toLowerCase();

    Color background;
    Color foreground;

    if (normalized.contains('resolved')) {
      background = _isDark(context)
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.055);

      foreground = _primaryText(context);
    } else if (normalized.contains('review') ||
        normalized.contains('progress')) {
      background = purple.withValues(alpha: 0.14);
      foreground = purple;
    } else {
      background = _isDark(context)
          ? Colors.white.withValues(alpha: 0.065)
          : Colors.black.withValues(alpha: 0.045);

      foreground = _primaryText(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // SMALL IMAGE BADGE
  // ============================================================

  Widget _smallBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: _isDark(context) ? 0.55 : 0.45,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ICON BUTTON
  // ============================================================

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _isDark(context)
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.black.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder(context)),
          ),
          child: Icon(
            icon,
            color: _actionIcon(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// MAP PATTERN
// ================================================================

class _MapPatternPainter extends CustomPainter {
  final bool isDark;

  const _MapPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final lineBase = isDark ? Colors.white : Colors.black;

    final gridPaint = Paint()
      ..color = lineBase.withValues(alpha: isDark ? 0.035 : 0.045)
      ..strokeWidth = 1;

    final roadPaint = Paint()
      ..color = lineBase.withValues(alpha: isDark ? 0.055 : 0.07)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final smallerRoadPaint = Paint()
      ..color = lineBase.withValues(alpha: isDark ? 0.035 : 0.05)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const gridSize = 32.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final roadOne = Path()
      ..moveTo(-20, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.48,
        size.width + 30,
        size.height * 0.28,
      );

    canvas.drawPath(roadOne, roadPaint);

    final roadTwo = Path()
      ..moveTo(size.width * 0.12, -20)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.38,
        size.width * 0.92,
        size.height + 20,
      );

    canvas.drawPath(roadTwo, roadPaint);

    final roadThree = Path()
      ..moveTo(-10, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.58,
        size.width + 15,
        size.height * 0.72,
      );

    canvas.drawPath(roadThree, smallerRoadPaint);

    final roadFour = Path()
      ..moveTo(size.width * 0.70, -10)
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.40,
        size.width * 0.20,
        size.height + 15,
      );

    canvas.drawPath(roadFour, smallerRoadPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
