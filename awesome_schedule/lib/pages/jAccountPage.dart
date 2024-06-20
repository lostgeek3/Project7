import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class jAccountPage extends StatelessWidget {
  final url = "https://jaccount.sjtu.edu.cn/oauth2/authorize?response_type=code&client_id=ov3SLrO4HyZSELxcHiqS&redirect_uri=a";

  Future<String?> getLoginURL() async {
    var dio = Dio();
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      // 如果请求成功，返回跳转的url
      var url = response.redirects.last.location.toString();
      return url;
    } else {
      // 如果请求失败，返回空字符串
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录jAccount'),
      ),
      body: FutureBuilder<String?>(
        future: getLoginURL(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 如果数据已经加载完成，显示WebView
            return WebView(
              initialUrl: snapshot.data!,
              javascriptMode: JavascriptMode.unrestricted, // 启用 JavaScript
              navigationDelegate: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                // 当页面开始加载时调用
                int codeIndex = url.indexOf('code=');
                print(url);
                if (codeIndex != -1) {
                  String newCode = url.substring(codeIndex + 5);
                  Navigator.pop(context, newCode);
                }
              },
            );
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 显示加载中的提示
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
