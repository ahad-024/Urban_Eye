
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api/api_client.dart';

class SubmitComplaintScreen extends StatefulWidget {
  final XFile image;
  final String issueType;
  final String severity;
  final int confidence;

  const SubmitComplaintScreen({
    super.key,
    required this.image,
    required this.issueType,
    required this.severity,
    required this.confidence,
  });

  @override
  State<SubmitComplaintScreen> createState() =>
      _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState
    extends State<SubmitComplaintScreen> {
  final TextEditingController _descriptionController =
      TextEditingController();

  Uint8List? _imageBytes;

  double? _latitude;
  double? _longitude;

  String _address = '';

  bool _isAddressLoading = false;
  bool _isSubmitting = false;

  Object? _createdReportId;

  static const Color _background = Color(0xFF08080A);
  static const Color _card = Color(0xFF141318);
  static const Color _border = Color(0xFF292630);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _muted = Color(0xFF9A96A5);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
      });
    } catch (error) {
      debugPrint('Image loading error: $error');
    }
  }

  String get _formattedIssue {
    return widget.issueType
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String get _formattedSeverity {
    if (widget.severity.isEmpty) return 'Unknown';

    final value = widget.severity.toLowerCase();

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Future<void> _updateAddress(LatLng location) async {
    setState(() {
      _isAddressLoading = true;
      _latitude = location.latitude;
      _longitude = location.longitude;
    });

    try {
      final geocoding = Geocoding();

      final placemarks =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        setState(() {
          _address =
              '${location.latitude.toStringAsFixed(6)}, '
              '${location.longitude.toStringAsFixed(6)}';
          _isAddressLoading = false;
        });
        return;
      }

      final place = placemarks.first;

      final street = place.street?.trim() ?? '';
      final subLocality = place.subLocality?.trim() ?? '';
      final administrativeArea =
          place.administrativeArea?.trim() ?? '';
      final city = place.locality?.trim() ?? '';

      final area = subLocality.isNotEmpty
          ? subLocality
          : administrativeArea;

      final parts = <String>[
        if (street.isNotEmpty) street,
        if (area.isNotEmpty &&
            area.toLowerCase() != street.toLowerCase())
          area,
        if (city.isNotEmpty &&
            city.toLowerCase() != street.toLowerCase() &&
            city.toLowerCase() != area.toLowerCase())
          city,
      ];

      setState(() {
        _address = parts.isNotEmpty
            ? parts.join(', ')
            : '${location.latitude.toStringAsFixed(6)}, '
                '${location.longitude.toStringAsFixed(6)}';
        _isAddressLoading = false;
      });
    } catch (error) {
      debugPrint('Address lookup error: $error');

      if (!mounted) return;

      setState(() {
        _address =
            '${location.latitude.toStringAsFixed(6)}, '
            '${location.longitude.toStringAsFixed(6)}';
        _isAddressLoading = false;
      });
    }
  }

  Future<void> _chooseLocation() async {
    final result = await context.push<Object?>(
      '/location-picker',
      extra: {
        'latitude': _latitude,
        'longitude': _longitude,
        'address': _address,
      },
    );

    if (!mounted || result == null) return;

    if (result is Map) {
      final latitude = result['latitude'];
      final longitude = result['longitude'];
      final address = result['address'];

      if (latitude is num && longitude is num) {
        await _updateAddress(
          LatLng(
            latitude.toDouble(),
            longitude.toDouble(),
          ),
        );

        if (address is String &&
            address.trim().isNotEmpty &&
            mounted) {
          setState(() {
            _address = address.trim();
          });
        }
      } else if (address is String &&
          address.trim().isNotEmpty) {
        setState(() {
          _address = address.trim();
        });
      }
    }
  }

  Object? _extractId(dynamic response) {
    if (response is Map) {
      if (response['id'] != null) {
        return response['id'];
      }

      if (response['report'] is Map) {
        return response['report']['id'];
      }

      if (response['data'] is Map) {
        return _extractId(response['data']);
      }

      if (response['results'] is Map) {
        return _extractId(response['results']);
      }
    }

    return null;
  }

  Future<void> _submitComplaint() async {
    if (_isSubmitting) return;

    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      _showMessage('Please enter a complaint description.');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showMessage('Please select the issue location.');
      return;
    }

    if (_address.trim().isEmpty) {
      _showMessage('Please wait for the location address.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _createdReportId = null;
    });

    try {
      // Step 1: Create the report and upload its image.
      final reportResponse = await ApiClient.createReport(
        image: widget.image,
        issueType: widget.issueType,
        severity: widget.severity,
        confidence: widget.confidence,
        description: description,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      final reportId = _extractId(reportResponse);

      if (reportId == null) {
        throw Exception(
          'The report API did not return an ID. '
          'Check the API response before retrying.',
        );
      }

      _createdReportId = reportId;

      // Step 2: Create the complaint linked to the report.
      final complaintResponse =
          await ApiClient.createComplaint(
        reportId: reportId,
        title: '$_formattedIssue Complaint',
        description: description,
      );

      final complaintId = _extractId(complaintResponse);

      if (!mounted) return;

      // Step 3: Navigate after both requests succeed.
      context.go(
        '/complaint-success',
        extra: {
          'issueType': widget.issueType,
          'severity': widget.severity,
          'confidence': widget.confidence,
          'latitude': _latitude,
          'longitude': _longitude,
          'address': _address,
          'reportId': reportId,
          'complaintId': complaintId,
        },
      );
    } catch (error) {
      debugPrint('Submit complaint error: $error');

      if (!mounted) return;

      final message = _createdReportId != null
          ? 'The report may already be saved, but complaint '
              'submission failed. Check My Reports before retrying.'
          : error.toString();

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF24212B),
        ),
      );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIssueCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              LucideIcons.search,
              color: _purple,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formattedIssue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'AI confidence: ${widget.confidence}%',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: widget.severity.toLowerCase() == 'high'
                  ? const Color(0xFF4B252B)
                  : const Color(0xFF302842),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formattedSeverity,
              style: TextStyle(
                color: widget.severity.toLowerCase() == 'high'
                    ? const Color(0xFFFF929B)
                    : const Color(0xFFC4B5FD),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 190,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: _imageBytes == null
          ? const Center(
              child: CircularProgressIndicator(
                color: _purple,
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.checkCircle2,
                          color: Color(0xFFA78BFA),
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Image selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  color: _purple,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select the exact location on the map',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isAddressLoading
                    ? null
                    : _chooseLocation,
                icon: const Icon(
                  LucideIcons.pencil,
                  color: _purple,
                  size: 19,
                ),
                tooltip: 'Change location',
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0C11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isAddressLoading)
                  const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _purple,
                    ),
                  )
                else
                  const Icon(
                    LucideIcons.navigation,
                    size: 17,
                    color: _purple,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isAddressLoading
                        ? 'Getting address...'
                        : _address.isEmpty
                            ? 'No location selected'
                            : _address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 9),
            Text(
              'Lat: ${_latitude!.toStringAsFixed(6)}  '
              'Lng: ${_longitude!.toStringAsFixed(6)}',
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isAddressLoading
                  ? null
                  : _chooseLocation,
              icon: const Icon(
                LucideIcons.map,
                size: 17,
              ),
              label: const Text('Choose on map'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC4B5FD),
                side: const BorderSide(color: _border),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      minLines: 4,
      maxLines: 6,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText:
            'Describe the civic issue and any details that may help...',
        hintStyle: const TextStyle(
          color: Color(0xFF77727F),
          fontSize: 13,
        ),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _purple),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting
              ? null
              : () => context.pop(),
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Submit Complaint',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report a civic issue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Review the AI result, add details, and '
                      'submit your complaint to the system.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _sectionTitle(
                      'AI detection result',
                      subtitle:
                          'Detected issue and estimated severity',
                    ),
                    const SizedBox(height: 12),
                    _buildIssueCard(),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Evidence image',
                      subtitle:
                          'Image that will be uploaded with your report',
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Location',
                      subtitle:
                          'Choose where the civic issue was found',
                    ),
                    const SizedBox(height: 12),
                    _buildLocationCard(),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Complaint description',
                      subtitle:
                          'Explain the issue for the responsible team',
                    ),
                    const SizedBox(height: 12),
                    _buildDescriptionField(),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17131F),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF352746),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.info,
                            color: Color(0xFFA78BFA),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your image, AI result, description, '
                              'and selected coordinates will be '
                              'sent to UrbanEye.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                18,
              ),
              decoration: const BoxDecoration(
                color: _background,
                border: Border(
                  top: BorderSide(color: _border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor:
                        _purple.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.send,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Submit Complaint',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
