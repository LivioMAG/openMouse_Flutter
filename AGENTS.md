# Flutter + Supabase Projektstruktur

## Ziel
Saubere, skalierbare Struktur für ein kleines bis mittleres Flutter-Projekt mit **Supabase** als Backend.

Wichtige Prinzipien:
- **Trennung von UI (Pages), Logik und Datenzugriff**
- **Keine Credentials im Code**
- **Konfiguration über JSON**
- **SQL-Migrationen strikt versioniert (001, 002, 003, …)**
- **CRUD-Logik sauber getrennt**

---

## Projektstruktur

```text
project_root/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   ├── config_loader.dart
│   │   │   └── app_config.dart
│   │   ├── services/
│   │   │   └── supabase_client.dart
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── pages/
│   │   │   │   └── login_page.dart
│   │   │   ├── logic/
│   │   │   │   └── auth_controller.dart
│   │   │   └── data/
│   │   │       └── auth_repository.dart
│   │   │
│   │   ├── user/
│   │   │   ├── pages/
│   │   │   │   └── profile_page.dart
│   │   │   ├── logic/
│   │   │   │   └── user_controller.dart
│   │   │   └── data/
│   │   │       └── user_repository.dart
│   │   │
│   │   └── ...
│   │
│   └── main.dart
│
├── assets/
│   └── config/
│       ├── supabase_config.json
│       └── app_integrations.json
│
├── supabase/
│   └── migrations/
│       ├── 001_initial_schema.sql
│       ├── 002_add_profiles.sql
│       ├── 003_add_logs.sql
│       └── ...
│
└── README.md
