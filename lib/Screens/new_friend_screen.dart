import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/auth/auth_service.dart';
import '../services/realtime_db/firebase_db.dart';
import 'QrCodeMger/generate_qr_code.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen>
    with SingleTickerProviderStateMixin {
      FirebaseDatabaseHelper fbdatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();
  
  late TabController _tabController;
  final TextEditingController _friendNameController = TextEditingController();
  final TextEditingController _qrCodeDataController = TextEditingController();

  User? user;

  @override
  void initState() {
    super.initState();
    fetchUser();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendNameController.dispose();
    _qrCodeDataController.dispose();
    super.dispose();
  }

  void fetchUser() async {
    user = authService.getCurrenctuser();
    setState(() {});
  }

  void _addFriendByName() {
    String friendName = _friendNameController.text.trim();
    if (friendName.isNotEmpty) {
      // Add friend by name logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend $friendName added')),
      );
    }
  }

  void _generateQRCode() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Qr Code'),
              content: SizedBox(
                  height: 250,
                  width: 250,
                  child: GenerateQRCodeScreen(
                      dataToEncode: _qrCodeDataController.text)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Add by Name'),
            Tab(text: 'My QrCode'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Add by Name tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _friendNameController,
                  decoration: const InputDecoration(
                    labelText: 'Friend Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addFriendByName,
                  child: const Text('Add Friend'),
                ),
              ],
            ),
          ),
          // Add by QR Code tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('User Id: ${user!.uid}'),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade700),
                    height: 300,
                    width: 300,
                      child: GenerateQRCodeScreen(
                          dataToEncode: user!.uid)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
