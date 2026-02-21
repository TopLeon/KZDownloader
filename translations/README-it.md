<div align="center">
&nbsp;
<p align="center">
  <img src="../assets/logo.png" width="50%"/>
  <br>
</p>

**A beautiful, cross-platform desktop download manager with AI-powered video analysis.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)]()


[English](https://github.com/TopLeon/KZDownloader/blob/main/README.md) &nbsp;•&nbsp; [Italiano](#italian)

</div>

---

> [!WARNING]
> **KZDownloader è attualmente in beta.** Potrebbero essere presenti bug o funzionalità incomplete. Segnala eventuali problemi sull'[issue tracker](../../issues).

<a id="italian"></a>

## Panoramica

KZDownloader è un'applicazione desktop cross-platform realizzata con Flutter per scaricare video, musica e file generici da centinaia di siti web. Integra un assistente AI in grado di riassumere video di YouTube e rispondere a domande su di essi. 

Il design è moderno, minimale e completamente reattivo, con bordi animati a gradiente neon/arcobaleno sulle card di download e sugli elementi interattivi, transizioni fluide e feedback in tempo reale.

## ✨ Funzionalità

### 🎬 Download di Video e Audio
- Scarica video e audio da **YouTube** e centinaia di altre piattaforme grazie a [yt-dlp](https://github.com/yt-dlp/yt-dlp).
- Scegli **formato video** (MP4, MKV) e **qualità** prima del download, con due modalità di selezione:
  - **Semplice**: Migliore · Alta · Media · Bassa
  - **Esperto**: Best · 2160p (4K) · 1440p · 1080p · 720p · 480p
- Scarica interi **playlist di YouTube** con concorrenza configurabile — ogni video è tracciato individualmente.
- Estrazione solo audio in **MP3, M4A, OGG (Vorbis)**.

### 📁 Downloader Generico
- Scaricamento veloce a **chunk multipli**, in stile IDM, per qualsiasi link HTTP/HTTPS diretto.
  - **Writer Isolate**: un Dart isolate dedicato scrive i dati direttamente nella posizione finale del file tramite `RandomAccessFile`, eliminando file temporanei e passaggi I/O ridondanti.
  - **Controllo del backpressure (ackIterator)**: ogni worker di rete attende la conferma di scrittura su disco da parte del Writer Isolate prima di scaricare altri dati — prevenendo crash per Out-of-Memory quando la velocità di rete supera quella di scrittura del disco.
  - **Dynamic Connection Reuse**: al termine del proprio intervallo di byte, una connessione viene immediatamente riassegnata al chunk più lento, mantenendo il massimo numero di connessioni attive in ogni momento per velocità di download costantemente al picco.
- **Ripresa automatica** — i download interrotti riprendono da dove si erano fermati se il server supporta le range request.
- Visualizzazione del progresso per ogni chunk con contatore dei worker attivi e barre di avanzamento per segmento.
- Backend HTTP basato su Rust ([rhttp_plus](https://pub.dev/packages/rhttp_plus)) per la massima velocità e per il **TLS fingerprinting**, che consente di aggirare i sistemi anti-bot su server protetti.

### 🤖 AI — Riassunti e Chat sui Video
- Recupera automaticamente la **trascrizione / descrizione** di un video YouTube e genera un riassunto strutturato tramite LLM.
- Poni **domande di follow-up** in una sessione di chat persistente legata al video — la cronologia Q&A è salvata localmente.
- Supporto per più provider AI:
  - **Ollama** (locale al 100%, nessun dato lascia il dispositivo)
  - **OpenAI** (GPT-3.5-turbo, GPT-4, GPT-4o, …)
  - **Google Gemini** (Gemini 2.5 Pro, Flash, …)
- Output in streaming con rendering Markdown animato.
- Dimensione del contesto configurabile (numero massimo di caratteri inviati all'LLM).

### 🎵 Libreria Musicale e Player
- Scheda **Musica** dedicata con la lista di tutti i file audio scaricati.
- **Player audio** integrato con barra di avanzamento, play/pausa, avanti/indietro e seek.
- **Gestione playlist**: crea playlist con nome personalizzato e aggiungi le tracce.

### 🔒 Sicurezza e Integrità
- **Verifica checksum** (MD5, SHA-256) prima di avviare il download, per garantire l'integrità del file.
- Le chiavi API sono memorizzate nel **secure storage** del sistema operativo (keychain / credential manager).

### ⚙️ Impostazioni e Personalizzazione
- Selezione della **cartella di download** con onboarding al primo avvio.
- Preset predefiniti di **formato**, **qualità** e **formato audio**.
- Tema **Scuro / Chiaro / Sistema** con transizioni fluide.
- **Lingua dell'interfaccia**: Inglese 🇬🇧 e Italiano 🇮🇹.
- Configurazione dei **download simultanei** per playlist e globali.
- Selezione del modello e del provider AI con gestione delle chiavi API.

### 🖥️ Esperienza Desktop
- Interfaccia divisa in sezioni dedicate: **Video**, **Musica** e **File generici** — ognuna con layout, ordinamento e ricerca propri.
- Design moderno, minimale e completamente reattivo con aggiornamenti di progresso in tempo reale.
- **Bordi neon animati** (`RainbowAnimatedBorder`) attorno alle card di download e agli elementi interattivi, renderizzati tramite un `CustomPainter` dedicato.
- Effetti glow glassmorphism sulla schermata iniziale e transizioni fluide nell'intera UI.
- Layout responsive con adattamenti separati per Windows/Linux e macOS.

&nbsp;
<p align="center">
  <img src="../img/1.png" width="45%">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../img/2.png" width="45%">
</p>
&nbsp;
<p align="center">
  <img src="../img/3.png" width="45%">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../img/4.png" width="45%">
</p>
&nbsp;

## ⬇️ Download

I binari precompilati per Windows e macOS sono disponibili direttamente nella sezione [**Releases**](../../releases) — nessun ambiente di build necessario.

> ⚠️ Utenti macOS: poiché l'app è attualmente autofirmata, Gatekeeper la bloccherà al primo avvio. Per eseguirla, fai clic con il pulsante destro del mouse sull'app, seleziona Apri, quindi fai nuovamente clic su Apri nella finestra di dialogo.

## 🏗️ Architettura e Stack Tecnologico

| Livello | Tecnologia |
|---|---|
| UI Framework | Flutter 3.x + Material 3 |
| State Management | flutter_riverpod + riverpod_annotation (code generation) |
| Database Locale | isar_community |
| AI / LLM | langchain, langchain_ollama, langchain_openai, langchain_google |
| Client HTTP | rhttp_plus (FFI basato su Rust, TLS fingerprinting) |
| Metadati Video | youtube_explode_dart + yt-dlp come fallback |
| Riproduzione Audio | just_audio + media_kit (Windows) |
| Secure Storage | flutter_secure_storage |
| Font e Icone | Google Fonts, ultimate_flutter_icons, not_static_icons |
| Localizzazione | Flutter Gen-l10n (file ARB) |

## 📦 Binari Esterni (scaricati automaticamente al primo avvio)

KZDownloader scarica e gestisce automaticamente i seguenti strumenti esterni nella directory di supporto dell'applicazione — nessuna installazione manuale richiesta:

| Binario | Scopo |
|---|---|
| **yt-dlp** | Download di video/audio ed estrazione metadati |
| **ffmpeg** | Post-processing, remuxing ed estrazione audio |
| **deno** | Necessario a ytdlp per estrarre i dati |

## 🚀 Avvio Rapido

### Prerequisiti

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- Target desktop configurato (`flutter config --enable-windows-desktop` / `--enable-macos-desktop` / `--enable-linux-desktop`)

### Installazione

```bash
# Clona il repository
git clone https://github.com/TopLeon/KZDownloader.git
cd KZDownloader

# Installa le dipendenze Flutter
flutter pub get

# Esegui la code generation (Isar + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Avvia sulla tua piattaforma
flutter run -d windows   # oppure macos / linux
```

### Primo Avvio

Al primo avvio KZDownloader:
1. Chiederà di selezionare una **cartella di download predefinita**.
2. Scaricherà automaticamente **yt-dlp** e **ffmpeg** in background.

Per le funzionalità AI, apri le **Impostazioni** e scegli un provider:
- **Ollama**: installa [Ollama](https://ollama.com) in locale e scarica un modello (es. `ollama pull llama3`).
- **OpenAI / Google**: inserisci la tua chiave API nel pannello Impostazioni o al primo avvio — verrà salvata nel keychain del sistema operativo.

## 📋 Piattaforme Supportate

| Piattaforma | Stato |
|---|---|
| Windows | ✅ Pieno supporto |
| macOS | ✅ Pieno supporto (layout adattato) |
| Linux | ⚠️ Bisogna testare |
| Android / iOS | ❌ Non supportato |

## 🗂️ Struttura del Progetto

```
lib/
├── main.dart                  # Entry point, schermata di avvio
├── core/
│   ├── download/
│   │   ├── logic/             # ChunkDownloader, IDMDownloader, YtDlpService
│   │   ├── providers/         # Provider Riverpod per i download
│   │   └── strategies/        # Strategie di download (IDM, yt-dlp, playlist, standard)
│   ├── providers/             # Provider tema, lingua, qualità
│   ├── services/              # DB, LLM, audio player, impostazioni, secure storage
│   ├── theme/                 # Temi Material 3 (chiaro/scuro)
│   └── utils/                 # BinaryManager, ChecksumVerifier, FileUtils
├── models/                    # Modelli Isar (DownloadTask, Playlist)
├── views/
│   ├── chat/                  # UI principale: home, lista contenuti, musica, chat
│   ├── settings/              # Schermata impostazioni
│   └── widgets/               # Dialog e widget condivisi
└── l10n/arb/                  # Localizzazione (EN / IT)
```

## 🗺️ Roadmap

| Funzionalità | Stato |
|---|---|
| **Integrazione con il browser** — cattura i download direttamente da Chrome / Firefox tramite un'estensione companion | 🔜 In programma |
| **Supporto streaming HLS / M3U8** — download e remux di stream video adattivi | 🔜 In programma |

## 🤝 Contribuire

Contributi, segnalazioni di bug e richieste di funzionalità sono benvenuti. Apri una issue o invia una pull request.

The maintainer of KZDownloader cannot be held liable for misuse of this application, as stated in the GPL-3.0 license (section 16).
The usage of this application may also cause a violation of the Terms of Service between you and the stream provider.
Users are personally responsible for ensuring they use this software fairly and within legal boundaries.