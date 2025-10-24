import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/company.dart';
import '../Services/company_service.dart';

class CompanyListNotifier extends StateNotifier<List<Company>> {
  CompanyListNotifier() : super([]);

  final _service = CompanyService();

  Future<void> fetchCompanies() async {
    print("Fetch");
    state = await _service.getAllCompanies();
  }

  void addCompany(Company company) {
    print("Add");
    state = [...state, company];
  }

  void updateCompany(Company updated) {
    print("Update");
    state = [
      for (final c in state) if (c.id == updated.id) updated else c,
    ];
  }

  Future<void> deleteCompany(int id) async {
    print("Delete");
    await _service.deleteCompany(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final companyListProvider =
StateNotifierProvider<CompanyListNotifier, List<Company>>(
        (ref) => CompanyListNotifier());
