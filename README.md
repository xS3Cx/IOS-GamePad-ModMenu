# 🎮 GameFusion Mod Menu

[![iOS](https://img.shields.io/badge/iOS-14.0+-blue.svg?style=for-the-badge&logo=apple)](https://www.apple.com/ios/)
[![No Jailbreak](https://img.shields.io/badge/No%20Jailbreak-Supported-green.svg?style=for-the-badge&logo=checkra1n)](https://checkra.in/)
[![Version](https://img.shields.io/badge/Version-1.0-orange.svg?style=for-the-badge)](control)
[![Architecture](https://img.shields.io/badge/Architecture-arm64%20%7C%20arm64e-blue.svg?style=for-the-badge)](https://en.wikipedia.org/wiki/ARM_architecture)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS-lightgrey.svg?style=for-the-badge&logo=ios)](https://www.apple.com/ios/)

> 🚀 iOS Mod Menu with Gamepad Support and Controller Light Customization

![photo_2025-06-28_23-02-08](https://github.com/user-attachments/assets/3eab5bca-6f3c-4c9e-ae64-b028affab9e2)


---

## 📋 Table of Contents

- [✨ Features](#-features)
- [📱 Requirements](#-requirements)
- [🚀 Installation](#-installation)
- [🎮 Usage](#-usage)
- [🛠️ Development](#️-development)
- [🔧 Configuration](#-configuration)
- [🐛 Troubleshooting](#-troubleshooting)
- [🙏 Acknowledgments](#-acknowledgments)

---

## ✨ Features

### 🎯 Core Mod Menu
![photo_2025-06-28_23-02-40](https://github.com/user-attachments/assets/fdec3a52-fe35-42db-8a92-efb4dcc8df74)

- **Elegant UI Design**: Modern, customizable interface with smooth animations
- **Multi-Submenu System**: Organized feature categories with function counters
- **Infinite Scrolling**: Smooth navigation through unlimited menu items
- **Auto-Resizing**: Dynamic menu sizing based on content
- **Real-time Toggle Switches**: Instant activation/deactivation of features
- **Memory Patching**: Advanced offset-based memory manipulation

### 🎮 Gamepad Controller Light Features

- **Static Colors**: Red, Green, Blue, Yellow, Purple, Cyan, White
- **Dynamic Effects**: RGB Cycle, Police Lights, Breathing, Rainbow Wave, Strobe, Pulse

### 🔧 Advanced Features
- **Gamepad Input Monitoring**: Real-time controller input detection
- **Custom Notifications**: Enhanced alert system
- **Memory Management**: Optimized for performance
- **Rootless Support**: Compatible with modern jailbreaks
- **Cross-Architecture**: Supports arm64 and arm64e
- **Function Counters**: Track number of features in each submenu

### 🔔 Custom Notification System

- **Modern UI Design**: Dark themed notifications with rounded corners and smooth animations
- **Dynamic Positioning**: Automatic stacking of multiple notifications
- **Progress Indicator**: Violet progress bar showing notification duration
- **Auto-Hide**: Notifications automatically disappear after 2.5 seconds
- **Smooth Animations**: Spring-based slide-in animations from right side
![photo_2025-06-28_23-02-06](https://github.com/user-attachments/assets/960d4afa-7f02-4024-bca3-2e3fc4a4dd08)

---

## 📱 Requirements

- **iOS Version**: 14.0 or later
- **Jailbreak**: Rootless, Rootful, or Non-jailbreak (JIT)
- **Device**: iPhone/iPad with gamepad support
- **Dependencies**: mobilesubstrate, GameController framework

---

## 🚀 Installation

### 📦 Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/GameFusion.git
cd GameFusion

# Install dependencies
make setup

# Build for device
make package

# Install to device
make install
```

**🎯 Quick Start Guide**

```bash
git clone https://github.com/yourusername/GameFusion.git && cd GameFusion && make setup && make package
```

---

## 🎮 Usage

### 🎯 Accessing the Menu

- **Open/Show Menu**: L1 - Toggle menu visibility
- **Hide Menu**: L1 - Close menu
- **Navigate**: Arrow Keys - Move through menu items
- **Enter/Activate**: Square - Enter submenu or activate function
- **Exit/Close**: Circle - Exit submenu or close menu

### 🧪 Testing the Mod Menu

To test the mod menu functionality:

1. **Change Bundle ID**: Edit `GameFusion.plist` and change the bundle identifier to match your target application
2. **Install Tweak**: Install the tweak to your device
3. **Open Target App**: Launch the application you specified in the bundle ID
4. **Access Menu**: Press **L1** on your gamepad controller to open the mod menu
5. **Navigate**: Use the controller to navigate through menu options and test features

---

## 🛠️ Development

### 📁 Project Structure

```
GameFusion/
├── GameFusion.xm          # Main tweak entry point
├── Menu.mm                # Core menu implementation
├── Menu.h                 # Menu interface definitions
├── GameFusion/            # Feature modules
│   ├── ControllerLight.m  # Controller light effects
│   ├── GamepadInput.m     # Gamepad input handling
│   ├── Layout.xm          # UI layout and styling
│   └── CustomNotification.mm # Notification system
├── KittyMemory/           # Memory manipulation library
├── SCLAlertView/          # Alert view components
├── DobbyHook/             # Hooking framework
└── Makefile               # Build configuration
```

### 🔨 Building Commands

- `make clean` - Clean build artifacts
- `make package` - Create .deb package
- `make install` - Install to device
- `make debug` - Build with debug symbols

---

## 🔧 Configuration

### ➕ Adding New Features

#### Simple Toggle (Switch without patching function)
```objc
[switches addSimpleSwitchToSubMenuByName:@"New Feature"    // Function name in menu
    description:@"Description of new feature"              // Function description
    subMenuName:@"SUB MENU 1"];                            // Submenu name where it will appear
```

#### Memory Patch (Switch with memory patching function)
```objc
[switches addOffsetSwitchToSubMenuByName:@"Memory Hack"    // Function name in menu
    description:@"Memory manipulation feature"             // Function description
    patchOffsets:{0x100394E60}                             // Memory addresses to change (offsets)
    patchBytes:{"0x00f0271e"}                              // New bytes to write to memory
    unpatchOffsets:{0x100394E60}                           // Addresses to restore original bytes
    unpatchBytes:{"0x0008211E"}                            // Original bytes to restore
    subMenuName:@"SUB MENU 1"];                            // Submenu name where it will appear
```

### 📂 Adding New Sub Menus

To add more sub menus, modify the `subMenuNames` array in your main file:

```objc
NSArray *subMenuNames = @[
    NSSENCRYPT("SUB MENU 1"), 
    NSSENCRYPT("GamePad Menu"),
    NSSENCRYPT("New Sub Menu"),     // Add your new sub menu here
    NSSENCRYPT("Another Menu")      // Add more sub menus as needed
];
```

Then add your features to the new sub menu by specifying the sub menu name:

```objc
[switches addSimpleSwitchToSubMenuByName:@"New Feature"
    description:@"Description of new feature"
    subMenuName:NSSENCRYPT("New Sub Menu")];  // Use the new sub menu name
```

---

## 🐛 Troubleshooting

### ❗ Common Issues

- **Menu not appearing**: Ensure tweak is properly installed and respring. Check bundle application matches GameFusion.plist
- **Controller not detected**: Check gamepad connection and permissions
- **Effects not working**: Verify iOS version compatibility
- **Build errors**: Check Theos installation and SDK setup

---

## 🙏 Acknowledgments

- **AlexZero** - Original Creator
- **joeyjurjens** - [iOS Mod Menu Template for Theos](https://github.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos)
- **MJx0** - [KittyMemory](https://github.com/MJx0/KittyMemory) - Memory manipulation
- **dogo** - [SCLAlertView](https://github.com/dogo/SCLAlertView) - Alert components
- **jmpews** - [Dobby](https://github.com/jmpews/Dobby) - Hooking framework

---

### ⚠️ Disclaimer

**This software is for educational and research purposes only. Use responsibly and in accordance with applicable laws and terms of service.**

---

### 🎮 Made with ❤️ by xSECx (AlexZero)

[![GitHub](https://img.shields.io/badge/GitHub-alex0-black?style=for-the-badge&logo=github)](https://github.com/alex0) 
