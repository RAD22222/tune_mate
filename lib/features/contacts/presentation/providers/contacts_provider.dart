// FILE: lib/features/contacts/presentation/providers/contacts_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../services/supabase/contact_service.dart';

part 'contacts_provider.g.dart';

@riverpod
class ContactsList extends _$ContactsList {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return ContactService().getContacts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ContactService().getContacts());
  }
}

@riverpod
class IncomingRequestsList extends _$IncomingRequestsList {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return ContactService().getIncomingRequests();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ContactService().getIncomingRequests());
  }

  Future<void> accept(String requestId) async {
    await ContactService().acceptConnectionRequest(requestId);
    ref.invalidateSelf();
    // Invalidate the contacts list so it fetches the newly added contact
    ref.invalidate(contactsListProvider);
  }

  Future<void> decline(String requestId) async {
    await ContactService().declineConnectionRequest(requestId);
    ref.invalidateSelf();
  }
}
