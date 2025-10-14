import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  final String menuName;
  final IconData icon;
  final Widget screen;
  const ProfileMenuWidget({
    super.key,
    required this.menuName,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.only(left: 16, right: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  menuName,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
