import 'package:flutter/material.dart';
import '../api_service.dart';
import '../userManagement/login_page.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Pengguna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF007BFF),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Profil',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            // Display user information
            _buildProfileInfo('Nama Pengguna', userData['userName']),
            Divider(color: Colors.grey.shade300, thickness: 1.5),
            _buildProfileInfo('Nomor Telepon', userData['phoneNumber']),
            Divider(color: Colors.grey.shade300, thickness: 1.5),
            _buildProfileInfo('Alamat Tinggal', userData['address']),
            Divider(color: Colors.grey.shade300, thickness: 1.5),
            _buildProfileInfo('Pertanyaan Personal', userData['pqQuestion']),
            Divider(color: Colors.grey.shade300, thickness: 1.5),
            _buildProfileInfo('Jawaban Personal', userData['pqAnswer']),
            Spacer(),
            // Update Profile Button
            ElevatedButton.icon(
              onPressed: () {
                // Implement Update Profile Navigation
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text(
                'Perbarui Profil',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF28A745), // Green color for update button
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await ApiService().logoutUser(); // Call logout method
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                'Keluar',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDC3545), // Red color for logout button
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column with fixed width to ensure alignment
          SizedBox(
            width: 180, // Adjust width as necessary for longest label
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          // Value column with flexible space
          Expanded(
            child: Text(
              value ?? 'Tidak tersedia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
