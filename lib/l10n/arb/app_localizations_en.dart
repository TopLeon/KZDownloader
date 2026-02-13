// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KzDownloader';

  @override
  String get initialization => 'Initialization...';

  @override
  String get checkingComponents =>
      'Checking components (yt-dlp, ffmpeg, deno)...';

  @override
  String get downloadingYtDlp => 'Downloading yt-dlp...';

  @override
  String get downloadingFfmpeg => 'Downloading ffmpeg...';

  @override
  String get downloadingDeno => 'Downloading deno (JS Runtime)...';

  @override
  String get checkingDownloadPath => 'Checking download folder...';

  @override
  String startupError(Object error) {
    return 'Startup error: $error';
  }

  @override
  String get initialConfiguration => 'Initial Configuration';

  @override
  String get selectDownloadFolderMessage =>
      'Please select the folder where you want to save your downloads.';

  @override
  String get chooseFolder => 'Choose Folder';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get retry => 'Retry';

  @override
  String get retrying => 'Retrying...';

  @override
  String get error => 'Error';

  @override
  String get onboardingTitle => 'Welcome to KzDownloader';

  @override
  String get onboardingContent =>
      'Please configure your download preferences to get started.';

  @override
  String get btnGoSettings => 'Go to Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get downloadPath => 'Download Path';

  @override
  String get defaultFormat => 'Default Format';

  @override
  String get defaultQuality => 'Default Quality';

  @override
  String get language => 'Language';

  @override
  String get chatTitle => 'Chat to Download';

  @override
  String get pasteLink => 'Paste a link to start downloading';

  @override
  String get pasteLinkHint => 'Paste link here...';

  @override
  String get aiMagicHint => 'Ask AI (e.g., \'Best quality audio only\')...';

  @override
  String get videoOptions => 'Video Options';

  @override
  String get qualityBest => 'Best';

  @override
  String get qualityLow => 'Low';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionSummarize => 'Summarize';

  @override
  String get actionBoth => 'Both';

  @override
  String get downloadModelTitle => 'Download AI Model';

  @override
  String get downloadModelContent =>
      'To use AI features, a small model (~800MB) needs to be downloaded. Continue?';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDownload => 'Download';

  @override
  String get downloadingModel => 'Downloading Model...';

  @override
  String get videoSummaryTitle => 'Video Summary';

  @override
  String get summaryShort => 'Short';

  @override
  String get summaryLong => 'Report (Long)';

  @override
  String get btnClose => 'Close';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get aiError => 'AI Error: ';

  @override
  String get providerAuto => 'Auto-Detect';

  @override
  String get statusInitializing => 'Initializing...';

  @override
  String get statusCheckingBinaries => 'Checking binaries...';

  @override
  String get statusReady => 'Ready';

  @override
  String get btnContinue => 'Continue';

  @override
  String get actionSummarizeOnly => 'Summarize Only';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get newDownload => 'New Download';

  @override
  String get general => 'General';

  @override
  String get downloads => 'Downloads';

  @override
  String get clearHistoryTitle => 'Clear History?';

  @override
  String get clearHistoryContent =>
      'This will remove all download records. Files will not be deleted.';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get clear => 'Clear';

  @override
  String get dataStorage => 'Data & Storage';

  @override
  String get clearDownloadHistory => 'Clear Download History';

  @override
  String get clearDownloadHistorySubtitle =>
      'Remove all finished downloads from the list';

  @override
  String get emptyVideoLibrary => 'Empty Video Library';

  @override
  String get emptyVideoLibrarySubtitle =>
      'Search for a video on YouTube and paste it here';

  @override
  String get emptyMusicLibrary => 'No Music';

  @override
  String get emptyMusicLibrarySubtitle =>
      'Download your first song or playlist';

  @override
  String get emptyGenericLibrary => 'Empty Archive';

  @override
  String get emptyGenericLibrarySubtitle =>
      'No files downloaded in this section';

  @override
  String get emptySummaryLibrary => 'No Summaries';

  @override
  String get emptySummaryLibrarySubtitle => 'Generate a summary with local AI';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryFiles => 'Files';

  @override
  String get categorySummaries => 'Summaries';

  @override
  String get providerAutoDesc => 'Smart selection';

  @override
  String get providerStandardDesc => 'Fast for small files';

  @override
  String get providerProDesc => 'Multi-thread, Resume';

  @override
  String get selectProvider => 'Select Provider';

  @override
  String get optionVideo => 'Video';

  @override
  String get optionAudio => 'Audio';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String downloadedWith(Object provider, Object time) {
    return 'Downloaded with $provider in $time';
  }

  @override
  String get openFolder => 'Folder';

  @override
  String get regenerate => 'Regenerate Summary';

  @override
  String get cancel => 'Cancel';

  @override
  String ofTotalSize(Object totalSize) {
    return 'of $totalSize';
  }

  @override
  String proDownloading(Object workers) {
    return 'Pro Downloading with $workers Threads';
  }

  @override
  String get aiAnalyzing => 'AI is analyzing the video...';

  @override
  String get readLess => 'Read Less';

  @override
  String get readMore => 'Read More';

  @override
  String get headerVideoTitle => 'Video';

  @override
  String get headerVideoDesc => 'YouTube, Vimeo, Twitch & more';

  @override
  String get headerMusicTitle => 'Music';

  @override
  String get headerMusicDesc => 'Spotify, SoundCloud & Audio files';

  @override
  String get headerFileTitle => 'Generic';

  @override
  String get headerFileDesc => 'Direct downloads, Torrents & Docs';

  @override
  String get headerSummaryTitle => 'Summaries';

  @override
  String get headerSummaryDesc => 'Summaries generated from videos';

  @override
  String get actionEmpty => 'Empty';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionCopy => 'Copy';

  @override
  String get statusCopied => 'Copied!';

  @override
  String get searchTooltip => 'Search in list';

  @override
  String get searchPlaceholder => 'Link, title or date...';

  @override
  String get searchButton => 'Search';

  @override
  String get searchComingSoon => 'Search function coming soon...';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get stepInitialization => 'Initialization';

  @override
  String get stepMetadata => 'Metadata Retrieval';

  @override
  String get stepDownloading => 'Downloading';

  @override
  String get stepProcessing => 'Processing';

  @override
  String get stepSubtitles => 'Subtitle Extraction';

  @override
  String get stepSummary => 'Summary Generation';

  @override
  String get stepCompleted => 'Completed';

  @override
  String get categoriesTitle => 'Category';

  @override
  String get headerInProgressTitle => 'In-progress';

  @override
  String get headerInProgressDesc => 'Here you can find in progess downloads';

  @override
  String get unknownChannel => 'Unknown Channel';

  @override
  String get headerFailedTitle => 'Failed';

  @override
  String get headerFailedDesc => 'Sometimes you might stumble';

  @override
  String get modeDownload => 'Download';

  @override
  String get modeSummary => 'Summary';

  @override
  String get pasteLinkSummaryHint => 'Paste link to summarize...';

  @override
  String get library => 'Library';

  @override
  String get downloadingTitle => 'Downloading';

  @override
  String get settings => 'Settings';

  @override
  String get fullSummary => 'Executive Summary';

  @override
  String get noSummaryAvailable => 'No summary available.';

  @override
  String get videoInfo => 'Video Information';

  @override
  String get selectVideoToStart => 'Select a video to start';

  @override
  String get askSomethingAboutVideo => 'Ask something about the video...';

  @override
  String get unknownTitle => 'Unknown Title';

  @override
  String get unknown => 'Unknown';

  @override
  String get goToChat => 'Go to Chat';

  @override
  String get showSummary => 'Show Summary';

  @override
  String get fullReport => '📄 Full Report';

  @override
  String get keyPoints => '🔑 Key Points';

  @override
  String get goals => '🎯 Goals';

  @override
  String get conclusions => '❓ Conclusions';

  @override
  String get labelTitle => 'Title';

  @override
  String get labelChannel => 'Channel';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelTranscript => 'Transcript';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get noTranscriptAvailable => 'No transcript available.';

  @override
  String get chatEmptyState => 'Ask any question about the video.';

  @override
  String get aiModelOllama => 'AI Model (Ollama)';

  @override
  String get ollamaNotDetected => 'Ollama not detected';

  @override
  String ollamaError(Object error) {
    return 'Ensure Ollama is running.\nError: $error';
  }

  @override
  String get noModelsFound => 'No models found';

  @override
  String get downloadModelHint =>
      'Download a model (e.g., \'llama3\') via terminal: \'ollama pull llama3\'';

  @override
  String get selectModel => 'Select a model';

  @override
  String get aiSectionTitle => 'AI (Ollama)';

  @override
  String get aiProvider => 'AI Provider';

  @override
  String get aiProviderOllama => 'Ollama (Local)';

  @override
  String get aiProviderOpenAI => 'OpenAI (Cloud)';

  @override
  String get aiProviderGoogle => 'Google AI (Cloud)';

  @override
  String get openAiApiKey => 'OpenAI API Key';

  @override
  String get openAiApiKeyHint => 'sk-...';

  @override
  String get googleAiApiKey => 'Google AI API Key';

  @override
  String get googleAiApiKeyHint => 'AIza...';

  @override
  String get apiKeySaved => 'API Key saved';

  @override
  String get categoryHome => 'Home';

  @override
  String get etaPlaceholder => '--:--';

  @override
  String get defaultChannelName => 'Unknown Channel';

  @override
  String get defaultDownloadPath => 'Default (Downloads folder)';

  @override
  String get versionInfo => 'Version 1.0.0 • Build 2026.2';

  @override
  String get copyright => '© 2026 KZDownloader. Open Source Project.';

  @override
  String get eta => 'ETA';

  @override
  String get aiModelRecommended => 'Recommended AI Model';

  @override
  String get aiModelDescription =>
      'To use summarization features, installing the \'Gemma 3 QAT\' model is recommended.';

  @override
  String get aiModelSizeWarning => 'Requires ~3GB of space';

  @override
  String get aiModelManualSelection => 'Choose manually later';

  @override
  String get aiModelInstallAndStart => 'Install and Start';

  @override
  String get aiModelInstalling => 'Installing...';

  @override
  String get aiModelInstallationDescription =>
      'The download will happen in an external terminal window or background. Please wait for completion.';

  @override
  String get inputFormat => 'FORMAT';

  @override
  String get inputQuality => 'QUALITY';

  @override
  String get untitled => 'Untitled';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get deleted => 'Deleted';

  @override
  String get play => 'Play';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get beta => 'BETA';

  @override
  String get executiveSummary => 'Executive Summary';

  @override
  String get generating => 'Generating...';

  @override
  String get generateAiSummary => 'Generate Summary';

  @override
  String get showAll => 'Show All';

  @override
  String get chatWithVideo => 'Chat with Video';

  @override
  String get qualityMedium => 'Medium';

  @override
  String get aiNotAvailableForNonYoutube =>
      'AI features are only available for supported YouTube content. You can summarize the video after download.';

  @override
  String get noPlaylistsCreated => 'No playlists created.';

  @override
  String addedToPlaylist(String name) {
    return 'Added to $name';
  }

  @override
  String get openAi => 'OpenAI';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get italiano => 'Italiano';

  @override
  String get generateSummaryFirst => 'Generate summary first';

  @override
  String get deleteFile => 'Delete File';

  @override
  String get actionOpen => 'Open';

  @override
  String get deleteTaskTitle => 'Delete Task';

  @override
  String get deleteTaskConfirmation =>
      'Are you sure you want to delete this task? This action cannot be undone.';

  @override
  String playlistInfo(Object count, Object date) {
    return '$count songs • Created on $date';
  }

  @override
  String get optionBestQuality => 'Best Quality';

  @override
  String get btnAddUrl => 'Add URL';

  @override
  String get searchPromptMusic => 'Search tracks, artists, or titles...';

  @override
  String get searchPromptVideo => 'Search videos, titles, or urls...';

  @override
  String get searchPromptPlaylist => 'Search playlists, titles, or urls...';

  @override
  String get searchPromptGeneric => 'Search urls, names, or types...';

  @override
  String get searchPromptDefault => 'Search downloads, URLs, or AI prompts...';

  @override
  String get newPlaylistTitle => 'New Playlist';

  @override
  String get playlistNameHint => 'Playlist name';

  @override
  String get btnCreate => 'Create';

  @override
  String get aiSmartPlaylists => 'Playlists';

  @override
  String get yourLibrary => 'Your Library';

  @override
  String get sortBy => 'Sort by: ';

  @override
  String get sortDateAdded => 'Date Added';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortBitrate => 'Bitrate';

  @override
  String get noMusicFound => 'No music found';

  @override
  String get btnBackToDetails => 'Back to details';

  @override
  String get videoAnalysis => 'Video Analysis';

  @override
  String get selectVideoToViewDetails => 'Select a video to view details';

  @override
  String get selectFileToViewDetails => 'Select a file to view details';

  @override
  String get aiFeatureYouTubeOnly =>
      'AI features are only available for supported YouTube content.';

  @override
  String get removeFromPlaylistTitle => 'Remove from Playlist';

  @override
  String removeFromPlaylistContent(Object title) {
    return 'Do you want to remove \'$title\' from the playlist? The file will remain on the device.';
  }

  @override
  String get btnRemove => 'Remove';

  @override
  String get addSongsTitle => 'Add Songs';

  @override
  String get subSearchSong => 'Search song...';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get btnAdd => 'Add';

  @override
  String btnAddCount(Object count) {
    return 'Add ($count)';
  }

  @override
  String get videoChatDesc => 'Ask questions to the video';

  @override
  String get chatDisabled => 'Chat Disabled';

  @override
  String get playlistEmpty => 'This playlist is empty';

  @override
  String get addMusic => 'Add Music';

  @override
  String get settingsAI => 'Artificial Intelligence';

  @override
  String get settingsAISubtitle =>
      'Automatically create summaries and smart answers for your downloads';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Choose an interface theme';

  @override
  String get settingsDataStorage => 'Data & Storage';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralSubtitle => 'Manage your general preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Select application language';

  @override
  String get settingsDownloadPath => 'Download Path';

  @override
  String get settingsDownloadPathSubtitle =>
      'Choose where to save downloaded files';

  @override
  String get settingsFormat => 'Format';

  @override
  String get settingsFormatSubtitle => 'Select audio/video format';

  @override
  String get settingsResolution => 'Resolution';

  @override
  String get settingsResolutionSubtitle => 'Video download quality';

  @override
  String get selectThemeTitle => 'Select Theme';

  @override
  String get clearHistoryConfirmTitle => 'Clear History?';

  @override
  String get clearHistoryConfirmMessage =>
      'This action cannot be undone. Are you sure you want to remove all downloads from the history?';

  @override
  String get btnClear => 'Clear';

  @override
  String get copyText => 'Copy Text';

  @override
  String get downloadPathDescription =>
      'All downloaded files will be saved here automatically.';

  @override
  String get settingsPageDescription =>
      'Manage your general preferences, AI engine configurations, and interface appearance.';

  @override
  String get enterNamePlaceholder => 'Enter name...';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskConfirmMessage =>
      'Are you sure you want to delete this task? This operation cannot be undone.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get delete => 'Delete';

  @override
  String get summarized => 'Summarized';

  @override
  String get backToPlaylist => 'Back to playlist';

  @override
  String get playlistVideo => 'Playlist Video';

  @override
  String get playlist => 'Playlist';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String videoNumber(String number) {
    return 'Video $number';
  }

  @override
  String get noTracksToAdd => 'No tracks available to add';

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String removeTrackConfirmMessage(String title) {
    return 'Are you sure you want to remove \"$title\" from this playlist?';
  }

  @override
  String get close => 'Close';

  @override
  String get track => 'track';

  @override
  String get tracks => 'tracks';

  @override
  String createdOnDate(String date) {
    return 'Created on $date';
  }

  @override
  String get searchTracksPlaceholder => 'Search tracks...';

  @override
  String get selectedTrackSingular => 'selected track';

  @override
  String get selectedTracksPlural => 'selected tracks';

  @override
  String get noTracksFound => 'No tracks found';

  @override
  String addWithCount(String count) {
    return 'Add ($count)';
  }

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String get deletePlaylistConfirmMessage =>
      'Are you sure you want to delete this playlist and all its videos? This operation cannot be undone.';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get concurrentDownloadsPlaylist => 'Concurrent Downloads (Playlist)';

  @override
  String get maxConcurrentDownloadsDescription =>
      'Maximum number of videos downloaded simultaneously';

  @override
  String get maxCharactersForAI => 'Max Characters for AI';

  @override
  String get maxCharactersForAIDescription =>
      'Maximum number of characters to use for AI summary and chat';

  @override
  String get unknownFile => 'Unknown File';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get playlistNamePlaceholder => 'Playlist name';

  @override
  String get save => 'Save';

  @override
  String get deletePlaylistTitle => 'Delete Playlist';

  @override
  String deletePlaylistContent(String name) {
    return 'Are you sure you want to delete the playlist \'$name\'? Files will not be deleted.';
  }

  @override
  String get rename => 'Rename';

  @override
  String get deleteTrackTitle => 'Delete Track';

  @override
  String deleteTrackContent(String title) {
    return 'Are you sure you want to delete \'$title\'? Files will not be deleted.';
  }

  @override
  String get unknownTrack => 'Unknown Track';

  @override
  String get downloadAction => 'Download';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String get openFolderTooltip => 'Open Folder';

  @override
  String get copyLinkTooltip => 'Copy Link';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get playlistSection => 'Playlist';

  @override
  String get musicSection => 'Music';

  @override
  String get recentSection => 'Recent';

  @override
  String get genericSection => 'Generic';

  @override
  String get inprogressSection => 'In Progress';

  @override
  String get failedSection => 'Failed';

  @override
  String get summarySection => 'Summaries';

  @override
  String get titleColumn => 'TITLE';

  @override
  String get artistColumn => 'ARTIST';

  @override
  String get albumColumn => 'ALBUM';

  @override
  String get durationColumn => 'DURATION';

  @override
  String get formatColumn => 'FORMAT';

  @override
  String get videoSection => 'Video';

  @override
  String get playlistNameEditHint => 'The name can be changed later.';

  @override
  String get almostReady => 'Almost ready...';

  @override
  String get downloadingMetadata => 'Downloading metadata...';

  @override
  String get metadataReady => 'Metadata retrieved! Ready to download';

  @override
  String get readyToDownload => 'Ready to download';

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }

  @override
  String tracksCount(String count) {
    return '$count TRACKS';
  }

  @override
  String get addMusicUrl => 'Add Music URL';

  @override
  String get pasteMusicLink => 'Paste YouTube/SoundCloud link...';

  @override
  String get addToPlaylistTooltip => 'Add to Playlist';

  @override
  String get aiConfiguration => 'AI Configuration';

  @override
  String get ollamaDetected => 'Ollama detected! Choose your AI provider:';

  @override
  String get configureAiFeatures =>
      'Configure AI features to enable video summaries and chat:';

  @override
  String get useOllama => 'Use Ollama';

  @override
  String get ollamaLocalFree => 'Free local AI (already installed ✓)';

  @override
  String get ollamaNeedsInstall => 'Free local AI (needs installation)';

  @override
  String get useOpenAI => 'Use OpenAI';

  @override
  String get openAiDescription => 'GPT models, industry standard';

  @override
  String get useGoogleAI => 'Use Google AI';

  @override
  String get googleAiDescription => 'Gemini models, fast and powerful';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get configureInSettings => 'Configure later in Settings';

  @override
  String get useGoogle => 'Google';

  @override
  String get skip => 'Skip';

  @override
  String get selectAiModel => 'Select AI Model';

  @override
  String get chooseModel =>
      'Ollama is installed! Choose a model for AI features:';

  @override
  String get recommended => 'Recommended';

  @override
  String get installAiModel => 'Install AI Model';

  @override
  String get installModelMessage =>
      'Ollama is installed but no models found. We recommend Gemma 3 4B for the best balance of speed and quality.';

  @override
  String get sizeLabel => 'Size: ~2.5 GB';

  @override
  String get installGemma => 'Install Gemma 3 4B';

  @override
  String get openAiApiKeyTitle => 'OpenAI API Key';

  @override
  String get enterOpenAiKey => 'Enter your OpenAI API key to use AI features:';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get getApiKeyOpenAI => 'Get API Key from OpenAI';

  @override
  String get googleAiApiKeyTitle => 'Google AI API Key';

  @override
  String get enterGoogleKey =>
      'Enter your Google AI API key to use Gemini models:';

  @override
  String get getApiKeyGoogle => 'Get API Key from Google AI Studio';

  @override
  String get installOllamaTitle => 'Install Ollama';

  @override
  String get installOllamaMessage =>
      'To use local AI features, you need to install Ollama:';

  @override
  String get visitOllama => '1. Visit ollama.com';

  @override
  String get downloadInstall => '2. Download and install';

  @override
  String get restartApp => '3. Restart this app';

  @override
  String get openOllamaWebsite => 'Open ollama.com';

  @override
  String get installingAiModel => 'Installing AI Model';

  @override
  String get openingTerminal =>
      'Opening terminal to install the model. This may take a few minutes...';

  @override
  String get loadingAiConfig => 'Loading AI configuration...';

  @override
  String get downloadInfo => 'Informations';

  @override
  String get fileType => 'File Type';

  @override
  String get fileSize => 'File Size';

  @override
  String get downloadTime => 'Download Time';

  @override
  String get downloadType => 'Download Type';

  @override
  String get avgSpeed => 'Average Speed';

  @override
  String get multithread => 'Multithread';

  @override
  String get connections => 'connections';

  @override
  String get multithreadAria2 => 'Multithread (Aria2)';

  @override
  String get standardHttp => 'Standard (HTTP)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Image';

  @override
  String get archive => 'Archive';

  @override
  String get document => 'Document';

  @override
  String get code => 'Code';

  @override
  String get executable => 'Executable';

  @override
  String get file => 'File';

  @override
  String get qualityMode => 'Quality Mode';

  @override
  String get qualityModeSimple => 'Simple';

  @override
  String get qualityModeExpert => 'Expert';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get second => 'second';

  @override
  String get seconds => 'seconds';

  @override
  String get millisecond => 'ms';

  @override
  String get milliseconds => 'ms';

  @override
  String get and => 'and';
}
