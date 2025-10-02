import 'package:easy_localization/easy_localization.dart';

class AppLocalizations {
  const AppLocalizations();

  static AppLocalizations of(context) => const AppLocalizations();

  // App
  String get appName => 'app.appName'.tr();
  String get appDescription => 'app.appDescription'.tr();
  String get welcome => 'app.welcome'.tr();
  String get readyToLearn => 'app.readyToLearn'.tr();

  // Common
  String get ok => 'common.ok'.tr();
  String get cancel => 'common.cancel'.tr();
  String get save => 'common.save'.tr();
  String get delete => 'common.delete'.tr();
  String get edit => 'common.edit'.tr();
  String get add => 'common.add'.tr();
  String get search => 'common.search'.tr();
  String get loading => 'common.loading'.tr();
  String get error => 'common.error'.tr();
  String get success => 'common.success'.tr();
  String get retry => 'common.retry'.tr();
  String get back => 'common.back'.tr();
  String get next => 'common.next'.tr();
  String get previous => 'common.previous'.tr();
  String get finish => 'common.finish'.tr();
  String get skip => 'common.skip'.tr();
  String get done => 'common.done'.tr();

  // Auth
  String get login => 'auth.login'.tr();
  String get register => 'auth.register'.tr();
  String get logout => 'auth.logout'.tr();
  String get email => 'auth.email'.tr();
  String get password => 'auth.password'.tr();
  String get confirmPassword => 'auth.confirmPassword'.tr();
  String get forgotPassword => 'auth.forgotPassword'.tr();
  String get resetPassword => 'auth.resetPassword'.tr();
  String get createAccount => 'auth.createAccount'.tr();
  String get alreadyHaveAccount => 'auth.alreadyHaveAccount'.tr();
  String get dontHaveAccount => 'auth.dontHaveAccount'.tr();

  // Games
  String get games => 'games.games'.tr();
  String get wordMatching => 'games.wordMatching'.tr();
  String get wordMatchingDesc => 'games.wordMatchingDesc'.tr();
  String get sentenceBuilding => 'games.sentenceBuilding'.tr();
  String get sentenceBuildingDesc => 'games.sentenceBuildingDesc'.tr();
  String get pronunciation => 'games.pronunciation'.tr();
  String get pronunciationDesc => 'games.pronunciationDesc'.tr();
  String get spelling => 'games.spelling'.tr();
  String get spellingDesc => 'games.spellingDesc'.tr();

  // Words
  String get words => 'words.words'.tr();
  String get word => 'words.word'.tr();
  String get meaning => 'words.meaning'.tr();
  String get pronunciationWord => 'words.pronunciation'.tr();
  String get category => 'words.category'.tr();
  String get level => 'words.level'.tr();
  String get recentWords => 'words.recentWords'.tr();
  String get favoriteWords => 'words.favoriteWords'.tr();
  String get seeAll => 'words.seeAll'.tr();
  String get addToFavorites => 'words.addToFavorites'.tr();
  String get removeFromFavorites => 'words.removeFromFavorites'.tr();

  // Categories
  String get objects => 'categories.objects'.tr();
  String get animals => 'categories.animals'.tr();
  String get colors => 'categories.colors'.tr();
  String get numbers => 'categories.numbers'.tr();
  String get family => 'categories.family'.tr();
  String get food => 'categories.food'.tr();
  String get nature => 'categories.nature'.tr();
  String get places => 'categories.places'.tr();
  String get actions => 'categories.actions'.tr();
  String get emotions => 'categories.emotions'.tr();

  // Levels
  String get beginner => 'levels.beginner'.tr();
  String get intermediate => 'levels.intermediate'.tr();
  String get advanced => 'levels.advanced'.tr();

  // Profile
  String get profile => 'profile.profile'.tr();
  String get settings => 'profile.settings'.tr();
  String get statistics => 'profile.statistics'.tr();
  String get achievements => 'profile.achievements'.tr();
  String get progress => 'profile.progress'.tr();

  // Settings
  String get language => 'settings.language'.tr();
  String get theme => 'settings.theme'.tr();
  String get notifications => 'settings.notifications'.tr();
  String get sound => 'settings.sound'.tr();
  String get privacy => 'settings.privacy'.tr();
  String get about => 'settings.about'.tr();

  // Permissions
  String get permissionsTitle => 'permissions.title'.tr();
  String get permissionsDescription => 'permissions.description'.tr();
  String get microphone => 'permissions.microphone'.tr();
  String get microphoneDesc => 'permissions.microphoneDesc'.tr();
  String get camera => 'permissions.camera'.tr();
  String get cameraDesc => 'permissions.cameraDesc'.tr();
  String get storage => 'permissions.storage'.tr();
  String get storageDesc => 'permissions.storageDesc'.tr();
  String get photos => 'permissions.photos'.tr();
  String get photosDesc => 'permissions.photosDesc'.tr();
  String get required => 'permissions.required'.tr();
  String get optional => 'permissions.optional'.tr();
  String get optionalPermissions => 'permissions.optionalPermissions'.tr();
  String get grantPermissions => 'permissions.grantPermissions'.tr();
  String get skipOptional => 'permissions.skipOptional'.tr();
  String get checkingPermissions => 'permissions.checkingPermissions'.tr();
  String get permissionDenied => 'permissions.permissionDenied'.tr();
  String get permissionRequired => 'permissions.permissionRequired'.tr();
  String get openSettings => 'permissions.openSettings'.tr();
  String get settingsMessage => 'permissions.settingsMessage'.tr();

  // Errors
  String get networkError => 'errors.networkError'.tr();
  String get serverError => 'errors.serverError'.tr();
  String get unknownError => 'errors.unknownError'.tr();
  String get validationError => 'errors.validationError'.tr();
  String get permissionError => 'errors.permissionError'.tr();
}
