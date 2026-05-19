import 'package:flutter/material.dart';
import 'guardian_model.dart';
import '../services/api_service.dart';

class GuardianScreen extends StatefulWidget {
  final List<Guardian> guardians;

  const GuardianScreen({super.key, required this.guardians});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  final ApiService api = ApiService();

  late List<Guardian> guardians;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    guardians = List.from(widget.guardians);
  }

  Future<void> _addGuardian(String name, String phone) async {
    setState(() {
      isLoading = true;
    });

    try {
      await api.addGuardian(name, phone);

      if (!mounted) return;
      Navigator.pop(context); // closes dialog

      setState(() {
        guardians.add(
          Guardian(
            id: DateTime.now().toString(),
            name: name,
            phone: phone,
          ),
        );
        isLoading = false;
      });

      Navigator.pop(context, true); // tells HomeScreen to reload from backend
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add guardian: $e")),
      );
    }
  }

  Future<void> _removeGuardian(int index) async {
    final g = guardians[index];

    setState(() {
      isLoading = true;
    });

    try {
      await api.deleteGuardian(g.id);

      setState(() {
        guardians.removeAt(index);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete guardian: $e")),
      );
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Guardian"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();

                    if (name.isNotEmpty && phone.isNotEmpty) {
                      _addGuardian(name, phone);
                    }
                  },
            child: Text(isLoading ? "Adding..." : "Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guardians"),
        backgroundColor: const Color(0xFF1E567B),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: isLoading && guardians.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : guardians.isEmpty
              ? const Center(child: Text("No guardians yet"))
              : ListView.builder(
                  itemCount: guardians.length,
                  itemBuilder: (context, index) {
                    final g = guardians[index];
                    return ListTile(
                      title: Text(g.name),
                      subtitle: Text(g.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: isLoading ? null : () => _removeGuardian(index),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: isLoading ? null : _showAddDialog,
        backgroundColor: const Color(0xFF1E567B),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
          ),
      ),
    );
  }
}