import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/user/profile_interface.dart';
import '../services/ProfileService.dart';
import '../services/QrService.dart';
import 'dart:convert';
import '../widgets/MessageDialog.dart';
import '../services/UserService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final fetchedProfile = await ProfileService.fetchProfile();

    setState(() {
      profile = fetchedProfile;
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Error cargando perfil')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 60,
                backgroundImage: profile!.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                backgroundColor: Colors.grey[400],
                child: profile!.photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                profile!.fullName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                profile!.phone ?? '',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoBox(
                      icon: Icons.male,
                      label: 'Género',
                      value: profile!.gender == 'M'
                          ? 'Masculino'
                          : profile!.gender == 'F'
                              ? 'Femenino'
                              : profile!.gender,
                    ),
                    _InfoBox(
                      icon: Icons.calendar_month,
                      label: 'Nacimiento',
                      value: profile!.birthDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _OptionItem(
                title: 'Subscripción',
                icon: Icons.credit_card,
                iconColor: Color(0xFF7012DA),
              ),
              const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    if (profile == null) return;
                    try {
                      final qrData = await ProfileService.fetchQrCode();
                      if (qrData != null && qrData.qr_image_base64 != null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Tu código QR'),
                            content: Image.memory(
                              base64Decode(
                                qrData.qr_image_base64.split(',').last,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo generar el QR')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generando QR: '
                              '${e.toString().replaceAll('Exception:', '').trim()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const _OptionItem(
                    title: 'QR',
                    icon: Icons.qr_code_2_rounded,
                    iconColor: Color(0xFF7012DA),
                  ),
                ),
                const SizedBox(height: 12),
                _ClearPreferencesButton(),
                const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _EditableField(label: 'Nombre completo', value: profile!.fullName),
                    const SizedBox(height: 12),
                    _EditableField(label: 'Contraseña', value: '********'),
                    const SizedBox(height: 12),
                    _EditableField(label: 'Teléfono', value: profile!.phone ?? ''),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color.fromRGBO(103, 58, 183, 1), size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const _OptionItem({required this.title, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon != null
                  ? Icon(icon, size: 24, color: iconColor ?? Colors.grey[600])
                  : Container(width: 24, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;

  const _EditableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          const Icon(Icons.edit_note_rounded, color: Color.fromRGBO(122, 90, 249, 1)        
          )],
      ),
    );
  }
}

class _ClearPreferencesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('first-init-app');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferencias borradas. Reinicia la app para ver el efecto.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_forever, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Borrar Preferencias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
