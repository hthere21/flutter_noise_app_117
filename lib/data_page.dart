import 'package:flutter/material.dart';
import 'package:flutter_noise_app_117/settings_page.dart';
import 'aws_service.dart'; // Import the AWS service file
import 'package:path_provider/path_provider.dart';
import 'local_storage.dart';
import 'dart:io';

// All rows of data to be shown. Keeps track of any additions of recordings
List<DataItem> data = [
  DataItem(1, "Item 1", []),
  DataItem(2, "Item 2", []),
  DataItem(3, "Item 3", []),
];

const List<DataColumn> COLUMNS = [
  DataColumn(
    label: Expanded(
      child: Text(
        'TimeStamp',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Average',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Minimum',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Maximum',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Latitude',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Longitude',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  )
];

class DataStoragePage extends StatefulWidget {
  @override
  _DataStoragePageState createState() => _DataStoragePageState();
}

class DataItem {
  final int id;
  String title;
  List<dynamic> data;

  DataItem(this.id, this.title, this.data);
}

class _DataStoragePageState extends State<DataStoragePage> {
  DataItem? selectedItem;
  String editedTitle = "";

  @override
  void initState() {
    super.initState();
  }

  void handleRowPress(DataItem item) {
    setState(() {
      selectedItem = item;
      editedTitle = item.title;
    });

    // Show a bottom sheet for editing
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: editedTitle),
                onChanged: (value) {
                  editedTitle = value;
                },
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: handleDelete,
                      child: const Text('Delete'), // Add Delete button
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: () {
                        try {
                          handleUpload();
                          _showUploadConfirmation(context);
                        } catch (e) {
                          print(e);
                          _showUploadFailure(context);
                        }
                      },
                      child: const Text('Upload'), // Add Upload button
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return handleView();
                          },
                        );
                      },
                      child: const Text('View'),
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: handleClosePopup,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _createTableRows(int index) {
    List<DataRow> rows = [];
    // for (DataItem item in data) {
    DataItem item = data[index];
    List<dynamic> itemData = item.data;
    for (Map<dynamic, dynamic> row in itemData) {
      DataRow dataRow = DataRow(cells: <DataCell>[
        DataCell(Text(row['timeStamp'].toString())),
        DataCell(Text(row['avg'].toString())),
        DataCell(Text(row['min'].toString())),
        DataCell(Text(row['max'].toString())),
        DataCell(Text(row['lat'].toString())),
        DataCell(Text(row['lon'].toString())),
      ]);
      rows.add(dataRow);
    }

    return rows;
  }

  // List<Map<String, dynamic>> _prepTableRows(int index) {
  //   List<Map<String, dynamic>> result = [];
  //   DataItem item = data[index];
  //   List<Map<String, dynamic>> input = item.data;

  //   input[0].forEach((key, value) {
  //     Map<String, dynamic> transposedRow = {key: value};
  //     for (int i = 1; i < input.length; i++) {
  //       transposedRow[input[i].keys.first] = input[i][key];
  //     }
  //     result.add(transposedRow);
  //   });
  //   return result;
  // }

  void handleClosePopup() {
    setState(() {
      selectedItem = null;
    });
  }

  void handleEditTitle() {
    if (selectedItem != null) {
      int selectedIndex =
          data.indexWhere((item) => item.id == selectedItem!.id);
      data[selectedIndex].title = editedTitle;
      handleClosePopup();
    }
  }

  AlertDialog handleView() {
    // if (selectedItem != null) {
    List<DataRow> rows = _createTableRows(selectedItem!.id - 1);
    // List<Map<String,dynamic>> transposedData = _prepTableRows(selectedItem!.id - 1);
    return AlertDialog(
      content: Container(
          width: 300.0,
          height: 400.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: COLUMNS, rows: rows)),
          )),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
      ],
    );
    // }
  }

  void handleDelete() {
    if (selectedItem != null) {
      data.removeWhere((item) => item.id == selectedItem!.id);
      handleClosePopup();
    }
  }

  void _showUploadConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Confirmed'),
          content: const Text('Successfully Uploaded!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the AlertDialog
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUploadFailure(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Failed'),
          content: const Text('Failed to upload... Try Again Later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the AlertDialog
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // void handleUpload() {
  //   // // Call the AWS service to handle the upload
  //   // final awsService = AwsService();
  //   // awsService.handleUpload(selectedItem);
  // }
  void handleUpload() async {
    final awsService = AwsS3Service();
    // Replace 'your/s3/bucket/key' and 'localFilePath' with your specific values
    // awsService.uploadIOFile('/Users/christian/Desktop/IMG_2193 copy.jpg');
    // awsService.uploadImage();
    String fileName = selectedItem!.title;
    File csvFile = await getLocalFile(fileName);
    awsService.uploadCSVFile(csvFile, studyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Storage Page'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            title: Text(item.title),
            onTap: () => handleRowPress(item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          data.add(DataItem(data.length + 1, "New Item", []));
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
