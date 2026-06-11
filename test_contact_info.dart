import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final supabaseService = SupabaseService();
  
  // Test 1: Get current user profile
  print('=== Test 1: Get Current User Profile ===');
  final user = await supabaseService.getCurrentUserProfile();
  print('User ID: ${user?.id}');
  print('User Email: ${user?.email}');
  print('User Phone: ${user?.phone}');
  
  // Test 2: Get contact info directly
  print('\n=== Test 2: Get Contact Info Directly ===');
  if (user != null) {
    final contactInfo = await supabaseService.getContactInfo(user.id);
    print('Contact Info: $contactInfo');
  }
  
  // Test 3: Update contact info
  print('\n=== Test 3: Update Contact Info ===');
  if (user != null) {
    try {
      await supabaseService.updateContactInfo(user.id, {
        'email': 'test@example.com',
        'phone': '1234567890',
      });
      print('Contact info updated successfully');
      
      // Verify update
      final updatedUser = await supabaseService.getCurrentUserProfile();
      print('Updated User Email: ${updatedUser?.email}');
      print('Updated User Phone: ${updatedUser?.phone}');
      
    } catch (e) {
      print('Error updating contact info: $e');
    }
  }
  
  // Test 4: Check if contact info exists in database
  print('\n=== Test 4: Check Database Directly ===');
  if (user != null) {
    try {
      final response = await supabaseService.getClient()
          .from('contact_info')
          .select()
          .eq('user_id', user.id);
      
      print('Database response: ${response.data}');
    } catch (e) {
      print('Error querying database: $e');
    }
  }
}