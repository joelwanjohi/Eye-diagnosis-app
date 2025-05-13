import 'package:flutter/material.dart';
import 'package:opt_app/constants/animation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart';

class FindHospitalScreen extends StatefulWidget {
  const FindHospitalScreen({super.key});

  @override
  State<FindHospitalScreen> createState() => _FindHospitalScreenState();
}

class _FindHospitalScreenState extends State<FindHospitalScreen> {
  WebViewController? _controller;
  bool _isLoading = false;
  bool _isMapOpened = false; // Track if map is opened

  // Load Google Maps only when button is clicked
  void _openMapWebView() {
    setState(() {
      _isLoading = true;
      _isMapOpened = true; // Set to true when opening the map
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            'https://www.google.com/maps/search/ophthalmologist+near+me?hl=en'), // Ensures English
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Eye Clinic"),
      ),
      body: Stack(
        children: [
          // Only show WebView if map is opened
          if (_isMapOpened) WebViewWidget(controller: _controller!),

          // Show loading animation when the page is loading
          if (_isLoading)
            Center(
              child:
                  Lottie.asset(LottieManager.loading, frameRate: FrameRate.max),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        onPressed: !_isLoading ? _openMapWebView : null,
        child:
            Icon(Icons.location_on, color: Theme.of(context).iconTheme.color),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
// import 'package:geolocator/geolocator.dart';
// import 'package:lottie/lottie.dart';
// import 'package:opt_app/constants/animation.dart';

// class FindHospitalScreen extends StatefulWidget {
//   const FindHospitalScreen({super.key});

//   @override
//   State<FindHospitalScreen> createState() => _FindHospitalScreenState();
// }

// class _FindHospitalScreenState extends State<FindHospitalScreen> {
//   gmaps.GoogleMapController? mapController;
//   bool _isLoading = false;

//   final gmaps.LatLng _center = const gmaps.LatLng(-1.286389, 36.817223);
//   final Set<gmaps.Marker> _markers = {};

//   /// Fetch user's current location and update map
//   Future<void> _getCurrentLocation() async {
//     setState(() => _isLoading = true);

//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showError("Location permission denied.");
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         _showError("Location permissions are permanently denied.");
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       if (mapController != null) {
//         mapController!.animateCamera(
//           gmaps.CameraUpdate.newCameraPosition(
//             gmaps.CameraPosition(
//               target: gmaps.LatLng(position.latitude, position.longitude),
//               zoom: 14.0,
//             ),
//           ),
//         );
//       }

//       await Future.delayed(const Duration(milliseconds: 500));
//       await _searchNearbyClinics(position.latitude, position.longitude);
//     } catch (e) {
//       _showError("Error getting location: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _searchNearbyClinics(double lat, double lng) async {
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         gmaps.Marker(
//           markerId: const gmaps.MarkerId('currentLocation'),
//           position: gmaps.LatLng(lat, lng),
//           infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
//         ),
//       );

//       _markers.add(
//         gmaps.Marker(
//           markerId: const gmaps.MarkerId('clinic1'),
//           position: gmaps.LatLng(lat + 0.01, lng + 0.01),
//           infoWindow: const gmaps.InfoWindow(
//               title: 'Eye Clinic', snippet: 'Sample Eye Clinic'),
//           icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
//               gmaps.BitmapDescriptor.hueBlue),
//         ),
//       );
//     });
//   }

//   void _onMapCreated(gmaps.GoogleMapController controller) {
//     mapController = controller;
//     _getCurrentLocation();
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Find Eye Clinic")),
//       body: Stack(
//         children: [
//           gmaps.GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition:
//                 gmaps.CameraPosition(target: _center, zoom: 11.0),
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//           ),
//           if (_isLoading)
//             Center(
//                 child: Lottie.asset(LottieManager.loading,
//                     frameRate: FrameRate.max)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         onPressed: !_isLoading ? _getCurrentLocation : null,
//         child:
//             Icon(Icons.location_on, color: Theme.of(context).iconTheme.color),
//       ),
//     );
//   }
// }
