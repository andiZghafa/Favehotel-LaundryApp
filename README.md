# Housekeeping Laundry Logbook

A mobile and web application built with Flutter for hotel housekeeping teams to log, track, and export daily laundry inventory and rewash data to Microsoft Excel (`.xlsx`).

---

## Overview

The application streamlines housekeeping linen handovers between hotel floors and laundry facilities. It provides dedicated counting, note-taking for damaged or heavily soiled items, and one-click report generation compatible with desktop spreadsheets.

### Three Primary Categories

1. **FREN (Bedding & Bath Linens)**
   * **Items:** Duvet Double, Duvet Single, Sheet Double, Sheet Single, Pillowcase, Bathtowel, Kain Coklat, Kain Batik.
   * **Flow:** Item counting with stepper and quick increment buttons (`+1`, `+5`, `+10`) -> Notes/remarks per item -> Summary review with Handler identification -> Excel export.
   * *Rewash items are excluded from this flow.*

2. **FAST (F&B & Housekeeping Linens)**
   * **Items:** Bath Towel, Bath Mat, Mukena, Sejadah, Sarung, Bendera.
   * **Flow:** Item counting -> Notes per item -> Summary review with Handler identification -> Excel export.
   * *Rewash items are excluded from this flow.*

3. **REWASH (Dedicated Standalone Station)**
   * **Concept:** Standalone station for logging stained, torn, or defective linens requiring special re-wash chemical cycles or repair.
   * **Segmented Tabs:**
     * **FREN Linen Tab:** Duvets, sheets, pillowcases, bathtowels.
     * **FAST Items Tab:** Bath mats, prayer rugs, mukena, sarung, flags.
   * **Stain & Defect Tags:** Quick selection for coffee stains, blood, rust/grease, heavy dirt, tears, and discoloration.
   * **Multi-Sheet Report:** Generates an Excel workbook containing organized `FREN REWASH` and `FAST REWASH` worksheets.

---

## Brand Identity & Design System

The visual design is constructed around the brand palette and logo assets:

| Token | Hex Value | Usage |
|---|---|---|
| **Plum Dark** | `#1A0B2E` | Deep background canvas |
| **Purple Deep** | `#2D1B69` | Mid-gradient surface |
| **Brand Magenta** | `#900C46` | Primary action buttons and header fills |
| **Brand Magenta Dark** | `#7A0A3C` | Button gradients and active states |
| **Coral Accent** | `#FF6B6B` | Status highlights and warning badges |
| **Peach Light** | `#FFE4E1` | Subtitles and pill labels |
| **Surface Card** | `#24153B` | Elevated card containers |
| **Surface Input** | `#1F1133` | Form inputs and counter wells |

* **Logo:** Preserved from `assets/IKON.png`.
* **Typography:** Poppins powered by Google Fonts.
* **Motion & Transitions:**
  * Sliding segmented tabs: 250ms cubic-bezier transition.
  * Counter feedback: 150ms pop animation on number updates.
  * Page routes: Asymmetric horizontal slide with fade-through.

---

## Cross-Platform Excel Export

Export logic in `lib/services/excel_service.dart` supports multiple platforms:

* **Flutter Web (e.g. Vercel, Netlify):** Converts Excel workbook into binary streams and invokes client-side browser download using HTML anchor blobs.
* **Android / iOS:** Writes `.xlsx` files directly to the device `Download/laundry/<CATEGORY>/` directory or application documents directory.

Generated spreadsheets include:
* Standardized header block with category name, timestamp, and date.
* Columns: `Item Name`, `Quantity`, `Notes / Stain Reason`, `Handler`, `Date`, `Time`.
* Auto-calculated summary row with total pieces.
* Auto-fitted column widths and styled table headers.

---

## Project Structure

```
lib/
├── main.dart                      # App entry point & theme initialization
├── models/
│   └── linen_models.dart          # Category definitions, default items & data models
├── page/
│   ├── splash.dart                # Splash entrance with brand logo
│   ├── home.dart                  # Dashboard featuring FREN, FAST & REWASH
│   ├── linen_form_screen.dart     # Dedicated form for FREN and FAST
│   ├── rewash_screen.dart         # Dedicated tabbed REWASH station
│   ├── summary_export_screen.dart # Handler entry, review & Excel generator
│   ├── fast.dart                  # Compatibility bridge to LinenCategory.fast
│   ├── fren.dart                  # Compatibility bridge to LinenCategory.fren
│   ├── return.dart                # Compatibility bridge to RewashScreen
│   ├── return2.dart               # Compatibility bridge to RewashScreen
│   ├── fast2.dart                 # Compatibility bridge to SummaryExportScreen
│   └── fren2.dart                 # Compatibility bridge to SummaryExportScreen
├── services/
│   └── excel_service.dart         # Cross-platform Excel generation & file saving
├── theme/
│   └── app_theme.dart             # Colors, typography, and motion tokens
└── widgets/
    ├── app_background.dart        # Responsive container & brand gradient
    ├── app_dialogs.dart           # Quantity keypad & stain tag modals
    ├── custom_tab_bar.dart        # Sliding pill tab control
    └── linen_counter_card.dart    # Counter cards with +1/+5/+10 chips & notes
```

---

## Getting Started

### Prerequisites

* Flutter SDK (3.7.2 or later)
* Dart SDK (3.7.2 or later)

### Run Locally

1. Clone or navigate to the project directory:
   ```bash
   cd laundry_app_web
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run on Chrome (Web):
   ```bash
   flutter run -d chrome
   ```

4. Run on Connected Device / Emulator (Android):
   ```bash
   flutter run -d android
   ```

### Building for Deployment

* **Build for Web (Vercel / Netlify / Hosting):**
  ```bash
  flutter build web --release
  ```
  The production output will be generated in `build/web/`.

* **Build Android APK:**
  ```bash
  flutter build apk --release
  ```
  The APK file will be located at `build/app/outputs/flutter-apk/app-release.apk`.
