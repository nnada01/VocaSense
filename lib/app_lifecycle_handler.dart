import 'package:flutter/material.dart';
import 'services/pending_call_log_service.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  final PendingCallLogService pendingService = PendingCallLogService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    uploadPendingLogs();
  }

  Future<void> uploadPendingLogs() async {
    try {
      await pendingService.uploadPendingLogs();
    } catch (e) {
      print("Pending upload failed: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      uploadPendingLogs();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}