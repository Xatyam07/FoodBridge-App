import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/ar_overlay_widget.dart';
import './widgets/impact_summary_dialog.dart';
import './widgets/navigation_controls.dart';
import './widgets/route_summary_card.dart';

class VolunteerRouteNavigation extends StatefulWidget {
  const VolunteerRouteNavigation({super.key});

  @override
  State<VolunteerRouteNavigation> createState() =>
      _VolunteerRouteNavigationState();
}

class _VolunteerRouteNavigationState extends State<VolunteerRouteNavigation>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isRouteSummaryCollapsed = true;
  bool _isARActive = false;
  bool _isVoiceEnabled = true;
  bool _showImpactDialog = false;
  int _currentStopIndex = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Mock route data
  final Map<String, dynamic> _routeData = {
    'totalDistance': '12.5 km',
    'estimatedTime': '45 min',
    'stops': [
      {
        'id': 1,
        'name': 'Green Valley Restaurant',
        'type': 'pickup',
        'status': 'current',
        'foodType': 'Mixed meals',
        'quantity': 25,
        'instructions': 'Use back entrance, ask for Manager Sarah',
        'latitude': 37.7849,
        'longitude': -122.4094,
        'distance': '0.5 km',
        'eta': '3 min',
        'contact': '+1 (555) 123-4567',
      },
      {
        'id': 2,
        'name': 'Downtown Food Bank',
        'type': 'delivery',
        'status': 'pending',
        'foodType': 'Mixed meals',
        'quantity': 25,
        'instructions': 'Loading dock on 2nd street',
        'latitude': 37.7849,
        'longitude': -122.4194,
        'distance': '2.1 km',
        'eta': '8 min',
        'contact': '+1 (555) 987-6543',
      },
      {
        'id': 3,
        'name': 'Sunset Bakery',
        'type': 'pickup',
        'status': 'pending',
        'foodType': 'Baked goods',
        'quantity': 40,
        'instructions': 'Refrigerated items, handle with care',
        'latitude': 37.7649,
        'longitude': -122.4294,
        'distance': '4.2 km',
        'eta': '15 min',
        'contact': '+1 (555) 456-7890',
      },
      {
        'id': 4,
        'name': 'Community Center',
        'type': 'delivery',
        'status': 'pending',
        'foodType': 'Mixed items',
        'quantity': 65,
        'instructions': 'Main entrance, check in at reception',
        'latitude': 37.7549,
        'longitude': -122.4394,
        'distance': '6.8 km',
        'eta': '22 min',
        'contact': '+1 (555) 321-0987',
      },
    ],
  };

  final Map<String, dynamic> _impactData = {
    'mealsDelivered': 130,
    'wasteReduced': '45 kg',
    'co2Saved': '120 kg',
    'peopleHelped': 85,
    'totalTime': '2h 15m',
    'efficiency': 92,
    'blockchainId': '0x1a2b3c4d5e6f7890abcdef1234567890',
  };

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Request location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        setState(() => _isLoading = false);
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Setup markers and polylines
      _setupMapData();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setupMapData() {
    final stops = (_routeData['stops'] as List).cast<Map<String, dynamic>>();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add stop markers
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isPickup = stop['type'] == 'pickup';
      final isCompleted = stop['status'] == 'completed';
      final isCurrent = stop['status'] == 'current';

      _markers.add(
        Marker(
          markerId: MarkerId('stop_${stop['id']}'),
          position: LatLng(stop['latitude'], stop['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isCompleted
                ? BitmapDescriptor.hueGreen
                : isCurrent
                    ? BitmapDescriptor.hueRed
                    : isPickup
                        ? BitmapDescriptor.hueBlue
                        : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: stop['name'],
            snippet: '${stop['type']} - ${stop['quantity']} meals',
          ),
        ),
      );
    }

    // Add route polyline
    final List<LatLng> routePoints = [];
    if (_currentPosition != null) {
      routePoints
          .add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }

    for (final stop in stops) {
      routePoints.add(LatLng(stop['latitude'], stop['longitude']));
    }

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Theme.of(context).colorScheme.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Move camera to current location or first stop
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14.0,
        ),
      );
    } else {
      final firstStop =
          (_routeData['stops'] as List)[0] as Map<String, dynamic>;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(firstStop['latitude'], firstStop['longitude']),
          14.0,
        ),
      );
    }
  }

  void _toggleRouteSummary() {
    setState(() {
      _isRouteSummaryCollapsed = !_isRouteSummaryCollapsed;
    });
  }

  void _toggleAR() {
    setState(() {
      _isARActive = !_isARActive;
    });
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceEnabled = !_isVoiceEnabled;
    });

    if (_isVoiceEnabled) {
      _speakDirections();
    }
  }

  void _speakDirections() {
    // Voice guidance implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isVoiceEnabled
            ? 'Voice guidance enabled'
            : 'Voice guidance disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextStop() {
    final stops = (_routeData['stops'] as List).cast<Map<String, dynamic>>();

    if (_currentStopIndex < stops.length - 1) {
      setState(() {
        stops[_currentStopIndex]['status'] = 'completed';
        _currentStopIndex++;
        stops[_currentStopIndex]['status'] = 'current';
      });

      _setupMapData();

      // Move camera to next stop
      final nextStop = stops[_currentStopIndex];
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(nextStop['latitude'], nextStop['longitude']),
          16.0,
        ),
      );

      if (_isVoiceEnabled) {
        _speakDirections();
      }
    } else {
      // Route completed - show impact summary
      setState(() {
        stops[_currentStopIndex]['status'] = 'completed';
        _showImpactDialog = true;
      });
    }
  }

  void _callContact() {
    final stops = (_routeData['stops'] as List).cast<Map<String, dynamic>>();
    final currentStop = stops[_currentStopIndex];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${currentStop['contact']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markComplete() {
    _nextStop();
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_off),
              title: const Text('Location Issue'),
              subtitle: const Text('Cannot find the address'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Contact Issue'),
              subtitle: const Text('No one available at location'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Food Safety Issue'),
              subtitle: const Text('Food quality concerns'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('Other'),
              subtitle: const Text('Different issue'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _closeImpactDialog() {
    setState(() {
      _showImpactDialog = false;
    });

    // Navigate back to dashboard or show completion options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route Complete'),
        content: const Text(
            'Would you like to take another route or return to dashboard?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/volunteer-route-navigation');
            },
            child: const Text('New Route'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            child: const Text('Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stops = (_routeData['stops'] as List).cast<Map<String, dynamic>>();
    final currentStop = _currentStopIndex < stops.length
        ? stops[_currentStopIndex]
        : stops.last;

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps View
          if (!_isARActive) ...[
            if (_isLoading)
              Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Loading route...',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude)
                      : LatLng(stops[0]['latitude'], stops[0]['longitude']),
                  zoom: 14.0,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                trafficEnabled: true,
                buildingsEnabled: true,
                indoorViewEnabled: true,
                mapType: MapType.normal,
              ),
          ],

          // AR Overlay
          if (_isARActive)
            AROverlayWidget(
              isARActive: _isARActive,
              currentDestination: currentStop,
              onToggleAR: _toggleAR,
            ),

          // Route Summary Card
          if (!_isARActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: RouteSummaryCard(
                  routeData: _routeData,
                  isCollapsed: _isRouteSummaryCollapsed,
                  onToggle: _toggleRouteSummary,
                ),
              ),
            ),

          // AR Toggle Button (when not in AR mode)
          if (!_isARActive)
            Positioned(
              top: _isRouteSummaryCollapsed ? 12.h : 35.h,
              right: 4.w,
              child: AROverlayWidget(
                isARActive: false,
                currentDestination: currentStop,
                onToggleAR: _toggleAR,
              ),
            ),

          // My Location Button
          if (!_isARActive)
            Positioned(
              top: _isRouteSummaryCollapsed ? 18.h : 41.h,
              right: 4.w,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.primary,
                onPressed: () {
                  if (_currentPosition != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        16.0,
                      ),
                    );
                  }
                },
                child: CustomIconWidget(
                  iconName: 'my_location',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),

          // Navigation Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigationControls(
              currentStop: currentStop,
              isVoiceEnabled: _isVoiceEnabled,
              onNextStop: _nextStop,
              onCallContact: _callContact,
              onMarkComplete: _markComplete,
              onReportIssue: _reportIssue,
              onToggleVoice: _toggleVoice,
            ),
          ),

          // Impact Summary Dialog
          if (_showImpactDialog)
            Positioned.fill(
              child: ImpactSummaryDialog(
                impactData: _impactData,
                onClose: _closeImpactDialog,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
