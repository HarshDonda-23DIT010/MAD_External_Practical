# Description of Implemented Modules
**Project: Smart File Sharing & Collaboration App**

This document outlines the core modules implemented in the Flutter application, detailing their functionalities and the technologies used to achieve them.

---

## 1. Local Storage & Data Persistence Module
**Purpose:** Ensure the app works completely offline and retains data across app restarts.
**Implementation:**
- Implemented using **Hive (NoSQL Database)** for extremely fast, synchronous local data storage.
- Created custom data models (`FileModel`, `VersionModel`, `CommentModel`) with Hive TypeAdapters for automatic serialization.
- Stores complex data including file metadata, version histories, comment threads, and raw file bytes (for web support).

## 2. Native File Picking & Handling Module
**Purpose:** Allow users to seamlessly browse their device and upload actual files into the application.
**Implementation:**
- Integrated the `file_picker` package to open native system file dialogs on Windows, Android, and Web.
- Captures critical file metadata such as file name, extension, size, and absolute local system paths.
- For Flutter Web (which restricts absolute file paths for security), the module intelligently captures raw `Uint8List` bytes instead to ensure cross-platform compatibility.

## 3. Cross-Platform File Viewing Module
**Purpose:** Enable users to physically open and view the files they uploaded.
**Implementation:**
- On **Windows & Android**: Utilizes the `open_filex` package to trigger the operating system's default application (e.g., Adobe Acrobat for PDFs, Photos for images) using the absolute file path.
- On **Flutter Web**: Utilizes the `universal_html` package to dynamically generate a secure `Blob URL` from the stored file bytes, successfully opening PDFs and images in a new browser tab with the correct MIME type.

## 4. State Management & Reactivity Module
**Purpose:** Ensure the User Interface (UI) updates instantly and efficiently when data changes.
**Implementation:**
- Implemented using the **Provider** pattern (`ChangeNotifierProvider`).
- The `FileProvider` acts as the central source of truth, managing interactions with the Hive database and notifying the UI (via `Consumer` widgets) to rebuild only when necessary (e.g., after a successful file upload or deletion).

## 5. Version Control & Collaboration Module
**Purpose:** Simulate a collaborative environment where multiple users interact with files over time.
**Implementation:**
- **Version Tracking:** Every time a file's details are updated, a new `VersionModel` is created, tracking the timestamp and change description.
- **Commenting System:** Users can add and delete comments on specific files, stored in a dedicated Hive box linked by the `fileId`.
- **Conflict Resolution:** Simulates file conflicts if changes happen rapidly, giving the user options to "Keep Latest" or "Keep Both".
- **Sharing Status:** Toggles for marking files as 'Shared' or 'Personal'.

## 6. Search & Filtering Module
**Purpose:** Allow users to quickly find specific documents in a large library.
**Implementation:**
- Real-time text search filtering files by name and description.
- Categorical filtering allowing users to sort files by specific extensions (PDF, DOCX, Images, ZIP).
- Filter toggles to switch views between 'All Files', 'Personal', and 'Shared' files.

## 7. Dynamic Theming & UI Module
**Purpose:** Provide a visually appealing, premium, and responsive user experience.
**Implementation:**
- Centralized `AppTheme` utility class managing all colors, typography, and widget styles.
- Successfully implemented a modern **Light/White Theme** featuring crisp indigo primary colors, dynamic gradients, and soft shadows.
- Responsive layout adapting smoothly to desktop windows, web browsers, and mobile screens.
