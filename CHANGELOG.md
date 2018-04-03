# Atlas Messenger Changelog

## 4.0.0

### Bugfixes

* Fixed animations when showing/hiding keyboard in conversation view
* Fixed starting new conversations

## 1.0.0-pre2

### Enhancements

* Updated LayerXDK/UI and LayerKit to 1.0.0-pre2 versions. Please refer to [LayerXDK changelog](https://github.com/layerhq/iOS-XDK/releases/tag/v1.0.0-pre2) and [LayerKit changelog](https://github.com/layerhq/releases-ios/releases/tag/v1.0.0-pre2) respectively.

### Bugfixes

* Fixed instastart configuration, when downloading pre-configured app form Layer dashboard.

## 1.0.0-pre1

### New Features

* New, improved UI with XDK UI components.

### Known Issues

* When creating new conversation, identities list items don’t have selected state. Selecting participants for new conversation is possible, but is not visible.
* Creating and presenting new conversation crashes app. As a temporary workaround a status message is sent to each new conversation, so after restarting app it remains on conversations list.
