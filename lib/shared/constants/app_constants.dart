import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AOP';

  // Colors
  static const Color primaryColor = Color(0xff1B047C);
  static const Color backgroundColor = Colors.white;
  static const Color shadowColor = Colors.black;

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double headerPadding = 20.0;
  static const double headerImageHeight = 100.0;

  // API URLs

  // Asset paths
  static const String logoPath = 'assets/logo.png';
  static const String profilePath = 'assets/profile.png';
  static const String aopPath = 'assets/aop.png';

  // Language flags
  static const String persianFlagPath = 'assets/flags/persian.png';
  static const String englishFlagPath = 'assets/flags/english.png';
  static const String pashtoFlagPath = 'assets/flags/pashto.png';

  // Route names
  static const String homeRoute = '/';
  static const String languageRoute = '/language';
  static const String webViewRoute = '/webview';
  static const String pashtoRoute = '/pashto';
  static const String persianRoute = '/persian';
  static const String englishRoute = '/english';
  static const String settingsRoute = '/settings';
  static const String serviceRoute = '/service';
  static const String feedbackRoute = '/feedback';

  // Styles
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final BoxDecoration headerDecoration = BoxDecoration(
    color: primaryColor,
    boxShadow: [
      BoxShadow(
        color: shadowColor.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // URLs
  static const Map<String, String> aopUrls = {
    'persian': 'https://aop.gov.af/dr',
    'pashto': 'https://aop.gov.af/pa',
    'english': 'https://aop.gov.af/en',
  };

  static const Map<String, String> aopVideosUrls = {
    'persian': 'https://aop.gov.af/dr/videos',
    'pashto': 'https://aop.gov.af/dr/pictures',
    'english': 'https://aop.gov.af/en/videos',
  };

  static const Map<String, String> aopMinistryUrls = {
    'persian': 'https://aop.gov.af/dr/government/ministries',
    'pashto': 'https://aop.gov.af/pa/government/ministries',
    'english': 'https://aop.gov.af/en/government/ministries',
  };

  static const Map<String, String> passportUrls = {
    'persian': 'https://passport.moi.gov.af/da',
    'pashto': 'https://passport.moi.gov.af/pa',
    'english': 'https://passport.moi.gov.af/pa',
  };

  static const Map<String, String> aopFormUrls = {
    'persian': 'https://aop.gov.af/dr/forms',
    'pashto': 'https://aop.gov.af/pa/forms',
    'english': 'https://aop.gov.af/en/forms',
  };

  // Multilingual welcome messages
  static const String welcomeAppMessagePashto = 'د ادارې ایپ ته ښه راغلاست.';
  static const String welcomeAppMessagePersian = 'به اپلیکیشن اداره امور خوش آمدید';
  static const String welcomeAppMessageEnglish = 'Welcome to the AOP App';

  // Persian Text
  static const Map<String, String> persianText = {
    'videos': 'ویدیوها',
    'welcome': 'خوش آمدید',
    'headerTitle': 'ریاست عمومی اداره امور',
    'aopWebsite': 'وبسایت اداره امور',
    'agencyList': 'لیست وزارت خانه ها',
    'publicServices': 'خدمات عامه',
    'passportServices': 'خدمات پاسپورت',
    'changeLanguage': 'تغییر زبان',
    'comments': 'نظریات',
    'contactUs': 'تماس با ما',
    'feedbackGuide': 'لطفاً نظریات/شکایات خود را با ما شریک سازید',
    'whatsapp': 'واتساپ',
    'email': 'ایمیل',
    'contactForm': 'فورم تماس',
    'langGuide': 'لطفاً زبان خود را انتخاب نمایید',
    // News Screen Texts
    'newsTitle': 'اخبار',
    'newsTabsAll': 'همه',
    'newsTabsLatest': 'آخرین اخبار',
    'newsTabsSocial': 'اجتماعی',
    'newsTabsEconomic': 'اقتصادی',
    'newsTabsPolitical': 'سیاسی',
    'newsTabsCultural': 'فرهنگی',
    'searchNewsHint': 'جستجو در اخبار...',
    'clearSearch': 'پاک کردن',
    'searchLabel': 'جستجو برای:',
    'emptySearchResult': 'نتیجه‌ای برای "{query}" یافت نشد',
    'emptySearchSuggestion': 'لطفا با کلمات کلیدی دیگری جستجو کنید',
    'clearSearchButton': 'پاک کردن جستجو',
    'savedNews': 'اخبار ذخیره شده',
    'noSavedNews': 'هیچ خبری ذخیره نشده است',
    'newsRemoved': 'خبر حذف شد',
    'undo': 'بازگشت',
    'browseNews': 'مشاهده اخبار',
    'newsSaved': 'خبر ذخیره شد',
    'newsUnsaved': 'خبر از لیست ذخیره‌ها حذف شد',
    'clearAllSavedNews': 'حذف همه اخبار ذخیره شده',
    'clearAllSavedNewsConfirm': 'آیا مطمئن هستید که می‌خواهید همه اخبار ذخیره شده را حذف کنید؟',
    'cancel': 'انصراف',
    'clear': 'حذف',
    'allNewsRemoved': 'همه اخبار ذخیره شده حذف شدند',
    'save': 'ذخیره',
    'changeTextSize': 'تغییر اندازه متن',
    'comingSoon': 'به زودی',
    'fullscreenComingSoon': 'نمایش تمام صفحه به زودی',
    'imageGallery': 'گالری تصاویر',
    'imageCount': '{count} تصویر',
    'noImages': 'تصویری وجود ندارد',
    'additionalInfo': 'اطلاعات بیشتر',
    'viewCount': '{count} بازدید',
    'noTitle': 'بدون عنوان',
    'viewFullNews': 'مشاهده کامل خبر در برنامه ما',
    'newsItem': 'مورد خبری',
    'errorLoadingNews': 'خطا در بارگیری خبر',
    // Ministry Screen Texts
    'ministries': 'وزارت‌خانه‌ها',
    'searchMinistries': 'جستجو در وزارت‌خانه‌ها...',
    'noMinistries': 'هیچ وزارت‌خانه‌ای وجود ندارد',
    'ministryComingSoon': 'به زودی وزارت‌خانه‌های جدید اضافه خواهند شد',
    'ministryLoadError': 'خطا در بارگیری لیست وزارت‌خانه‌ها',
    'tryAgain': 'تلاش مجدد',
    'viewDetails': 'مشاهده جزئیات',
    'ministry': 'وزارت‌خانه',
    'aboutMinistry': 'درباره وزارت‌خانه',
    'contactInfo': 'اطلاعات تماس',
    'viewOfficialWebsite': 'مشاهده وب‌سایت رسمی',
    'phone': 'تلفن',
    'website': 'وب‌سایت',
    'share': 'اشتراک‌گذاری',
    'noWebsite': 'وب‌سایتی موجود نیست',
    'back': 'بازگشت',
    // Independent Directorates Text
    'independentDirectorates': 'ریاست‌های مستقل',
    'searchDirectorates': 'جستجو در ریاست‌های مستقل...',
    'noDirectorates': 'هیچ ریاست مستقلی وجود ندارد',
    'directorateComingSoon': 'به زودی ریاست‌های مستقل جدید اضافه خواهند شد',
    'directorateLoadError': 'خطا در بارگیری لیست ریاست‌های مستقل',
    'directorate': 'ریاست مستقل',
    'aboutDirectorate': 'درباره ریاست مستقل',
    // Provinces Text
    'provinces': 'ولایات',
    'searchProvinces': 'جستجو در ولایات...',
    'noProvinces': 'هیچ ولایتی وجود ندارد',
    'provinceComingSoon': 'به زودی ولایات جدید اضافه خواهند شد',
    'provinceLoadError': 'خطا در بارگیری لیست ولایات',
    'province': 'ولایت',
    'aboutProvince': 'درباره ولایت',
    // Error messages
    'cannotOpenWebsite': 'متاسفانه نمی‌توان وب‌سایت را باز کرد: {url}',
    'cannotMakeCall': 'متاسفانه نمی‌توان تماس برقرار کرد: {phone}',
    // API Error Messages
    'cannotLoadData': 'خطا در بارگیری اطلاعات',
    'noConnection': 'اتصال به اینترنت برقرار نیست',
    'timeout': 'زمان درخواست به پایان رسید',
    'serverError': 'خطا در سرور رخ داده است',
    'retry': 'تلاش مجدد',
    'backToHome': 'بازگشت به صفحه اصلی',
    'offline': 'شما آفلاین هستید',
    'checkConnection': 'لطفا اتصال اینترنت خود را بررسی کنید',
  };

  // Pashto Text
  static const Map<String, String> pashtoText = {
    'videos': 'ویډیوګانې',
    'welcome': 'ښه راغلاست',
    'headerTitle': 'د چارو ادارې لوی ریاست',
    'aopWebsite': 'د چارو ادارې ویب پاڼه',
    'agencyList': 'د وزارتونو لیست',
    'publicServices': 'عامه خدمتونه',
    'passportServices': 'د پاسپورت خدمتونه',
    'changeLanguage': 'د ژبې بدلول',
    'comments': 'نظرونه',
    'contactUs': 'له موږ سره اړیکه',
    'feedbackGuide': 'مهرباني وکړئ خپل نظرونه/شکایتونه له موږ سره شریک کړئ',
    'whatsapp': 'واټساپ',
    'email': 'بریښنالیک',
    'contactForm': 'د اړیکې فورم',
    'langGuide': 'مهرباني وکړئ خپله ژبه غوره کړئ',
    // News Screen Texts
    'newsTitle': 'خبرونه',
    'newsTabsAll': 'ټول',
    'newsTabsLatest': 'وروستي خبرونه',
    'newsTabsSocial': 'ټولنیز',
    'newsTabsEconomic': 'اقتصادي',
    'newsTabsPolitical': 'سیاسي',
    'newsTabsCultural': 'کلتوري',
    'searchNewsHint': 'په خبرونو کې پلټنه...',
    'clearSearch': 'پاکول',
    'searchLabel': 'لټون د:',
    'emptySearchResult': 'د "{query}" لپاره پایله ونه موندل شوه',
    'emptySearchSuggestion': 'مهرباني وکړئ د نورو کلیدي کلمو سره پلټنه وکړئ',
    'clearSearchButton': 'لټون پاک کړئ',
    'savedNews': 'خوندي شوي خبرونه',
    'noSavedNews': 'هیڅ خبر خوندي شوی نه دی',
    'newsRemoved': 'خبر لرې شو',
    'undo': 'بیرته راوستل',
    'browseNews': 'خبرونه وګورئ',
    'newsSaved': 'خبر خوندي شو',
    'newsUnsaved': 'خبر د خوندي شویو له لیست څخه لرې شو',
    'clearAllSavedNews': 'ټول خوندي شوي خبرونه لرې کړئ',
    'clearAllSavedNewsConfirm': 'آیا تاسو ډاډه یاست چې غواړئ ټول خوندي شوي خبرونه لرې کړئ؟',
    'cancel': 'لغوه کول',
    'clear': 'لرې کول',
    'allNewsRemoved': 'ټول خوندي شوي خبرونه لرې شول',
    'save': 'خوندي کول',
    'changeTextSize': 'د متن اندازه بدلول',
    'comingSoon': 'ژر راځي',
    'fullscreenComingSoon': 'بشپړ سکرین به ژر راشي',
    'imageGallery': 'د انځورونو ګالری',
    'imageCount': '{count} انځورونه',
    'noImages': 'هیڅ انځور شتون نلري',
    'additionalInfo': 'اضافي معلومات',
    'viewCount': '{count} لیدنې',
    'noTitle': 'بې سرلیکه',
    'viewFullNews': 'په موږ اپلیکیشن کې بشپړ خبر وګورئ',
    'newsItem': 'خبري توکی',
    'errorLoadingNews': 'د خبر په لوډولو کې ستونزه',
    // Ministry Screen Texts
    'ministries': 'وزارتونه',
    'searchMinistries': 'په وزارتونو کې پلټنه...',
    'noMinistries': 'هیڅ وزارت شتون نلري',
    'ministryComingSoon': 'ژر به نوي وزارتونه اضافه شي',
    'ministryLoadError': 'د وزارتونو د لیست په بارولو کې ستونزه',
    'tryAgain': 'بیا هڅه وکړئ',
    'viewDetails': 'جزئیات وګورئ',
    'ministry': 'وزارت',
    'aboutMinistry': 'د وزارت په اړه',
    'contactInfo': 'د اړیکې معلومات',
    'viewOfficialWebsite': 'رسمي ویب پاڼه وګورئ',
    'phone': 'تلیفون',
    'website': 'ویب پاڼه',
    'share': 'شریکول',
    'noWebsite': 'هیڅ ویب پاڼه شتون نلري',
    'back': 'شاته',
    // Independent Directorates Text
    'independentDirectorates': 'خپلواک ریاستونه',
    'searchDirectorates': 'په خپلواک ریاستونو کې پلټنه...',
    'noDirectorates': 'هیڅ خپلواک ریاست شتون نلري',
    'directorateComingSoon': 'ژر به نوي خپلواک ریاستونه اضافه شي',
    'directorateLoadError': 'د خپلواک ریاستونو د لیست په بارولو کې ستونزه',
    'directorate': 'خپلواک ریاست',
    'aboutDirectorate': 'د خپلواک ریاست په اړه',
    // Provinces Text
    'provinces': 'ولایتونه',
    'searchProvinces': 'په ولایتونو کې پلټنه...',
    'noProvinces': 'هیڅ ولایت شتون نلري',
    'provinceComingSoon': 'ژر به نوي ولایتونه اضافه شي',
    'provinceLoadError': 'د ولایتونو د لیست په بارولو کې ستونزه',
    'province': 'ولایت',
    'aboutProvince': 'د ولایت په اړه',
    // Error messages
    'cannotOpenWebsite': 'په خواشینۍ سره ویب پاڼه نشو خلاصولی: {url}',
    'cannotMakeCall': 'په خواشینۍ سره تلیفون نشو کولی: {phone}',
    // API Error Messages
    'cannotLoadData': 'د معلوماتو په بارولو کې ستونزه',
    'noConnection': 'انټرنیټ سره اړیکه نشته',
    'timeout': 'د غوښتنې وخت پای ته ورسېد',
    'serverError': 'په سرور کې ستونزه شتون لري',
    'retry': 'بیا هڅه وکړئ',
    'backToHome': 'اصلي پاڼې ته ستنېدل',
    'offline': 'تاسو آفلاین یاست',
    'checkConnection': 'مهرباني وکړئ خپله انټرنیټ اړیکه وګورئ',
  };

  // English Text
  static const Map<String, String> englishText = {
    'videos': 'Videos',
    'welcome': 'Welcome',
    'headerTitle': 'General Directorate of Administration',
    'aopWebsite': 'Office of the Prime Minister',
    'agencyList': 'Ministry List',
    'publicServices': 'Public Services',
    'passportServices': 'Passport Services',
    'changeLanguage': 'Change Language',
    'comments': 'Comments',
    'contactUs': 'Contact Us',
    'feedbackGuide': 'Please share your feedback with us',
    'whatsapp': 'WhatsApp',
    'email': 'Email',
    'contactForm': 'Contact Form',
    'langGuide': 'Please select your language',
    // News Screen Texts
    'newsTitle': 'News',
    'newsTabsAll': 'All',
    'newsTabsLatest': 'Latest News',
    'newsTabsSocial': 'Social',
    'newsTabsEconomic': 'Economic',
    'newsTabsPolitical': 'Political',
    'newsTabsCultural': 'Cultural',
    'searchNewsHint': 'Search news...',
    'clearSearch': 'Clear',
    'searchLabel': 'Searching for:',
    'emptySearchResult': 'No results found for "{query}"',
    'emptySearchSuggestion': 'Please search with different keywords',
    'clearSearchButton': 'Clear Search',
    'savedNews': 'Saved News',
    'noSavedNews': 'No saved news',
    'newsRemoved': 'News removed',
    'undo': 'Undo',
    'browseNews': 'Browse News',
    'newsSaved': 'News saved',
    'newsUnsaved': 'News unsaved',
    'clearAllSavedNews': 'Clear all saved news',
    'clearAllSavedNewsConfirm': 'Are you sure you want to clear all saved news?',
    'cancel': 'Cancel',
    'clear': 'Clear',
    'allNewsRemoved': 'All saved news removed',
    'save': 'Save',
    'changeTextSize': 'Change Text Size',
    'comingSoon': 'Coming Soon',
    'fullscreenComingSoon': 'Fullscreen view coming soon',
    'imageGallery': 'Image Gallery',
    'imageCount': '{count} Images',
    'noImages': 'No images available',
    'additionalInfo': 'Additional Information',
    'viewCount': '{count} Views',
    'noTitle': 'No Title',
    'viewFullNews': 'View full news in our app',
    'newsItem': 'News Item',
    'errorLoadingNews': 'Error loading news',
    // Ministry Screen Texts
    'ministries': 'Ministries',
    'searchMinistries': 'Search ministries...',
    'noMinistries': 'No ministries available',
    'ministryComingSoon': 'New ministries will be added soon',
    'ministryLoadError': 'Error loading ministry list',
    'tryAgain': 'Try Again',
    'viewDetails': 'View Details',
    'ministry': 'Ministry',
    'aboutMinistry': 'About the Ministry',
    'contactInfo': 'Contact Information',
    'viewOfficialWebsite': 'View Official Website',
    'phone': 'Phone',
    'website': 'Website',
    'share': 'Share',
    'noWebsite': 'No website available',
    'back': 'Back',
    // Independent Directorates Text
    'independentDirectorates': 'Independent Directorates',
    'searchDirectorates': 'Search independent directorates...',
    'noDirectorates': 'No independent directorates available',
    'directorateComingSoon': 'New independent directorates will be added soon',
    'directorateLoadError': 'Error loading independent directorates list',
    'directorate': 'Independent Directorate',
    'aboutDirectorate': 'About the Independent Directorate',
    // Provinces Text
    'provinces': 'Provinces',
    'searchProvinces': 'Search provinces...',
    'noProvinces': 'No provinces available',
    'provinceComingSoon': 'New provinces will be added soon',
    'provinceLoadError': 'Error loading provinces list',
    'province': 'Province',
    'aboutProvince': 'About the Province',
    // Error messages
    'cannotOpenWebsite': 'Unfortunately, cannot open the website: {url}',
    'cannotMakeCall': 'Unfortunately, cannot make the call: {phone}',
    // API Error Messages
    'cannotLoadData': 'Failed to load data',
    'noConnection': 'No internet connection',
    'timeout': 'Request timed out',
    'serverError': 'Server error occurred',
    'retry': 'Try Again',
    'backToHome': 'Back to Home',
    'offline': 'You are offline',
    'checkConnection': 'Please check your internet connection',
  };
}
