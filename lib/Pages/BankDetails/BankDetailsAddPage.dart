import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Model/BankDetailsModel.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';

class AddBankDetailsPage extends StatefulWidget {

  final BankDetails? bankDetails;
  const AddBankDetailsPage({Key? key, this.bankDetails}) : super(key: key);

  @override
  State<AddBankDetailsPage> createState() => _AddBankDetailsPageState();
}

class _AddBankDetailsPageState extends State<AddBankDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isUpdating = false;

  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.bankDetails != null) {

      _accountNameController.text = widget.bankDetails!.accountName;
      _accountNumberController.text = widget.bankDetails!.accountNumber;
      _bankNameController.text = widget.bankDetails!.bankName;
      _ifscCodeController.text = widget.bankDetails!.ifscCode;
      isUpdating = true;
    }
  }

  Future<void> saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    Map<String, String> data = {
      'bankDetailsAccountName': _accountNameController.text,
      'bankDetailsAccountNumber': _accountNumberController.text,
      'bankDetailsBankName': _bankNameController.text,
      'bankDetailsIfscCode': _ifscCodeController.text,
    };

    try {
      final response = await NetworkUtil.post(NetworkUtil.BANK_DETAILS_ADD_URL, body: data);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['success'] == true) {
          AppUtil.showToast(context, result['data']['message']);
          Navigator.pop(context, true); // Return true to refresh BankDetailsPage
        } else {
          AppUtil.showToast(context, result['data']['message']);
        }
      } else {
        AppUtil.showToast(context, "Something went wrong. Please try again.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error: $e");
      AppUtil.showToast(context, "Failed to connect to server.");
    }
  }

  InputDecoration customInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isUpdating ? "Update Bank Details" : "Add Bank Details"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: customInputDecoration("Account Name", Icons.account_box),
                validator: (value) => value!.isEmpty ? "Account Name is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _accountNumberController,
                decoration: customInputDecoration("Account Number", Icons.numbers),
                validator: (value) => value!.isEmpty ? "Account Number is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bankNameController,
                decoration: customInputDecoration("Bank Name", Icons.account_balance),
                validator: (value) => value!.isEmpty ? "Bank Name is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ifscCodeController,
                decoration: customInputDecoration("IFSC Code", Icons.code),
                validator: (value) => value!.isEmpty ? "IFSC Code is required" : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveBankDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                    isUpdating ? "Update" : "Submit",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
