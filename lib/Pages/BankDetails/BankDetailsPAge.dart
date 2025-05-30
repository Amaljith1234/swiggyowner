import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Model/BankDetailsModel.dart';
import '../../Utils/Network_Utils.dart';
import 'BankDetailsAddPage.dart';

class BankDetailsPage extends StatefulWidget {
  @override
  _BankDetailsPageState createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  BankProfile? bankProfile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBankDetails();
  }

  Future<void> _fetchBankDetails() async {
    try {
      var response = await NetworkUtil.get(NetworkUtil.BANK_DETAILS_URL);
      debugPrint('Fetch Bank Data Status Code: ${response.statusCode}');
      debugPrint('Fetch Bank Data Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          bankProfile = BankDataResponse.fromJson(jsonData).bankProfile;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode} - ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bank Details"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem("Name", bankProfile!.name),
                      _buildDetailItem("Email", bankProfile!.email),
                      _buildDetailItem("Phone", bankProfile!.phone),
                      Divider(),
                      _buildDetailItem(
                          "Account Name", bankProfile!.bankDetails.accountName),
                      _buildDetailItem("Account Number",
                          bankProfile!.bankDetails.accountNumber),
                      _buildDetailItem(
                          "Bank Name", bankProfile!.bankDetails.bankName),
                      _buildDetailItem(
                          "IFSC Code", bankProfile!.bankDetails.ifscCode),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBankDetailsPage(
                  bankDetails: bankProfile?.bankDetails,
              ),
            ),
          );

          if (result == true) {
            _fetchBankDetails();
          }
        },
        child: Icon(Icons.edit), // Icon for edit
        backgroundColor: Colors.orange,
      )

    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}
