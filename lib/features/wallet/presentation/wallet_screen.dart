import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int currentCoins = 0;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final String _productId500 = 'coin_pack_500'; // Product ID for 500 coins
  final String _productId1000 = 'coin_pack_1000'; // Product ID for 1000 coins
  final String _productId2000 = 'coin_pack_2000'; // Product ID for 2000 coins
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();

    // Subscribe to the purchase updates stream
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        EasyLoading.showError('An error occurred: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the subscription to avoid memory leaks
    super.dispose();
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

  Future<void> _buyCoins(String productId) async {
    EasyLoading.show(status: 'Processing...');
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        EasyLoading.showError('In-app purchases are not available.');
        return;
      }

      final ProductDetailsResponse response =
      await _inAppPurchase.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        EasyLoading.showError('Product not found.');
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      // Start purchase flow
      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
    } catch (e) {
      EasyLoading.showError('Failed to initiate purchase.');
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _onPurchaseSuccess(purchaseDetails.productID);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        EasyLoading.showError('Purchase failed: ${purchaseDetails.error?.message}');
      }
    }
  }

  Future<void> _onPurchaseSuccess(String productId) async {
    int coinsToAdd = 0;
    if (productId == _productId500) {
      coinsToAdd = 500;
    } else if (productId == _productId1000) {
      coinsToAdd = 1000;
    } else if (productId == _productId2000) {
      coinsToAdd = 2000;
    }

    if (coinsToAdd > 0) {
      try {
        // Update user's coin balance in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .update({
          'raffleCoins': FieldValue.increment(coinsToAdd),
        });

        // Save transaction to Firestore
        await FirebaseFirestore.instance.collection('transactions').add({
          'userId': currentUser?.uid,
          'type': 'Deposit',
          'amount': coinsToAdd,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          currentCoins += coinsToAdd;
        });

        EasyLoading.showSuccess('Successfully added $coinsToAdd coins!');
      } catch (e) {
        EasyLoading.showError('Failed to update balance.');
      }
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
              _buildDepositButton(productId: _productId500, label: '500'),
              const SizedBox(width: 10),
              _buildDepositButton(productId: _productId1000, label: '1000'),
              const SizedBox(width: 10),
              _buildDepositButton(productId: _productId2000, label: '2000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton({required String productId, required String label}) {
    return ElevatedButton(
      onPressed: () {
        _buyCoins(productId);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Deposit $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
