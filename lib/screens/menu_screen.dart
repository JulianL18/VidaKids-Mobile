import 'package:flutter/material.dart';
import 'package:vida_kids/main.dart';
import 'package:vida_kids/screens/listar_donacion.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vida Kids',
          style: TextStyle(color: Colors.black, fontSize: 30),
        ),
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
        leading: Image.asset(
          'assets/images/vidakids-logo.png',
          width: 40,
          height: 40,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Donaciones', style: TextStyle(fontSize: 20)),
            subtitle: const Text(
              'Ayuda a los niños de la fundación Vida Kids',
              style: TextStyle(color: Colors.grey),
            ),
            leading: const Icon(
              Icons.assignment,
              color: Color.fromRGBO(143, 148, 251, 1),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => const ListarScreen(),
              );
              Navigator.push(context, route);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.grey,
        child: const Center(
          child: Text(
            'Autor: Julián Lopera',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
