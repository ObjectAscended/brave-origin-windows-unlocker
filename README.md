# Brave Origin Windows Unlocker

A native C# (win-x64, compiled with Native AOT) utility for unlocking Brave Origin features on Windows by modifying
the local application state.

## Overview

This tool modifies the Brave Origin browser's local state configuration to
unlock premium features. It works by updating the `Local State` JSON file used
by Brave to store user preferences and license validation status.

## Features

- ✅ Unlocks Brave Origin features
- ✅ Modifies purchase validation state
- ✅ Updates SKU credentials
- ✅ Windows-compatible local data path handling

## Requirements

- **Windows OS** - Designed for Windows file paths
- **Brave Origin** - The browser being modified
- **File Write Permissions** - Access to `%LOCALAPPDATA%` directory
- **.NET 8.0 SDK** - Only required to build the project (the built `BraveOriginUnlocker.exe` is completely standalone)

## Quick Build & Run (C# Executable) 🚀

We've automated the build process to make it as simple as possible.

1. **Build the Executable**:
   - Double-click `build.bat` in Windows Explorer, OR
   - Run the following in PowerShell:
     ```powershell
     .\build.ps1
     ```
   This script checks if you have the .NET 8.0 SDK installed (and offers to install it via `winget` if missing). It then compiles the C# source code using **Native AOT** (or falls back to a trimmed self-contained Single-File build if C++ build tools are missing) to output a highly optimized, zero-dependency `BraveOriginUnlocker.exe`.

2. **Run the Unlocker**:
   - Simply run the generated `BraveOriginUnlocker.exe`:
     ```cmd
     .\BraveOriginUnlocker.exe
     ```

## Why Run the Windows Unlocker Instead of WSL? 🤔

Running the Windows unlocker natively is typically a better choice than running a browser inside WSL:

1. **Performance**: Native Windows executables offer optimal startup speed and memory efficiency. ⚡
2. **Simplicity**: You avoid complex WSL setups and Windows-to-WSL file path translation. 🛠️
3. **Zero Dependencies**: Once built, the native `BraveOriginUnlocker.exe` runs on any Windows machine without needing Deno, Node.js, or even a .NET runtime! 🔗

Enjoy using our tool! 🎈
