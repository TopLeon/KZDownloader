<div align="center">

# KZDownloader

**A beautiful, cross-platform desktop download manager with AI-powered video analysis.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)]()

---

🇬🇧 [English](#english) &nbsp;•&nbsp; 🇮🇹 [Italiano](#italiano)

</div>

---

<a id="english"></a>

## 🇬🇧 English

### Overview

KZDownloader is a cross-platform desktop application built with Flutter that lets you download videos, music, and generic files from hundreds of websites. It integrates a powerful AI assistant that can summarize YouTube video content and answer questions about it.

The interface is organized into dedicated sections — **Videos**, **Music**, and **Generic files** — each with its own tailored view and controls. The design is modern, minimal, and fully reactive, featuring animated neon/rainbow gradient borders on download cards and interactive elements, smooth transitions, and real-time progress feedback.

---

### ✨ Features

#### 🎬 Video & Audio Downloads
- Download videos and audio from **YouTube** and hundreds of other platforms powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp).
- Choose **video format** (MP4, MKV) and **quality** before downloading, with two selector modes:
  - **Simple**: Best · High · Medium · Low
  - **Expert**: 2160p (4K) · 1440p · 1080p · 720p · 480p
- Download entire **YouTube playlists** with configurable concurrency — each video is tracked individually.
- Audio-only extraction to **MP3, M4A, OGG (Vorbis)**.

