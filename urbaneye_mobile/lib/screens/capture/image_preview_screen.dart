import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewScreen extends StatefulWidget {
  final XFile image;

  const ImagePreviewScreen({
    super.key,
    required this.image,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  Uint8List? _imageBytes;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isAnalyzing = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);

  static const Color success = Color(0xFF86EFAC);
  static const Color warning = Color(0xFFFBBF24);

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _backgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6F687A);
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xE61C1C1E)
        : Colors.white.withValues(alpha: 0.94);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _subtleBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.black.withValues(alpha: 0.035);
  }

  Color _iconColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF514A5C);
  }

  Color _sheetColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF18151D)
        : const Color(0xFFF9F7FC);
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // ============================================================
  // LOAD IMAGE
  // ============================================================

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.image.readAsBytes();

      if (!mounted) return;

      if (bytes.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // ANALYZE IMAGE
  // ============================================================

  Future<void> _analyzeImage() async {
    if (_imageBytes == null || _isAnalyzing || _hasError) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // UI-only analysis delay.
    // Backend / YOLO integration will be connected later.
    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    context.push(
      '/ai-loading',
      extra: widget.image,
    );
  }

  // ============================================================
  // IMAGE INFORMATION
  // ============================================================

  void _showImageInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bool dark = _isDark(sheetContext);
        final Color textColor = _primaryText(sheetContext);
        final Color mutedColor = _secondaryText(sheetContext);

        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            28,
          ),
          decoration: BoxDecoration(
            color: _sheetColor(sheetContext),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: _borderColor(sheetContext),
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
                    color: dark
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: purple.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: purple.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: purpleLight,
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
                            'Ready for analysis',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your image is ready to analyze',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'UrbanEye will analyze this image to identify a civic issue and estimate its severity.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                _buildInfoRow(
                  context: sheetContext,
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Analysis',
                  value: 'Ready',
                ),

                const SizedBox(height: 10),

                _buildInfoRow(
                  context: sheetContext,
                  icon: Icons.image_outlined,
                  title: 'Image Status',
                  value: 'Selected',
                ),

                const SizedBox(height: 10),

                _buildInfoRow(
                  context: sheetContext,
                  icon: Icons.verified_outlined,
                  title: 'Image Quality',
                  value: _hasError ? 'Check' : 'Ready',
                  isReady: !_hasError,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool isReady = true,
  }) {
    final Color statusColor = isReady ? success : warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _subtleBackground(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _subtleBackground(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: _iconColor(context),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(
        children: [
          _PreviewBackground(
            isDark: _isDark(context),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      14,
                    ),
                    child: _buildImageViewer(context),
                  ),
                ),

                _buildBottomPanel(context),
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
            context: context,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: _isAnalyzing
                ? () {}
                : () => context.pop(),
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

          _buildTopIcon(
            context: context,
            icon: Icons.info_outline_rounded,
            onTap: _isAnalyzing
                ? () {}
                : _showImageInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _subtleBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: _borderColor(context),
          ),
        ),
        child: Icon(
          icon,
          color: _iconColor(context),
          size: 18,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE VIEWER
  // ============================================================

  Widget _buildImageViewer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.32 : 0.08,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImageArea(context),
    );
  }

  Widget _buildImageArea(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: purpleLight,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading image...',
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return _buildImageError(context);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: _isDark(context)
              ? const Color(0xFF09090B)
              : const Color(0xFFF2EFF5),
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(20),
            child: Image.memory(
              _imageBytes!,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return _buildImageError(context);
              },
            ),
          ),
        ),

        // ======================================================
        // IMAGE READY BADGE
        // ======================================================

        Positioned(
          top: 16,
          left: 16,
          child: _buildOverlayBadge(
            context: context,
            icon: Icons.check_circle_outline_rounded,
            iconColor: success,
            text: 'Image Ready',
          ),
        ),

        // ======================================================
        // AI READY BADGE
        // ======================================================

        Positioned(
          top: 16,
          right: 16,
          child: _buildOverlayBadge(
            context: context,
            icon: Icons.auto_awesome_outlined,
            iconColor: purpleLight,
            text: 'AI READY',
            smallText: true,
          ),
        ),

        // ======================================================
        // ZOOM HINT
        // ======================================================

        Positioned(
          right: 16,
          bottom: 16,
          child: _buildOverlayBadge(
            context: context,
            icon: Icons.zoom_in_rounded,
            iconColor: _isDark(context)
                ? Colors.white
                : const Color(0xFF4F4858),
            text: 'Pinch to zoom',
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayBadge({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String text,
    bool smallText = false,
  }) {
    final bool dark = _isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.62)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.07),
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: smallText ? 15 : 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: dark
                  ? Colors.white
                  : const Color(0xFF332E3A),
              fontSize: smallText ? 9 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: smallText ? 0.7 : 0,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM PANEL
  // ============================================================

  Widget _buildBottomPanel(BuildContext context) {
    final bool canAnalyze =
        _imageBytes != null &&
        !_hasError &&
        !_isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.20 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: purple.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: purpleLight,
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
                        'Ready to analyze',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Let UrbanEye identify the civic issue.',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (canAnalyze ? success : warning)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    canAnalyze ? 'READY' : 'WAIT',
                    style: TextStyle(
                      color: canAnalyze ? success : warning,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // ANALYZE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: canAnalyze
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF5B21B6),
                          ],
                        )
                      : null,
                  color: canAnalyze
                      ? null
                      : _subtleBackground(context),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: canAnalyze
                      ? [
                          BoxShadow(
                            color: purple.withValues(alpha: 0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed:
                      canAnalyze && !_isAnalyzing
                          ? _analyzeImage
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor:
                        Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor:
                        _secondaryText(context),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: _isAnalyzing
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Preparing analysis...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 21,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Analyze Image',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // CHOOSE ANOTHER IMAGE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 47,
              child: OutlinedButton.icon(
                onPressed: _isAnalyzing
                    ? null
                    : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryText(context),
                  disabledForegroundColor:
                      _secondaryText(context),
                  side: BorderSide(
                    color: _borderColor(context),
                  ),
                  backgroundColor:
                      _subtleBackground(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: purpleLight,
                  size: 19,
                ),
                label: Text(
                  'Choose Another Image',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'Your image will be analyzed for civic issues and severity.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE ERROR
  // ============================================================

  Widget _buildImageError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _subtleBackground(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _borderColor(context),
                ),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                color: _secondaryText(context),
                size: 35,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to display image',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Please select another image and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class _PreviewBackground extends StatelessWidget {
  final bool isDark;

  const _PreviewBackground({
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
              0.25,
              0.55,
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
                    Color(0xFFE7D4FA),
                    Color(0xFFF1E7F8),
                    Color(0xFFF8F7FC),
                    Color(0xFFFFFFFF),
                  ],
          ),
        ),
      ),
    );
  }
}