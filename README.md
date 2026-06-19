# Brave Origin Unlocker

A TypeScript utility for unlocking Brave Origin features on Windows and macOS by modifying the local application state.

## Overview

This tool modifies the Brave Origin browser's local state configuration to unlock premium features. It works by updating the `Local State` JSON file used by Brave to store user preferences and license validation status.

## Features

- ✅ Unlocks Brave Origin features
- ✅ Modifies purchase validation state
- ✅ Updates SKU credentials
- ✅ Windows and macOS auto-detection & compatibility
- ✅ Easy execution and cross-compilation via Deno tasks

## Requirements

- **Deno** - Modern JavaScript/TypeScript runtime
- **Windows OS or macOS** - Supported operating systems
- **Brave Origin** - The browser being modified
- **File Write Permissions** - Access to browser configurations

## Installation

1. Install [Deno](https://deno.land/) if you haven't already.
2. Clone this repository:
   ```bash
   git clone https://github.com/ObjectAscended/brave-origin-windows-unlocker.git
   cd brave-origin-windows-unlocker
   ```

## How to Run 🚀

The script automatically detects whether you are running on Windows or macOS. You can run the unlocker directly with:

```bash
deno task unlock
```

---

## How to Compile / Cross-Compile 📦

You can build standalone binaries for different operating systems and architectures using the pre-configured compilation tasks:

### Compile for Windows (x64)
```bash
deno task compile-win
```

### Compile for macOS Apple Silicon (ARM64)
```bash
deno task compile-mac-arm
```

### Compile for macOS Intel (x64)
```bash
deno task compile-mac-x64
```

These tasks will output the built binaries into the `dist/` directory.

---

## Pre-Bundled Deno Binaries 🎉

In our latest releases, we offer **pre-bundled Deno binaries** that make running the unlocker easier than ever! 🚀 You can download them from our [latest release page](https://github.com/ObjectAscended/brave-origin-windows-unlocker/releases/latest). These binaries ensure a smooth setup and save you time.

## Why Run the Unlocker Natively? 🤔

Running the unlocker natively is typically a better choice than running a browser inside virtual/emulated environments. Here's why:

1. **Performance**: The native experience generally offers better performance than emulated environments. ⚡
2. **Simplicity**: You avoid complex setups and configurations, making it more straightforward for users of all levels. 🛠️
3. **Compatibility**: Some features and functionalities might only work seamlessly in a native environment, ensuring you get the most out of your tools. 🔗
4. **User Experience**: Enjoy a more intuitive interface and fewer problems managing dependencies. 😊

Enjoy using our tool! 🎈
