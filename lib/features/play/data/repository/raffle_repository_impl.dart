import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raffle_app/features/play/domain/entities/raffle.dart';
import 'package:raffle_app/features/play/domain/repositories/raffle_repository.dart';

class RaffleRepositoryImpl implements RaffleRepository {
  final FirebaseFirestore firestore;

  RaffleRepositoryImpl(this.firestore);

  @override
  Stream<Raffle> getRaffleStream(String raffleId) {
    return firestore
        .collection('raffles')
        .where('raffleId', isEqualTo: raffleId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Raffle(
          id: data['raffleId'],
          title: data['title'],
          totalSlots: data['totalSlots'],
          availableSlots: data['availableSlots'],
          participants: List<Map<String, dynamic>>.from(data['participants'] ?? []),
        );
      } else {
        throw Exception('Raffle not found');
      }
    });
  }

  @override
  Future<void> bookSlot(String raffleId, int slotNumber) async {
    final query = await firestore
        .collection('raffles')
        .where('raffleId', isEqualTo: raffleId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      final participants = List<Map<String, dynamic>>.from(data['participants'] ?? []);
      final availableSlots = data['availableSlots'];

      // Check if the slot is already booked
      if (participants.any((participant) => participant['slot'] == slotNumber)) {
        throw Exception('Slot $slotNumber is already booked.');
      }

      // Check if there are available slots
      if (availableSlots > 0) {
        // Add the slot as a map
        participants.add({'slot': slotNumber, 'userId': 'YOUR_USER_ID_HERE'});

        // Update Firestore with the new participants list and decrement available slots
        await doc.reference.update({
          'participants': participants,
          'availableSlots': availableSlots - 1,
        });
      } else {
        throw Exception('No slots available');
      }
    } else {
      throw Exception('Raffle not found');
    }
  }
}
