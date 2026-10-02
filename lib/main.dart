import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AguaApp());

class AguaApp extends StatelessWidget {
  const AguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AguaApp',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087EA4)),
        scaffoldBackgroundColor: const Color(0xFFF4F9FB),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 45),
                Container(
                  width: 105, height: 105,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF5FB),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.water_drop_rounded,
                      size: 62, color: Color(0xFF087EA4)),
                ),
                const SizedBox(height: 25),
                const Text('AguaApp',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Agua cuando la necesites.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
                const SizedBox(height: 55),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Soy cliente'),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen(role: 'Cliente'))),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Soy chofer'),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen(role: 'Chofer'))),
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Ya tengo una cuenta · Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final user = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();
  final cedula = TextEditingController();
  final address = TextEditingController();

  Future<void> register() async {
    if ([user, pass, name, cedula, address].any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')));
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setString('user', user.text.trim());
    await p.setString('pass', pass.text);
    await p.setString('name', name.text.trim());
    await p.setString('cedula', cedula.text.trim());
    await p.setString('address', address.text.trim());
    await p.setString('role', widget.role);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => HomeScreen(role: widget.role, name: name.text.trim())),
      (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear cuenta · ${widget.role}')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text('Datos de ${widget.role.toLowerCase()}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          field(user, 'Usuario', Icons.person_outline),
          field(pass, 'Contraseña', Icons.lock_outline, obscure: true),
          field(name, 'Nombre y Apellido', Icons.badge_outlined),
          field(cedula, 'Cédula', Icons.credit_card_outlined),
          field(address, 'Dirección', Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 14),
          SizedBox(height: 54, child: FilledButton(
            onPressed: register, child: const Text('CREAR CUENTA'))),
        ],
      ),
    );
  }

  Widget field(TextEditingController c, String label, IconData icon,
      {bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c, obscureText: obscure, maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true, fillColor: Colors.white),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final user = TextEditingController();
  final pass = TextEditingController();

  Future<void> login() async {
    final p = await SharedPreferences.getInstance();
    if (user.text == p.getString('user') && pass.text == p.getString('pass')) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => HomeScreen(
          role: p.getString('role') ?? 'Cliente',
          name: p.getString('name') ?? 'Usuario')), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos.')));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        const SizedBox(height: 25),
        TextField(controller: user, decoration: const InputDecoration(
          labelText: 'Usuario', prefixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder())),
        const SizedBox(height: 15),
        TextField(controller: pass, obscureText: true, decoration: const InputDecoration(
          labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline),
          border: OutlineInputBorder())),
        const SizedBox(height: 22),
        SizedBox(height: 54, child: FilledButton(
          onPressed: login, child: const Text('ENTRAR'))),
      ]),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String role, name;
  const HomeScreen({super.key, required this.role, required this.name});

  @override
  Widget build(BuildContext context) {
    final driver = role == 'Chofer';
    return Scaffold(
      appBar: AppBar(
        title: Text(driver ? 'Panel del Chofer' : 'Panel del Cliente'),
        actions: [IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () => Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false),
          icon: const Icon(Icons.logout))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hola, $name 👋', style: const TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(driver
              ? 'En V0.1 podrás configurar tu disponibilidad y recibir solicitudes.'
              : 'En V0.1 podrás preparar tu primera solicitud de agua.',
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(driver ? Icons.local_shipping : Icons.water_drop,
                    size: 44, color: const Color(0xFF087EA4)),
                const SizedBox(height: 12),
                Text(driver ? 'Modo Chofer' : 'Solicitar agua',
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(driver
                    ? 'La conexión con solicitudes reales y GPS será añadida en las siguientes versiones.'
                    : 'El sistema de pedidos, cantidades, asignación y seguimiento GPS será añadido en las siguientes versiones.'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
