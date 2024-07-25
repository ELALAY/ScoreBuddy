import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Screens/QrCodeMger/scan_qr_code.dart';

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

  List<String> friends = [];
  User? user;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchFriends();
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

  void fetchFriends() async {
    List<String> players = await fbdatabaseHelper.getFriends(user!.uid);
    setState(() {
      friends = players;
    });
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

  void navScanQrCode() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const QRScannerScreen();
    }));
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
          Column(children: [
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
            friends.isEmpty
                ? const Text('No friends to be displayed ...')
                : Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Theme.of(context).colorScheme.primary,
                        elevation: 2.0,
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      friends[index],
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                      );
                    }),
                  ),
          ]),
          // Add by QR Code tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('User Id: ${user!.uid}'),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade700),
                      height: 300,
                      width: 300,
                      child: GenerateQRCodeScreen(dataToEncode: user!.uid)),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const QRScannerScreen();
          }));
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
