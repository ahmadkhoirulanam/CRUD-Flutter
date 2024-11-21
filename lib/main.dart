import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  // Fungsi untuk mengambil data dari database dan memperbarui tampilan daftar item.
  Future<void> fetchItems() async {
    final data = await DatabaseHelper.instance.readAllItems();
    setState(() {
      items = data;
    });
  }

  // Fungsi untuk menambah item baru ke dalam database.

  // Fungsi ini adalah sebuah fungsi asinkron yang mengembalikan Future<void>.
  // Fungsi ini biasanya dipanggil saat pengguna ingin menambahkan item, seperti melalui tombol "Add".
  Future<void> addItem() async {
    final name = nameController.text;
    final quantity = int.tryParse(quantityController.text) ?? 0;

    if (name.isNotEmpty) {
      final item = Item(name: name, quantity: quantity);
      await DatabaseHelper.instance.createItem(item);
      nameController.clear();
      quantityController.clear();
      fetchItems();
    }
  }

  // Fungsi untuk memperbarui item yang ada.
  Future<void> updateItem(Item item) async {
    final updatedItem = Item(
        id: item.id,
        name: nameController.text,
        quantity: int.parse(quantityController.text));
    await DatabaseHelper.instance.updateItem(updatedItem);
    nameController.clear();
    quantityController.clear();
    fetchItems();
  }

  // Fungsi untuk menghapus item dari database berdasarkan id.
  Future<void> deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    fetchItems();
  }

  // Fungsi untuk menampilkan dialog pengeditan item, yang memungkinkan pengguna untuk mengedit nama dan jumlah barang.
  void showEditDialog(Item item) {
    nameController.text = item.name;
    quantityController.text = item.quantity.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              updateItem(item);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter CRUD')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity')),
                ElevatedButton(
                    onPressed: addItem, child: const Text('Add Item')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(item)),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteItem(item.id!)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
