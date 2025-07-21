import 'package:flutter/material.dart';
import 'package:expense_monitoring_v1/api_service.dart';
import 'package:expense_monitoring_v1/userManagement/login_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  ApiService apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String phoneNumber = '';
  String address = '';
  String pqAnswer = '';
  String? selectedPQId;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordMatching = true;
  bool _isLoading = false;

  List<Map<String, dynamic>> questions = [];

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confirmPasswordController.addListener(_checkPasswordMatch);
    _loadQuestions(); 
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      _isPasswordMatching = _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final fetchedQuestions = await apiService.getQuestions();
      setState(() {
        questions = fetchedQuestions;
        selectedPQId = questions.isNotEmpty ? questions.first['pqId'] : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading security questions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Daftar Akun Baru',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Nama Pengguna',
                    onSaved: (value) => userName = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Silakan masukan Nama Pengguna' : null,
                  ),
                  SizedBox(height: 12),
                  _buildPasswordField(),
                  SizedBox(height: 12),
                  _buildConfirmPasswordField(),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: 'Nomor Telepon',
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => phoneNumber = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Silakan masukan Nomor Telepon' : null,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: 'Alamat tinggal',
                    maxLines: 3,
                    onSaved: (value) => address = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Silakan masukan Alamat tinggal Anda' : null,
                  ),
                  SizedBox(height: 12),
                  _buildPQDropdown(),
                  SizedBox(height: 12),
                  _buildPQAnswerField(),
                  SizedBox(height: 20),
                  _buildSubmitButton(),
                  SizedBox(height: 12),
                  _buildLoginPrompt(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Kata Sandi',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) =>
          value!.isEmpty ? 'Silahkan masukan kata sandi Anda' : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Kata Sandi',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isConfirmPasswordVisible,
      validator: (value) {
        if (value!.isEmpty) return 'Silahkan konfirmasi kata sandi Anda';
        if (!_isPasswordMatching) return 'Kata sandi tidak cocok';
        return null;
      },
    );
  }

  Widget _buildPQDropdown() {
    return Container(
      width: double.infinity, // Lebar penuh
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Menambah padding agar lebih lega
      child: DropdownButtonFormField<String>(
        isExpanded: true, // Menghindari teks terpotong
        value: selectedPQId,
        decoration: InputDecoration(
          labelText: 'Pilih Pertanyaan Keamanan',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Tinggi field diperbesar
        ),
        items: questions.map((question) {
          return DropdownMenuItem<String>(
            value: question['pqId'], // Pastikan ini tipe String
            child: Text(
              question['pqQuestion'] ?? '',
              style: TextStyle(fontSize: 14),
              maxLines: 2, // Mengizinkan teks multi-baris
              overflow: TextOverflow.ellipsis, // Tambahkan elipsis jika teks terlalu panjang
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPQId = value!;
          });
        },
        validator: (value) =>
        value == null ? 'Silakan pilih pertanyaan keamanan' : null,
      ),
    );
  }




  Widget _buildPQAnswerField() {
    return _buildTextField(
                    label: 'Jawaban Anda',
                    maxLines: 3,
                    onSaved: (value) => pqAnswer = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Silakan masukkan jawaban Anda' : null,
                  );
  }

  Widget _buildSubmitButton() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _register,
            child: Center(
              child: Text(
                'Daftar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
  }
  
  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah memiliki akun?',
          style: TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text(
            'Masuk',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await apiService.registerUser(
          action: "registerUser",
          dateTime: DateTime.now().toIso8601String(),
          userName: userName,
          userPasswd: _passwordController.text,
          phoneNumber: phoneNumber,
          address: address,
          pqId: selectedPQId!,
          pqAnswer: pqAnswer,
        );

        if (response['status'] == 'SUCCESS') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Pendaftaran Berhasil'),
                content: Text('Akun Anda telah berhasil dibuat.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal mendaftar')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
