import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/task_model.dart';

class ExportService {
  static Future<void> exportToCSV(List<Task> tasks) async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Title", "Description", "Due Date", "Completed", "Repeat"]);

    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description,
        task.dueDate.toIso8601String(),
        task.isCompleted ? "Yes" : "No",
        task.repeatType.name,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/tasks.csv";
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Exported Tasks CSV');
  }

  static Future<void> exportToPDF(List<Task> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Task Management Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Title', 'Due Date', 'Status'],
                  ...tasks.map((task) => [
                        task.title,
                        task.dueDate.toString().split(' ')[0],
                        task.isCompleted ? 'Completed' : 'Pending'
                      ])
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/tasks.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'Exported Tasks PDF');
  }
}
