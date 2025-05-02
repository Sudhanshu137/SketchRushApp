import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController namecontroller;
  final String hintText;

  const CustomTextField({
    Key? key,
    required this.namecontroller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: namecontroller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_outline),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5), // soft off-white
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }
}
