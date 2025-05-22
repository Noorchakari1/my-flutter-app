# Shared Widgets

This directory contains reusable widgets that can be used across the application.

## EmptyStateWidget

A customizable widget for displaying empty states in a consistent way across the application. It provides a friendly visual and message when no data is available, such as in empty lists or no search results.

### Features

- Customizable icon or image
- Primary and secondary messages
- Optional action button
- RTL language support
- Dark mode support
- Subtle animation

### Usage

```dart
// Basic usage
EmptyStateWidget(
  message: 'No items found',
  subMessage: 'Try adjusting your search or filters',
  icon: Icons.inbox_outlined,
)

// With action button
EmptyStateWidget(
  message: 'No saved news',
  subMessage: 'Save news items to view them here',
  icon: Icons.bookmark_outline,
  actionLabel: 'Browse News',
  onActionPressed: () => Navigator.pushNamed(context, '/news'),
)

// With custom image instead of icon
EmptyStateWidget(
  message: 'Your cart is empty',
  subMessage: 'Add items to your cart to see them here',
  imagePath: 'assets/images/empty_cart.png',
  imageHeight: 150,
  actionLabel: 'Start Shopping',
  onActionPressed: () => Navigator.pushNamed(context, '/products'),
)

// Using localized text
EmptyStateWidget(
  // Will use the 'noResults' key from localization
  icon: Icons.search_off,
  subMessage: LocalizationHelper.getText(ref, 'emptySearchSuggestion'),
)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| message | String? | Main message to display. If null, uses localized 'noResults' text |
| subMessage | String? | Optional secondary message with additional context |
| icon | IconData? | Icon to display above the message. Default is Icons.search_off_rounded |
| iconSize | double? | Size of the icon. Default is 64 |
| iconColor | Color? | Color of the icon. Adapts to dark/light mode if not specified |
| messageStyle | TextStyle? | Style for the main message text |
| subMessageStyle | TextStyle? | Style for the sub-message text |
| padding | EdgeInsetsGeometry? | Padding around the entire widget. Default is EdgeInsets.all(24) |
| onActionPressed | VoidCallback? | Callback when the action button is pressed |
| actionLabel | String? | Label for the action button |
| animate | bool | Whether to show a subtle animation. Default is true |
| imagePath | String? | Optional image asset path to display instead of an icon |
| imageHeight | double? | Height of the image if provided. Default is 120 |
| imageWidth | double? | Width of the image if provided |

## Best Practices

1. **Use Consistent Icons**: Choose icons that clearly represent the empty state context
2. **Clear Messages**: Provide clear, concise messages that explain why the user is seeing an empty state
3. **Helpful Guidance**: When appropriate, include a sub-message that guides the user on what to do next
4. **Action Buttons**: Include action buttons when there's a clear next step for the user
5. **Localization**: Use localized text for all user-facing strings
