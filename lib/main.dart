import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'services/placement_data_service.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Instantly load locally persisted accounts and drives (works offline / instant launch)
  await PlacementDataService().loadFromLocalStorage();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization note: $e');
  }

  // 2. Sync with Supabase Cloud in background
  PlacementDataService().initSupabaseSync();

  runApp(const PlaceTrackApp());
}
