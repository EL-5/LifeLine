import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';

class PaymentMethodModel {
  final String? id;
  final String userId;
  final String providerName;
  final String accountNumber;
  final String iconName;
  final String colorCode;
  final bool isDefault;

  PaymentMethodModel({
    this.id,
    required this.userId,
    required this.providerName,
    required this.accountNumber,
    this.iconName = 'phone_android',
    this.colorCode = '#FFC107',
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      providerName: json['provider_name'] as String,
      accountNumber: json['account_number'] as String,
      iconName: json['icon_name'] as String? ?? 'phone_android',
      colorCode: json['color_code'] as String? ?? '#FFC107',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'provider_name': providerName,
      'account_number': accountNumber,
      'icon_name': iconName,
      'color_code': colorCode,
      'is_default': isDefault,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

final paymentMethodsProvider = FutureProvider<List<PaymentMethodModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider).client;
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];

  final data = await supabase
      .from('payment_methods')
      .select()
      .eq('user_id', user.id)
      .order('is_default', ascending: false);
      
  return (data as List).map((json) => PaymentMethodModel.fromJson(json)).toList();
});

final addPaymentMethodProvider = Provider((ref) {
  final supabase = ref.read(supabaseServiceProvider).client;
  
  return (PaymentMethodModel method) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final data = method.toJson();
    data['user_id'] = user.id;

    if (method.isDefault) {
      // If setting as default, unset others first (handled by DB triggers or two queries)
      await supabase
          .from('payment_methods')
          .update({'is_default': false})
          .eq('user_id', user.id)
          .eq('is_default', true);
    }

    await supabase.from('payment_methods').insert(data);
    ref.invalidate(paymentMethodsProvider);
  };
});

final deletePaymentMethodProvider = Provider((ref) {
  final supabase = ref.read(supabaseServiceProvider).client;
  
  return (String id) async {
    await supabase.from('payment_methods').delete().eq('id', id);
    ref.invalidate(paymentMethodsProvider);
  };
});
