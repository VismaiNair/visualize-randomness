import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:js' as js;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.navyDoesntHurt,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const MultiControlPage(),
    );
  }
}

class MultiControlPage extends StatefulWidget {
  const MultiControlPage({super.key});

  @override
  State<MultiControlPage> createState() => _MultiControlPageState();
}

class _MultiControlPageState extends State<MultiControlPage> {
  // State Variables
  double _singleValue = 50.0;
  RangeValues _rangeValues = const RangeValues(10, 20);
  bool _isSliderEnabled = true;
  
  // WASM-related state
  Uint8List? _imageBytes;
  bool _isGenerating = false;
  String? _errorMessage;

  // Call the Go WASM function
  Future<void> _generateRandomWalk() async {
  setState(() {
    _isGenerating = true;
    _errorMessage = null;
  });

  try {
    // 1. Verify the function exists in the JS context
    if (!js.context.hasProperty('walk')) {
      throw Exception('WASM module not loaded. Make sure you are running on Flutter web.');
    }

    // Determine step length
    double stepLength;
    if (_isSliderEnabled) {
      stepLength = (_rangeValues.start + _rangeValues.end) / 2;
    } else {
      stepLength = 10.0;
    }

    // 2. Call the Go function
    // The result is a JsObject (a proxy to the JS object returned by Go)
    final dynamic result = js.context.callMethod('walk', [
      stepLength,
      _singleValue.round(),
      800, // width
      600, // height
    ]);

    if (result == null) {
      throw Exception('Received null response from WASM');
    }

    // 3. Extract the data using map-style access
    // result['error'] corresponds to the "error" key in Go's map[string]interface{}
    final String? goError = result['error'];
    if (goError != null) {
      throw Exception('Go Error: $goError');
    }

    // result['image'] is the base64 string
    final String? base64Image = result['image'];
    if (base64Image == null) {
      throw Exception('No image data found in WASM response');
    }

    // 4. Decode base64 to bytes
    final imageBytes = base64Decode(base64Image);

    setState(() {
      _imageBytes = imageBytes;
      _isGenerating = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = '$e';
      _isGenerating = false;
    });
    print('Error generating walk: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Random Walk Generator',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navyDoesntHurt,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image display container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isGenerating
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : _imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      'Click "Run Random Walk" to generate',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                  ),
                  const SizedBox(width: 20),
                  // Controls column
                  Expanded(
                    child: Column(
                      children: [
                        // Number of Steps Slider
                        Text("Number of Steps: ${_singleValue.round()}"),
                        Slider(
                          inactiveColor: AppColors.grey,
                          activeColor: AppColors.richardsons,
                          value: _singleValue,
                          min: 10,
                          max: 500,
                          onChanged: _isSliderEnabled
                              ? (value) => setState(() => _singleValue = value)
                              : null,
                        ),
                        const SizedBox(height: 30),
                        const Divider(height: 40),

                        // Enable Randomized Step Lengths Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Enable Randomized Step Lengths",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Switch(
                              thumbColor: WidgetStateProperty.all(
                                AppColors.hairlineGray,
                              ),
                              trackColor: WidgetStateProperty.all(
                                AppColors.navyDoesntHurt,
                              ),
                              value: _isSliderEnabled,
                              onChanged: (bool value) {
                                setState(() => _isSliderEnabled = value);
                              },
                            ),
                          ],
                        ),

                        // Range Slider for Step Lengths
                        Text(
                          "Range: ${_rangeValues.start.round()} to ${_rangeValues.end.round()}",
                        ),
                        RangeSlider(
                          inactiveColor: AppColors.grey,
                          activeColor: AppColors.richardsons,
                          values: _rangeValues,
                          min: 5,
                          max: 50,
                          divisions: 9,
                          labels: RangeLabels(
                            _rangeValues.start.round().toString(),
                            _rangeValues.end.round().toString(),
                          ),
                          onChanged: _isSliderEnabled
                              ? (values) =>
                                  setState(() => _rangeValues = values)
                              : null,
                        ),
                        const SizedBox(height: 30),

                        // Run Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _generateRandomWalk,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyDoesntHurt,
                              disabledBackgroundColor: AppColors.grey,
                            ),
                            child: Text(
                              _isGenerating
                                  ? "Generating..."
                                  : "Run Random Walk",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}