import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class InfoMetricCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final String unit;
  final IconData iconData;
  final String? lottieAssetPath;
  final Color backgroundColor;
  final Color contentColor; 
  final String noDataMessage;
  final String? timestamp; 

  const InfoMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.iconData,
    this.lottieAssetPath,
    required this.backgroundColor,
    required this.contentColor,
    this.noDataMessage = "No data today",
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(18.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: contentColor.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (lottieAssetPath != null && lottieAssetPath!.isNotEmpty)
                  Lottie.asset(
                    lottieAssetPath!,
                    width: 34,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                else
                  Icon(iconData, size: 26, color: contentColor.withOpacity(0.8)),
              ],
            ),
            const Spacer(flex: 2), 
            if (value != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 26, 
                        fontWeight: FontWeight.w600,
                        color: contentColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '$value'),
                        if (unit.isNotEmpty)
                          TextSpan(
                            text: ' $unit',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500), 
                          ),
                      ],
                    ),
                  ),
                  if (timestamp != null && timestamp!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        timestamp!,
                        style: GoogleFonts.poppins(
                          fontSize: 13, 
                          color: contentColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    noDataMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: contentColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            const Spacer(flex: 1), 
          ],
        ),
      ),
    );
  }
}
