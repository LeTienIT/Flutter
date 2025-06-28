import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SessionTitle extends StatelessWidget{
  String title, subtitle;
  bool required;

  SessionTitle({super.key, required this.title, this.subtitle = '', this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16, right: 16, left: 5),
        child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
                text: TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.titleLarge,
                    children: [
                      TextSpan(
                          text: subtitle.isEmpty ? '' : ' - $subtitle',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                          )
                      ),
                      if(required)
                        TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red)
                        )
                    ]
                )
            )
        )
    );
  }
}