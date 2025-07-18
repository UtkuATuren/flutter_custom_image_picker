// permissions_provider.dart
// Manages the state of photo library permissions using Riverpod.

import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions_provider.g.dart';

@riverpod
class Permissions extends _$Permissions {
  @override
  Future<PermissionState> build() async {
    // Immediately requests permission when the provider is first read.
    // The `future` property of the provider will hold the result of this.
    return await PhotoManager.requestPermissionExtend();
  }

  // Method to guide the user to the app settings if permission is denied.
  Future<void> openSettings() async {
    await PhotoManager.openSetting();
  }

  // Optional: A method to manually re-request permissions if needed.
  Future<void> request() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => PhotoManager.requestPermissionExtend());
  }
}
