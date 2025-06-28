import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberForm extends StatelessWidget {
  final TextEditingController amount;
  final String title;
  final String? hint;
  final String? Function(String?)? validator;

  const NumberForm({super.key, required this.amount, this.validator, required this.title, this.hint=''});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: TextFormField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text(title),
              hintText: hint
          ),
          validator: validator,
        )
    );
  }
}