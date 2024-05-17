import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0
  )
);
const String logTag = '[SharedPreferences]SharedPreferences: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = true;

class SharedPreferencesUtil<T> {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // 保存数据到共享首选项
  static Future<void> save<T>(String key, T value) async {
    final SharedPreferences prefs = await _prefs;
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      logger.e('${logTag}Unsupported value type: $T');
    }
  }

  // 从共享首选项读取数据
  static Future<T?> read<T>(String key) async {
    final SharedPreferences prefs = await _prefs;
    T? value;
    try {
      if (T == bool) {
        value = prefs.getBool(key) as T?;
      } else if (T == int) {
        value = prefs.getInt(key) as T?;
      } else if (T == double) {
        value = prefs.getDouble(key) as T?;
      } else if (T == String) {
        value = prefs.getString(key) as T?;
      } else if (T == List<String>) {
        value = prefs.getStringList(key) as T?;
      } else {
        logger.e('${logTag}Unsupported value type: $T');
      }
    } catch (_) {
      // 如果键不存在或类型不匹配，则返回null
      return null;
    }
    return value;
  }

  // 从共享首选项删除数据
  static Future<void> delete(String key) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(key);
  }
}

// 首选项类，各种设置选项都加到这里，并在组件初始化时从这里获取数据
class MySharedPreferences {
  // 是否显示周末
  static bool showWeekend = false;

  static Future<void> init() async {
    bool? showWeekendTmp = await SharedPreferencesUtil.read<bool>('showWeekend');
    if (showWeekendTmp == null) {
      // 应用尚未保存首选项时需要初始化设置默认值
      await SharedPreferencesUtil.save<bool>('showWeekend', true);
    }
    else {
      showWeekend = showWeekendTmp;
    }
  }

  static Future<void> saveShowWeekend(bool flag) async {
    showWeekend = flag;
    await SharedPreferencesUtil.save<bool>('showWeekend', flag);
  }

  static final MySharedPreferences _instance = MySharedPreferences._privateConstructor();

  MySharedPreferences._privateConstructor();

  factory MySharedPreferences() => _instance;
}