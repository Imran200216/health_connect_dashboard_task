import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart';
import 'package:health_connect_dashboard/core/utils/logger_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_connect_dashboard/core/constants/app_assets_constants.dart';

class HealthPermissionScreen extends StatefulWidget {
  const HealthPermissionScreen({super.key});

  @override
  State<HealthPermissionScreen> createState() => _HealthPermissionScreenState();
}

class _HealthPermissionScreenState extends State<HealthPermissionScreen> {
  bool _isLoading = false;

  Future<void> _checkAndRequestHealthPermissions() async {
    setState(() => _isLoading = true);

    final health = Health();
    await health.configure();

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVITY_INTENSITY,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ_WRITE);

    try {
      // 1️⃣ Check current Health Connect permissions
      bool? hasPermissions = await health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPermissions == true) {
        _showSnackBar("Permissions already granted!", Colors.green);
        setState(() => _isLoading = false);
        return;
      }

      // 2️⃣ Request Activity Recognition & Location permissions
      final activityStatus = await Permission.activityRecognition.request();
      final locationStatus = await Permission.location.request();

      if (!(activityStatus.isGranted || activityStatus.isLimited)) {
        _showSnackBar(
          "Activity Recognition permission is required",
          Colors.orange,
        );
        setState(() => _isLoading = false);
        return;
      }

      // 3️⃣ Request Health Connect authorization
      bool? granted = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (granted == true) {
        _showSnackBar("Permissions granted successfully!", Colors.green);
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      LoggerUtils.logError(
        "Exception in _checkAndRequestHealthPermissions: $e",
      );
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Health Connect permissions are required to use this app. '
          'Please grant permissions in Health Connect settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // App Title
              Text(
                "Health Connect",
                style: GoogleFonts.googleSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              // Illustration
              Expanded(
                child: SvgPicture.asset(
                  AppAssetsConstants.permissionImage,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                "Connect your health data",
                textAlign: TextAlign.center,
                style: GoogleFonts.googleSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                "Allow Health Connect to securely access your health data "
                "so we can give you accurate insights and a better experience.",
                textAlign: TextAlign.center,
                style: GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Filled Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _checkAndRequestHealthPermissions,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "Allow access",
                          style: GoogleFonts.googleSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
