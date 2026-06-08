import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {

  final String text;
  final Gradient gradient;
  final VoidCallback onTap;

  const GradientButton({
    required this.text,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {

  double scale = 1;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        setState(() {
          scale = 0.95;
        });
      },

      onTapUp: (_) {
        setState(() {
          scale = 1;
        });
        widget.onTap();
      },

      onTapCancel: () {
        setState(() {
          scale = 1;
        });
      },

      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 150),

        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 28,
          ),

          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0,4),
              )
            ],
          ),

          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}