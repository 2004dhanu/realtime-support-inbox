import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugController extends GetxController {
  final RxBool showFakeBanner = true.obs;
  final RxString environment = 'local'.obs;
}

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  static const routeName = '/debug';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DebugController());

    return Scaffold(
      appBar: AppBar(title: const Text('Debug & Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => SwitchListTile(
                value: controller.showFakeBanner.value,
                onChanged: (value) => controller.showFakeBanner.value = value,
                title: const Text('Show fake banner'),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButton<String>(
                value: controller.environment.value,
                onChanged: (value) => controller.environment.value = value ?? 'local',
                items: const [
                  DropdownMenuItem(value: 'local', child: Text('Local')),
                  DropdownMenuItem(value: 'staging', child: Text('Staging')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Legacy settings area (GetX). Keep this module intact.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
