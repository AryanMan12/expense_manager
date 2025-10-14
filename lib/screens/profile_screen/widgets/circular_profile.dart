import 'package:flutter/material.dart';

class CircularProfile extends StatelessWidget {
  final String userName;
  const CircularProfile({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    List<String> listOfInitials = userName.split(" ");
    String initals = listOfInitials.length == 1
        ? listOfInitials.first[0].toUpperCase()
        : listOfInitials.first[0].toUpperCase() +
            listOfInitials.last[0].toUpperCase();
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          child: Text(
            initals,
            style: TextStyle(fontSize: 36),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          userName,
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
