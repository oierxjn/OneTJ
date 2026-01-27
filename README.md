<div align="center">

[![OneTJ Logo](assets/icon/logo.jpg)](https://github.com/oierxjn/OneTJ)
# OneTJ

[中文](README_zh.md) | [English](README.md)

`OneTJ` is a third-party client for Tongji University services. It provides a clean, focused experience for student profile access and academic calendar information.   

Original repository: [FlowerBlackG/OneTJ](https://github.com/FlowerBlackG/OneTJ).

Most features in this project are still under active development and may be unstable; feedback is welcome.

<div>

## Features

- Student profile fetch and display
- Current term calendar overview (week number and term name)
- Local caching with Hive for faster startup and offline-friendly reads

## Tech Stack

- Flutter (Dart)

## Project Structure

- `lib/app/`: app-level constants and exceptions
- `lib/features/`: feature modules (launcher, login, home)
- `lib/models/`: shared data models (API responses and local models)
- `lib/repo/`: local repositories and caching (token, student info, calendar)
- `lib/services/`: API/services layer (TongjiApi)
- `lib/l10n/`: localization resources
- `assets/`: static assets used in the app

## Getting Started

The project has not yet completed the development of all functions, so no release version is available for direct running.  

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## App Flow

1. Launcher initializes storage and checks cached tokens.
2. If a valid access token exists, it navigates to Home.
3. Otherwise, it opens the login WebView and exchanges the auth code for tokens.
4. Home fetches student profile data and the current term calendar.

