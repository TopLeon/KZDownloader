import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KzDownloader'**
  String get appTitle;

  /// No description provided for @initialization.
  ///
  /// In en, this message translates to:
  /// **'Initialization...'**
  String get initialization;

  /// No description provided for @checkingComponents.
  ///
  /// In en, this message translates to:
  /// **'Checking components (yt-dlp, ffmpeg, deno)...'**
  String get checkingComponents;

  /// No description provided for @downloadingYtDlp.
  ///
  /// In en, this message translates to:
  /// **'Downloading yt-dlp...'**
  String get downloadingYtDlp;

  /// No description provided for @downloadingFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Downloading ffmpeg...'**
  String get downloadingFfmpeg;

  /// No description provided for @downloadingDeno.
  ///
  /// In en, this message translates to:
  /// **'Downloading deno (JS Runtime)...'**
  String get downloadingDeno;

  /// No description provided for @checkingDownloadPath.
  ///
  /// In en, this message translates to:
  /// **'Checking download folder...'**
  String get checkingDownloadPath;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Startup error: {error}'**
  String startupError(Object error);

  /// No description provided for @initialConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Initial Configuration'**
  String get initialConfiguration;

  /// No description provided for @selectDownloadFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select the folder where you want to save your downloads.'**
  String get selectDownloadFolderMessage;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get chooseFolder;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get retrying;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KzDownloader'**
  String get onboardingTitle;

  /// No description provided for @onboardingContent.
  ///
  /// In en, this message translates to:
  /// **'Please configure your download preferences to get started.'**
  String get onboardingContent;

  /// No description provided for @btnGoSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get btnGoSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @downloadPath.
  ///
  /// In en, this message translates to:
  /// **'Download Path'**
  String get downloadPath;

  /// No description provided for @defaultFormat.
  ///
  /// In en, this message translates to:
  /// **'Default Video Format'**
  String get defaultFormat;

  /// No description provided for @defaultAudioFormat.
  ///
  /// In en, this message translates to:
  /// **'Default Audio Format'**
  String get defaultAudioFormat;

  /// No description provided for @defaultQuality.
  ///
  /// In en, this message translates to:
  /// **'Default Quality'**
  String get defaultQuality;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat to Download'**
  String get chatTitle;

  /// No description provided for @pasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to start downloading'**
  String get pasteLink;

  /// No description provided for @pasteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste link here...'**
  String get pasteLinkHint;

  /// No description provided for @aiMagicHint.
  ///
  /// In en, this message translates to:
  /// **'Ask AI (e.g., \'Best quality audio only\')...'**
  String get aiMagicHint;

  /// No description provided for @videoOptions.
  ///
  /// In en, this message translates to:
  /// **'Video Options'**
  String get videoOptions;

  /// No description provided for @qualityBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get qualityBest;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get qualityHigh;

  /// No description provided for @qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get qualityMedium;

  /// No description provided for @qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get qualityLow;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionSummarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get actionSummarize;

  /// No description provided for @actionBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get actionBoth;

  /// No description provided for @downloadModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Download AI Model'**
  String get downloadModelTitle;

  /// No description provided for @downloadModelContent.
  ///
  /// In en, this message translates to:
  /// **'To use AI features, a small model (~800MB) needs to be downloaded. Continue?'**
  String get downloadModelContent;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get btnDownload;

  /// No description provided for @downloadingModel.
  ///
  /// In en, this message translates to:
  /// **'Downloading Model...'**
  String get downloadingModel;

  /// No description provided for @videoSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Summary'**
  String get videoSummaryTitle;

  /// No description provided for @summaryShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get summaryShort;

  /// No description provided for @summaryLong.
  ///
  /// In en, this message translates to:
  /// **'Report (Long)'**
  String get summaryLong;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI Error: '**
  String get aiError;

  /// No description provided for @providerAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-Detect'**
  String get providerAuto;

  /// No description provided for @statusInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get statusInitializing;

  /// No description provided for @statusCheckingBinaries.
  ///
  /// In en, this message translates to:
  /// **'Checking binaries...'**
  String get statusCheckingBinaries;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @actionSummarizeOnly.
  ///
  /// In en, this message translates to:
  /// **'Summarize Only'**
  String get actionSummarizeOnly;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @newDownload.
  ///
  /// In en, this message translates to:
  /// **'New Download'**
  String get newDownload;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove all download records. Files will not be deleted.'**
  String get clearHistoryContent;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataStorage;

  /// No description provided for @clearDownloadHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Download History'**
  String get clearDownloadHistory;

  /// No description provided for @clearDownloadHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all finished downloads from the list'**
  String get clearDownloadHistorySubtitle;

  /// No description provided for @emptyVideoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Empty Video Library'**
  String get emptyVideoLibrary;

  /// No description provided for @emptyVideoLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a video on YouTube and paste it here'**
  String get emptyVideoLibrarySubtitle;

  /// No description provided for @emptyMusicLibrary.
  ///
  /// In en, this message translates to:
  /// **'No Music'**
  String get emptyMusicLibrary;

  /// No description provided for @emptyMusicLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download your first song or playlist'**
  String get emptyMusicLibrarySubtitle;

  /// No description provided for @emptyGenericLibrary.
  ///
  /// In en, this message translates to:
  /// **'Empty Archive'**
  String get emptyGenericLibrary;

  /// No description provided for @emptyGenericLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No files downloaded in this section'**
  String get emptyGenericLibrarySubtitle;

  /// No description provided for @emptySummaryLibrary.
  ///
  /// In en, this message translates to:
  /// **'No Summaries'**
  String get emptySummaryLibrary;

  /// No description provided for @emptySummaryLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a summary with local AI'**
  String get emptySummaryLibrarySubtitle;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @categoryVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get categoryVideo;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get categoryFiles;

  /// No description provided for @categorySummaries.
  ///
  /// In en, this message translates to:
  /// **'Summaries'**
  String get categorySummaries;

  /// No description provided for @providerAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart selection'**
  String get providerAutoDesc;

  /// No description provided for @providerStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast for small files'**
  String get providerStandardDesc;

  /// No description provided for @providerProDesc.
  ///
  /// In en, this message translates to:
  /// **'Multi-thread, Resume'**
  String get providerProDesc;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select Provider'**
  String get selectProvider;

  /// No description provided for @optionVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get optionVideo;

  /// No description provided for @optionAudio.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get optionAudio;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @downloadedWith.
  ///
  /// In en, this message translates to:
  /// **'Downloaded with {provider} in {time}'**
  String downloadedWith(Object provider, Object time);

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get openFolder;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Summary'**
  String get regenerate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ofTotalSize.
  ///
  /// In en, this message translates to:
  /// **'of {totalSize}'**
  String ofTotalSize(Object totalSize);

  /// No description provided for @proDownloading.
  ///
  /// In en, this message translates to:
  /// **'Pro Downloading with {workers} Threads'**
  String proDownloading(Object workers);

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing the video...'**
  String get aiAnalyzing;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @headerVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get headerVideoTitle;

  /// No description provided for @headerVideoDesc.
  ///
  /// In en, this message translates to:
  /// **'YouTube, Vimeo, Twitch & more'**
  String get headerVideoDesc;

  /// No description provided for @headerMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get headerMusicTitle;

  /// No description provided for @headerMusicDesc.
  ///
  /// In en, this message translates to:
  /// **'Spotify, SoundCloud & Audio files'**
  String get headerMusicDesc;

  /// No description provided for @headerFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get headerFileTitle;

  /// No description provided for @headerFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct downloads, Torrents & Docs'**
  String get headerFileDesc;

  /// No description provided for @headerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summaries'**
  String get headerSummaryTitle;

  /// No description provided for @headerSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Summaries generated from videos'**
  String get headerSummaryDesc;

  /// No description provided for @actionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get actionEmpty;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @statusCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get statusCopied;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search in list'**
  String get searchTooltip;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Link, title or date...'**
  String get searchPlaceholder;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @searchComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search function coming soon...'**
  String get searchComingSoon;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @stepInitialization.
  ///
  /// In en, this message translates to:
  /// **'Initialization'**
  String get stepInitialization;

  /// No description provided for @stepMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata Retrieval'**
  String get stepMetadata;

  /// No description provided for @stepDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get stepDownloading;

  /// No description provided for @stepProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get stepProcessing;

  /// No description provided for @stepSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Extraction'**
  String get stepSubtitles;

  /// No description provided for @stepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary Generation'**
  String get stepSummary;

  /// No description provided for @stepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get stepCompleted;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoriesTitle;

  /// No description provided for @headerInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'In-progress'**
  String get headerInProgressTitle;

  /// No description provided for @headerInProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'Here you can find in progess downloads'**
  String get headerInProgressDesc;

  /// No description provided for @unknownChannel.
  ///
  /// In en, this message translates to:
  /// **'Unknown Channel'**
  String get unknownChannel;

  /// No description provided for @headerFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get headerFailedTitle;

  /// No description provided for @headerFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Sometimes you might stumble'**
  String get headerFailedDesc;

  /// No description provided for @modeDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get modeDownload;

  /// No description provided for @modeSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get modeSummary;

  /// No description provided for @pasteLinkSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Paste link to summarize...'**
  String get pasteLinkSummaryHint;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @downloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadingTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @fullSummary.
  ///
  /// In en, this message translates to:
  /// **'Executive Summary'**
  String get fullSummary;

  /// No description provided for @noSummaryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No summary available.'**
  String get noSummaryAvailable;

  /// No description provided for @videoInfo.
  ///
  /// In en, this message translates to:
  /// **'Video Information'**
  String get videoInfo;

  /// No description provided for @selectVideoToStart.
  ///
  /// In en, this message translates to:
  /// **'Select a video to start'**
  String get selectVideoToStart;

  /// No description provided for @askSomethingAboutVideo.
  ///
  /// In en, this message translates to:
  /// **'Ask something about the video...'**
  String get askSomethingAboutVideo;

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Title'**
  String get unknownTitle;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @goToChat.
  ///
  /// In en, this message translates to:
  /// **'Go to Chat'**
  String get goToChat;

  /// No description provided for @showSummary.
  ///
  /// In en, this message translates to:
  /// **'Show Summary'**
  String get showSummary;

  /// No description provided for @fullReport.
  ///
  /// In en, this message translates to:
  /// **'📄 Full Report'**
  String get fullReport;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'🔑 Key Points'**
  String get keyPoints;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'🎯 Goals'**
  String get goals;

  /// No description provided for @conclusions.
  ///
  /// In en, this message translates to:
  /// **'❓ Conclusions'**
  String get conclusions;

  /// No description provided for @labelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelTitle;

  /// No description provided for @labelChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get labelChannel;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get labelTranscript;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @noTranscriptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transcript available.'**
  String get noTranscriptAvailable;

  /// No description provided for @chatEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Ask any question about the video.'**
  String get chatEmptyState;

  /// No description provided for @aiModelOllama.
  ///
  /// In en, this message translates to:
  /// **'AI Model (Ollama)'**
  String get aiModelOllama;

  /// No description provided for @ollamaNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Ollama not detected'**
  String get ollamaNotDetected;

  /// No description provided for @ollamaError.
  ///
  /// In en, this message translates to:
  /// **'Ensure Ollama is running.\nError: {error}'**
  String ollamaError(Object error);

  /// No description provided for @noModelsFound.
  ///
  /// In en, this message translates to:
  /// **'No models found'**
  String get noModelsFound;

  /// No description provided for @downloadModelHint.
  ///
  /// In en, this message translates to:
  /// **'Download a model (e.g., \'llama3\') via terminal: \'ollama pull llama3\''**
  String get downloadModelHint;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select a model'**
  String get selectModel;

  /// No description provided for @aiSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI (Ollama)'**
  String get aiSectionTitle;

  /// No description provided for @aiProvider.
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get aiProvider;

  /// No description provided for @aiProviderOllama.
  ///
  /// In en, this message translates to:
  /// **'Ollama (Local)'**
  String get aiProviderOllama;

  /// No description provided for @aiProviderOpenAI.
  ///
  /// In en, this message translates to:
  /// **'OpenAI (Cloud)'**
  String get aiProviderOpenAI;

  /// No description provided for @aiProviderGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google AI (Cloud)'**
  String get aiProviderGoogle;

  /// No description provided for @openAiApiKey.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get openAiApiKey;

  /// No description provided for @openAiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get openAiApiKeyHint;

  /// No description provided for @googleAiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Google AI API Key'**
  String get googleAiApiKey;

  /// No description provided for @googleAiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'AIza...'**
  String get googleAiApiKeyHint;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved'**
  String get apiKeySaved;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @etaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'--:--'**
  String get etaPlaceholder;

  /// No description provided for @defaultChannelName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Channel'**
  String get defaultChannelName;

  /// No description provided for @defaultDownloadPath.
  ///
  /// In en, this message translates to:
  /// **'Default (Downloads folder)'**
  String get defaultDownloadPath;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 • Build 2026.2'**
  String get versionInfo;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 KZDownloader by Le0nZ (github.com/topleon)'**
  String get copyright;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @aiModelRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended AI Model'**
  String get aiModelRecommended;

  /// No description provided for @aiModelDescription.
  ///
  /// In en, this message translates to:
  /// **'To use summarization features, installing the \'Gemma 3 QAT\' model is recommended.'**
  String get aiModelDescription;

  /// No description provided for @aiModelSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'Requires ~3GB of space'**
  String get aiModelSizeWarning;

  /// No description provided for @aiModelManualSelection.
  ///
  /// In en, this message translates to:
  /// **'Choose manually later'**
  String get aiModelManualSelection;

  /// No description provided for @aiModelInstallAndStart.
  ///
  /// In en, this message translates to:
  /// **'Install and Start'**
  String get aiModelInstallAndStart;

  /// No description provided for @aiModelInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get aiModelInstalling;

  /// No description provided for @aiModelInstallationDescription.
  ///
  /// In en, this message translates to:
  /// **'The download will happen in an external terminal window or background. Please wait for completion.'**
  String get aiModelInstallationDescription;

  /// No description provided for @inputFormat.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get inputFormat;

  /// No description provided for @inputQuality.
  ///
  /// In en, this message translates to:
  /// **'QUALITY'**
  String get inputQuality;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get beta;

  /// No description provided for @executiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Executive Summary'**
  String get executiveSummary;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generateAiSummary.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get generateAiSummary;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @chatWithVideo.
  ///
  /// In en, this message translates to:
  /// **'Chat with Video'**
  String get chatWithVideo;

  /// No description provided for @aiNotAvailableForNonYoutube.
  ///
  /// In en, this message translates to:
  /// **'AI features are only available for supported YouTube content. You can summarize the video after download.'**
  String get aiNotAvailableForNonYoutube;

  /// No description provided for @noPlaylistsCreated.
  ///
  /// In en, this message translates to:
  /// **'No playlists created.'**
  String get noPlaylistsCreated;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToPlaylist(String name);

  /// No description provided for @openAi.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get openAi;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @italiano.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italiano;

  /// No description provided for @generateSummaryFirst.
  ///
  /// In en, this message translates to:
  /// **'Generate summary first'**
  String get generateSummaryFirst;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete File'**
  String get deleteFile;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task? This action cannot be undone.'**
  String get deleteTaskConfirmation;

  /// No description provided for @playlistInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} songs • Created on {date}'**
  String playlistInfo(Object count, Object date);

  /// No description provided for @optionBestQuality.
  ///
  /// In en, this message translates to:
  /// **'Best Quality'**
  String get optionBestQuality;

  /// No description provided for @btnAddUrl.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get btnAddUrl;

  /// No description provided for @searchPromptMusic.
  ///
  /// In en, this message translates to:
  /// **'Search tracks, artists, or titles...'**
  String get searchPromptMusic;

  /// No description provided for @searchPromptVideo.
  ///
  /// In en, this message translates to:
  /// **'Search videos, titles, or urls...'**
  String get searchPromptVideo;

  /// No description provided for @searchPromptPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Search playlists, titles, or urls...'**
  String get searchPromptPlaylist;

  /// No description provided for @searchPromptGeneric.
  ///
  /// In en, this message translates to:
  /// **'Search urls, names, or types...'**
  String get searchPromptGeneric;

  /// No description provided for @searchPromptDefault.
  ///
  /// In en, this message translates to:
  /// **'Search downloads, URLs, or AI prompts...'**
  String get searchPromptDefault;

  /// No description provided for @newPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylistTitle;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistNameHint;

  /// No description provided for @btnCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get btnCreate;

  /// No description provided for @aiSmartPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get aiSmartPlaylists;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get yourLibrary;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get sortBy;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get sortDateAdded;

  /// No description provided for @sortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// No description provided for @sortBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get sortBitrate;

  /// No description provided for @noMusicFound.
  ///
  /// In en, this message translates to:
  /// **'No music found'**
  String get noMusicFound;

  /// No description provided for @btnBackToDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to details'**
  String get btnBackToDetails;

  /// No description provided for @videoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Video Analysis'**
  String get videoAnalysis;

  /// No description provided for @selectVideoToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Select a video to view details'**
  String get selectVideoToViewDetails;

  /// No description provided for @selectFileToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Select a file to view details'**
  String get selectFileToViewDetails;

  /// No description provided for @aiFeatureYouTubeOnly.
  ///
  /// In en, this message translates to:
  /// **'AI features are only available for supported YouTube content.'**
  String get aiFeatureYouTubeOnly;

  /// No description provided for @removeFromPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylistTitle;

  /// No description provided for @removeFromPlaylistContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove \'{title}\' from the playlist? The file will remain on the device.'**
  String removeFromPlaylistContent(Object title);

  /// No description provided for @btnRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get btnRemove;

  /// No description provided for @addSongsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Songs'**
  String get addSongsTitle;

  /// No description provided for @subSearchSong.
  ///
  /// In en, this message translates to:
  /// **'Search song...'**
  String get subSearchSong;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsFound;

  /// No description provided for @btnAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// No description provided for @btnAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String btnAddCount(Object count);

  /// No description provided for @videoChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask questions to the video'**
  String get videoChatDesc;

  /// No description provided for @chatDisabled.
  ///
  /// In en, this message translates to:
  /// **'Chat Disabled'**
  String get chatDisabled;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty'**
  String get playlistEmpty;

  /// No description provided for @addMusic.
  ///
  /// In en, this message translates to:
  /// **'Add Music'**
  String get addMusic;

  /// No description provided for @settingsAI.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence'**
  String get settingsAI;

  /// No description provided for @settingsAISubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically create summaries and smart answers for your downloads'**
  String get settingsAISubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an interface theme'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @summaryAnimations.
  ///
  /// In en, this message translates to:
  /// **'Summary Animations'**
  String get summaryAnimations;

  /// No description provided for @summaryAnimationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable animated text for summaries'**
  String get summaryAnimationsSubtitle;

  /// No description provided for @settingsDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get settingsDataStorage;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your general preferences'**
  String get settingsGeneralSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsDownloadPath.
  ///
  /// In en, this message translates to:
  /// **'Download Path'**
  String get settingsDownloadPath;

  /// No description provided for @settingsDownloadPathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where to save downloaded files'**
  String get settingsDownloadPathSubtitle;

  /// No description provided for @settingsFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get settingsFormat;

  /// No description provided for @settingsFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select audio/video format'**
  String get settingsFormatSubtitle;

  /// No description provided for @settingsResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get settingsResolution;

  /// No description provided for @settingsResolutionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Video download quality'**
  String get settingsResolutionSubtitle;

  /// No description provided for @selectThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectThemeTitle;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History?'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to remove all downloads from the history?'**
  String get clearHistoryConfirmMessage;

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @downloadPathDescription.
  ///
  /// In en, this message translates to:
  /// **'All downloaded files will be saved here automatically.'**
  String get downloadPathDescription;

  /// No description provided for @settingsPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your general preferences, AI engine configurations, and interface appearance.'**
  String get settingsPageDescription;

  /// No description provided for @enterNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter name...'**
  String get enterNamePlaceholder;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task? This operation cannot be undone.'**
  String get deleteTaskConfirmMessage;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @summarized.
  ///
  /// In en, this message translates to:
  /// **'Summarized'**
  String get summarized;

  /// No description provided for @backToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Back to playlist'**
  String get backToPlaylist;

  /// No description provided for @playlistVideo.
  ///
  /// In en, this message translates to:
  /// **'Playlist Video'**
  String get playlistVideo;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// No description provided for @videoNumber.
  ///
  /// In en, this message translates to:
  /// **'Video {number}'**
  String videoNumber(String number);

  /// No description provided for @noTracksToAdd.
  ///
  /// In en, this message translates to:
  /// **'No tracks available to add'**
  String get noTracksToAdd;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylist;

  /// No description provided for @removeTrackConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{title}\" from this playlist?'**
  String removeTrackConfirmMessage(String title);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'track'**
  String get track;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'tracks'**
  String get tracks;

  /// No description provided for @createdOnDate.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOnDate(String date);

  /// No description provided for @searchTracksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search tracks...'**
  String get searchTracksPlaceholder;

  /// No description provided for @selectedTrackSingular.
  ///
  /// In en, this message translates to:
  /// **'selected track'**
  String get selectedTrackSingular;

  /// No description provided for @selectedTracksPlural.
  ///
  /// In en, this message translates to:
  /// **'selected tracks'**
  String get selectedTracksPlural;

  /// No description provided for @noTracksFound.
  ///
  /// In en, this message translates to:
  /// **'No tracks found'**
  String get noTracksFound;

  /// No description provided for @addWithCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addWithCount(String count);

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopiedToClipboard;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylist;

  /// No description provided for @deletePlaylistConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this playlist and all its videos? This operation cannot be undone.'**
  String get deletePlaylistConfirmMessage;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// No description provided for @concurrentDownloadsPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Concurrent Downloads (Playlist)'**
  String get concurrentDownloadsPlaylist;

  /// No description provided for @maxConcurrentDownloadsDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of videos downloaded simultaneously'**
  String get maxConcurrentDownloadsDescription;

  /// No description provided for @maxCharactersForAI.
  ///
  /// In en, this message translates to:
  /// **'Max Characters for AI'**
  String get maxCharactersForAI;

  /// No description provided for @maxCharactersForAIDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of characters to use for AI summary and chat'**
  String get maxCharactersForAIDescription;

  /// No description provided for @unknownFile.
  ///
  /// In en, this message translates to:
  /// **'Unknown File'**
  String get unknownFile;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylist;

  /// No description provided for @playlistNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistNamePlaceholder;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the playlist \'{name}\'? Files will not be deleted.'**
  String deletePlaylistContent(String name);

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Track'**
  String get deleteTrackTitle;

  /// No description provided for @deleteTrackContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{title}\'? Files will not be deleted.'**
  String deleteTrackContent(String title);

  /// No description provided for @unknownTrack.
  ///
  /// In en, this message translates to:
  /// **'Unknown Track'**
  String get unknownTrack;

  /// No description provided for @downloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAction;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// No description provided for @openFolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolderTooltip;

  /// No description provided for @copyLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLinkTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @playlistSection.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistSection;

  /// No description provided for @musicSection.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicSection;

  /// No description provided for @recentSection.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSection;

  /// No description provided for @genericSection.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get genericSection;

  /// No description provided for @inprogressSection.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inprogressSection;

  /// No description provided for @failedSection.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedSection;

  /// No description provided for @summarySection.
  ///
  /// In en, this message translates to:
  /// **'Summaries'**
  String get summarySection;

  /// No description provided for @titleColumn.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get titleColumn;

  /// No description provided for @artistColumn.
  ///
  /// In en, this message translates to:
  /// **'ARTIST'**
  String get artistColumn;

  /// No description provided for @albumColumn.
  ///
  /// In en, this message translates to:
  /// **'ALBUM'**
  String get albumColumn;

  /// No description provided for @durationColumn.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get durationColumn;

  /// No description provided for @formatColumn.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get formatColumn;

  /// No description provided for @videoSection.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoSection;

  /// No description provided for @playlistNameEditHint.
  ///
  /// In en, this message translates to:
  /// **'The name can be changed later.'**
  String get playlistNameEditHint;

  /// No description provided for @almostReady.
  ///
  /// In en, this message translates to:
  /// **'Almost ready...'**
  String get almostReady;

  /// No description provided for @downloadingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Downloading metadata...'**
  String get downloadingMetadata;

  /// No description provided for @metadataReady.
  ///
  /// In en, this message translates to:
  /// **'Metadata retrieved! Ready to download'**
  String get metadataReady;

  /// No description provided for @readyToDownload.
  ///
  /// In en, this message translates to:
  /// **'Ready to download'**
  String get readyToDownload;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOn(String date);

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} TRACKS'**
  String tracksCount(String count);

  /// No description provided for @addMusicUrl.
  ///
  /// In en, this message translates to:
  /// **'Add Music URL'**
  String get addMusicUrl;

  /// No description provided for @pasteMusicLink.
  ///
  /// In en, this message translates to:
  /// **'Paste YouTube/SoundCloud link...'**
  String get pasteMusicLink;

  /// No description provided for @addToPlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylistTooltip;

  /// No description provided for @aiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI Configuration'**
  String get aiConfiguration;

  /// No description provided for @ollamaDetected.
  ///
  /// In en, this message translates to:
  /// **'Ollama detected! Choose your AI provider:'**
  String get ollamaDetected;

  /// No description provided for @configureAiFeatures.
  ///
  /// In en, this message translates to:
  /// **'Configure AI features to enable video summaries and chat:'**
  String get configureAiFeatures;

  /// No description provided for @useOllama.
  ///
  /// In en, this message translates to:
  /// **'Use Ollama'**
  String get useOllama;

  /// No description provided for @ollamaLocalFree.
  ///
  /// In en, this message translates to:
  /// **'Free local AI (already installed ✓)'**
  String get ollamaLocalFree;

  /// No description provided for @ollamaNeedsInstall.
  ///
  /// In en, this message translates to:
  /// **'Free local AI (needs installation)'**
  String get ollamaNeedsInstall;

  /// No description provided for @useOpenAI.
  ///
  /// In en, this message translates to:
  /// **'Use OpenAI'**
  String get useOpenAI;

  /// No description provided for @openAiDescription.
  ///
  /// In en, this message translates to:
  /// **'GPT models, industry standard'**
  String get openAiDescription;

  /// No description provided for @useGoogleAI.
  ///
  /// In en, this message translates to:
  /// **'Use Google AI'**
  String get useGoogleAI;

  /// No description provided for @googleAiDescription.
  ///
  /// In en, this message translates to:
  /// **'Gemini models, fast and powerful'**
  String get googleAiDescription;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @configureInSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure later in Settings'**
  String get configureInSettings;

  /// No description provided for @useGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get useGoogle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @selectAiModel.
  ///
  /// In en, this message translates to:
  /// **'Select AI Model'**
  String get selectAiModel;

  /// No description provided for @chooseModel.
  ///
  /// In en, this message translates to:
  /// **'Ollama is installed! Choose a model for AI features:'**
  String get chooseModel;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @installAiModel.
  ///
  /// In en, this message translates to:
  /// **'Install AI Model'**
  String get installAiModel;

  /// No description provided for @installModelMessage.
  ///
  /// In en, this message translates to:
  /// **'Ollama is installed but no models found. We recommend Gemma 3 4B for the best balance of speed and quality.'**
  String get installModelMessage;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: ~2.5 GB'**
  String get sizeLabel;

  /// No description provided for @installGemma.
  ///
  /// In en, this message translates to:
  /// **'Install Gemma 3 4B'**
  String get installGemma;

  /// No description provided for @openAiApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get openAiApiKeyTitle;

  /// No description provided for @enterOpenAiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key to use AI features:'**
  String get enterOpenAiKey;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @getApiKeyOpenAI.
  ///
  /// In en, this message translates to:
  /// **'Get API Key from OpenAI'**
  String get getApiKeyOpenAI;

  /// No description provided for @googleAiApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Google AI API Key'**
  String get googleAiApiKeyTitle;

  /// No description provided for @enterGoogleKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google AI API key to use Gemini models:'**
  String get enterGoogleKey;

  /// No description provided for @getApiKeyGoogle.
  ///
  /// In en, this message translates to:
  /// **'Get API Key from Google AI Studio'**
  String get getApiKeyGoogle;

  /// No description provided for @installOllamaTitle.
  ///
  /// In en, this message translates to:
  /// **'Install Ollama'**
  String get installOllamaTitle;

  /// No description provided for @installOllamaMessage.
  ///
  /// In en, this message translates to:
  /// **'To use local AI features, you need to install Ollama:'**
  String get installOllamaMessage;

  /// No description provided for @visitOllama.
  ///
  /// In en, this message translates to:
  /// **'1. Visit ollama.com'**
  String get visitOllama;

  /// No description provided for @downloadInstall.
  ///
  /// In en, this message translates to:
  /// **'2. Download and install'**
  String get downloadInstall;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'3. Restart this app'**
  String get restartApp;

  /// No description provided for @openOllamaWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open ollama.com'**
  String get openOllamaWebsite;

  /// No description provided for @installingAiModel.
  ///
  /// In en, this message translates to:
  /// **'Installing AI Model'**
  String get installingAiModel;

  /// No description provided for @openingTerminal.
  ///
  /// In en, this message translates to:
  /// **'Opening terminal to install the model. This may take a few minutes...'**
  String get openingTerminal;

  /// No description provided for @loadingAiConfig.
  ///
  /// In en, this message translates to:
  /// **'Loading AI configuration...'**
  String get loadingAiConfig;

  /// No description provided for @downloadInfo.
  ///
  /// In en, this message translates to:
  /// **'Informations'**
  String get downloadInfo;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File Type'**
  String get fileType;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @downloadTime.
  ///
  /// In en, this message translates to:
  /// **'Download Time'**
  String get downloadTime;

  /// No description provided for @downloadType.
  ///
  /// In en, this message translates to:
  /// **'Download Type'**
  String get downloadType;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average Speed'**
  String get avgSpeed;

  /// No description provided for @multithread.
  ///
  /// In en, this message translates to:
  /// **'Multithread'**
  String get multithread;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'connections'**
  String get connections;

  /// No description provided for @multithreadAria2.
  ///
  /// In en, this message translates to:
  /// **'Multithread (Aria2)'**
  String get multithreadAria2;

  /// No description provided for @standardHttp.
  ///
  /// In en, this message translates to:
  /// **'Standard (HTTP)'**
  String get standardHttp;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @executable.
  ///
  /// In en, this message translates to:
  /// **'Executable'**
  String get executable;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @qualityMode.
  ///
  /// In en, this message translates to:
  /// **'Quality Mode'**
  String get qualityMode;

  /// No description provided for @qualityModeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get qualityModeSimple;

  /// No description provided for @qualityModeExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get qualityModeExpert;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get second;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @millisecond.
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get millisecond;

  /// No description provided for @milliseconds.
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get milliseconds;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @concurrentDownloadsGlobal.
  ///
  /// In en, this message translates to:
  /// **'Concurrent Downloads (Global)'**
  String get concurrentDownloadsGlobal;

  /// No description provided for @concurrentDownloadsGlobalDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of files downloaded simultaneously'**
  String get concurrentDownloadsGlobalDesc;

  /// No description provided for @checksumLabel.
  ///
  /// In en, this message translates to:
  /// **'Checksum (optional)'**
  String get checksumLabel;

  /// No description provided for @checksumHint.
  ///
  /// In en, this message translates to:
  /// **'If you want paste MD5 or SHA256 hash...'**
  String get checksumHint;

  /// No description provided for @checksumAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get checksumAlgorithm;

  /// No description provided for @checksumMatch.
  ///
  /// In en, this message translates to:
  /// **'Checksum verified'**
  String get checksumMatch;

  /// No description provided for @checksumMismatch.
  ///
  /// In en, this message translates to:
  /// **'Checksum mismatch'**
  String get checksumMismatch;

  /// No description provided for @checksumVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying checksum...'**
  String get checksumVerifying;

  /// No description provided for @checksumError.
  ///
  /// In en, this message translates to:
  /// **'Checksum error'**
  String get checksumError;

  /// No description provided for @linkExpired.
  ///
  /// In en, this message translates to:
  /// **'Link expired (403)'**
  String get linkExpired;

  /// No description provided for @linkExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The download link has expired. Please provide a new URL to resume.'**
  String get linkExpiredMessage;

  /// No description provided for @updateUrl.
  ///
  /// In en, this message translates to:
  /// **'Update URL'**
  String get updateUrl;

  /// No description provided for @updateUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Download URL'**
  String get updateUrlTitle;

  /// No description provided for @updateUrlContent.
  ///
  /// In en, this message translates to:
  /// **'The download link has expired. Paste a new URL to resume the download from where it left off.'**
  String get updateUrlContent;

  /// No description provided for @updateUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste new URL...'**
  String get updateUrlHint;

  /// No description provided for @diskSpaceFree.
  ///
  /// In en, this message translates to:
  /// **'{space} free'**
  String diskSpaceFree(String space);

  /// No description provided for @insufficientDiskSpace.
  ///
  /// In en, this message translates to:
  /// **'Insufficient disk space'**
  String insufficientDiskSpace(String available, String required);

  /// No description provided for @cancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelDownload;

  /// No description provided for @cancelDownloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Download'**
  String get cancelDownloadTooltip;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// No description provided for @diskSpace.
  ///
  /// In en, this message translates to:
  /// **'Disk Space'**
  String get diskSpace;

  /// No description provided for @folderNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get folderNotSelected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
