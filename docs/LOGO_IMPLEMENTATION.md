# Job Opportunities Logo Implementation

This document explains how ministry logos are implemented in the job opportunities feature.

## Overview

The job opportunities screen and detail screen now display ministry logos retrieved from the website's storage. The logos are dynamically loaded using the configurable base URL.

## URL Configuration

### Base URL Configuration
The base URL is configured in `lib/core/config/url_config.dart`:

```dart
class UrlConfig {
  static const String baseUrl = 'http://172.16.15.229';
  static const String storageBaseUrl = '$baseUrl/storage';
}
```

### Logo URL Structure
Ministry logos are accessed using the following URL pattern:
```
http://172.16.15.229/storage/{logo_path}
```

Where `{logo_path}` is the value from the `JobMinistry.logoPath` field.

## Implementation Details

### 1. URL Configuration Service
- **File**: `lib/core/config/url_config.dart`
- **Purpose**: Centralized URL management for dynamic configuration
- **Key Methods**:
  - `buildLogoUrl(String? logoPath)`: Builds full URL for ministry logos
  - `buildStorageUrl(String? path)`: Builds full URL for any storage resource

### 2. Job Opportunities Screen
- **File**: `lib/features/job_opportunities/presentation/screens/job_opportunities_screen.dart`
- **Changes**:
  - Added ministry logo display in job cards
  - Logo appears as a 50x50 image on the left side of each job card
  - Fallback icon displayed when logo is not available

### 3. Job Detail Screen
- **File**: `lib/features/job_opportunities/presentation/screens/job_detail_screen.dart`
- **Changes**:
  - Added ministry logo in the SliverAppBar background (80x80)
  - Added ministry logo in the job info card (40x40)
  - Enhanced ministry information display with logo

### 4. Data Model
- **File**: `lib/features/job_opportunities/data/models/job_model.dart`
- **Existing Field**: `JobMinistry.logoPath` - Contains the relative path to the logo

### 5. Service Layer
- **File**: `lib/features/job_opportunities/data/services/job_service.dart`
- **Changes**: Updated to use `UrlConfig.apiBaseUrl` for dynamic URL configuration

## Features

### Logo Display
1. **Job List Screen**:
   - 50x50 ministry logo on the left side of each job card
   - Fallback business icon when logo is unavailable
   - Rounded corners (8px border radius)

2. **Job Detail Screen**:
   - Large logo (80x80) in the app bar background
   - Medium logo (40x40) in the ministry info section
   - Fallback icons with appropriate styling

### Error Handling
- Graceful fallback to default icons when logos fail to load
- Proper error widgets with consistent styling
- No impact on functionality when logos are unavailable

### Performance
- Uses `CachedNetworkImage` for efficient image loading and caching
- Shimmer loading effects for better user experience
- Optimized image sizes for different contexts

## Configuration

### Changing the Base URL
To change the base URL (e.g., for different environments):

1. Update `UrlConfig.baseUrl` in `lib/core/config/url_config.dart`
2. The change will automatically apply to all logo URLs

### Example URL Changes
```dart
// Development
static const String baseUrl = 'http://172.16.15.229';

// Production
static const String baseUrl = 'https://your-production-domain.com';

// Local testing
static const String baseUrl = 'http://localhost:8000';
```

## Testing

### Manual Testing
1. Navigate to Job Opportunities screen
2. Verify ministry logos appear in job cards
3. Tap on a job to view details
4. Verify logo appears in app bar and ministry info section
5. Test with jobs that have and don't have ministry logos

### URL Testing
You can test different logo URLs by temporarily modifying the `buildLogoUrl` method or by updating the base URL configuration.

## Troubleshooting

### Common Issues
1. **Logos not loading**: Check network connectivity and base URL configuration
2. **Wrong logo URLs**: Verify the `logo_path` field in the API response
3. **Performance issues**: Ensure `CachedNetworkImage` is properly configured

### Debug Information
- Logo URLs are built using `UrlConfig.buildLogoUrl(ministry.logoPath)`
- Check the constructed URLs in debug mode
- Verify the API returns valid `logo_path` values

## Future Enhancements

### Potential Improvements
1. **Dynamic URL Configuration**: Load base URL from remote configuration
2. **Logo Caching**: Implement advanced caching strategies
3. **Placeholder Images**: Add ministry-specific placeholder images
4. **Image Optimization**: Implement different image sizes for different contexts
5. **Offline Support**: Cache logos for offline viewing

### API Enhancements
1. **Logo Validation**: Ensure API validates logo file existence
2. **Multiple Sizes**: Provide different logo sizes (thumbnail, medium, large)
3. **Image Metadata**: Include image dimensions and format information 