import 'package:flutter/material.dart';
import '../models/birth_details.dart';
import '../services/astrology_engine.dart';
import '../services/profile_service.dart';
import 'report_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();

  String _gender = 'Male';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Local lookup for major global cities with coordinates & timezones
  final List<Map<String, dynamic>> _citiesList = [
    {'name': 'New Delhi, India', 'lat': 28.6139, 'lng': 77.2090, 'tz': 5.5},
    {'name': 'Mumbai, India', 'lat': 19.0760, 'lng': 72.8777, 'tz': 5.5},
    {'name': 'Bengaluru, India', 'lat': 12.9716, 'lng': 77.5946, 'tz': 5.5},
    {'name': 'Kolkata, India', 'lat': 22.5726, 'lng': 88.3639, 'tz': 5.5},
    {'name': 'London, UK', 'lat': 51.5074, 'lng': -0.1278, 'tz': 0.0},
    {'name': 'New York, USA', 'lat': 40.7128, 'lng': -74.0060, 'tz': -5.0},
    {'name': 'San Francisco, USA', 'lat': 37.7749, 'lng': -122.4194, 'tz': -8.0},
    {'name': 'Los Angeles, USA', 'lat': 34.0522, 'lng': -118.2437, 'tz': -8.0},
    {'name': 'Chicago, USA', 'lat': 41.8781, 'lng': -87.6298, 'tz': -6.0},
    {'name': 'Sydney, Australia', 'lat': -33.8688, 'lng': 151.2093, 'tz': 10.0},
    {'name': 'Tokyo, Japan', 'lat': 35.6762, 'lng': 139.6503, 'tz': 9.0},
    {'name': 'Singapore', 'lat': 1.3521, 'lng': 103.8198, 'tz': 8.0},
    {'name': 'Dubai, UAE', 'lat': 25.2048, 'lng': 55.2708, 'tz': 4.0},
    {'name': 'Paris, France', 'lat': 48.8566, 'lng': 2.3522, 'tz': 1.0},
    {'name': 'Berlin, Germany', 'lat': 52.5200, 'lng': 13.4050, 'tz': 1.0},
    {'name': 'Toronto, Canada', 'lat': 43.6532, 'lng': -79.3832, 'tz': -5.0},
  ];

  Map<String, dynamic>? _selectedCity;
  List<Map<String, dynamic>> _filteredCities = [];

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _onCityChanged(String val) {
    if (val.isEmpty) {
      setState(() => _filteredCities = []);
      return;
    }
    setState(() {
      _filteredCities = _citiesList
          .where((city) => city['name'].toString().toLowerCase().contains(val.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF03001e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF03001e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Time of Birth')),
      );
      return;
    }

    // Set coordinates based on city lookup or default
    final double lat = _selectedCity?['lat'] ?? 28.6139;
    final double lng = _selectedCity?['lng'] ?? 77.2090;
    final double tz = _selectedCity?['tz'] ?? 5.5;
    final String cityName = _placeController.text;

    final newProfile = BirthDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      gender: _gender,
      dob: _selectedDate!,
      tob: _selectedTime!,
      place: cityName.isNotEmpty ? cityName : 'Delhi, India',
      latitude: lat,
      longitude: lng,
      timezone: tz,
    );

    // Save to Firestore via ProfileService
    try {
      await ProfileService.instance.saveProfile(newProfile);
    } catch (e) {
      debugPrint("Error saving profile to Firestore: $e");
    }

    // Calculate report and navigate to Report Screen
    final report = AstrologyEngine.generateReport(newProfile);

    if (!mounted) return;
    // Push the report screen and replace this screen or notify pop to refresh home list
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReportScreen(report: report)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate == null
        ? 'Select Date of Birth'
        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
    final formattedTime = _selectedTime == null
        ? 'Select Time of Birth'
        : _selectedTime!.format(context);

    return Scaffold(
      backgroundColor: const Color(0xFF03001e),
      appBar: AppBar(
        title: const Text(
          'Map Birth Details',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF03001e),
              Color(0xFF240b36),
              Color(0xFF03001e),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withOpacity(0.05),
                        ),
                        child: const Icon(
                          Icons.blur_circular,
                          color: Colors.amber,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Input
                    const Text(
                      'NAME',
                      style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.amber),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Gender Selector
                    const Text(
                      'GENDER',
                      style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Male', 'Female', 'Non-Binary'].map((genderOption) {
                        final isSelected = _gender == genderOption;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _gender = genderOption);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.amber : Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                genderOption,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.amber : Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Date & Time pickers
                    Row(
                      children: [
                        // Date Picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DATE OF BIRTH',
                                style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: _selectedDate == null ? Colors.white.withOpacity(0.3) : Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Time Picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TIME OF BIRTH',
                                style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: _selectedTime == null ? Colors.white.withOpacity(0.3) : Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Icon(Icons.access_time, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Place of Birth Autocomplete
                    const Text(
                      'PLACE OF BIRTH',
                      style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _placeController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: _onCityChanged,
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. New Delhi)',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.amber),
                        ),
                        suffixIcon: const Icon(Icons.search, color: Colors.amber, size: 20),
                      ),
                    ),

                    // City Autocomplete List Panel
                    if (_filteredCities.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1b0a24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredCities.length,
                          itemBuilder: (context, index) {
                            final city = _filteredCities[index];
                            return ListTile(
                              title: Text(
                                city['name'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              subtitle: Text(
                                'Lat: ${city['lat']}, Lng: ${city['lng']} | GMT: ${city['tz']}',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCity = city;
                                  _placeController.text = city['name'] as String;
                                  _filteredCities = [];
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 50),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'GENERATE CELESTIAL ANALYSIS',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
