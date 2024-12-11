import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentCoins = userDoc['raffleCoins'] ?? 0;
        });
      }
    } catch (e) {
      EasyLoading.showError('Failed to fetch wallet data.');
    }
  }

  Future<void> _depositCoins(int amount) async {
    if (amount < 500) {
      EasyLoading.showError('Minimum deposit amount is 500 coins.');
      return;
    }

    EasyLoading.show(status: 'Processing deposit...');
    try {
      // Update user's coin balance
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .update({
        'raffleCoins': FieldValue.increment(amount),
      });

      // Save transaction to Firestore
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': currentUser?.uid,
        'type': 'Deposit',
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentCoins += amount;
      });

      EasyLoading.showSuccess('Successfully deposited $amount coins!');
    } catch (e) {
      EasyLoading.showError('Failed to deposit coins.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: currentUser == null
          ? const Center(
        child: Text(
          'Please log in to view your wallet.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Wallet Header
          const Text(
            'Your Wallet',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Current Coins Display
          Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Coins:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$currentCoins',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Minimum Deposit Note
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Note: The minimum deposit amount is 500 coins.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Deposit Section
          const Text(
            'Deposit Coins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Deposit Options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDepositButton(amount: 500),
              const SizedBox(width: 10),
              _buildDepositButton(amount: 1000),
              const SizedBox(width: 10),
              _buildDepositButton(amount: 2000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton({required int amount}) {
    return ElevatedButton(
      onPressed: () {
        _depositCoins(amount);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Deposit $amount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
