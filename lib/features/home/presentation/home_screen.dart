import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:raffle_app/core/services/service_locator.dart';
import 'package:raffle_app/features/home/domain/entities/bet_option.dart';
import 'package:raffle_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:raffle_app/features/play/presentation/playing_screen.dart';
import 'package:raffle_app/features/profile/presentation/profile_screen.dart';
import 'package:raffle_app/features/raffle_history/presentation/raffle_history_screen.dart';
import 'package:raffle_app/features/transactions/presentation/transactions_screen.dart';
import 'package:raffle_app/features/wallet/presentation/wallet_screen.dart';
import 'package:raffle_app/features/withdraw/presentation/withdraw_screen.dart';
import 'package:raffle_app/utils/colors/common_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raffle_app/features/auth/presentation/login_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onMenuItemTap(BuildContext context, String menu) async {
    switch (menu) {
      // case 'Home':
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const HomeScreen()),
      //   );
      //   break;
      case 'Profile':
      // Navigate to Profile screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'Wallet':
      // Navigate to Wallet screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
        break;
      case 'Withdraw':
      // Navigate to Withdraw screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WithdrawScreen()),
        );
        break;
      case 'Transactions':
      // Navigate to Transactions screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionsScreen()),
        );
        break;
      case 'Raffle History':
      // Navigate to Raffle History screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RaffleHistoryScreen()),
        );
        break;
      case 'Logout':
      // Handle Logout
        EasyLoading.show(status: 'Logging out...');
        try {
          await FirebaseAuth.instance.signOut();
          EasyLoading.dismiss();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } catch (e) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (_) => sl<HomeCubit>()..fetchBetOptions(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Raffle Game',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.error, color: Colors.red),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final raffleCoins = userData['raffleCoins'] ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          '$raffleCoins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.monetization_on,
                          color: Colors.yellow[700],
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.red[900], // Raffle theme
            child: Column(
              children: [
                Container(
                  width: double.infinity, // Ensures the container spans the full width of the drawer
                  color: Colors.black, // Background color
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Lottie.asset(
                        'assets/lottie/drawer_animation.json', // Replace with your asset
                        width: 150,
                        height: 150,
                      ),
                      const Text(
                        'Welcome to Raffle Game!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // ListTile(
                //   leading: const Icon(Icons.home, color: Colors.white),
                //   title: const Text('Home', style: TextStyle(color: Colors.white)),
                //   onTap: () => _onMenuItemTap(context, 'Home'),
                // ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: const Text('Profile', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  title: const Text('Wallet', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Wallet'),
                ),
                ListTile(
                  leading: const Icon(Icons.money, color: Colors.white),
                  title: const Text('Withdraw', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Withdraw'),
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white),
                  title: const Text('Transactions', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Transactions'),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.white),
                  title: const Text('Raffle History', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Raffle History'),
                ),
                const Divider(color: Colors.white54),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () => _onMenuItemTap(context, 'Logout'),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: Text('Welcome!')),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (betOptions) {
                return Column(
                  children: [
                    // Mega Jackpot Card
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('raffles')
                          .where('raffleId', isEqualTo: 'mega_jackpot')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text(
                            'Error fetching Mega Jackpot data',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        final raffleData = snapshot.data!.docs.first.data();
                        final availableSlots = raffleData['availableSlots'] ?? 0;
                        final totalSlots = raffleData['totalSlots'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[900],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Mega Jackpot 🎉',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Bet 500 Coins to Win',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Text(
                                          '100,000 PHP',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Total slots: $totalSlots',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Text(
                                          'Available slots: $availableSlots',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Join Now Button
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2.6,
                                          child: ElevatedButton(
                                            onPressed: availableSlots > 0
                                                ? () async {
                                              EasyLoading.show(status: 'Loading...');
                                              final hasInternet = await _hasInternetConnection();

                                              if (!hasInternet) {
                                                EasyLoading.dismiss();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('No internet connection.'),
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                                return;
                                              }
                                              EasyLoading.dismiss();

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const PlayingScreen(
                                                    raffleId: 'mega_jackpot',
                                                    title: 'Mega Jackpot',
                                                  ),
                                                ),
                                              );
                                            }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black, // Disabled if slots are full
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Join Now',
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
                                  // Animation beside the text
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: Lottie.asset(
                                      'assets/lottie/jackpot_animation.json',
                                      repeat: true,
                                      animate: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Regular Options Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two columns
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: betOptions.length,
                        itemBuilder: (context, index) {
                          final option = betOptions[index];
                          return BetOptionCard(
                            option: option,
                            onTap: () async {
                              EasyLoading.show(status: 'Loading...');
                              final hasInternet =
                              await _hasInternetConnection();

                              if (!hasInternet) {
                                EasyLoading.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No internet connection.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }

                              EasyLoading.dismiss();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayingScreen(
                                    raffleId: option.id,
                                    title: option.title,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              error: (message) => Center(child: Text(message)),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

class BetOptionCard extends StatelessWidget {
  final BetOption option;
  final VoidCallback onTap;

  const BetOptionCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('raffles')
          .where('raffleId', isEqualTo: option.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            'Error fetching slot data',
            style: TextStyle(color: Colors.red),
          );
        }

        final raffleData = snapshot.data!.docs.first.data();
        final availableSlots = raffleData['availableSlots'] ?? 0;
        final totalSlots = raffleData['totalSlots'] ?? 0;

        final formattedText = _getFormattedTitle(option.title);

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: CommonColors.black2B3033,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
            children: [
              // Display title and formatted content
              ...formattedText,
              // Available Slots (directly below the title)
              Text(
                'Total slots: $totalSlots',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Available slots: $availableSlots',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              // Join Now Button
              const SizedBox(height: 10,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: availableSlots > 0 ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: availableSlots > 0
                        ? Colors.green
                        : Colors.grey, // Disabled if slots are full
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Join Now',
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
        );
      },
    );
  }

  List<Widget> _getFormattedTitle(String title) {
    final regex = RegExp(r'\d{1,3}(,\d{3})*\s?(PHP)');
    final match = regex.firstMatch(title);

    if (match != null) {
      final boldText = match.group(0) ?? '';
      final parts = title.split(boldText);

      return [
        Text(
          parts[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          boldText,
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (parts.length > 1)
          Text(
            parts[1],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
      ];
    }

    return [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    ];
  }
}



