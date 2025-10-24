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
  bool _isCardView = true;
  final int _chunkSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

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
      appBar: AppBar(
        title: const Text("Company"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isCardView ? Icons.list : Icons.grid_view),
            tooltip: _isCardView ? "Switch to List View" : "Switch to Card View",
            onPressed: () {
              setState(() {
                _isCardView = !_isCardView;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCompany()),
          );
          if (result == true) _refreshCompanies();
        },
        child: const Icon(Icons.add),
      ),
      body: companies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshCompanies,
        child: ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: companies.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == companies.length) {
              if (_isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      "No more companies available",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                );
              }
            }

            final company = companies[index];
            return _isCardView
                ? _buildCardCompanyItem(company, itemHeight)
                : _buildListCompanyItem(company);
          },
        ),
      ),
    );
  }

  Widget _buildCardCompanyItem(Company company, double itemHeight) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: itemHeight,
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: _buildCompanyRow(company, itemHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildListCompanyItem(Company company) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          company.companyLogo ?? "https://logo.clearbit.com/google.ru",
        ),
      ),
      title: Text(company.companyName ?? "Company name unavailable"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(company.companyAddress ?? "Address unavailable"),
          Text(company.phoneNumber ?? "Phone number unavailable")
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UpdateCompany(company: company)),
              );
              if (result == true) _refreshCompanies();
            },
            icon: const Icon(Icons.edit, color: Colors.blue),
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog(company);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyRow(Company company, double itemHeight) {
    return Row(
      children: [
        CircleAvatar(
          radius: itemHeight / 4,
          backgroundImage: CachedNetworkImageProvider(
            company.companyLogo ?? "https://logo.clearbit.com/google.ru",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.companyName ?? "Company name unavailable",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UpdateCompany(company: company)),
                  );
                  if (result == true) _refreshCompanies();
                },
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteDialog(company);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(Company company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete the company?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(companyListProvider.notifier).deleteCompany(company.id!);
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
