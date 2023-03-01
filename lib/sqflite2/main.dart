import 'package:flutter/material.dart';
import 'package:sqflite_storage2/sqflite2/sqlOperations.dart';

void main() {
  runApp(const MaterialApp(
    home: Sqflite2(),
  ));
}

class Sqflite2 extends StatefulWidget {
  const Sqflite2({Key? key}) : super(key: key);

  @override
  State<Sqflite2> createState() => _Sqflite2State();
}

class _Sqflite2State extends State<Sqflite2> {
  bool isloading = true;
  List<Map<String, dynamic>> datas = [];

  void refreshdata() async {
    final data = await SqlHelper.getItems();
    setState(() {
      datas = data;
      isloading = false;

    });
  }

  @override
  void initState() {
    refreshdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqfLite Demo"),
      ),
      body: isloading
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: datas.length,
              itemBuilder: (context, int) {
                return Card(
                  child: ListTile(
                    title: Text(datas[int]["title"]),
                    subtitle: Text(datas[int]["description"]),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: () => showform(datas[int]["id"]),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => deleteItem(datas[int]["id"]),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showform(null),
        child: const Text("add"),
      ),
    );
  }

  final title_controller = TextEditingController();
  final description_controller = TextEditingController();

  void showform(int? id) {
    if (id != null) {
      final existing_data = datas.firstWhere((element) => element['id'] == id);
      title_controller.text = existing_data["title"];
      description_controller.text = existing_data["description"];
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: title_controller,
              decoration: InputDecoration(hintText: "title"),
            ),
            TextField(
              controller: description_controller,
              decoration: InputDecoration(hintText: "description"),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await createItem();
                  }
                  if (id != null) {
                     await updateItem(id);
                  }
                  title_controller.text = "";
                  description_controller.text = "";
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? "create" : "update"))
          ],
        ),
      ),
    );
  }

  Future<void> createItem() async {
    await SqlHelper.create_item(
        title_controller.text, description_controller.text);
    refreshdata();
  }

  void deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    refreshdata();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Successfully deleted")));
  }

 Future<void> updateItem(int id) async{
    await SqlHelper.updateItem(id,title_controller.text,description_controller.text);
    refreshdata();
  }
}
