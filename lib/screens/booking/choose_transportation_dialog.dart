import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/transportation_service.dart';
import '../../models/transportation_model.dart';
import '../../utils/error_formatter.dart';
import '../../widgets/custom_snackbar.dart';
import 'booking_screen.dart';

class ChooseTransportationDialog extends StatefulWidget {
  final Map<String, dynamic> destination;
  final int guestCount;

  const ChooseTransportationDialog({
    super.key,
    required this.destination,
    required this.guestCount,
  });

  @override
  State<ChooseTransportationDialog> createState() => _ChooseTransportationDialogState();
}

class _ChooseTransportationDialogState extends State<ChooseTransportationDialog> {
  int _selectedTransportation = 0;
  int _guestCount = 1;
  bool _isLoading = false;
  List<Transportation> _transportations = [];
  DateTime? _travelDate;
  DateTime? _returnDate;
  TimeOfDay? _travelTime;
  TimeOfDay? _returnTime;

  @override
  void initState() {
    super.initState();
    _guestCount = widget.guestCount;
    _loadTransportations();
  }

  Future<void> _selectTravelDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _travelTime ?? const TimeOfDay(hour: 7, minute: 0),
      );
      if (pickedTime != null) {
        setState(() {
          _travelDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _travelTime = pickedTime;
          if (_returnDate != null && _returnDate!.isBefore(pickedDate.add(const Duration(days: 1)))) {
            _returnDate = pickedDate.add(const Duration(days: 1));
          }
        });
      } else {
        setState(() {
          _travelDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _travelTime?.hour ?? 7,
            _travelTime?.minute ?? 0,
          );
        });
      }
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? (_travelDate?.add(const Duration(days: 1)) ?? DateTime.now()),
      firstDate: _travelDate?.add(const Duration(days: 1)) ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _returnTime ?? const TimeOfDay(hour: 7, minute: 0),
      );
      if (pickedTime != null) {
        setState(() {
          _returnDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _returnTime = pickedTime;
        });
      } else {
        setState(() {
          _returnDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _returnTime?.hour ?? 7,
            _returnTime?.minute ?? 0,
          );
        });
      }
    }
  }

  Future<void> _loadTransportations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final destinationId = widget.destination['id'] as int?;
      if (destinationId == null) {
        throw Exception('Destination ID not found');
      }

      final transportations = await TransportationService.getTransportationsByDestination(destinationId);
      setState(() {
        _transportations = transportations;
        if (_transportations.isNotEmpty) {
          _selectedTransportation = 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = ErrorFormatter.format(e.toString());
        showCustomSnackBar(
          context,
          errorMessage,
          isSuccess: false,
        );
      }
    }
  }

  String _getTransportationIcon(String transportTypeId) {
    // icon
    switch (transportTypeId) {
      case '1':
        return "assets/icons/transportation/car.svg";
      case '2':
        return "assets/icons/transportation/bus.svg";
      case '3':
        return "assets/icons/transportation/plane.svg";
      case '4':
        return "assets/icons/transportation/ship.svg";
      default:
        return "assets/icons/transportation/car.svg";
    }
  }

  String _getTransportationName(int transportTypeId) {
    switch (transportTypeId) {
      case 1:
        return "Car";
      case 2:
        return "Bus";
      case 3:
        return "Airplane";
      case 4:
        return "Ship";
      default:
        return "Car";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Choose Transportation",
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectTravelDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textSecondary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Travel Date",
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _travelDate != null
                                          ? "${DateFormat('dd/MM/yyyy').format(_travelDate!)} ${_travelTime != null ? '${_travelTime!.hour.toString().padLeft(2, '0')}:${_travelTime!.minute.toString().padLeft(2, '0')}' : ''}"
                                          : "Select date & time",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectReturnDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textSecondary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Return Date",
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _returnDate != null
                                          ? "${DateFormat('dd/MM/yyyy').format(_returnDate!)} ${_returnTime != null ? '${_returnTime!.hour.toString().padLeft(2, '0')}:${_returnTime!.minute.toString().padLeft(2, '0')}' : ''}"
                                          : "Select date & time",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_transportations.isEmpty)
                        const Center(child: Text('No transportations available'))
                      else
                        ..._transportations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final transport = entry.value;
                        final isSelected = _selectedTransportation == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTransportation = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textSecondary.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                    _getTransportationIcon(transport.transportTypeId.toString()),
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          _getTransportationName(transport.transportTypeId),
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Estimation: ${transport.estimate}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                    "Rp. ${transport.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        }).toList(),

                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Guests",
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_guestCount > 1) {
                                  setState(() {
                                    _guestCount--;
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.textSecondary.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "$_guestCount",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _guestCount++;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_transportations.isEmpty || _travelDate == null || _returnDate == null) ? null : () {
                            if (_transportations.isEmpty || _selectedTransportation >= _transportations.length) {
                              return;
                            }

                            if (_travelDate == null || _returnDate == null) {
                              showCustomSnackBar(
                                context,
                                "Please select travel and return dates",
                                isSuccess: false,
                              );
                              return;
                            }

                            final selectedTransport = _transportations[_selectedTransportation];
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  destination: widget.destination,
                                  transportation: {
                                    "id": selectedTransport.id,
                                    "icon": _getTransportationIcon(selectedTransport.transportTypeId.toString()),
                                    "name": _getTransportationName(selectedTransport.transportTypeId),
                                    "estimation": selectedTransport.estimate,
                                    "price": selectedTransport.price, // Store as int for calculation
                                  },
                                  travelDate: _travelDate!,
                                  returnDate: _returnDate!,
                                  guestCount: _guestCount,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Book Now",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

