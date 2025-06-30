import 'package:flutter/material.dart';

class ShowExactAlarmPermissionDialog{
  static Future<bool> showExactAlarmPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Không cho đóng khi bấm ra ngoài
      builder: (context) {
        return AlertDialog(
          title: const Text('Cần quyền "Chuông & lời nhắc"'),
          content: const Text(
            'Ứng dụng sử dụng tính năng lập lịch để gửi thông báo định kỳ mỗi ngày.\n\n'
                'Tính năng này yêu cầu quyền "Chuông và lời nhắc".\n\n'
                'Nếu bạn muốn nhận được các thông báo đúng giờ, vui lòng bật quyền này cho ứng dụng.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Mở cài đặt'),
            ),
          ],
        );
      },
    ) ?? false; // Nếu bị đóng ngoài ý muốn, coi như từ chối
  }
}