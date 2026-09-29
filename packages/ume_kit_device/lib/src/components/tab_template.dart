import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListTileItem {
  final String title;
  final String subtitle;
  final IconData? icon;

  const ListTileItem({
    required this.title,
    required this.subtitle,
    this.icon,
  });
}

abstract class TabTemplate extends StatelessWidget {
  const TabTemplate({super.key});

  Future<List<ListTileItem>> getItemList(); // 需要子类实现
  // static Tab get tab => Tab(text: 'Tab', icon: Icon(Icons.tab));
  static Tab createTab(String title, IconData icon) =>
      Tab(text: title, icon: Icon(icon));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListTileItem>>(
      future: getItemList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: item.title + ': ' + item.subtitle));
                  // Fluttertoast.showToast(msg: 'Copied to clipboard');
                },
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.copy),
              );
            },
          );
        } else {
          return const Center(child: Text('Loading...'));
        }
      },
    );
  }
}
