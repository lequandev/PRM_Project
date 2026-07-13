import 'package:flutter/material.dart';

class DigitalRewardCard extends StatefulWidget {
  final String fullname;
  const DigitalRewardCard({super.key, required this.fullname});

  @override
  State<DigitalRewardCard> createState() => _DigitalRewardCardState();
}

class _DigitalRewardCardState extends State<DigitalRewardCard> {
  bool _showFlippedCard = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFlippedCard = !_showFlippedCard),
      child: Container(
        height: 115,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: !_showFlippedCard
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LUXE DIGITAL CARD',
                        style: TextStyle(
                          color: Color(0xFFE6C875),
                          fontSize: 8,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fullname.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '750',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'RESERVE POINTS',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SECURE SCAN ACTIVE',
                      style: TextStyle(
                        color: Color(0xFFE6C875),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap card to return. Present code under barista screen sensor.',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      child: LinearProgressIndicator(
                        value: 1.0,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                        minHeight: 2,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
