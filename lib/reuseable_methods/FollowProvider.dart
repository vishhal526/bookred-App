import 'package:flutter/material.dart';

class FollowProvider with ChangeNotifier {
  bool _needsRefresh = false;

  bool get needsRefresh => _needsRefresh;

  // Call this method whenever an action requires a refresh in LibraryPage
  void triggerRefresh() {
    _needsRefresh = true;
    notifyListeners(); // This triggers rebuilds where this provider is being listened to
  }

  // After refresh is complete, call this to stop endless refreshing
  void reset() {
    _needsRefresh = false;
    notifyListeners(); // Optional: only needed if UI depends on needsRefresh's false state
  }
}
