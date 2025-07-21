import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ReportDownloader extends StatefulWidget {
  final String userId;
  final String startDate;
  final String endDate;
  final String format;

  ReportDownloader({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.format,
  });

  @override
  _ReportDownloaderState createState() => _ReportDownloaderState();
}

class _ReportDownloaderState extends State<ReportDownloader> {
  // Fungsi untuk mengunduh file dari URL
  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      await Permission.storage.request();
      if (await Permission.storage.isGranted) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/$fileName';

        var response = await http.get(Uri.parse(fileUrl));

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Menggunakan context yang benar di dalam State
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File berhasil diunduh!")));
        OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Izin penyimpanan ditolak!")));
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan saat mengunduh file.")));
    }
  }

  // Fungsi untuk mengunduh CSV
  Future<void> downloadCSV(String csvData, String fileName) async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csvData);

      // Menggunakan context yang benar di dalam State
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File CSV berhasil diunduh!")));
      OpenFile.open(filePath);
    } catch (e) {
      print('Error saving CSV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan saat menyimpan file.")));
    }
  }

  // Fungsi untuk meminta data laporan dari API
  Future<void> fetchReport() async {
    final url = 'https://script.google.com/macros/s/AKfycbxW5v.../exec';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'action': 'generateReport',
        'userId': widget.userId,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'includeIncome': 'true',
        'includeExpense': 'true',
        'format': widget.format,
      },
    );

    if (response.statusCode == 200) {
      final result = response.body;
      final data = result.contains('csvData') ? result : null;

      if (data != null) {
        // Format CSV
        await downloadCSV(data, 'report.csv');
      } else {
        // Format Excel
        final fileUrl = result.contains('fileUrl') ? result : null;
        if (fileUrl != null) {
          await downloadFile(fileUrl, 'report.xlsx');
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengunduh laporan.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: fetchReport,
      child: Text('Unduh Laporan'),
    );
  }
}
