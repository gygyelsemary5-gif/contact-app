import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class Contact {
  final String name;
  final String email;
  final String phone;
  final File? image;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.image,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<Contact> _contacts = [];
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFF1D4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFF1D4), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Image.asset('assets/images/splash.png', height: 44),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(41, 56, 77, 1),
      ),
      backgroundColor: const Color.fromRGBO(41, 56, 77, 1),
      body: _contacts.isEmpty ? _buildEmptyState() : _buildGrid(),

      floatingActionButton: _contacts.length >= 6
          ? null
          : FloatingActionButton(
        backgroundColor: const Color(0xFFFFF1D4),
        onPressed: _showAddContactSheet,
        child: const Icon(Icons.add, color: Color(0xFF29384D)),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Column(
      children: [
        Lottie.asset(
          'assets/animation/Not Found.json',
          controller: _controller,
          width: 500,
          height: 550,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..repeat();
          },
        ),
        const Text(
          'There is No Contacts Added Here',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _contacts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // الصورة
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    child: contact.image != null
                        ? Image.file(contact.image!, fit: BoxFit.cover)
                        : const Icon(Icons.person,
                        size: 60, color: Color(0xFF29384D)),
                  ),
                ),
              ),
              // البيانات
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF29384D),
                            fontWeight: FontWeight.bold)),
                    Text(contact.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF29384D), fontSize: 12)),
                    Text(contact.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF29384D), fontSize: 12)),
                    const SizedBox(height: 6),
                    // زرار Delete
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _contacts.removeAt(index));
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(StateSetter setSheetState) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setSheetState(() => _pickedImage = File(picked.path));
    }
  }

  void _saveContact() {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _contacts.add(Contact(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        image: _pickedImage,
      ));
    });

    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _pickedImage = null;

    Navigator.pop(context);
  }

  void _showAddContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF29384D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setSheetState),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFF1D4)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_pickedImage!,
                              fit: BoxFit.cover),
                        )
                            : const Icon(
                          Icons.add_a_photo,
                          color: Color(0xFFFFF1D4),
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty
                                ? 'User Name'
                                : _nameController.text,
                            style: const TextStyle(color: Color(0xFFFFF1D4)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _emailController.text.isEmpty
                                ? 'example@email.com'
                                : _emailController.text,
                            style: const TextStyle(color: Color(0xFFFFF1D4)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _phoneController.text.isEmpty
                                ? '+200000000000'
                                : _phoneController.text,
                            style: const TextStyle(color: Color(0xFFFFF1D4)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setSheetState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter User Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  onChanged: (_) => setSheetState(() {}),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter User Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  onChanged: (_) => setSheetState(() {}),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter User Phone'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1D4),
                      foregroundColor: const Color(0xFF29384D),
                    ),
                    onPressed: _saveContact,
                    child: const Text('Enter user'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}