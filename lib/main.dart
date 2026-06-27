import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emotion_wheel.dart';

const List<Map<String, String>> images = [
  {
    'path': 'assets/R. Plutchiko emocijų ratas.png',
    'name': 'R. Plutchiko emocijų ratas (Pokalbių Gidas)',
  },
  {
    'path': 'assets/R. Plutchiko emocijų ratas 2.png',
    'name': 'R. Plutchiko emocijų ratas 2',
  },
  {'path': 'assets/lengvos mintys.png', 'name': 'lengvos mintys'},
];

/// Selection index for the code-drawn (non-image) interactive wheel, shown as
/// the entry right after the [images].
const int kWheelIndex = 3;
const String kWheelName = 'R. Plutchiko emocijų ratas';

void main() {
  runApp(const EmocijuRatasApp());
}

class EmocijuRatasApp extends StatelessWidget {
  const EmocijuRatasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emocijų Ratas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB5651D),
        scaffoldBackgroundColor: kPaperColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPaperColor,
          foregroundColor: Color(0xFF4A3B2F),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Defaults to the interactive wheel; overridden by a saved choice if any.
  int _selectedIndex = kWheelIndex;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedImage') ?? kWheelIndex;
    });
  }

  Future<void> _saveSelection(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedImage', index);
  }

  void _selectImage(int index) {
    setState(() {
      _selectedIndex = index;
      _transformationController.value = Matrix4.identity();
    });
    _saveSelection(index);
    Navigator.pop(context);
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pasirinkite ratą',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...List.generate(images.length, (index) {
                final image = images[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      image['path']!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(image['name']!),
                  trailing: _selectedIndex == index
                      ? const Icon(Icons.check, color: Color(0xFF9C5B2E))
                      : null,
                  onTap: () => _selectImage(index),
                );
              }),
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: EmotionWheelThumbnail(size: 56),
                  ),
                ),
                title: const Text(kWheelName),
                trailing: _selectedIndex == kWheelIndex
                    ? const Icon(Icons.check, color: Color(0xFF9C5B2E))
                    : null,
                onTap: () => _selectImage(kWheelIndex),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_selectedIndex == kWheelIndex) {
      return const Center(child: EmotionWheelView());
    }
    return Center(
      child: Image.asset(images[_selectedIndex]['path']!, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emocijų Ratas'), centerTitle: true),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 10.0,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImagePicker,
        child: const Icon(Icons.menu),
      ),
    );
  }
}
