import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSelectingImage = false;

  // ============================================================
  // DESIGN SYSTEM
  // ============================================================

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6B6675);
  }

  Color _card(BuildContext context) {
    return _isDark(context)
        ? const Color(0xD91C1C1E)
        : Colors.white.withValues(alpha: 0.95);
  }

  Color _cardSoft(BuildContext context) {
    return _isDark(context)
        ? const Color(0x991C1C1E)
        : Colors.black.withValues(alpha: 0.045);
  }

  Color _border(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _iconBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.black.withValues(alpha: 0.045);
  }

  Color _captureSurface(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF111014)
        : const Color(0xFFF3EFF7);
  }

  Color _captureBorder(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    if (_isSelectingImage) return;

    setState(() {
      _isSelectingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted) return;

      if (image != null) {
        context.push(
          '/image-preview',
          extra: image,
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unable to select image. Please try again.',
              style: TextStyle(
                color: _primaryText(context),
              ),
            ),
            backgroundColor: _card(context),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _border(context),
              ),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingImage = false;
        });
      }
    }
  }

  // ============================================================
  // IMAGE SOURCE SHEET
  // ============================================================

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final dark = _isDark(sheetContext);

        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            28,
          ),
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xFF18151D)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: _border(sheetContext),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _primaryText(sheetContext)
                        .withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _iconBackground(sheetContext),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _border(sheetContext),
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: _primaryText(sheetContext),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add an image',
                            style: TextStyle(
                              color: _primaryText(sheetContext),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose a source for your civic issue.',
                            style: TextStyle(
                              color: _secondaryText(sheetContext),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        sheetContext,
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Take a photo',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSourceOption(
                        sheetContext,
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        subtitle: 'Choose a photo',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: _iconBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8D55C4),
                      Color(0xFF5B21B6),
                    ],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(17),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(height: 12),

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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO SHEET
  // ============================================================

  void _showInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            14,
            22,
            28,
          ),
          decoration: BoxDecoration(
            color: _isDark(sheetContext)
                ? const Color(0xFF18151D)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(
                color: _border(sheetContext),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _primaryText(sheetContext)
                          .withValues(alpha: 0.22),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _iconBackground(sheetContext),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        color: _primaryText(sheetContext),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      'Capture tips',
                      style: TextStyle(
                        color: _primaryText(sheetContext),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildInfoItem(
                  sheetContext,
                  Icons.visibility_outlined,
                  'Keep the issue clearly visible',
                ),

                _buildInfoItem(
                  sheetContext,
                  Icons.wb_sunny_outlined,
                  'Use good lighting whenever possible',
                ),

                _buildInfoItem(
                  sheetContext,
                  Icons.center_focus_strong_outlined,
                  'Keep the camera steady',
                ),

                _buildInfoItem(
                  sheetContext,
                  Icons.photo_camera_back_outlined,
                  'Capture the surrounding area too',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _iconBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryText(context)
                  .withValues(alpha: 0.75),
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      body: Stack(
        children: [
          _CaptureBackground(
            isDark: _isDark(context),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      36,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),

                        const SizedBox(height: 24),

                        _buildCaptureCard(context),

                        const SizedBox(height: 16),

                        _buildAiCard(context),

                        const SizedBox(height: 18),

                        _buildTipsCard(context),

                        const SizedBox(height: 26),

                        _buildIssueTypes(context),
                      ],
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        6,
      ),
      child: Row(
        children: [
          _buildTopIcon(
            context,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),

          Expanded(
            child: Center(
              child: Text(
                'URBANEYE',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _iconBackground(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _border(context),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'A',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _iconBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: _border(context),
          ),
        ),
        child: Icon(
          icon,
          color: _primaryText(context)
              .withValues(alpha: 0.85),
          size: 17,
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report a civic issue',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Capture an issue and let UrbanEye analyze it automatically.',
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN CAPTURE CARD
  // ============================================================

  Widget _buildCaptureCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 245,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _captureSurface(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _captureBorder(context),
              ),
            ),
            child: Stack(
              children: [
                // Ambient center glow
                Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          purple.withValues(alpha: 0.24),
                          purple.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top-left
                Positioned(
                  left: 22,
                  top: 22,
                  child: _cornerGuide(
                    context,
                    top: true,
                    left: true,
                  ),
                ),

                // Top-right
                Positioned(
                  right: 22,
                  top: 22,
                  child: _cornerGuide(
                    context,
                    top: true,
                    left: false,
                  ),
                ),

                // Bottom-left
                Positioned(
                  left: 22,
                  bottom: 22,
                  child: _cornerGuide(
                    context,
                    top: false,
                    left: true,
                  ),
                ),

                // Bottom-right
                Positioned(
                  right: 22,
                  bottom: 22,
                  child: _cornerGuide(
                    context,
                    top: false,
                    left: false,
                  ),
                ),

                // Center
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _primaryText(context)
                              .withValues(alpha: 0.065),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _primaryText(context)
                                .withValues(alpha: 0.11),
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: _primaryText(context),
                          size: 31,
                        ),
                      ),

                      const SizedBox(height: 13),

                      Text(
                        'Ready to capture',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Take a clear photo of the issue',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // AI Ready badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: _isDark(context)
                            ? 0.42
                            : 0.58,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 6,
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: purpleLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI READY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Capture or upload an image',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'UrbanEye will identify the civic issue and estimate its severity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // Primary action
          SizedBox(
            width: double.infinity,
            height: 55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF5B21B6),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(
                      alpha: 0.22,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isSelectingImage
                    ? null
                    : _showImageSourceSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor:
                      Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor:
                      Colors.white.withValues(
                    alpha: 0.65,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                ),
                icon: _isSelectingImage
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                      ),
                label: Text(
                  _isSelectingImage
                      ? 'Selecting...'
                      : 'Capture or Choose Photo',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerGuide(
    BuildContext context, {
    required bool top,
    required bool left,
  }) {
    const double size = 24;
    const double thickness = 2;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          top: top,
          left: left,
          color: _primaryText(context).withValues(
            alpha: 0.32,
          ),
          thickness: thickness,
        ),
      ),
    );
  }

  // ============================================================
  // AI CARD
  // ============================================================

  Widget _buildAiCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSoft(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: purple.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: purpleLight,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-powered detection',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Detect issue type and estimate severity from your image.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11.5,
                    height: 1.35,
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
  // TIPS CARD
  // ============================================================

  Widget _buildTipsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _cardSoft(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: _primaryText(context),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'For better AI results',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Keep the issue visible, use good lighting, and avoid blurry photos.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          GestureDetector(
            onTap: _showInfo,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _iconBackground(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: _primaryText(context)
                    .withValues(alpha: 0.65),
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ISSUE TYPES
  // ============================================================

  Widget _buildIssueTypes(BuildContext context) {
    const issues = [
      _IssueType(
        icon: Icons.warning_amber_outlined,
        title: 'Pothole',
      ),
      _IssueType(
        icon: Icons.alt_route_outlined,
        title: 'Road Crack',
      ),
      _IssueType(
        icon: Icons.delete_outline_rounded,
        title: 'Garbage',
      ),
      _IssueType(
        icon: Icons.lightbulb_outline_rounded,
        title: 'Street Light',
      ),
      _IssueType(
        icon: Icons.water_drop_outlined,
        title: 'Water Overflow',
      ),
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Issues UrbanEye can detect',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Supported civic issue categories',
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: issues
              .map(
                (issue) => _buildIssueChip(
                  context,
                  issue,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildIssueChip(
    BuildContext context,
    _IssueType issue,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _cardSoft(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            issue.icon,
            color: _primaryText(context)
                .withValues(alpha: 0.72),
            size: 17,
          ),

          const SizedBox(width: 7),

          Text(
            issue.title,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BACKGROUND
// ================================================================

class _CaptureBackground extends StatelessWidget {
  final bool isDark;

  const _CaptureBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.0,
              0.28,
              0.58,
              1.0,
            ],
            colors: isDark
                ? const [
                    Color(0xFF6E3BA7),
                    Color(0xFF2B1446),
                    Color(0xFF0D0B12),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFE9D5FF),
                    Color(0xFFF3E8FF),
                    Color(0xFFF8F7FC),
                    Color(0xFFF8F7FC),
                  ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CORNER PAINTER
// ================================================================

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.top,
    required this.left,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();

    if (top && left) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant _CornerPainter oldDelegate,
  ) {
    return oldDelegate.top != top ||
        oldDelegate.left != left ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}

// ================================================================
// ISSUE MODEL
// ================================================================

class _IssueType {
  final IconData icon;
  final String title;

  const _IssueType({
    required this.icon,
    required this.title,
  });
}