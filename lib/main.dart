import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<Map<String, String>> images = [
  {
    'path': 'assets/R. Plutchiko emocijų ratas.png',
    'name': 'R. Plutchiko emocijų ratas',
  },
  {
    'path': 'assets/R. Plutchiko emocijų ratas 2.png',
    'name': 'R. Plutchiko emocijų ratas 2',
  },
  {'path': 'assets/lengvos mintys.png', 'name': 'lengvos mintys'},
];

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
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
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
  int _selectedIndex = 0;
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
      _selectedIndex = prefs.getInt('selectedImage') ?? 0;
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
                      ? const Icon(Icons.check, color: Colors.deepPurple)
                      : null,
                  onTap: () => _selectImage(index),
                );
              }),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emocijų Ratas'), centerTitle: true),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 10.0,
        child: Center(
          child: Image.asset(
            images[_selectedIndex]['path']!,
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImagePicker,
        child: const Icon(Icons.menu),
      ),
    );
  }
}
