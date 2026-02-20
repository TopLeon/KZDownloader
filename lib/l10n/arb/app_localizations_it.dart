// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'KzDownloader';

  @override
  String get initialization => 'Inizializzazione...';

  @override
  String get checkingComponents =>
      'Controllo componenti (yt-dlp, ffmpeg, deno)...';

  @override
  String get downloadingYtDlp => 'Download yt-dlp...';

  @override
  String get downloadingFfmpeg => 'Download ffmpeg...';

  @override
  String get downloadingDeno => 'Download deno (JS Runtime)...';

  @override
  String get checkingDownloadPath => 'Verifica cartella di download...';

  @override
  String startupError(Object error) {
    return 'Errore durante l\'avvio: $error';
  }

  @override
  String get initialConfiguration => 'Configurazione Iniziale';

  @override
  String get selectDownloadFolderMessage =>
      'Per favore, seleziona la cartella dove vuoi salvare i tuoi download.';

  @override
  String get chooseFolder => 'Scegli Cartella';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get retry => 'Riprova';

  @override
  String get retrying => 'Riprovo...';

  @override
  String get error => 'Errore';

  @override
  String get onboardingTitle => 'Benvenuto in KzDownloader';

  @override
  String get onboardingContent =>
      'Configura le tue preferenze di download per iniziare.';

  @override
  String get btnGoSettings => 'Vai alle Impostazioni';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get downloadPath => 'Percorso Download';

  @override
  String get defaultFormat => 'Formato Video Predefinito';

  @override
  String get defaultAudioFormat => 'Formato Audio Predefinito';

  @override
  String get defaultQuality => 'Qualità Predefinita';

  @override
  String get language => 'Lingua';

  @override
  String get chatTitle => 'Chatta per Scaricare';

  @override
  String get pasteLink => 'Incolla un link per iniziare a scaricare';

  @override
  String get pasteLinkHint => 'Incolla il link qui...';

  @override
  String get aiMagicHint =>
      'Chiedi all\'AI (es. \'Solo audio alta qualità\')...';

  @override
  String get videoOptions => 'Opzioni Video';

  @override
  String get qualityBest => 'Migliore';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityMedium => 'Media';

  @override
  String get qualityLow => 'Bassa';

  @override
  String get actionDownload => 'Scarica';

  @override
  String get actionSummarize => 'Riassumi';

  @override
  String get actionBoth => 'Entrambi';

  @override
  String get downloadModelTitle => 'Scarica Modello AI';

  @override
  String get downloadModelContent =>
      'Per usare le funzioni AI, è necessario scaricare un piccolo modello (~800MB). Continuare?';

  @override
  String get btnCancel => 'Annulla';

  @override
  String get btnDownload => 'Scarica';

  @override
  String get downloadingModel => 'Scaricamento Modello...';

  @override
  String get videoSummaryTitle => 'Riassunto Video';

  @override
  String get summaryShort => 'Breve';

  @override
  String get summaryLong => 'Report (Lungo)';

  @override
  String get btnClose => 'Chiudi';

  @override
  String get errorPrefix => 'Errore: ';

  @override
  String get aiError => 'Errore AI: ';

  @override
  String get providerAuto => 'Rilevamento Auto';

  @override
  String get statusInitializing => 'Inizializzazione...';

  @override
  String get statusCheckingBinaries => 'Controllo binari...';

  @override
  String get statusReady => 'Pronto';

  @override
  String get btnContinue => 'Continua';

  @override
  String get actionSummarizeOnly => 'Solo Riassunto';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Predefinito di Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get newDownload => 'Nuovo Download';

  @override
  String get general => 'Generale';

  @override
  String get downloads => 'Download';

  @override
  String get clearHistoryTitle => 'Cancellare Cronologia?';

  @override
  String get clearHistoryContent =>
      'Questo rimuoverà tutti i record di download. I file non verranno eliminati.';

  @override
  String get historyCleared => 'Cronologia cancellata';

  @override
  String get clear => 'Cancella';

  @override
  String get dataStorage => 'Dati e Archiviazione';

  @override
  String get clearDownloadHistory => 'Cancella cronologia download';

  @override
  String get clearDownloadHistorySubtitle =>
      'Rimuovi tutti i download completati dalla lista';

  @override
  String get emptyVideoLibrary => 'Libreria Video Vuota';

  @override
  String get emptyVideoLibrarySubtitle =>
      'Cerca un video su YouTube e incollalo qui';

  @override
  String get emptyMusicLibrary => 'Nessuna Musica';

  @override
  String get emptyMusicLibrarySubtitle =>
      'Scarica la tua prima canzone o playlist';

  @override
  String get emptyGenericLibrary => 'Archivio Vuoto';

  @override
  String get emptyGenericLibrarySubtitle =>
      'Nessun file scaricato in questa sezione';

  @override
  String get emptySummaryLibrary => 'Nessun Riassunto';

  @override
  String get emptySummaryLibrarySubtitle =>
      'Genera un riassunto con l\'AI in locale';

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryMusic => 'Musica';

  @override
  String get categoryFiles => 'File';

  @override
  String get categorySummaries => 'Riassunti';

  @override
  String get providerAutoDesc => 'Selezione intelligente';

  @override
  String get providerStandardDesc => 'Veloce per file piccoli';

  @override
  String get providerProDesc => 'Multi-thread, Resume';

  @override
  String get selectProvider => 'Seleziona Provider';

  @override
  String get optionVideo => 'Video';

  @override
  String get optionAudio => 'Musica';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get analyzing => 'Analisi in corso...';

  @override
  String downloadedWith(Object provider, Object time) {
    return 'Scaricato con $provider in $time';
  }

  @override
  String get openFolder => 'Cartella';

  @override
  String get regenerate => 'Rigenera Riassunto';

  @override
  String get cancel => 'Annulla';

  @override
  String ofTotalSize(Object totalSize) {
    return 'di $totalSize';
  }

  @override
  String proDownloading(Object workers) {
    return 'Download Pro con $workers Thread';
  }

  @override
  String get aiAnalyzing => 'L\'AI sta analizzando il video...';

  @override
  String get readLess => 'Riduci';

  @override
  String get readMore => 'Leggi tutto';

  @override
  String get headerVideoTitle => 'Video';

  @override
  String get headerVideoDesc => 'YouTube, Vimeo, Twitch & altro';

  @override
  String get headerMusicTitle => 'Musica';

  @override
  String get headerMusicDesc => 'Spotify, SoundCloud & File Audio';

  @override
  String get headerFileTitle => 'Generale';

  @override
  String get headerFileDesc => 'Download diretti, Torrent & Documenti';

  @override
  String get headerSummaryTitle => 'Riassunti';

  @override
  String get headerSummaryDesc => 'Riassunti generati dai video';

  @override
  String get actionEmpty => 'Svuota';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionPause => 'Pausa';

  @override
  String get actionResume => 'Riprendi';

  @override
  String get actionCopy => 'Copia';

  @override
  String get statusCopied => 'Copiato!';

  @override
  String get searchTooltip => 'Cerca nella lista';

  @override
  String get searchPlaceholder => 'Link, titolo o data...';

  @override
  String get searchButton => 'Cerca';

  @override
  String get searchComingSoon => 'Funzione ricerca in arrivo...';

  @override
  String get fileNotFound => 'File non trovato';

  @override
  String get stepInitialization => 'Inizializzazione';

  @override
  String get stepMetadata => 'Recupero Metadati';

  @override
  String get stepDownloading => 'Download in corso';

  @override
  String get stepProcessing => 'Elaborazione';

  @override
  String get stepSubtitles => 'Estrazione Sottotitoli';

  @override
  String get stepSummary => 'Generazione Riassunto';

  @override
  String get stepCompleted => 'Completato';

  @override
  String get categoriesTitle => 'Categoria';

  @override
  String get headerInProgressTitle => 'In corso';

  @override
  String get headerInProgressDesc => 'Qui vengono mostrati i download in corso';

  @override
  String get unknownChannel => 'Canale Sconosciuto';

  @override
  String get headerFailedTitle => 'Falliti';

  @override
  String get headerFailedDesc => 'Qualche volta può capitare di inciampare';

  @override
  String get modeDownload => 'Download';

  @override
  String get modeSummary => 'Riassunto';

  @override
  String get pasteLinkSummaryHint => 'Incolla link da riassumere...';

  @override
  String get library => 'Libreria';

  @override
  String get downloadingTitle => 'Scaricamento';

  @override
  String get settings => 'Impostazioni';

  @override
  String get fullSummary => 'Riassunto Esecutivo';

  @override
  String get noSummaryAvailable => 'Nessun riassunto disponibile.';

  @override
  String get videoInfo => 'Informazioni sul video';

  @override
  String get selectVideoToStart => 'Seleziona un video per iniziare';

  @override
  String get askSomethingAboutVideo => 'Chiedi qualcosa sul video...';

  @override
  String get unknownTitle => 'Titolo Sconosciuto';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get goToChat => 'Vai alla Chat';

  @override
  String get showSummary => 'Mostra Riassunto';

  @override
  String get fullReport => '📄 Report Completo';

  @override
  String get keyPoints => '🔑 Punti Chiave';

  @override
  String get goals => '🎯 Obiettivi';

  @override
  String get conclusions => '❓ Conclusioni';

  @override
  String get labelTitle => 'Titolo';

  @override
  String get labelChannel => 'Canale';

  @override
  String get labelDescription => 'Descrizione';

  @override
  String get labelTranscript => 'Trascrizione';

  @override
  String get noDescriptionAvailable => 'Nessuna descrizione disponibile.';

  @override
  String get noTranscriptAvailable => 'Nessuna trascrizione disponibile.';

  @override
  String get chatEmptyState => 'Fai qualsiasi domanda sul video.';

  @override
  String get aiModelOllama => 'Modello AI (Ollama)';

  @override
  String get ollamaNotDetected => 'Ollama non rilevato';

  @override
  String ollamaError(Object error) {
    return 'Assicurati che Ollama sia in esecuzione.\nErrore: $error';
  }

  @override
  String get noModelsFound => 'Nessun modello trovato';

  @override
  String get downloadModelHint =>
      'Scarica un modello (es. \'llama3\') via terminale: \'ollama pull llama3\'';

  @override
  String get selectModel => 'Seleziona un modello';

  @override
  String get aiSectionTitle => 'AI (Ollama)';

  @override
  String get aiProvider => 'Provider AI';

  @override
  String get aiProviderOllama => 'Ollama';

  @override
  String get aiProviderOpenAI => 'OpenAI';

  @override
  String get aiProviderGoogle => 'Google AI';

  @override
  String get openAiApiKey => 'Chiave API OpenAI';

  @override
  String get openAiApiKeyHint => 'sk-...';

  @override
  String get googleAiApiKey => 'Chiave API Google AI';

  @override
  String get googleAiApiKeyHint => 'AIza...';

  @override
  String get apiKeySaved => 'Chiave API salvata';

  @override
  String get categoryHome => 'Home';

  @override
  String get etaPlaceholder => '--:--';

  @override
  String get defaultChannelName => 'Canale Sconosciuto';

  @override
  String get defaultDownloadPath => 'Predefinito (Cartella Download)';

  @override
  String get versionInfo => 'Versione 1.0.0 • Build 2026.2';

  @override
  String get copyright => '© 2026 KZDownloader by Le0nZ (github.com/topleon)';

  @override
  String get eta => 'Tempo rimasto';

  @override
  String get aiModelRecommended => 'Modello AI consigliato';

  @override
  String get aiModelDescription =>
      'Per utilizzare le funzioni di riassunto, è consigliato installare il modello \'Gemma 3 QAT\'.';

  @override
  String get aiModelSizeWarning => 'Richiede ~3GB di spazio';

  @override
  String get aiModelManualSelection => 'Scegli manualmente dopo';

  @override
  String get aiModelInstallAndStart => 'Installa e avvia';

  @override
  String get aiModelInstalling => 'Installazione in corso...';

  @override
  String get aiModelInstallationDescription =>
      'Il download avverrà in una finestra di terminale esterna o in background. Attendi il completamento.';

  @override
  String get inputFormat => 'FORMATO';

  @override
  String get inputQuality => 'QUALITÀ';

  @override
  String get untitled => 'Senza Titolo';

  @override
  String get downloaded => 'Scaricato';

  @override
  String get deleted => 'Cancellato';

  @override
  String get play => 'Riproduci';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get beta => 'BETA';

  @override
  String get executiveSummary => 'Riassunto Esecutivo';

  @override
  String get generating => 'Generazione...';

  @override
  String get generateAiSummary => 'Genera Riassunto';

  @override
  String get showAll => 'Mostra tutto';

  @override
  String get chatWithVideo => 'Chatta col Video';

  @override
  String get aiNotAvailableForNonYoutube =>
      'Le funzionalità AI sono disponibili solo per contenuti YouTube supportati. Il video si può riassumere anche in seguito al download.';

  @override
  String get noPlaylistsCreated => 'Nessuna playlist creata.';

  @override
  String addedToPlaylist(String name) {
    return 'Aggiunto a $name';
  }

  @override
  String get openAi => 'OpenAI';

  @override
  String get selectLanguageTitle => 'Seleziona Lingua';

  @override
  String get english => 'English';

  @override
  String get italiano => 'Italiano';

  @override
  String get generateSummaryFirst => 'Genera prima il riassunto';

  @override
  String get deleteFile => 'Elimina File';

  @override
  String get actionOpen => 'Apri';

  @override
  String get deleteTaskTitle => 'Elimina Task';

  @override
  String get deleteTaskConfirmation =>
      'Sei sicuro di voler eliminare questa task? L\'operazione non può essere annullata.';

  @override
  String playlistInfo(Object count, Object date) {
    return '$count brani • Creata il $date';
  }

  @override
  String get optionBestQuality => 'Migliore Qualità';

  @override
  String get btnAddUrl => 'Aggiungi URL';

  @override
  String get searchPromptMusic => 'Cerca brani, artisti o titoli...';

  @override
  String get searchPromptVideo => 'Cerca video, titoli o url...';

  @override
  String get searchPromptPlaylist => 'Cerca playlist, titoli o url...';

  @override
  String get searchPromptGeneric => 'Cerca url, nomi o tipi...';

  @override
  String get searchPromptDefault => 'Cerca download, URL o prompt AI...';

  @override
  String get newPlaylistTitle => 'Nuova Playlist';

  @override
  String get playlistNameHint => 'Nome playlist';

  @override
  String get btnCreate => 'Crea';

  @override
  String get aiSmartPlaylists => 'Playlist';

  @override
  String get yourLibrary => 'La tua Libreria';

  @override
  String get sortBy => 'Ordina per: ';

  @override
  String get sortDateAdded => 'Data Aggiunta';

  @override
  String get sortArtist => 'Artista';

  @override
  String get sortBitrate => 'Bitrate';

  @override
  String get noMusicFound => 'Nessuna musica trovata';

  @override
  String get btnBackToDetails => 'Torna ai dettagli';

  @override
  String get videoAnalysis => 'Analisi del video';

  @override
  String get selectVideoToViewDetails =>
      'Seleziona un video per vedere i dettagli';

  @override
  String get selectFileToViewDetails =>
      'Seleziona un file per vedere i dettagli';

  @override
  String get aiFeatureYouTubeOnly =>
      'Le funzionalità AI sono disponibili solo per contenuti YouTube supportati.';

  @override
  String get removeFromPlaylistTitle => 'Rimuovi dalla Playlist';

  @override
  String removeFromPlaylistContent(Object title) {
    return 'Vuoi rimuovere \'$title\' dalla playlist? Il file rimarrà nel dispositivo.';
  }

  @override
  String get btnRemove => 'Rimuovi';

  @override
  String get addSongsTitle => 'Aggiungi Brani';

  @override
  String get subSearchSong => 'Cerca brano...';

  @override
  String get noSongsFound => 'Nessun brano trovato';

  @override
  String get btnAdd => 'Aggiungi';

  @override
  String btnAddCount(Object count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get videoChatDesc => 'Fai domande al video';

  @override
  String get chatDisabled => 'Chat Disabilitata';

  @override
  String get playlistEmpty => 'Questa playlist è vuota';

  @override
  String get addMusic => 'Aggiungi Musica';

  @override
  String get settingsAI => 'Intelligenza Artificiale';

  @override
  String get settingsAISubtitle =>
      'Crea automaticamente riassunti e risposte intelligenti per i tuoi download';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsAppearanceSubtitle => 'Scegli un tema per l\'interfaccia';

  @override
  String get summaryAnimations => 'Animazioni Riassunto';

  @override
  String get summaryAnimationsSubtitle =>
      'Abilita testo animato per i riassunti';

  @override
  String get settingsDataStorage => 'Dati e Archiviazione';

  @override
  String get settingsGeneral => 'Generale';

  @override
  String get settingsGeneralSubtitle => 'Gestisci le tue preferenze generali';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSubtitle =>
      'Seleziona la lingua dell\'applicazione';

  @override
  String get settingsDownloadPath => 'Percorso di download';

  @override
  String get settingsDownloadPathSubtitle =>
      'Scegli dove salvare i file scaricati';

  @override
  String get settingsFormat => 'Formato';

  @override
  String get settingsFormatSubtitle => 'Seleziona il formato audio/video';

  @override
  String get settingsResolution => 'Risoluzione';

  @override
  String get settingsResolutionSubtitle => 'Qualità del download video';

  @override
  String get selectThemeTitle => 'Seleziona Tema';

  @override
  String get clearHistoryConfirmTitle => 'Cancellare Cronologia?';

  @override
  String get clearHistoryConfirmMessage =>
      'Questa azione non può essere annullata. Sei sicuro di voler rimuovere tutti i download dalla cronologia?';

  @override
  String get btnClear => 'Cancella';

  @override
  String get copyText => 'Copia Testo';

  @override
  String get downloadPathDescription =>
      'Tutti i file scaricati verranno salvati qui automaticamente.';

  @override
  String get settingsPageDescription =>
      'Gestisci le tue preferenze generali, configurazioni del motore AI e aspetto dell\'interfaccia.';

  @override
  String get enterNamePlaceholder => 'Inserisci il nome...';

  @override
  String get deleteTask => 'Elimina Task';

  @override
  String get deleteTaskConfirmMessage =>
      'Sei sicuro di voler eliminare questa task? L\'operazione non può essere annullata.';

  @override
  String get linkCopied => 'Link copiato';

  @override
  String get addToPlaylist => 'Aggiungi a Playlist';

  @override
  String get copyLink => 'Copia Link';

  @override
  String get delete => 'Elimina';

  @override
  String get summarized => 'Riassunto';

  @override
  String get backToPlaylist => 'Torna alla playlist';

  @override
  String get playlistVideo => 'Video della Playlist';

  @override
  String get playlist => 'Playlist';

  @override
  String get noVideosFound => 'Nessun video trovato';

  @override
  String videoNumber(String number) {
    return 'Video $number';
  }

  @override
  String get noTracksToAdd => 'Nessuna traccia disponibile da aggiungere';

  @override
  String get removeFromPlaylist => 'Rimuovi dalla Playlist';

  @override
  String removeTrackConfirmMessage(String title) {
    return 'Sei sicuro di voler rimuovere \"$title\" da questa playlist?';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get track => 'brano';

  @override
  String get tracks => 'brani';

  @override
  String createdOnDate(String date) {
    return 'Creato il $date';
  }

  @override
  String get searchTracksPlaceholder => 'Cerca tracce...';

  @override
  String get selectedTrackSingular => 'traccia selezionata';

  @override
  String get selectedTracksPlural => 'tracce selezionate';

  @override
  String get noTracksFound => 'Nessuna traccia trovata';

  @override
  String addWithCount(String count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get linkCopiedToClipboard => 'Link copiato negli appunti';

  @override
  String get deletePlaylist => 'Elimina Playlist';

  @override
  String get deletePlaylistConfirmMessage =>
      'Sei sicuro di voler eliminare questa playlist e tutti i suoi video? L\'operazione non può essere annullata.';

  @override
  String get unknownArtist => 'Artista Sconosciuto';

  @override
  String get unknownAlbum => 'Album Sconosciuto';

  @override
  String get concurrentDownloadsPlaylist => 'Download Concorrenti (Playlist)';

  @override
  String get maxConcurrentDownloadsDescription =>
      'Numero massimo di video scaricati contemporaneamente';

  @override
  String get maxCharactersForAI => 'Caratteri Massimi per AI';

  @override
  String get maxCharactersForAIDescription =>
      'Numero massimo di caratteri da usare per riassunto e chat AI';

  @override
  String get unknownFile => 'File Sconosciuto';

  @override
  String get renamePlaylist => 'Rinomina Playlist';

  @override
  String get playlistNamePlaceholder => 'Nome playlist';

  @override
  String get save => 'Salva';

  @override
  String get deletePlaylistTitle => 'Elimina Playlist';

  @override
  String deletePlaylistContent(String name) {
    return 'Sei sicuro di voler eliminare la playlist \'$name\'? I file non verranno cancellati.';
  }

  @override
  String get rename => 'Rinomina';

  @override
  String get deleteTrackTitle => 'Elimina Brano';

  @override
  String deleteTrackContent(String title) {
    return 'Sei sicuro di voler eliminare \'$title\'? I file non verranno cancellati.';
  }

  @override
  String get unknownTrack => 'Traccia Sconosciuta';

  @override
  String get downloadAction => 'Scarica';

  @override
  String get newPlaylist => 'Nuova Playlist';

  @override
  String get openFolderTooltip => 'Apri Cartella';

  @override
  String get copyLinkTooltip => 'Copia Link';

  @override
  String get deleteTooltip => 'Elimina';

  @override
  String get playlistSection => 'Playlist';

  @override
  String get musicSection => 'Musica';

  @override
  String get recentSection => 'Recenti';

  @override
  String get genericSection => 'Generale';

  @override
  String get inprogressSection => 'In Corso';

  @override
  String get failedSection => 'Falliti';

  @override
  String get summarySection => 'Riassunti';

  @override
  String get titleColumn => 'TITOLO';

  @override
  String get artistColumn => 'ARTISTA';

  @override
  String get albumColumn => 'ALBUM';

  @override
  String get durationColumn => 'DURATA';

  @override
  String get formatColumn => 'FORMATO';

  @override
  String get videoSection => 'Video';

  @override
  String get playlistNameEditHint =>
      'Il nome potrà essere modificato in un secondo momento.';

  @override
  String get almostReady => 'Ho quasi finito...';

  @override
  String get downloadingMetadata => 'Sto scaricando i metadati...';

  @override
  String get metadataReady => 'Metadati ottenuti! Pronto per scaricare';

  @override
  String get readyToDownload => 'Pronto per scaricare';

  @override
  String createdOn(String date) {
    return 'Creato il $date';
  }

  @override
  String tracksCount(String count) {
    return '$count BRANI';
  }

  @override
  String get addMusicUrl => 'Aggiungi URL Musica';

  @override
  String get pasteMusicLink => 'Incolla link YouTube/SoundCloud...';

  @override
  String get addToPlaylistTooltip => 'Aggiungi a Playlist';

  @override
  String get aiConfiguration => 'Configurazione AI';

  @override
  String get ollamaDetected => 'Ollama rilevato! Scegli il tuo provider AI:';

  @override
  String get configureAiFeatures =>
      'Configura le funzioni AI per abilitare riassunti video e chat:';

  @override
  String get useOllama => 'Usa Ollama';

  @override
  String get ollamaLocalFree => 'AI locale gratuita (già installata ✓)';

  @override
  String get ollamaNeedsInstall =>
      'AI locale gratuita (richiede installazione)';

  @override
  String get useOpenAI => 'Usa OpenAI';

  @override
  String get openAiDescription => 'Modelli GPT, standard industriale';

  @override
  String get useGoogleAI => 'Usa Google AI';

  @override
  String get googleAiDescription => 'Modelli Gemini, veloci e potenti';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get configureInSettings => 'Configura dopo nelle Impostazioni';

  @override
  String get useGoogle => 'Google';

  @override
  String get skip => 'Salta';

  @override
  String get selectAiModel => 'Seleziona Modello AI';

  @override
  String get chooseModel =>
      'Ollama è installato! Scegli un modello per le funzioni AI:';

  @override
  String get recommended => 'Consigliato';

  @override
  String get installAiModel => 'Installa Modello AI';

  @override
  String get installModelMessage =>
      'Ollama è installato ma non sono stati trovati modelli. Raccomandiamo Gemma 3 4B per il miglior equilibrio tra velocità e qualità.';

  @override
  String get sizeLabel => 'Dimensione: ~2.5 GB';

  @override
  String get installGemma => 'Installa Gemma 3 4B';

  @override
  String get openAiApiKeyTitle => 'Chiave API OpenAI';

  @override
  String get enterOpenAiKey =>
      'Inserisci la tua chiave API OpenAI per usare le funzioni AI:';

  @override
  String get apiKeyLabel => 'Chiave API';

  @override
  String get getApiKeyOpenAI => 'Ottieni Chiave API da OpenAI';

  @override
  String get googleAiApiKeyTitle => 'Chiave API Google AI';

  @override
  String get enterGoogleKey =>
      'Inserisci la tua chiave API Google AI per usare i modelli Gemini:';

  @override
  String get getApiKeyGoogle => 'Ottieni Chiave API da Google AI Studio';

  @override
  String get installOllamaTitle => 'Installa Ollama';

  @override
  String get installOllamaMessage =>
      'Per usare le funzioni AI locali, devi installare Ollama:';

  @override
  String get visitOllama => '1. Visita ollama.com';

  @override
  String get downloadInstall => '2. Scarica e installa';

  @override
  String get restartApp => '3. Riavvia questa app';

  @override
  String get openOllamaWebsite => 'Apri ollama.com';

  @override
  String get installingAiModel => 'Installazione Modello AI';

  @override
  String get openingTerminal =>
      'Apertura del terminale per installare il modello. Potrebbero volerci alcuni minuti...';

  @override
  String get loadingAiConfig => 'Caricamento configurazione AI...';

  @override
  String get downloadInfo => 'Informazioni';

  @override
  String get fileType => 'Tipo File';

  @override
  String get fileSize => 'Dimensione';

  @override
  String get downloadTime => 'Tempo di Download';

  @override
  String get downloadType => 'Tipo di Download';

  @override
  String get avgSpeed => 'Velocità Media';

  @override
  String get multithread => 'Multithread';

  @override
  String get connections => 'connessioni';

  @override
  String get multithreadAria2 => 'Multithread (Aria2)';

  @override
  String get standardHttp => 'Standard (HTTP)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Immagine';

  @override
  String get archive => 'Archivio';

  @override
  String get document => 'Documento';

  @override
  String get code => 'Codice';

  @override
  String get executable => 'Eseguibile';

  @override
  String get file => 'File';

  @override
  String get qualityMode => 'Modalità Qualità';

  @override
  String get qualityModeSimple => 'Semplice';

  @override
  String get qualityModeExpert => 'Esperta';

  @override
  String get hour => 'ora';

  @override
  String get hours => 'ore';

  @override
  String get minute => 'minuto';

  @override
  String get minutes => 'minuti';

  @override
  String get second => 'secondo';

  @override
  String get seconds => 'secondi';

  @override
  String get millisecond => 'ms';

  @override
  String get milliseconds => 'ms';

  @override
  String get and => 'e';

  @override
  String get concurrentDownloadsGlobal => 'Download Concorrenti (Globale)';

  @override
  String get concurrentDownloadsGlobalDesc =>
      'Numero massimo di file scaricati contemporaneamente';

  @override
  String get checksumLabel => 'Checksum (opzionale)';

  @override
  String get checksumHint => 'Se vuoi incolla hash MD5 o SHA256...';

  @override
  String get checksumAlgorithm => 'Algoritmo';

  @override
  String get checksumMatch => 'Checksum verificato';

  @override
  String get checksumMismatch => 'Checksum non corrisponde';

  @override
  String get checksumVerifying => 'Verifica checksum...';

  @override
  String get checksumError => 'Errore Checksum';

  @override
  String get linkExpired => 'Link scaduto (403)';

  @override
  String get linkExpiredMessage =>
      'Il link di download è scaduto. Inserisci un nuovo URL per riprendere.';

  @override
  String get updateUrl => 'Aggiorna URL';

  @override
  String get updateUrlTitle => 'Aggiorna URL Download';

  @override
  String get updateUrlContent =>
      'Il link di download è scaduto. Incolla un nuovo URL per riprendere il download da dove si era fermato.';

  @override
  String get updateUrlHint => 'Incolla nuovo URL...';

  @override
  String diskSpaceFree(String space) {
    return '$space liberi';
  }

  @override
  String insufficientDiskSpace(String available, String required) {
    return 'Spazio su disco insufficiente';
  }

  @override
  String get cancelDownload => 'Annulla';

  @override
  String get cancelDownloadTooltip => 'Annulla Download';

  @override
  String get queued => 'In coda';

  @override
  String get diskSpace => 'Spazio su disco';

  @override
  String get folderNotSelected => 'Nessuna cartella selezionata';
}
