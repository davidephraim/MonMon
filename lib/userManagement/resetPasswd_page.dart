import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Untuk notifikasi sederhana
import 'package:expense_monitoring_v1/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final ApiService apiService = ApiService();
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep3 = GlobalKey<FormState>();

  String phoneNumber = '';
  String pqAnswer = '';
  String newPassword = '';
  String retypePassword = '';
  bool isLoading = false;
  String pqQuestion = '';
  String? pqId;
  bool isStep2 = false;
  bool isStep3 = false;
  bool isPQValidated = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: TextStyle(fontSize: 24)),

      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isStep2 && !isStep3) _buildStep1(),
              if (isStep2 && !isPQValidated) _buildStep2(),
              if (isStep3) _buildStep3(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Nomor Telepon Anda',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 20),
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              prefixIcon: Icon(Icons.phone, color: Colors.black),
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => phoneNumber = value!,
            validator: (value) => value!.isEmpty ? 'Masukkan nomor telepon Anda' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _validatePhoneNumber,
            child: Text('Lanjutkan', style: TextStyle (fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pqQuestion,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Jawaban Anda',
              prefixIcon: Icon(Icons.question_answer, color: Colors.black),
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => pqAnswer = value!,
            validator: (value) => value!.isEmpty ? 'Masukkan jawaban' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _verifyPQAnswer,
            child: Text('Lanjutkan', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Kata Sandi Baru',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Kata Sandi Baru',
              prefixIcon: Icon(Icons.lock, color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => newPassword = value,
            validator: (value) => value!.isEmpty ? 'Masukkan kata sandi baru' : null,
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Ketik Ulang Kata Sandi',
              prefixIcon: Icon(Icons.lock, color: Colors.black),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value != newPassword ? 'Kata sandi tidak cocok' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updatePassword,
            child: Text('Perbarui Kata Sandi', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _validatePhoneNumber() async {
    if (_formKeyStep1.currentState!.validate()) {
      _formKeyStep1.currentState!.save();
      setState(() => isLoading = true);
      try {
        final response = await apiService.verifyPhoneNumber(
          action: "verifyPhoneNumber",
          phoneNumber: phoneNumber,
        );
        if (response['status'] == 'SUCCESS') {
          setState(() {
            pqId = response['pqId'];
            pqQuestion = response['pqQuestion'];
            isStep2 = true;
          });
        } else {
          _showErrorSnackbar('Nomor telepon tidak ditemukan');
        }
      } catch (e) {
        _showErrorSnackbar('Terjadi kesalahan: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _verifyPQAnswer() async {
    if (_formKeyStep2.currentState!.validate()) {
      _formKeyStep2.currentState!.save();
      setState(() => isLoading = true);
      try {
        final response = await apiService.validatePQAnswer(
          action: "validatePQAnswer",
          phoneNumber: phoneNumber,
          pqId: pqId!,
          pqAnswer: pqAnswer,
        );
        if (response['status'] == 'SUCCESS') {
          setState(() {
            isPQValidated = true; // Tandai PQ sudah divalidasi
            isStep3 = true;
          });
        } else {
          _showErrorSnackbar('Jawaban pertanyaan pribadi salah');
        }
      } catch (e) {
        _showErrorSnackbar('Terjadi kesalahan: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _updatePassword() async {
    if (_formKeyStep3.currentState!.validate()) {
      _formKeyStep3.currentState!.save();
      setState(() => isLoading = true);
      try {
        final response = await apiService.changePassword(
          action: "changePassword",
          phoneNumber: phoneNumber,
          newPasswd: newPassword,
        );
        if (response['status'] == 'SUCCESS') {
          _showErrorSnackbar('Kata sandi berhasil diperbarui');
          Navigator.pop(context);
        } else {
          _showErrorSnackbar('Gagal memperbarui kata sandi');
        }
      } catch (e) {
        _showErrorSnackbar('Terjadi kesalahan: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }
}
