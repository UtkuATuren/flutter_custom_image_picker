// main.dart
// The entry point of the application.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'gallery_selection_screen.dart'; // Import the main picker screen

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Image Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State to hold the picked files
    final pickedFiles = useState<List<XFile>>([]);

    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker Demo Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Navigate to the gallery selection screen and wait for the result
                final result = await Navigator.of(context).push<List<XFile>>(MaterialPageRoute(builder: (_) => const GallerySelectionScreen()));

                // If files were selected, update the state
                if (result != null) {
                  pickedFiles.value = result;
                }
              },
              child: const Text('Open Custom Image Picker'),
            ),
            const SizedBox(height: 20),
            // Display the number of picked files
            Text('Picked files: ${pickedFiles.value.length}'),
            // You could add a grid view here to display the picked images
          ],
        ),
      ),
    );
  }
}
