import 'package:flutter/material.dart';
import 'package:shalat_aplikasi/pages/login.dart';
import 'package:shalat_aplikasi/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class BerandaPage extends StatefulWidget {
  final String role;
  final String name;

  const BerandaPage({
    super.key,
    required this.role,
    required this.name,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final List<String> _shalatList = ["Shalat Subuh", "Shalat Dzuhur", "Shalat Ashar", "Shalat Magrib", "Shalat Isya"];

  Future<void> _logout() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final success = await loginProvider.logout();

    if (success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loginProvider.errorMessage)),
      );
    }
  }

  void _addShalat(String name) {
    setState(() {
      _shalatList.add(name);
    });
    _showSnackbar('Shalat "$name" berhasil ditambahkan!');
  }

  void _editShalat(int index, String newName) {
    setState(() {
      _shalatList[index] = newName;
    });
    _showSnackbar('Shalat berhasil diubah menjadi "$newName"!');
  }

  void _deleteShalat(int index) {
    final removedItem = _shalatList[index];
    setState(() {
      _shalatList.removeAt(index);
    });
    _showSnackbar('Shalat "$removedItem" berhasil dihapus!');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShalatDialog({String? initialName, int? index}) {
    if (widget.role != 'admin') {
      _showSnackbar('Hanya admin yang dapat melakukan aksi ini!');
      return;
    }

    final TextEditingController _controller = TextEditingController(text: initialName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(index == null ? 'Tambah Shalat' : 'Edit Shalat'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Masukkan nama shalat'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _controller.text.trim();
                if (name.isNotEmpty) {
                  if (index == null) {
                    _addShalat(name);
                  } else {
                    _editShalat(index, name);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int index) {
    if (widget.role != 'admin') {
      _showSnackbar('Hanya admin yang dapat melakukan aksi ini!');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus "${_shalatList[index]}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteShalat(index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${widget.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${widget.role}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _shalatList.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      title: Text(_shalatList[index],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showShalatDialog(initialName: _shalatList[index], index: index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.role != 'admin') {
                    _showSnackbar('Hanya admin yang dapat melakukan aksi ini!');
                  } else {
                    _showShalatDialog();
                  }
                },
                child: const Text('Tambah Shalat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
