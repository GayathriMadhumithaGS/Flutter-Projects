import 'package:flutter/material.dart';
import 'package:flutter_projects/Models/company.dart';
import 'package:flutter_projects/Services/company_service.dart';

class UpdateCompany extends StatefulWidget {
  final Company? company;
  const UpdateCompany({super.key, this.company});

  @override
  State<UpdateCompany> createState() => _UpdateCompanyState();
}

class _UpdateCompanyState extends State<UpdateCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  @override
  void initState() {
    if(widget.company != null){
      _nameController.text = widget.company!.companyName!;
      _phoneController.text = widget.company!.phoneNumber!;
      _addressController.text = widget.company!.companyAddress!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Company"),
      ),
      body: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Please enter company name";
                      }
                      final alphanumeric = RegExp(r'^[a-zA-Z0-9 .-]+$');
                      if (!alphanumeric.hasMatch(value)) {
                        return "Company name must be alphanumeric";
                      }
                      return null;
                    },
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: "Company Name",
                        hintText: "Enter the company name",
                        border: OutlineInputBorder()
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Please enter phone number";
                      }
                      final phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{7,20}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return "Please enter a valid phone number";
                      }
                      return null;
                    },
                    controller: _phoneController,
                    decoration: InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Enter the phone number",
                        border: OutlineInputBorder()
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Please enter address";
                      }
                      return null;
                    },
                    controller: _addressController,
                    decoration: InputDecoration(
                        labelText: "Address",
                        hintText: "Enter the address",
                        border: OutlineInputBorder()
                    ),
                  ),
                ),

                ElevatedButton(onPressed: () async{
                  if(_key.currentState!.validate()){
                    Company company = Company(
                        companyName: _nameController.text,
                        phoneNumber: _phoneController.text,
                        companyAddress: _addressController.text,
                        companyLogo: "https://logo.clearbit.com/godaddy.com"
                    );

                    if(widget.company != null){
                      await CompanyService().updateCompany(company, widget.company!.id!);
                    }
                    else{
                      await CompanyService().createCompany(company);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Company Updated Successfully")));
                    Navigator.pop(context, true);
                  }
                }, child: Text("Submit"))
              ],
            ),
          )),
    );
  }
}
