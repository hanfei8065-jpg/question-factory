import 'package:flutter/foundation.dart';

/// Custom Multi-Language Translation Service (Hot-Switch Support)
/// Uses ValueNotifier for instant UI updates without .arb files
class Tr {
  // Current locale (default: Chinese)
  static final ValueNotifier<String> currentLocale = ValueNotifier<String>(
    'zh',
  );

  // Translation dictionary (4 languages: zh, en, ja, es)
  static final Map<String, Map<String, String>> _data = {
    // ========== Bottom Navigation ==========
    'nav_scan': {'zh': '拍题', 'en': 'Scan', 'ja': 'スキャン', 'es': 'Escanear'},
    'nav_arena': {'zh': '题库', 'en': 'Arena', 'ja': '問題集', 'es': 'Arena'},
    'nav_profile': {'zh': '我的', 'en': 'Profile', 'ja': 'マイページ', 'es': 'Perfil'},

    // ========== Camera Page (Home) ==========
    'home_promo': {'zh': '限时特惠', 'en': 'Promo', 'ja': '限定特典', 'es': 'Oferta'},
    'home_calc': {'zh': '计算器', 'en': 'Calc', 'ja': '電卓', 'es': 'Calc'},
    'home_import': {'zh': '导入', 'en': 'Import', 'ja': '導入', 'es': 'Importar'},
    'home_flash': {'zh': '照明', 'en': 'Light', 'ja': 'ライト', 'es': 'Luz'},
    'home_retry_camera': {
      'zh': '重试相机',
      'en': 'Retry Camera',
      'ja': 'カメラを再試行',
      'es': 'Reintentar Cámara',
    },
    'home_camera_error': {
      'zh': '相机初始化失败。\n请检查权限。',
      'en': 'Camera failed to initialize.\nPlease check permissions.',
      'ja': 'カメラの初期化に失敗しました。\n権限を確認してください。',
      'es': 'Error al inicializar la cámara.\nVerifique los permisos.',
    },

    // ========== Onboarding ==========
    'onboarding_step1_title': {
      'zh': '点击此处，开启全知之眼。',
      'en': 'Tap here to open the All-Seeing Eye.',
      'ja': 'ここをタップして全知の目を開く。',
      'es': 'Toca aquí para abrir el Ojo Omnisciente.',
    },
    'onboarding_step1_subtitle': {
      'zh': 'Tap here to open the All-Seeing Eye',
      'en': 'Tap here to open the All-Seeing Eye',
      'ja': 'Tap here to open the All-Seeing Eye',
      'es': 'Tap here to open the All-Seeing Eye',
    },
    'onboarding_step2_title': {
      'zh': '在这里，攻克你的弱点。',
      'en': 'Conquer your weaknesses here.',
      'ja': 'ここで弱点を克服しよう。',
      'es': 'Conquista tus debilidades aquí.',
    },
    'onboarding_step2_subtitle': {
      'zh': 'Conquer your weaknesses here',
      'en': 'Conquer your weaknesses here',
      'ja': 'Conquer your weaknesses here',
      'es': 'Conquer your weaknesses here',
    },
    'onboarding_step3_title': {
      'zh': '这里有你最顺手的武器。',
      'en': 'Your best weapon lies here.',
      'ja': 'あなたの最高の武器がここにあります。',
      'es': 'Tu mejor arma está aquí.',
    },
    'onboarding_step3_subtitle': {
      'zh': 'Your best weapon lies here',
      'en': 'Your best weapon lies here',
      'ja': 'Your best weapon lies here',
      'es': 'Your best weapon lies here',
    },
    'onboarding_skip': {'zh': '跳过', 'en': 'Skip', 'ja': 'スキップ', 'es': 'Saltar'},
    'onboarding_tap_continue': {
      'zh': '点击任意处继续',
      'en': 'Tap anywhere to continue',
      'ja': 'タップして続行',
      'es': 'Toca para continuar',
    },

    // ========== Arena (Question Bank) ==========
    'arena_revenge_mode': {
      'zh': '复仇模式',
      'en': 'Revenge Mode',
      'ja': 'リベンジモード',
      'es': 'Modo Venganza',
    },
    'arena_select_subject': {
      'zh': '选择科目',
      'en': 'Select Subject',
      'ja': '科目を選択',
      'es': 'Seleccionar Materia',
    },
    'arena_select_grade': {
      'zh': '选择年级',
      'en': 'Select Grade',
      'ja': '学年を選択',
      'es': 'Seleccionar Grado',
    },
    'arena_select_topic': {
      'zh': '选择主题',
      'en': 'Select Topic',
      'ja': 'トピックを選択',
      'es': 'Seleccionar Tema',
    },
    'arena_loading': {
      'zh': '加载题目中...',
      'en': 'Loading Questions...',
      'ja': '問題を読み込み中...',
      'es': 'Cargando Preguntas...',
    },
    'arena_no_questions': {
      'zh': '暂无题目',
      'en': 'No questions available',
      'ja': '問題がありません',
      'es': 'No hay preguntas disponibles',
    },
    'arena_ask_tutor': {
      'zh': '问导师',
      'en': 'Ask Tutor',
      'ja': '講師に聞く',
      'es': 'Preguntar al Tutor',
    },
    'arena_revenge_banner': {
      'zh': '🔥 复仇模式 - 复习错题',
      'en': '🔥 REVENGE MODE - Review Your Mistakes',
      'ja': '🔥 リベンジモード - 間違いを復習',
      'es': '🔥 MODO VENGANZA - Revisa tus Errores',
    },

    // ========== Profile Page ==========
    'profile_student_name': {
      'zh': '学生姓名',
      'en': 'Student Name',
      'ja': '学生名',
      'es': 'Nombre del Estudiante',
    },
    'profile_grade': {'zh': '年级', 'en': 'Grade', 'ja': '学年', 'es': 'Grado'},
    'profile_total_questions': {
      'zh': '总题数',
      'en': 'Total Questions',
      'ja': '総問題数',
      'es': 'Preguntas Totales',
    },
    'profile_accuracy': {
      'zh': '准确率',
      'en': 'Accuracy',
      'ja': '正解率',
      'es': 'Precisión',
    },
    'profile_focus_time': {
      'zh': '专注时长',
      'en': 'Focus Time',
      'ja': '集中時間',
      'es': 'Tiempo de Enfoque',
    },
    'profile_skill_radar': {
      'zh': '技能雷达',
      'en': 'Skill Radar',
      'ja': 'スキルレーダー',
      'es': 'Radar de Habilidades',
    },
    'profile_export_cert': {
      'zh': '导出证书',
      'en': 'Export Certificate',
      'ja': '証明書をエクスポート',
      'es': 'Exportar Certificado',
    },

    // ========== Solving Page ==========
    'solving_bingo': {
      'zh': '恭喜你答对了！',
      'en': 'Congratulations! Correct!',
      'ja': '正解おめでとうございます！',
      'es': '¡Felicitaciones! ¡Correcto!',
    },
    'solving_awesome': {
      'zh': '太棒了！',
      'en': 'Awesome!',
      'ja': '素晴らしい！',
      'es': '¡Increíble!',
    },
    'solving_checking': {
      'zh': '检查中...',
      'en': 'Checking...',
      'ja': '確認中...',
      'es': 'Verificando...',
    },

    // ========== Language Names ==========
    'lang_chinese': {'zh': '中文', 'en': 'Chinese', 'ja': '中国語', 'es': 'Chino'},
    'lang_english': {'zh': '英语', 'en': 'English', 'ja': '英語', 'es': 'Inglés'},
    'lang_japanese': {
      'zh': '日语',
      'en': 'Japanese',
      'ja': '日本語',
      'es': 'Japonés',
    },
    'lang_spanish': {
      'zh': '西班牙语',
      'en': 'Spanish',
      'ja': 'スペイン語',
      'es': 'Español',
    },

    // ========== Common Actions ==========
    'common_close': {'zh': '关闭', 'en': 'Close', 'ja': '閉じる', 'es': 'Cerrar'},
    'common_cancel': {
      'zh': '取消',
      'en': 'Cancel',
      'ja': 'キャンセル',
      'es': 'Cancelar',
    },
    'common_confirm': {
      'zh': '确认',
      'en': 'Confirm',
      'ja': '確認',
      'es': 'Confirmar',
    },
    'common_reset': {
      'zh': '重置',
      'en': 'Reset',
      'ja': 'リセット',
      'es': 'Restablecer',
    },
  };

  /// Get translated string for current locale
  /// Returns the key itself if translation not found (fallback)
  static String g(String key) {
    final locale = currentLocale.value;
    final translations = _data[key];

    if (translations == null) {
      debugPrint('⚠️ Translation key not found: $key');
      return key;
    }

    return translations[locale] ?? translations['zh'] ?? key;
  }

  /// Switch to a new locale (triggers ValueNotifier)
  static void setLocale(String locale) {
    if (['zh', 'en', 'ja', 'es'].contains(locale)) {
      currentLocale.value = locale;
      debugPrint('🌐 Language switched to: $locale');
    } else {
      debugPrint('⚠️ Invalid locale: $locale');
    }
  }

  /// Get language flag emoji
  static String getFlag(String locale) {
    switch (locale) {
      case 'zh':
        return '🇨🇳';
      case 'en':
        return '🇺🇸';
      case 'ja':
        return '🇯🇵';
      case 'es':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }

  /// Get language display name
  static String getLanguageName(String locale) {
    switch (locale) {
      case 'zh':
        return g('lang_chinese');
      case 'en':
        return g('lang_english');
      case 'ja':
        return g('lang_japanese');
      case 'es':
        return g('lang_spanish');
      default:
        return locale;
    }
  }
}
