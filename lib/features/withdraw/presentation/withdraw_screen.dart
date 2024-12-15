import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _nameOnCardController = TextEditingController();

  String? _selectedMethod;
  int availableCoins = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

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
          availableCoins = userDoc['raffleCoins'] ?? 0;
        });
      }
    } catch (e) {
      EasyLoading.showError('Failed to fetch wallet data.');
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final int amount = int.parse(_amountController.text.trim());
    final String account = _accountController.text.trim();
    final String? bankName =
    _selectedMethod == 'Bank Transfer' ? _bankNameController.text.trim() : null;
    final String? nameOnCard =
    _selectedMethod == 'Bank Transfer' ? _nameOnCardController.text.trim() : null;

    if (amount < 500) {
      EasyLoading.showError('Minimum withdrawal amount is 500 coins.');
      return;
    }

    if (amount > availableCoins) {
      EasyLoading.showError('Insufficient coins for this withdrawal.');
      return;
    }

    EasyLoading.show(status: 'Submitting withdrawal request...');

    try {
      // Save withdrawal request to Firestore
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': currentUser?.uid,
        'type': 'Withdrawal',
        'amount': amount,
        'method': _selectedMethod,
        'account': account,
        'bankName': bankName,
        'nameOnCard': nameOnCard,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending', // Mark for manual processing
      });

      // Deduct coins from user's account
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .update({
        'raffleCoins': FieldValue.increment(-amount),
      });

      EasyLoading.showSuccess('Withdrawal request submitted!');
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.showError('Failed to submit withdrawal request.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Withdraw Coins',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: availableCoins == 0
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Coins:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '$availableCoins',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Note: 1 coin = 1 PHP \nMinimum withdrawal is 500 coins.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Withdrawal Method',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                value: _selectedMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Gcash',
                    child: Text('Gcash'),
                  ),
                  DropdownMenuItem(
                    value: 'Maya',
                    child: Text('Maya'),
                  ),
                  DropdownMenuItem(
                    value: 'Bank Transfer',
                    child: Text('Bank Transfer'),
                  ),
                ],
                validator: (value) =>
                value == null ? 'Please select a method' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedMethod == 'Bank Transfer') ...[
                const Text(
                  'Bank Name',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bankNameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the bank name'
                      : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Name on Card',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameOnCardController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the name on the card'
                      : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Account Number',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter account number'
                    : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Amount to Withdraw',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final int amount = int.tryParse(value) ?? 0;
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  if (amount < 500) {
                    return 'Minimum withdrawal is 500 coins.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'It will take 2-3 business days to complete withdrawal requests. Thank you for your patience!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Withdrawal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
