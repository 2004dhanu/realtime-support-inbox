import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/dev_login_page.dart';
import 'features/debug/debug_page.dart';
import 'features/inbox/ui/inbox_page.dart';
import 'features/inbox/ui/conversation_page.dart';

class SupportInboxApp extends StatelessWidget {
  const SupportInboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Realtime Support Inbox',
      theme: AppTheme.light(),
      initialRoute: DevLoginPage.routeName,
      getPages: [
        GetPage(name: DevLoginPage.routeName, page: () => const DevLoginPage()),
        GetPage(name: InboxPage.routeName, page: () => const InboxPage()),
        GetPage(name: ConversationPage.routeName, page: () => const ConversationPage()),
        GetPage(name: DebugPage.routeName, page: () => const DebugPage()),
      ],
    );
  }
}
