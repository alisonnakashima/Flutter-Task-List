import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();


  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _showCodeField = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32.0),
              Text(
                'Task List App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.appBarTheme.backgroundColor,
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Gerenciador de tarefas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Organize-se de forma eficiente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 16.0),
                      _buildPhoneAndSendButton(context),
                      if (_showCodeField) ...[
                        const SizedBox(height: 16.0),
                        _buildCodeVerificationField(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Nome",
        hintText: "Ex: Roberto de Souza",
      ),
      keyboardType: TextInputType.name,
      validator: (text) {
        if (text == null || text.isEmpty) return "Insira seu nome";
        return null;
      },
    );
  }

  Widget _buildPhoneAndSendButton(BuildContext context) {

    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: "Telefone",
              hintText: "Ex: +55 44 987654321",
            ),
            keyboardType: TextInputType.phone,
            validator: (text) {
              if (text == null || text.isEmpty || !text.startsWith("+55")) {
                return "Telefone inválido! (DDI + DDD + número)";
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.appBarTheme.backgroundColor),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              _sendVerificationCode();
            }
          },
          child: Text("Enviar SMS",
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeVerificationField(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: "Código de Verificação",
              hintText: "Insira o código recebido",
            ),
            keyboardType: TextInputType.number,
            validator: (text) {
              if (text == null || text.isEmpty) return "Nenhum código inserido.";
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.appBarTheme.backgroundColor),
          onPressed: _verifyCode,
          child: Text(
            "Verificar e \n acessar",
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendVerificationCode() async {
    final phoneNumber = _phoneController.text.trim();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle automatic verification
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: ${e.message}")),
          );
        },
        codeSent: (verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _showCodeField = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Código enviado via SMS")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },

      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar código: $e")),
      );
    }
  }

  void _verifyCode() {
    if (_formKey.currentState?.validate() == true) {
      // Lógica de verificação do código
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código verificado com sucesso!")),
      );
      _onSuccess();
    } else {
      _onFail();
    }
  }

  void _onSuccess() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TaskListScreen()),
    );
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Código incorreto!")),
    );
  }
}
