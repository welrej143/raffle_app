import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transactions',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            'Please log in to view your transactions.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Withdraw'),
            Tab(text: 'Deposit'),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(currentUser.uid, 'Withdrawal'),
          _buildTransactionList(currentUser.uid, 'Deposit'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String userId, String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No transactions found.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final transactions = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final amount = transaction['amount'] as int;
              final timestamp = (transaction['timestamp'] as Timestamp).toDate();
              final status = type == 'Withdrawal'
                  ? transaction['status'] as String
                  : null;
              final data = transaction.data() as Map<String, dynamic>?; // Safely cast to a Map
              final method = data != null && data.containsKey('method')
                  ? data['method'] as String
                  : null;

              final bankName = method == 'Bank Transfer' && data != null && data.containsKey('bankName')
                  ? data['bankName'] as String?
                  : null;


              return Card(
                color: type == 'Deposit' ? Colors.green[900] : Colors.red[900],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '$type - $amount coins',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${timestamp.toLocal()}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (method != null)
                        Text(
                          'Method: $method',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if (bankName != null)
                        Text(
                          'Bank: $bankName',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if (status != null)
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: status == 'Pending'
                                ? Colors.orange
                                : status == 'Completed'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                    ],
                  ),
                  leading: Icon(
                    type == 'Deposit'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
