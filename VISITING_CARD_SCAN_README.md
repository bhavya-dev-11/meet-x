# Visiting Card Scan API Integration

This document explains the implementation of the visiting card scanning feature using Riverpod state management and MVC architecture.

## Overview

The visiting card scanning feature allows users to:
1. **Capture a photo** of a business card using the camera
2. **Select an image** from the gallery/photo library
3. Upload the image to the API for processing
4. Receive extracted information from the card (name, email, phone, etc.)
5. Track upload progress in real-time

## Features

### 1. Camera Capture
- Real-time camera preview with card frame guide
- Flash toggle support
- High-quality image capture for better OCR

### 2. Gallery Selection
- Pick business card images from photo library
- Automatic permission handling
- Support for all standard image formats

### 3. Real-time Upload Progress

The implementation follows the MVC (Model-View-Controller) pattern with Riverpod for state management:

### Files Created

1. **Model Layer**
   - `lib/models/visiting_card_model.dart` - Data model for the API response
   - `lib/models/visiting_card_state.dart` - State model for UI state management

2. **Repository Layer**
   - `lib/data/visiting_card_repository.dart` - API calls and data operations

3. **Controller Layer**
   - `lib/controllers/visiting_card_controller.dart` - Business logic and state management

4. **Provider Layer**
   - `lib/providers/visiting_card_provider.dart` - Riverpod providers for dependency injection

5. **View Layer**
   - `lib/views/scan_card_view.dart` - Updated to integrate with the API

## API Endpoint

**URL:** `/api/v1/visiting-cards/scan`  
**Method:** `POST`  
**Content-Type:** `multipart/form-data`  
**Authentication:** Bearer token (automatically added via ApiClient interceptor)

### Request
```
FormData:
  - image: File (business card image)
```

### Response (201 Created)
```json
{
  "id": "693081415ac0b3dfb19d7a1b",
  "user_id": "69234926bf700754b7226dec",
  "business_id": "string",
  "company_name": null,
  "contact_person": "Olivia Wilson",
  "phone_number": "+123-456-7890 +123-456-7890",
  "email": "hello@reallygreatsite.com",
  "address": "123 Anywhere St.,\nAny City, ST 12345",
  "linkedin_profile": null,
  "website": "www.reallygreatsite.com",
  "designation": "Real Estate Agent",
  "processing_status": "completed",
  "extraction_confidence": 0.95,
  "image_path": "uploads/visiting_cards/be2af586-a60f-4816-9c1e-882c7a01eddc.jpg",
  "created_at": "2025-12-03T18:28:17.643000",
  "scanned_at": "2025-12-03T18:28:17.643000",
  "tags": ["string"],
  "notes": "string"
}
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:meetzone/models/visiting_card_model.dart';
import 'package:meetzone/views/scan_card_view.dart';

// Navigate to scan card view
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ScanCardView(),
  ),
);

// Handle the result
if (result != null && result is VisitingCard) {
  // Successfully scanned a card
  print('Contact Person: ${result.contactPerson}');
  print('Email: ${result.email}');
  print('Phone: ${result.phoneNumber}');
  // ... use other fields
}
```

### Using the Provider Directly

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/providers/visiting_card_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitingCardState = ref.watch(visitingCardProvider);
    
    return Column(
      children: [
        // Show upload progress
        if (visitingCardState.status == VisitingCardStatus.uploading)
          LinearProgressIndicator(
            value: visitingCardState.uploadProgress,
          ),
        
        // Show processing state
        if (visitingCardState.status == VisitingCardStatus.processing)
          const Text('Processing your card...'),
        
        // Show result
        if (visitingCardState.status == VisitingCardStatus.completed)
          Text('Name: ${visitingCardState.visitingCard?.contactPerson}'),
        
        // Show error
        if (visitingCardState.status == VisitingCardStatus.error)
          Text('Error: ${visitingCardState.errorMessage}'),
        
        // Scan button
        ElevatedButton(
          onPressed: () async {
            // Assuming you have an image path
            await ref.read(visitingCardProvider.notifier).scanCard(imagePath);
          },
          child: const Text('Scan Card'),
        ),
      ],
    );
  }
}
```

## State Management

### VisitingCardStatus Enum

- `initial` - Initial state, no operation in progress
- `uploading` - Image is being uploaded to the server
- `processing` - Server is processing the image
- `completed` - Scan completed successfully
- `error` - An error occurred

### VisitingCardState Properties

- `status` - Current status (VisitingCardStatus)
- `visitingCard` - The scanned card data (VisitingCard?)
- `errorMessage` - Error message if status is error (String?)
- `uploadProgress` - Upload progress from 0.0 to 1.0 (double)

## Features

### 1. Real-time Upload Progress
The implementation tracks upload progress in real-time and displays it to the user:
- Progress percentage shown during upload
- "Processing..." message after upload completes
- Smooth UI transitions between states

### 2. Automatic Authentication
The access token is automatically added to the request headers via the `ApiClient` interceptor, so you don't need to manually add it.

### 3. Error Handling
Comprehensive error handling with user-friendly messages:
- Network errors
- API errors
- Validation errors

### 4. State Reset
The state can be reset using:
```dart
ref.read(visitingCardProvider.notifier).reset();
```

## Integration with Dashboard

To integrate with the dashboard quick actions:

```dart
QuickActionCard(
  icon: Icons.credit_card,
  label: 'Scan Card',
  onTap: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanCardView(),
      ),
    );
    
    if (result != null && result is VisitingCard) {
      // Handle the scanned card
      // e.g., navigate to contact details, save to local DB, etc.
    }
  },
),
```

## Permissions

The app requires the following permissions to function properly:

### Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" /> <!-- For Android 13+ -->
```

### iOS Permissions (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan business cards</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select business card images</string>
```

### Permission Handling

The app automatically handles permission requests:
- **Camera Permission**: Requested when the user opens the scan card view
- **Photo Library Permission**: Requested when the user taps the gallery button

If permissions are denied, the app shows appropriate error messages with options to grant permissions.

## Notes

1. **JSON Serialization**: The `VisitingCard` model uses `json_serializable`. Run `dart run build_runner build` to generate the serialization code.

2. **Authorization**: The API requires a valid access token. Make sure the user is authenticated before calling the scan endpoint.

3. **Image Format**: The API accepts standard image formats (JPEG, PNG). The camera captures in JPEG format by default.

4. **Confidence Score**: The `extraction_confidence` field indicates how confident the AI is about the extracted data (0.0 to 1.0).

## Future Enhancements

Potential improvements:
- Add local caching of scanned cards
- Implement card editing functionality
- Add card search and filtering
- Implement card sharing
- Add OCR result review/editing before saving
