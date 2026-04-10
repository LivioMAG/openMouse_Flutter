# OpenMouse (Flutter + Supabase)

Produktionsnahe Flutter-Neuentwicklung mit Supabase für:

- Auth (E-Mail/Passwort + OTP Code Login)
- Arbeitsumgebungen
- Dokumentenablage (Dropbox-ähnlich mit Ordnern, Unterordnern, Upload, Umbenennen, Löschen, Suche)

## Architektur

Struktur gemäß AGENTS-Vorgaben:

- `lib/core/config`: JSON-basierte Konfiguration
- `lib/core/services`: zentraler Supabase Client
- `lib/features/*/pages`: UI
- `lib/features/*/logic`: Controller/State
- `lib/features/*/data`: Datenzugriff (Supabase)
- `lib/models`: Datenmodelle

## Setup

### 1) Abhängigkeiten

```bash
flutter pub get
```

### 2) Supabase Konfiguration

Datei: `assets/config/supabase_config.json`

```json
{
  "supabaseUrl": "https://YOUR-PROJECT.supabase.co",
  "supabaseAnonKey": "YOUR_ANON_KEY"
}
```

Datei: `assets/config/app_integrations.json`

```json
{
  "storageBucket": "documents",
  "appName": "OpenMouse"
}
```

### 3) SQL Migrationen ausführen

- `supabase/migrations/001_initial_schema.sql`
- `supabase/migrations/002_documents_and_storage.sql`

Diese enthalten:

- `profiles`
- `arbeitsumgebungen`
- `folders`
- `files`
- Storage Bucket `documents`
- RLS Policies für eigene Daten (`user_id == auth.uid()`)

### 4) Supabase Auth Einstellungen

- E-Mail/Passwort aktivieren
- E-Mail OTP aktivieren
- OTP Code Login wird über `verifyOtp` umgesetzt (kein Magic Link)

### 5) App starten

```bash
flutter run
```

## OTP-Flow (Passwort vergessen)

1. E-Mail eingeben
2. **Code senden**
3. Code eingeben
4. **Einloggen** (verify OTP)

## Abo-/Profil-Logik

- Beim Login wird `profiles` geladen
- Falls Profil fehlt: automatische Erstellung
- Arbeitsumgebung erstellen nur bei `has_subscription = true`

## Dokumentenablage

- Ordner erstellen
- Unterordner beliebig tief
- Datei-Upload in Storage Bucket `documents`
- Pfad: `user_id/workspace_id/folder_id/dateiname`
- Umbenennen / Löschen
- Rekursives Löschen von Ordnern
- Breadcrumb Navigation
- Suche über aktuelle Ebene
