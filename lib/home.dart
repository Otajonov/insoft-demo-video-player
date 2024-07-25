import 'package:flutter/material.dart';
import 'package:insoft/player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Demo"),
      ),

      body: ListView(
        children: [

          ListTile(
            title: const Text("Code With Otajonov (Asset)"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerPage()),
              );
            },
          ),

          ListTile(
            title: const Text("Onlayn demo (Onlayn)"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerPage(isOnline: true)),
              );
            },
          ),

        ],
      ),

    );
  }
}
