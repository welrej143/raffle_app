import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:raffle_app/features/play/presentation/cubit/raffle_cubit.dart';
import 'package:raffle_app/features/play/presentation/cubit/raffle_state.dart';
import 'package:raffle_app/core/services/service_locator.dart';

class PlayingScreen extends StatefulWidget {
  final String raffleId;
  final String title;

  const PlayingScreen({
    super.key,
    required this.raffleId,
    required this.title,
  });

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  final StreamController<int> _selectedStreamController = StreamController<int>.broadcast(); // Use broadcast
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 5));

  bool _hasSpun = false; // To ensure the wheel spins only once
  int? _winnerIndex; // To keep track of the winner index
  bool _isCountdownActive = false; // To track countdown state
  int _countdownValue = 5; // Initial countdown value
  bool isStartTambiolo = false;

  @override
  void dispose() {
    _selectedStreamController.close(); // Close the stream when done
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startCountdownAndSpin(int totalSlots) async {
    setState(() {
      _isCountdownActive = true;
    });

    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _countdownValue = i;
        });
      });
    }

    setState(() {
      _isCountdownActive = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      _spinWheel(totalSlots);
    });
  }

  void _spinWheel(int totalSlots) {
    setState(() {
      _hasSpun = true;
    });

    final winnerIndex = Random().nextInt(totalSlots); // Randomly select a winner
    _winnerIndex = winnerIndex; // Save the winner index
    _selectedStreamController.add(winnerIndex); // Pass the winner index to the wheel
  }

  void _showCelebrationDialog(String winnerSlot) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // Confetti animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.green],
          ),

          // Celebration dialog
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text(
                "🎉 We Have a Winner! 🎉",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Winning Slot: $winnerSlot",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Congratulations to the winner!",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confettiController.stop();
                    _resetRaffle();
                  },
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resetRaffle() async {
    try {
      // Fetch the raffle document based on the provided raffleId
      final raffleQuerySnapshot = await FirebaseFirestore.instance
          .collection('raffles')
          .where('raffleId', isEqualTo: widget.raffleId)
          .get();

      if (raffleQuerySnapshot.docs.isNotEmpty) {
        // Get the first matching raffle document
        final raffleDoc = raffleQuerySnapshot.docs.first;
        final raffleRef = raffleDoc.reference;

        // Fetch the totalSlots dynamically from the document
        final totalSlots = raffleDoc['totalSlots'] ?? 0;

        if (totalSlots > 0) {
          // Update the raffle document to reset slots and clear participants
          await raffleRef.update({
            'availableSlots': totalSlots, // Reset to totalSlots
            'participants': [], // Clear all participants
          });

          debugPrint("Raffle reset successfully with $totalSlots slots.");
        } else {
          debugPrint("Error: totalSlots is missing or invalid.");
        }
      } else {
        debugPrint("No raffle found with the given raffleId.");
      }
    } catch (e) {
      debugPrint("Error resetting raffle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: BlocProvider(
        create: (_) => sl<RaffleCubit>()..fetchRaffle(widget.raffleId),
        child: BlocConsumer<RaffleCubit, RaffleState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (raffle) {
                if (raffle.availableSlots == 0 && !_hasSpun && !_isCountdownActive) {
                  _startCountdownAndSpin(raffle.totalSlots);
                }
                if (raffle.availableSlots == 0 && widget.raffleId == 'mega_jackpot') {
                  setState(() {
                    isStartTambiolo = true; // Set the tambiolo flag to true
                  });
                }
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                  child: Text(
                "Initializing...",
                style: TextStyle(color: Colors.white),
              )),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              loaded: (raffle) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Available Slots: ${raffle.availableSlots} / ${raffle.totalSlots}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Display slots bought by the user
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('raffles')
                          .where('raffleId', isEqualTo: widget.raffleId) // Filter by raffleId
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(color: Colors.white);
                        }

                        if (snapshot.hasError) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Error fetching your slots.",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No raffle found.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          );
                        }

                        // Extract the raffle document
                        final raffleDoc = snapshot.data!.docs.first;
                        final participants = List<Map<String, dynamic>>.from(raffleDoc['participants'] ?? []);

                        // Find the user's slots
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        final userSlots = participants
                            .where((participant) => participant['userId'] == userId)
                            .map((participant) => participant['slot'])
                            .toList()
                            .cast<int>();

                        if (userSlots.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "You have not purchased any slots yet.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Your Slots: ${userSlots.join(', ')}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        );
                      },
                    ),

                    // Spinning Wheel or Countdown Animation
                    if (_isCountdownActive)
                      Center(
                        child: Text(
                          'Starting in $_countdownValue',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else if (widget.raffleId == 'mega_jackpot')
                      Expanded(
                        child: Center(
                          child: AnimatedTambiolo(
                            isStartTambiolo: isStartTambiolo,
                            totalSlots: raffle.totalSlots,
                            winnerCallback: (winner) {
                              _showCelebrationDialog("Slot $winner");
                            },
                            raffleId: widget.raffleId,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                        height: MediaQuery.of(context).size.width * 0.9, // 90% of screen width (square)
                        child: FortuneWheel(
                          selected: _selectedStreamController.stream,
                          animateFirst: false,
                          duration: const Duration(seconds: 15),
                          items: List.generate(
                            raffle.totalSlots,
                            (index) {
                              final double angle = (2 * pi) / raffle.totalSlots; // Angle per slice
                              return FortuneItem(
                                child: Transform.rotate(
                                  angle: -angle * index, // Rotate text upright
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                style: FortuneItemStyle(
                                  borderColor: Colors.white,
                                  borderWidth: 1,
                                  color: index % 2 == 0 ? Colors.blue[300]! : Colors.orange[300]!,
                                ),
                              );
                            },
                          ),
                          onAnimationEnd: () async {
                            if (_winnerIndex != null) {
                              final winnerSlot = 'Slot ${_winnerIndex! + 1}'; // Winner slot number

                              try {
                                // Fetch raffle document
                                final raffleQuerySnapshot = await FirebaseFirestore.instance
                                    .collection('raffles')
                                    .where('raffleId', isEqualTo: widget.raffleId)
                                    .get();

                                if (raffleQuerySnapshot.docs.isNotEmpty) {
                                  final raffleDoc = raffleQuerySnapshot.docs.first;
                                  final participants = List<Map<String, dynamic>>.from(
                                    raffleDoc['participants'] ?? [],
                                  );

                                  // Find winner
                                  final Map<String, dynamic> winner = participants.firstWhere(
                                    (participant) => participant['slot'] == _winnerIndex! + 1,
                                    orElse: () => {},
                                  );

                                  if (winner.isNotEmpty) {
                                    final winnerId = winner['userId'];

                                    // Fetch user data
                                    final userDoc =
                                        await FirebaseFirestore.instance.collection('users').doc(winnerId).get();

                                    if (userDoc.exists) {
                                      final prizeAmount = raffleDoc['winningAmount'] ?? 0;

                                      // Update user coins
                                      await FirebaseFirestore.instance.collection('users').doc(winnerId).update({
                                        'raffleCoins': FieldValue.increment(prizeAmount),
                                      });

                                      // Save to raffle_history
                                      await FirebaseFirestore.instance.collection('raffle_history').add({
                                        'slotNumber': _winnerIndex! + 1, // Save the winning slot number
                                        'winnerId': winnerId, // Winner's user ID
                                        'prizeAmount': prizeAmount, // Prize amount
                                        'timestamp': FieldValue.serverTimestamp(), // Timestamp of the event
                                      });

                                      // Show winner dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          title: const Center(
                                            child: Text(
                                              "🎉 Coins Added! 🎉",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Winning Slot: $winnerSlot",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                "Congratulations! $prizeAmount coins have been added to your account.",
                                                style: const TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _confettiController.stop();
                                                  _resetRaffle();
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } else {
                                    debugPrint('No participant found for slot ${_winnerIndex! + 1}');
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error awarding prize: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    const Text(
                      "Buy a Slot",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Note: You can only buy a maximum of 5 slots.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: raffle.totalSlots,
                        itemBuilder: (context, index) {
                          final isAvailable = raffle.participants == null ||
                              !raffle.participants!.any((participant) => participant['slot'] == index + 1);

                          return GestureDetector(
                            onTap: isAvailable
                                ? () async {
                                    EasyLoading.show(status: 'Booking slot...');
                                    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
                                    if (userId == null) {
                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('You must be logged in to book a slot.')),
                                      );
                                      return;
                                    }
                                    try {
                                      // Fetch the raffle document
                                      final raffleQuerySnapshot = await FirebaseFirestore.instance
                                          .collection('raffles')
                                          .where('raffleId', isEqualTo: widget.raffleId)
                                          .get();

                                      if (raffleQuerySnapshot.docs.isEmpty) {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Raffle not found.')),
                                        );
                                        return;
                                      }

                                      final raffleDoc = raffleQuerySnapshot.docs.first.reference;
                                      final raffleData = raffleQuerySnapshot.docs.first.data();
                                      final participants =
                                          List<Map<String, dynamic>>.from(raffleData['participants'] ?? []);

                                      // Check how many slots the user already has in this raffle
                                      final userSlots =
                                          participants.where((participant) => participant['userId'] == userId).length;

                                      if (userSlots >= 5) {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('You can only book a maximum of 5 slots in this raffle.')),
                                        );
                                        return;
                                      }

                                      // Fetch user document to check current raffleCoins
                                      final userDoc =
                                          await FirebaseFirestore.instance.collection('users').doc(userId).get();

                                      if (!userDoc.exists) {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('User data not found.')),
                                        );
                                        return;
                                      }

                                      final userCoins = userDoc.data()?['raffleCoins'] ?? 0;
                                      final raffleSnapshot = await raffleDoc.get();
                                      final betAmount = raffleSnapshot.data()?['betAmount'] ?? 0;


                                      if (userCoins < betAmount) {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Not enough raffleCoins to book this slot.')),
                                        );
                                        return;
                                      }

                                      // Perform transaction to book the slot
                                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                                        final raffleSnapshot = await transaction.get(raffleDoc);
                                        final availableSlots = raffleSnapshot['availableSlots'] as int;
                                        final participants =
                                            List<Map<String, dynamic>>.from(raffleSnapshot['participants'] ?? []);

                                        // Check if slot is already booked
                                        if (participants.any((p) => p['slot'] == index + 1)) {
                                          throw Exception('Slot already booked.');
                                        }

                                        if (availableSlots > 0) {
                                          participants.add({'slot': index + 1, 'userId': userId});

                                          // Deduct raffleCoins from the user
                                          transaction
                                              .update(FirebaseFirestore.instance.collection('users').doc(userId), {
                                            'raffleCoins': FieldValue.increment(-betAmount),
                                          });

                                          // Update the raffle slots
                                          transaction.update(raffleDoc, {
                                            'availableSlots': availableSlots - 1,
                                            'participants': participants,
                                          });
                                        } else {
                                          throw Exception('No slots available.');
                                        }
                                      });

                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar() // Dismiss the current SnackBar if any
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text('Slot ${index + 1} booked successfully!'),
                                            duration: const Duration(seconds: 2), // Adjust duration as needed
                                          ),
                                        );
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to book slot: $e')),
                                      );
                                    }
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.grey[700] : Colors.green[400],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (index + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              error: (message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedTambiolo extends StatefulWidget {
  final int totalSlots;
  final ValueChanged<int> winnerCallback;
  final bool isStartTambiolo;
  final String raffleId;

  const AnimatedTambiolo({
    super.key,
    required this.totalSlots,
    required this.winnerCallback,
    required this.isStartTambiolo,
    required this.raffleId,
  });

  @override
  State<AnimatedTambiolo> createState() => _AnimatedTambioloState();
}

class _AnimatedTambioloState extends State<AnimatedTambiolo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  final List<int> _numbers = [];
  int _currentNumber = 0; // Starting point is 0
  int _numberOfDigits = 1; // Default to 1 digit
  bool _isDrawing = false; // Tracks if the tambiolo has started
  final Random _random = Random();
  Timer? _tambioloTimer;

  @override
  void initState() {
    super.initState();
    _calculateNumberOfDigits(); // Calculate the number of digits
    _initializeNumbers();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start tambiolo if isStartTambiolo is initially true
    if (widget.isStartTambiolo) {
      _startTambiolo();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTambiolo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if isStartTambiolo changed from false to true
    if (!oldWidget.isStartTambiolo && widget.isStartTambiolo) {
      _startTambiolo();
    }
  }

  void _calculateNumberOfDigits() {
    // Calculate the number of digits in the total slots
    _numberOfDigits = widget.totalSlots.toString().length;
  }

  void _initializeNumbers() {
    _numbers.clear();
    for (int i = 1; i <= widget.totalSlots; i++) {
      _numbers.add(i);
    }
    _numbers.shuffle();
  }

  void _startTambiolo() {
    setState(() {
      _isDrawing = true; // Tambiolo has started
    });

    _tambioloTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentNumber = _numbers[_random.nextInt(widget.totalSlots)];
      });
    });

    Future.delayed(const Duration(seconds: 15), () {
      _tambioloTimer?.cancel();
      _pickWinner();
    });
  }

  void _pickWinner() async {
    _controller.forward().then((_) async {
      final winnerSlot = _currentNumber;

      try {
        // Fetch the raffle document dynamically
        final raffleQuerySnapshot = await FirebaseFirestore.instance
            .collection('raffles')
            .where('raffleId', isEqualTo: widget.raffleId)
            .get();

        if (raffleQuerySnapshot.docs.isNotEmpty) {
          final raffleDoc = raffleQuerySnapshot.docs.first;
          final participants = List<Map<String, dynamic>>.from(
            raffleDoc['participants'] ?? [],
          );

          // Find the winner by slot
          final Map<String, dynamic>? winner = participants.firstWhere(
                (participant) => participant['slot'] == winnerSlot,
            orElse: () => {},
          );

          if (winner != null && winner.isNotEmpty) {
            final winnerId = winner['userId'];

            // Fetch winner's user document
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(winnerId)
                .get();

            if (userDoc.exists) {
              // Fetch the prize amount dynamically
              final prizeAmount = raffleDoc['winningAmount'] ?? 0;

              // Add prize amount to winner's raffleCoins
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(winnerId)
                  .update({
                'raffleCoins': FieldValue.increment(prizeAmount),
              });

              // Save to raffle_history
              await FirebaseFirestore.instance.collection('raffle_history').add({
                'slotNumber': winnerSlot, // Save the winning slot number
                'winnerId': winnerId, // Winner's user ID
                'prizeAmount': prizeAmount, // Prize amount
                'timestamp': FieldValue.serverTimestamp(), // Timestamp of the event
              });

              // Show dialog to notify the winner
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text(
                      "🎉 We Have a Winner! 🎉",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Winning Slot: Slot $winnerSlot",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Congratulations! $prizeAmount coins have been added to your account.",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _isDrawing = false; // Tambiolo has finished
                          });
                        },
                        child: const Text("OK"),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Error awarding prize: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error awarding prize: $e")),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tambioloTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[850],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentNumber.toString().padLeft(_numberOfDigits, '0'), // Format dynamically
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isDrawing) // Show only if tambiolo has started
          const Text(
            "Drawing the winner...",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
      ],
    );
  }
}
