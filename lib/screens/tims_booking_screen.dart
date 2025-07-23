import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tims_provider.dart';
import '../providers/auth_provider.dart';
import '../models/tims_model.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class TimsBookingScreen extends StatefulWidget {
  final int trekId;
  final String trekkerArea;
  final String route;

  const TimsBookingScreen({
    super.key,
    required this.trekId,
    required this.trekkerArea,
    required this.route,
  });

  @override
  State<TimsBookingScreen> createState() => _TimsBookingScreenState();
}

class _TimsBookingScreenState extends State<TimsBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _passportController = TextEditingController();
  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedEntryDate;
  DateTime? _selectedExitDate;
  final _nepalContactNameController = TextEditingController();
  final _nepalOrganizationController = TextEditingController();
  final _nepalDesignationController = TextEditingController();
  final _nepalMobileController = TextEditingController();
  final _nepalOfficeController = TextEditingController();
  final _nepalAddressController = TextEditingController();
  final _homeContactNameController = TextEditingController();
  final _homeCityController = TextEditingController();
  final _homeMobileController = TextEditingController();
  final _homeOfficeController = TextEditingController();
  final _homeAddressController = TextEditingController();
  String? _selectedImageUrl;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalityController.dispose();
    _passportController.dispose();
    _nepalContactNameController.dispose();
    _nepalOrganizationController.dispose();
    _nepalDesignationController.dispose();
    _nepalMobileController.dispose();
    _nepalOfficeController.dispose();
    _nepalAddressController.dispose();
    _homeContactNameController.dispose();
    _homeCityController.dispose();
    _homeMobileController.dispose();
    _homeOfficeController.dispose();
    _homeAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: type == 'birth' ? DateTime(1900) : DateTime.now(),
      lastDate: type == 'birth' ? DateTime.now() : DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (type == 'birth') {
          _selectedDateOfBirth = picked;
        } else if (type == 'entry') {
          _selectedEntryDate = picked;
        } else if (type == 'exit') {
          _selectedExitDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Here you would typically upload the image to your server
      // For now, we'll just store the path
      setState(() {
        _selectedImageUrl = image.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateOfBirth == null || _selectedEntryDate == null || _selectedExitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all dates')),
      );
      return;
    }
    if (_selectedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book TIMS')),
      );
      return;
    }

    final booking = TimsBooking(
      trekId: widget.trekId,
      transactionId: 'TRX${DateTime.now().millisecondsSinceEpoch}',
      image: _selectedImageUrl!,
      fullName: _fullNameController.text,
      nationality: _nationalityController.text,
      passportNumber: _passportController.text,
      gender: _selectedGender,
      dateOfBirth: DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
      trekkerArea: widget.trekkerArea,
      route: widget.route,
      entryDate: DateFormat('yyyy-MM-dd').format(_selectedEntryDate!),
      exitDate: DateFormat('yyyy-MM-dd').format(_selectedExitDate!),
      nepalContactName: _nepalContactNameController.text,
      nepalOrganization: _nepalOrganizationController.text,
      nepalDesignation: _nepalDesignationController.text,
      nepalMobile: _nepalMobileController.text,
      nepalOfficeNumber: _nepalOfficeController.text,
      nepalAddress: _nepalAddressController.text,
      homeContactName: _homeContactNameController.text,
      homeCity: _homeCityController.text,
      homeMobile: _homeMobileController.text,
      homeOfficeNumber: _homeOfficeController.text,
      homeAddress: _homeAddressController.text,
      transitPassCost: '1500.00',
    );

    final success = await Provider.of<TimsProvider>(context, listen: false)
        .bookTims(booking, authProvider.token!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TIMS booked successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<TimsProvider>(context, listen: false).errorMessage ?? 
            'Failed to book TIMS'
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book TIMS Pass'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: Text(_selectedImageUrl == null ? 'Select Photo' : 'Change Photo'),
            ),
            if (_selectedImageUrl != null) ...[
              const SizedBox(height: 8),
              Text('Photo selected: ${_selectedImageUrl!.split('/').last}'),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter full name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalityController,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter nationality' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passportController,
              decoration: const InputDecoration(
                labelText: 'Passport Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter passport number' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: ['Male', 'Female', 'Other'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Date of Birth: ${_selectedDateOfBirth == null ? 'Not selected' : DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'birth'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Entry Date: ${_selectedEntryDate == null ? 'Not selected' : DateFormat('yyyy-MM-dd').format(_selectedEntryDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'entry'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Exit Date: ${_selectedExitDate == null ? 'Not selected' : DateFormat('yyyy-MM-dd').format(_selectedExitDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'exit'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nepal Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalContactNameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter contact name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalOrganizationController,
              decoration: const InputDecoration(
                labelText: 'Organization',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter organization' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalDesignationController,
              decoration: const InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter designation' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalMobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter mobile number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalOfficeController,
              decoration: const InputDecoration(
                labelText: 'Office Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter office number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nepalAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Home Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homeContactNameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter contact name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homeCityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homeMobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter mobile number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homeOfficeController,
              decoration: const InputDecoration(
                labelText: 'Office Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter office number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homeAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
            ),
            const SizedBox(height: 24),
            Consumer<TimsProvider>(
              builder: (context, timsProvider, child) {
                return ElevatedButton(
                  onPressed: timsProvider.isLoading ? null : _submitForm,
                  child: timsProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Book TIMS Pass'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
