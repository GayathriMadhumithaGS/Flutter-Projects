import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/company.dart';
import '../Providers/company_provider.dart';
import '../Screens/create_company.dart';
import '../Screens/update_company.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final int _chunkSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // fetch initial companies
    Future.microtask(
          () => ref.read(companyListProvider.notifier).fetchCompanies(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final totalCompanies = ref.read(companyListProvider).length;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore &&
        totalCompanies >= _chunkSize) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    // Simulate network delay for loader effect
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshCompanies() async {
    await ref.read(companyListProvider.notifier).fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companyListProvider);
    final double itemHeight = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      appBar: AppBar(title: const Text("Company"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CreateCompany()));
          if (result == true) _refreshCompanies();
        },
        child: const Icon(Icons.add),
      ),
      body: companies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshCompanies,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: companies.length + 1, // extra item for loader
          itemBuilder: (context, index) {
            if (index == companies.length) {
              return _isLoadingMore
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator()),
                ),
              )
                  : const SizedBox.shrink();
            }

            final company = companies[index];
            return _buildCompanyItem(company, itemHeight);
          },
        ),
      ),
    );
  }

  Widget _buildCompanyItem(Company company, double itemHeight) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: itemHeight,
        child: Material(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                // Logo
                CircleAvatar(
                  radius: itemHeight / 4,
                  backgroundImage: CachedNetworkImageProvider(
                    company.companyLogo ?? "https://logo.clearbit.com/google.ru",
                  ),
                ),
                const SizedBox(width: 8),
                // Company info
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName ?? "Company name unavailable",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        company.companyAddress ?? "Address unavailable",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        company.phoneNumber ?? "Phone number unavailable",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Actions
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UpdateCompany(company: company)));
                          if (result == true) _refreshCompanies();
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Are you sure you want to delete the company?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog without deleting
                                    },
                                    child: const Text("No"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Execute deletion
                                      await ref
                                          .read(companyListProvider.notifier)
                                          .deleteCompany(company.id!);
                                      Navigator.pop(context); // Close the dialog after deletion
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
