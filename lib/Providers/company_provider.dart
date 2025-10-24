import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/company.dart';
import '../Services/company_service.dart';

class CompanyListNotifier extends StateNotifier<List<Company>> {
  CompanyListNotifier() : super([]);

  final _service = CompanyService();

  Future<void> fetchCompanies() async {
    state = await _service.getAllCompanies();
  }

  void addCompany(Company company) {
    state = [...state, company];
  }

  void updateCompany(Company updated) {
    state = [
      for (final c in state) if (c.id == updated.id) updated else c,
    ];
  }

  Future<void> deleteCompany(int id) async {
    await _service.deleteCompany(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final companyListProvider =
StateNotifierProvider<CompanyListNotifier, List<Company>>(
        (ref) => CompanyListNotifier());
