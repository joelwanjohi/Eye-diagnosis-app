import 'package:flutter/material.dart';
import 'package:opt_app/library/opt_app.dart';

class PatientDetailsScreen extends StatefulWidget {
  final List<String> complaints;
  final EyeForComplaint location;
  final List<String> ocularHealth;
  final List<String> medicalHealth;

  const PatientDetailsScreen({
    super.key,
    required this.complaints,
    required this.location,
    required this.ocularHealth,
    required this.medicalHealth,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppbar(
        hasLeading: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: PrimaryButton(
          text: "Next",
          isEnabled: _isFormValid,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPhotos(
                    complaints: widget.complaints,
                    location: widget.location,
                    ocularHealth: widget.ocularHealth,
                    medicalHealth: widget.medicalHealth,
                    patientName: _nameController.text.trim(),
                    patientPhone: _phoneController.text.trim(),
                    patientEmail: _emailController.text.trim(),
                  ),
                ),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient Details",
                style: AppTypography().xxlBold,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                "Please enter the patient's information before proceeding to add photos.",
                style: AppTypography().baseMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Patient Name",
                  hintText: "Enter patient's full name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter patient's name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter patient's phone number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter patient's phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "Enter patient's email address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter patient's email address";
                  }
                  // Simple email validation
                  if (!value.contains('@') || !value.contains('.')) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
