import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static void _handleNotificationReceived(OSNotification notification) {
    print("OneSignal Received!!!!");
  }

  static void initOneSignal() async {
    //Remove this method to stop OneSignal Debugging
    print("initOneSignal started  !!!!");

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init("fb51cf8c-d4c8-4ed0-a0a1-9ba1545ce0ac", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared
        .setNotificationReceivedHandler(_handleNotificationReceived);

    print("initOneSignal end  !!!!");
    print("initOneSignal listening  !!!!");
  }
}
