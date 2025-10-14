import 'package:flutter/material.dart';

class SingleUserListTile extends StatelessWidget {
  const SingleUserListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Borrowed ",
                      style: TextStyle(color: Colors.red),
                    ),
                    Text("Lended ", style: TextStyle(color: Colors.green))
                  ],
                )
              ],
            ),
          ),
          Divider(
            thickness: 0.5,
            height: 1,
            color: Colors.deepPurpleAccent,
          )
        ],
      ),
    );
  }
}
