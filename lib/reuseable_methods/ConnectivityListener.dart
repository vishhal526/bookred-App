// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class ConnectivityListener extends StatefulWidget {
//   final Widget child;
//   const ConnectivityListener({required this.child, Key? key}) : super(key: key);
//
//   @override
//   State<ConnectivityListener> createState() => _ConnectivityListenerState();
// }
//
// class _ConnectivityListenerState extends State<ConnectivityListener> with WidgetsBindingObserver {
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   bool _isConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _checkAndShowStatus(); // Check on app start
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((_) => _checkAndShowStatus());
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Re-check connectivity when app is resumed
//     if (state == AppLifecycleState.resumed) {
//       _checkAndShowStatus();
//     }
//   }
//
//   Future<void> _checkAndShowStatus() async {
//     final isConnected = await _checkInternetConnection();
//
//     if (isConnected != _isConnected) {
//       _isConnected = isConnected;
//
//       // Clear old SnackBars to prevent stacking
//       ScaffoldMessenger.of(context).clearSnackBars();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isConnected ? 'Connected' : 'No Internet Connection',
//             style: const TextStyle(fontFamily: 'Poppins'),
//           ),
//           backgroundColor: isConnected ? Colors.green : Color(0xFF1D1A32),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   Future<bool> _checkInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.child;
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  const ConnectivityListener({required this.child, Key? key}) : super(key: key);

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late AnimationController _animationController;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _checkAndShowStatus();

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((_) => _checkAndShowStatus());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowStatus();
    }
  }

  Future<void> _checkAndShowStatus() async {
    final isConnected = await _checkInternetConnection();

    if (isConnected != _isConnected) {
      _isConnected = isConnected;

      ScaffoldMessenger.of(context).clearSnackBars();
      _animationController.reset();
      _animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: isConnected ? Colors.green : Color(0xFF1A1D32),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                child: Text(
                  isConnected ? 'Connected' : 'No Internet Connection',
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: 4,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
