import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_store.dart';
import 'cloud_login_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _companyFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _industryController = TextEditingController();
  final _locationController = TextEditingController(text: 'Main Stockroom');
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPinController = TextEditingController();
  final _adminPinConfirmController = TextEditingController();
  final _pageController = PageController();
  int _step = 0;
  String _locationType = 'Stockroom';
  bool _includeSampleData = kDebugMode;
  bool _isFinishing = false;

  @override
  void dispose() {
    _companyController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPinController.dispose();
    _adminPinConfirmController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _SetupStep(
              title: 'Issued',
              children: [
                const Text('Track tools, parts, supplies, and who has them.'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _next,
                  child: const Text('Get Started'),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Invited team members can sign in with their email account.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const CloudLoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_outlined),
                  label: const Text('Sign in with Account'),
                ),
              ],
            ),
            _SetupStep(
              title: 'Workspace',
              children: [
                Form(
                  key: _companyFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company or workspace name',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _industryController.text.isEmpty
                            ? null
                            : _industryController.text,
                        decoration: const InputDecoration(
                          labelText: 'Industry',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text('Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: 'Manufacturing',
                            child: Text('Manufacturing'),
                          ),
                          DropdownMenuItem(
                            value: 'Contractor',
                            child: Text('Contractor'),
                          ),
                          DropdownMenuItem(
                            value: 'Fleet',
                            child: Text('Fleet'),
                          ),
                          DropdownMenuItem(value: 'Farm', child: Text('Farm')),
                          DropdownMenuItem(
                            value: 'School/CTE',
                            child: Text('School/CTE'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          _industryController.text = value ?? '';
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _StepButtons(onBack: _back, onNext: _validateCompany),
              ],
            ),
            _SetupStep(
              title: 'First Location',
              children: [
                Form(
                  key: _locationFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location name',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _locationType,
                        decoration: const InputDecoration(
                          labelText: 'Location type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Stockroom',
                            child: Text('Stockroom'),
                          ),
                          DropdownMenuItem(
                            value: 'Tool Crib',
                            child: Text('Tool Crib'),
                          ),
                          DropdownMenuItem(
                            value: 'Warehouse',
                            child: Text('Warehouse'),
                          ),
                          DropdownMenuItem(
                            value: 'Truck',
                            child: Text('Truck'),
                          ),
                          DropdownMenuItem(
                            value: 'Job Box',
                            child: Text('Job Box'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _locationType = value ?? 'Stockroom';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _StepButtons(onBack: _back, onNext: _validateLocation),
              ],
            ),
            _SetupStep(
              title: 'Admin',
              children: [
                Form(
                  key: _adminFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _adminNameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin display name',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _adminEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email optional',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _adminPinController,
                        decoration: const InputDecoration(
                          labelText: 'PIN',
                          helperText: 'Use 4-8 digits for this shared device.',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: _pinValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _adminPinConfirmController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm PIN',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: _pinConfirmValidator,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Start with sample data'),
                        subtitle: const Text(
                          'Sample items help you explore the app. You can archive or replace them later.',
                        ),
                        value: _includeSampleData,
                        onChanged: (value) {
                          setState(() {
                            _includeSampleData = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isFinishing ? null : _back,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isFinishing ? null : _finish,
                        child: _isFinishing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Finish Setup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  void _validateCompany() {
    if (_companyFormKey.currentState!.validate()) {
      _next();
    }
  }

  void _validateLocation() {
    if (_locationFormKey.currentState!.validate()) {
      _next();
    }
  }

  void _next() {
    setState(() {
      _step += 1;
    });
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    setState(() {
      _step -= 1;
    });
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    if (!_adminFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isFinishing = true;
    });

    await AppStoreScope.of(context).completeSetup(
      companyName: _companyController.text,
      industry: _industryController.text,
      locationName: _locationController.text,
      locationType: _locationType,
      adminDisplayName: _adminNameController.text,
      adminEmail: _adminEmailController.text,
      adminPin: _adminPinController.text,
      includeSampleData: _includeSampleData,
    );
  }

  String? _pinValidator(String? value) {
    final pin = value?.trim() ?? '';
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) {
      return 'Enter a 4-8 digit PIN.';
    }
    return null;
  }

  String? _pinConfirmValidator(String? value) {
    final confirmation = value?.trim() ?? '';
    if (confirmation != _adminPinController.text.trim()) {
      return 'PINs do not match.';
    }
    return null;
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF17212F),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _StepButtons extends StatelessWidget {
  const _StepButtons({required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(onPressed: onNext, child: const Text('Next')),
        ),
      ],
    );
  }
}
