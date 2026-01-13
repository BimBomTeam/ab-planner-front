# AB Planner - Dokumentacja Projektu (Frontend)

## Przegląd Projektu
**AB Planner** to aplikacja mobilna i desktopowa stworzona w technologii Flutter, służąca do zarządzania planem zajęć. Aplikacja pełni rolę frontendu, komunikującego się z zewnętrznym backendem (API). Zapewnia obsługę logowania (w tym SSO Microsoft), zarządzanie lekcjami oraz system powiadomień Push.

## Technologie
Projekt wykorzystuje następujące kluczowe technologie i biblioteki:

*   **Flutter SDK**: ^3.7.0 (Wsparcie dla Material Design 3)
*   **Język**: Dart
*   **Zarządzanie Stanem / Logika**: Usługi (Services) wstrzykiwane/importowane w widokach.
*   **Komunikacja z API**: `http`
*   **Powiadomienia**: `firebase_messaging`, `firebase_core` (Firebase Cloud Messaging)
*   **Webview**: `webview_flutter` (Mobile), `webview_windows` (Windows) - wykorzystywane do logowania Microsoft.
*   **Przechowywanie danych lokalnych**: `shared_preferences`

## Struktura Katalogów (`lib/`)

Kod źródłowy aplikacji znajduje się w katalogu `lib` i jest podzielony na logiczne moduły:

### 1. `screens/` (Ekrany Aplikacji)
Katalog zawiera widoki poszczególnych ekranów aplikacji:
*   `log_in_screen.dart`: Ekran logowania użytkownika.
*   `microsoft_login_webview.dart`: Implementacja WebView do obsługi logowania przez konto Microsoft (SSO). Obsługuje specyficzne sterowniki przeglądarki dla Windows i Mobile.
*   `main_screen.dart`: Główny ekran aplikacji (prawdopodobnie widok kalendarza/listy zajęć).
*   `lesson_details_screen.dart`: Szczegółowy widok pojedynczej lekcji.
*   `add_lesson_screen.dart` / `edit_lesson_screen.dart`: Formularze dodawania i edycji zajęć.
*   `notification_list_screen.dart`: Lista odebranych powiadomień.
*   `profile_screen.dart`: Widok profilu użytkownika.
*   `settings_screen.dart`: Ustawienia aplikacji.

### 2. `services/` (Logika Biznesowa i API)
Odpowiadają za komunikację z backendem i logikę aplikacji:
*   `auth_service.dart`: Obsługa autentykacji, zarządzanie tokenami.
*   `lesson_service.dart`: Operacje CRUD na lekcjach (pobieranie, dodawanie, usuwanie).
*   `user_service.dart`: Zarządzanie danymi użytkownika.
*   `notification_service.dart`: Obsługa powiadomień wewnątrz aplikacji.
*   `fcm_service.dart`: Integracja z Firebase Cloud Messaging (odbieranie tokenów, obsługa komunikatów w tle/na pierwszym planie).
*   `lesson_form_service.dart`: Pomocniczy serwis do obsługi logiki formularzy lekcji.

### 3. `models/` (Modele Danych)
Reprezentacja struktur danych używanych w aplikacji:
*   `lesson.dart`: Model lekcji.
*   `user_model.dart`: Model użytkownika.
*   `notification_model.dart`: Model powiadomienia.
*   `group_model.dart`, `program_model.dart`: Modele pomocnicze dla struktur uczelni/szkoły.
*   `role_model.dart`: Zarządzanie rolami użytkowników.

### 4. `widgets/` (Komponenty)
*   Zawiera reużywalne elementy UI, np. kafelki powiadomień.

## Kluczowe Funkcjonalności

### Logowanie Microsoft (SSO)
Aplikacja wykorzystuje hybrydowe podejście do logowania OAuth2 przez Microsoft:
*   Używa komponentu `MicrosoftLoginWebView`.
*   Na Windows wykorzystuje `webview_windows`, na Android/iOS `webview_flutter`.
*   Przechwytuje przekierowanie (redirect) na `localhost:8080/auth/callback` w celu wydobycia kodu autoryzacyjnego (`code`).

### Powiadomienia Push (FCM)
*   Zaimplementowano obsługę Firebase Cloud Messaging w `FCMService`.
*   Serwis jest inicjalizowany w `main.dart` przed startem aplikacji.
*   Obsługuje pobieranie tokena urządzenia i przesyłanie go do backendu (logika w `ensureTokenSent functionality` - do weryfikacji w kodzie).

### Wieloplatformowość
Aplikacja jest przystosowana do działania na:
*   **Android / iOS**: Standardowy flow mobile.

## Wymagania i Uruchomienie

1.  **Wymagania wstępne**:
    *   Flutter SDK zainstalowane i dodane do PATH.
    *   Konfiguracja Firebase (plik `google-services.json` dla Androida w `android/app`).

2.  **Instalacja zależności**:
    ```bash
    flutter pub get
    ```

3.  **Uruchomienie**:
    ```bash
    flutter run
    ```
    Dla Windows: `flutter run -d windows`
