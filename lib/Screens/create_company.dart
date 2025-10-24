import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/company.dart';
import '../Providers/company_provider.dart';
import '../Services/company_service.dart';

class CreateCompany extends ConsumerStatefulWidget {
  const CreateCompany({super.key});

  @override
  ConsumerState<CreateCompany> createState() => _CreateCompanyState();
}

class _CreateCompanyState extends ConsumerState<CreateCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Company")),
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter company name";
                    final alphanumeric = RegExp(r'^[a-zA-Z0-9 .-]+$');
                    if (!alphanumeric.hasMatch(value)) {
                      return "Company name must be alphanumeric";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: "Company Name",
                      hintText: "Enter the company name",
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _phoneController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter phone number";
                    final phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{7,20}$');
                    if (!phoneRegExp.hasMatch(value)) {
                      return "Please enter a valid phone number";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter the phone number",
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _addressController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter address";
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: "Address",
                      hintText: "Enter the address",
                      border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    final newCompany = Company(
                      companyName: _nameController.text,
                      phoneNumber: _phoneController.text,
                      companyAddress: _addressController.text,
                      companyLogo: "https://logo.clearbit.com/godaddy.com",
                    );

                    await CompanyService().createCompany(newCompany);

                    ref.read(companyListProvider.notifier).addCompany(newCompany);

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Company Added Successfully")));

                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Submit"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
