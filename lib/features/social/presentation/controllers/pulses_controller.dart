import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pulse.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PulsesState {
  final bool isLoading;
  final List<Pulse> pulses;
  final String? gymFilterId;

  PulsesState({this.isLoading = true, this.pulses = const [], this.gymFilterId});

  PulsesState copyWith({bool? isLoading, List<Pulse>? pulses, String? gymFilterId}) {
    return PulsesState(
      isLoading: isLoading ?? this.isLoading,
      pulses: pulses ?? this.pulses,
      gymFilterId: gymFilterId ?? this.gymFilterId,
    );
  }
}

class PulsesController extends StateNotifier<PulsesState> {
  final SocialRepository _repository;
  final SupabaseClient _supabase;

  PulsesController(this._repository, this._supabase) : super(PulsesState()) {
    loadPulses();
  }

  Future<void> loadPulses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final pulses = await _repository.getPulses(userId, gymIdFilter: state.gymFilterId);
      state = state.copyWith(isLoading: false, pulses: pulses);
    } catch (e) {
      state = state.copyWith(isLoading: false, pulses: []);
    }
  }

  void toggleGymFilter(String? gymId) {
    if (state.gymFilterId == gymId) {
      state = state.copyWith(gymFilterId: null); // Toggle off
    } else {
      state = state.copyWith(gymFilterId: gymId);
    }
    loadPulses();
  }
}

final pulsesControllerProvider = StateNotifierProvider<PulsesController, PulsesState>((ref) {
  return PulsesController(
    ref.watch(socialRepositoryProvider),
    Supabase.instance.client,
  );
});
