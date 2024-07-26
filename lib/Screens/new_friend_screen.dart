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
  Map<String, dynamic>? playerProfile;
  String? username = '';
  String scannedQrCode = '';

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchFriends();
    _tabController = TabController(length: 2, vsync: this);
    username = playerProfile?['username'] ?? 'No username';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendNameController.dispose();
    _qrCodeDataController.dispose();
    super.dispose();
  }

  void fetchUser() async {
    Map<String, dynamic>? playerProfileTemp;
    user = authService.getCurrenctuser();
    if (user != null) {
      playerProfileTemp = await fbdatabaseHelper.getPlayerProfile(user!.uid);
    }
    setState(() {
      if (playerProfileTemp != null) {
        playerProfile = playerProfileTemp;
      }
    });
  }

  void fetchFriends() async {
    if (user != null) {
      List<String> players = await fbdatabaseHelper.getFriends(user!.uid);
      setState(() {
        friends = players;
      });
    }
  }

  void addFriend(String friendName) async {
    if (friendName.isNotEmpty) {
      // Add friend by name logic
      bool added = await fbdatabaseHelper.addFriend(user!.uid, friendName);
      // ignore: use_build_context_synchronously
      if (added) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend $friendName added')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend Not added')),
        );
      }
      fetchFriends();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend name invalid or Not Found!')),
      );
    }
  }

  void navScanQrCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onQRCodeScanned: (qrCode) {
            setState(() {
              if (qrCode.isNotEmpty) {
                scannedQrCode = qrCode;
                addFriend(scannedQrCode);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Friend $scannedQrCode Added!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Couldn't add friend")),
                );
              }
            });
          },
        ),
      ),
    );
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
          SingleChildScrollView(
            child: Column(
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
                        onPressed: () {
                          addFriend(_friendNameController.text.trim());
                        },
                        child: const Text('Add Friend'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                if (friends.isEmpty)
                  const Text('No friends to be displayed ...')
                else
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        300, // Adjust height as needed
                    width: 370.0,
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (BuildContext context, int index) {
                        String friend = friends[index];
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
                                        friend,
                                        style: const TextStyle(
                                          fontSize: 20,
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
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Add by QR Code tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "User Id: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    if (user != null)
                      Text(
                        "${playerProfile?['username'] ?? 'No username'}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade700),
                    height: 300,
                    width: 300,
                    child: GenerateQRCodeScreen(
                        dataToEncode:
                            playerProfile?['username'] ?? 'No username'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navScanQrCode();
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