#### 📁 Generic File Downloader (IDM-like)
- Multi-threaded, **IDM-style chunked download** for any direct HTTP/HTTPS link.
- Automatic **resume support** — interrupted downloads pick up where they left off if the server supports range requests.
- Per-chunk progress visualization with active worker count and individual segment progress bars.
- Built on a Rust-based HTTP backend ([rhttp_plus](https://pub.dev/packages/rhttp_plus)) for maximum throughput and **TLS fingerprinting** to avoid bot-detection on protected servers.

#### 🤖 AI — Video Summaries & Chat
- Automatically fetch the **transcript / description** of a YouTube video and generate a structured summary using an LLM.
- Ask **follow-up questions** in a persistent chat session tied to the video — Q&A history is saved locally.
- Support for multiple AI providers:
  - **Ollama** (fully local, no data leaves the machine)
  - **OpenAI** (GPT-3.5-turbo, GPT-4, GPT-4o, …)
  - **Google Gemini** (Gemini 2.5 Pro, Flash, …)
- Streaming text output with animated Markdown rendering.
- Configurable context size (max characters fed to the LLM).

#### 🎵 Music Library & Player
- Dedicated **Music** tab listing all downloaded audio files.
- Built-in **audio player** with a progress bar, play/pause, skip, and seek controls.
- **Playlist management**: create named playlists and add tracks to them.

#### 🔒 Security & Integrity
- **Checksum verification** (MD5, SHA-1, SHA-256, SHA-512) before triggering a download, ensuring file integrity.
- API keys stored in **secure storage** (OS keychain / credential manager).

#### ⚙️ Settings & Customisation
- **Download directory** selection with onboarding prompt on first launch.
- Default **format**, **quality**, and **audio format** presets.
- **Dark / Light / System** theme with smooth transitions.
- **Interface language**: English 🇬🇧 and Italian 🇮🇹.
- Configurable **concurrent downloads** per-playlist and globally.
- AI model and provider selection with API key management.

#### 🖥️ Desktop Experience
- Interface split into dedicated sections: **Videos**, **Music**, and **Generic files** — each with its own layout, sorting, and search.
- Modern, minimal, and fully reactive design with real-time progress updates.
- Animated **neon gradient borders** (`RainbowAnimatedBorder`) around download cards and interactive elements, rendered via a custom `CustomPainter`.
- Glassmorphism glow blobs on the home screen and smooth CSS-style transitions throughout.
- Responsive layout with separate view adaptations for Windows/Linux and macOS.

---

### 🏗️ Architecture & Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x + Material 3 |
| State Management | flutter_riverpod + riverpod_annotation (code generation) |
| Local Database | isar_community |
| AI / LLM | langchain, langchain_ollama, langchain_openai, langchain_google |
| HTTP Client | rhttp_plus (Rust-based FFI, TLS fingerprinting) |
| Video Metadata | youtube_explode_dart + yt-dlp fallback |
| Audio Playback | just_audio + media_kit (Windows) |
| Secure Storage | flutter_secure_storage |
| Fonts & Icons | Google Fonts, ultimate_flutter_icons, not_static_icons |
| Localisation | Flutter Gen-l10n (ARB files) |

---

### 📦 External Binaries (auto-downloaded on first launch)

KZDownloader automatically downloads and manages the following external tools into the app's support directory — no manual installation required:

| Binary | Purpose |
|---|---|
| **yt-dlp** | Video/audio download and metadata extraction |
| **ffmpeg** | Post-processing, remuxing, and audio extraction |
| **deno** | Scripting support for advanced operations |

---

### � Download

Pre-compiled binaries for Windows, macOS, and Linux are available directly in the [**Releases**](../../releases) section — no build environment needed.

---

### �🚀 Getting Started

#### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- A desktop target configured (`flutter config --enable-windows-desktop` / `--enable-macos-desktop` / `--enable-linux-desktop`)

#### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/KZDownloader.git
cd KZDownloader

# Install Flutter dependencies
flutter pub get

# Run code generation (Isar + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Launch on your platform
flutter run -d windows   # or macos / linux
```

#### First Launch

On the first run KZDownloader will:
1. Ask you to select a **default download directory**.
2. Automatically download **yt-dlp** and **ffmpeg** in the background.

For AI features, open **Settings** and choose an AI provider:
- **Ollama**: install [Ollama](https://ollama.com) locally and pull a model (e.g. `ollama pull llama3`).
- **OpenAI / Google**: enter your API key in the Settings panel — it is stored securely in the OS keychain.

---

### 📋 Supported Platforms

| Platform | Status |
|---|---|
| Windows | ✅ Full support |
| macOS | ✅ Full support (adapted layout) |
| Linux | ✅ Full support |
| Android / iOS | ⚠️ Experimental (not primary target) |

---

### 🗂️ Project Structure

```
lib/
├── main.dart                  # App entry point, startup screen
├── core/
│   ├── download/
│   │   ├── logic/             # ChunkDownloader, IDMDownloader, YtDlpService
│   │   ├── providers/         # Riverpod download providers
│   │   └── strategies/        # Download strategies (IDM, yt-dlp, playlist, standard)
│   ├── providers/             # Theme, locale, quality providers
│   ├── services/              # DB, LLM, audio player, settings, secure storage
│   ├── theme/                 # Material 3 light/dark themes
│   └── utils/                 # BinaryManager, ChecksumVerifier, FileUtils
├── models/                    # Isar models (DownloadTask, Playlist)
├── views/
│   ├── chat/                  # Main UI: home, content list, music, chat screens
│   ├── settings/              # Settings screen
│   └── widgets/               # Shared dialogs and widgets
└── l10n/arb/                  # Localisation (EN / IT)
```

---

### 🤝 Contributing

Contributions, bug reports and feature requests are welcome. Please open an issue or submit a pull request.

---

### 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)** — see the [LICENSE](LICENSE) file for details.

---

<a id="italiano"></a>

## 🇮🇹 Italiano

### Panoramica

KZDownloader è un'applicazione desktop cross-platform realizzata con Flutter per scaricare video, musica e file generici da centinaia di siti web. Integra un assistente AI in grado di riassumere contenuti video di YouTube e rispondere a domande su di essi.

L'interfaccia è organizzata in sezioni dedicate — **Video**, **Musica** e **File generici** — ognuna con la propria vista e i propri controlli. Il design è moderno, minimale e completamente reattivo, con bordi animati a gradiente neon/arcobaleno sulle card di download e sugli elementi interattivi, transizioni fluide e feedback in tempo reale.

---

### ✨ Funzionalità

#### 🎬 Download di Video e Audio
- Scarica video e audio da **YouTube** e centinaia di altre piattaforme grazie a [yt-dlp](https://github.com/yt-dlp/yt-dlp).
- Scegli **formato video** (MP4, MKV) e **qualità** prima del download, con due modalità di selezione:
  - **Semplice**: Migliore · Alta · Media · Bassa
  - **Esperto**: Best · 2160p (4K) · 1440p · 1080p · 720p · 480p
- Scarica interi **playlist di YouTube** con concorrenza configurabile — ogni video è tracciato individualmente.
- Estrazione solo audio in **MP3, M4A, OGG (Vorbis)**.

#### 📁 Downloader Generico (stile IDM)
- Download a **chunk multipli**, in stile IDM, per qualsiasi link HTTP/HTTPS diretto.
- **Ripresa automatica** — i download interrotti riprendono da dove si erano fermati se il server supporta le range request.
- Visualizzazione del progresso per ogni chunk con contatore dei worker attivi e barre di avanzamento per segmento.
- Backend HTTP basato su Rust ([rhttp_plus](https://pub.dev/packages/rhttp_plus)) per la massima velocità e per il **TLS fingerprinting**, che consente di aggirare i sistemi anti-bot su server protetti.

#### 🤖 AI — Riassunti e Chat sui Video
- Recupera automaticamente la **trascrizione / descrizione** di un video YouTube e genera un riassunto strutturato tramite LLM.
- Poni **domande di follow-up** in una sessione di chat persistente legata al video — la cronologia Q&A è salvata localmente.
- Supporto per più provider AI:
  - **Ollama** (locale al 100%, nessun dato lascia il dispositivo)
  - **OpenAI** (GPT-3.5-turbo, GPT-4, GPT-4o, …)
  - **Google Gemini** (Gemini 2.5 Pro, Flash, …)
- Output in streaming con rendering Markdown animato.
- Dimensione del contesto configurabile (numero massimo di caratteri inviati all'LLM).

#### 🎵 Libreria Musicale e Player
- Scheda **Musica** dedicata con la lista di tutti i file audio scaricati.
- **Player audio** integrato con barra di avanzamento, play/pausa, avanti/indietro e seek.
- **Gestione playlist**: crea playlist con nome personalizzato e aggiungi le tracce.

#### 🔒 Sicurezza e Integrità
- **Verifica checksum** (MD5, SHA-1, SHA-256, SHA-512) prima di avviare il download, per garantire l'integrità del file.
- Le chiavi API sono memorizzate nel **secure storage** del sistema operativo (keychain / credential manager).

#### ⚙️ Impostazioni e Personalizzazione
- Selezione della **cartella di download** con onboarding al primo avvio.
- Preset predefiniti di **formato**, **qualità** e **formato audio**.
- Tema **Scuro / Chiaro / Sistema** con transizioni fluide.
- **Lingua dell'interfaccia**: Inglese 🇬🇧 e Italiano 🇮🇹.
- Configurazione dei **download simultanei** per playlist e globali.
- Selezione del modello e del provider AI con gestione delle chiavi API.

#### 🖥️ Esperienza Desktop
- Interfaccia divisa in sezioni dedicate: **Video**, **Musica** e **File generici** — ognuna con layout, ordinamento e ricerca propri.
- Design moderno, minimale e completamente reattivo con aggiornamenti di progresso in tempo reale.
- **Bordi neon animati** (`RainbowAnimatedBorder`) attorno alle card di download e agli elementi interattivi, renderizzati tramite un `CustomPainter` dedicato.
- Effetti glow glassmorphism sulla schermata iniziale e transizioni fluide nell'intera UI.
- Layout responsive con adattamenti separati per Windows/Linux e macOS.

---

### 🏗️ Architettura e Stack Tecnologico

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

---

### 📦 Binari Esterni (scaricati automaticamente al primo avvio)

KZDownloader scarica e gestisce automaticamente i seguenti strumenti esterni nella directory di supporto dell'applicazione — nessuna installazione manuale richiesta:

| Binario | Scopo |
|---|---|
| **yt-dlp** | Download di video/audio ed estrazione metadati |
| **ffmpeg** | Post-processing, remuxing ed estrazione audio |
| **deno** | Supporto scripting per operazioni avanzate |

---

### � Download

I binari precompilati per Windows, macOS e Linux sono disponibili direttamente nella sezione [**Releases**](../../releases) — nessun ambiente di build necessario.

---

### �🚀 Avvio Rapido

#### Prerequisiti

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- Target desktop configurato (`flutter config --enable-windows-desktop` / `--enable-macos-desktop` / `--enable-linux-desktop`)

#### Installazione

```bash
# Clona il repository
git clone https://github.com/your-username/KZDownloader.git
cd KZDownloader

# Installa le dipendenze Flutter
flutter pub get

# Esegui la code generation (Isar + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Avvia sulla tua piattaforma
flutter run -d windows   # oppure macos / linux
```

#### Primo Avvio

Al primo avvio KZDownloader:
1. Chiederà di selezionare una **cartella di download predefinita**.
2. Scaricherà automaticamente **yt-dlp** e **ffmpeg** in background.

Per le funzionalità AI, apri le **Impostazioni** e scegli un provider:
- **Ollama**: installa [Ollama](https://ollama.com) in locale e scarica un modello (es. `ollama pull llama3`).
- **OpenAI / Google**: inserisci la tua chiave API nel pannello Impostazioni — verrà salvata nel keychain del sistema operativo.

---

### 📋 Piattaforme Supportate

| Piattaforma | Stato |
|---|---|
| Windows | ✅ Pieno supporto |
| macOS | ✅ Pieno supporto (layout adattato) |
| Linux | ✅ Pieno supporto |
| Android / iOS | ⚠️ Sperimentale (non target primario) |

---

### 🗂️ Struttura del Progetto

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

---

### 🤝 Contribuire

Contributi, segnalazioni di bug e richieste di funzionalità sono benvenuti. Apri una issue o invia una pull request.

---

### 📄 Licenza

Questo progetto è distribuito sotto la licenza **GNU General Public License v3.0 (GPL-3.0)** — consulta il file [LICENSE](LICENSE) per i dettagli.
