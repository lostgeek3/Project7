import 'package:flutter/material.dart';
import '../service/user.dart';
import '../pages/logInPage.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key});

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  String username = userStudent.getName;
  String mail = userStudent.getMail;
  String avatar = userStudent.getAvatar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // 处理头像点击事件，跳转到登录页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogInPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 主轴尺寸最小化，即垂直方向上尽可能小
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      width: 100, // 设置头像的宽度
                      height: 100, // 设置头像的高度
                      fit: BoxFit.cover, // 图片适配方式，保持比例填充
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          );
                        }
                      },
                    )
                  : const Icon(Icons.account_circle, size: 100), // 如果头像为空，则显示默认图标
              const SizedBox(height: 16.0), // 添加一些垂直间距

              Text(
                username,
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0), // 添加一些垂直间距

              Text(
                mail,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}