import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  runApp(const MaterialApp(home: DatenBank()));
}

class DatenBank extends StatefulWidget {
  const DatenBank({Key? key}) : super(key: key);

  @override
  State<DatenBank> createState() => _DatenBankState();
}

class _DatenBankState extends State<DatenBank> {
  String storeData = '';
  String keyText = 'KeyText';
  final picker = ImagePicker();
  String? imagePath;

  Future<void> createData() async {
    final box = await Hive.openBox('myBox');
    await box.put(keyText, 'Value1');
  }

  Future<void> updateData() async {
    final box = await Hive.openBox('myBox');
    await box.put(keyText, 'Value1');
  }

  Future<void> readData() async {
    final box = await Hive.openBox('myBox');
    setState(() {
      storeData = box.get(keyText, defaultValue: 'Unbekannt');
    });
    debugPrint(storeData);
  }

  Future<void> removeData() async {
    final box = await Hive.openBox('myBox');
    await box.delete(keyText);
  }

  Future<void> selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final box = await Hive.openBox('imageBox');
      await box.put('imagePath', pickedFile.path);
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> selectImageCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final box = await Hive.openBox('imageBox');
      await box.put('imagePath', pickedFile.path);
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> loadImage() async {
    final box = await Hive.openBox('imageBox');
    final path = box.get('imagePath', defaultValue: null);
    setState(() {
      imagePath = path;
    });
  }

  TextEditingController textController = TextEditingController();
  String savedText = '';

  @override
  void initState() {
    super.initState();
    loadSavedText();
  }

  Future<void> loadSavedText() async {
    final box = await Hive.openBox('textBox');
    setState(() {
      savedText = box.get('savedText', defaultValue: '');
    });
  }

  Future<void> saveText() async {
    final box = await Hive.openBox('textBox');
    box.put('savedText', textController.text);
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DatenBank_ Hive')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aufgabe 1 und 2'),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: createData,
                    child: const Text('speichern'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: readData, child: const Text('Abfrage')),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: removeData, child: const Text('Löschen')),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Aufgabe 3'),
            Container(
              color: Colors.grey,
              child: Text(
                storeData,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Text eingeben',
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          saveText();
                        },
                        child: const Text('Speichern'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          loadSavedText();
                          textController.text = savedText;
                        },
                        child: const Text('Laden und Einfügen'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Text('Zusatzaufgabe'),
                  if (imagePath != null)
                    Image.file(
                      File(imagePath!),
                      width: 150,
                      height: 150,
                    ),
                  Row(
                    children: [
                      SizedBox(width: 130,
                        child: ElevatedButton(
                          onPressed: selectImageCamera,
                          child: const Text('Bild machen'),
                        ),
                      ),
                      SizedBox(width: 130,
                        child: ElevatedButton(
                          onPressed: selectImage,
                          child: const Text('Bild auswählen'),
                        ),
                      ),
                      SizedBox(width: 100,
                        child: ElevatedButton(
                          onPressed: loadImage,
                          child: const Text('Bild laden'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
