# Gobbler

A simple Flutter project to showcase Gobbler's backend.

## Getting Started

# Install using APKs
We have built working APKs found in the /apk folder that you can install on your android device. Simply transfer the correct apk version based on your phone's CPU architecture and open the file.  

Alternatively, you can follow the steps below to build the app if you have Flutter set up.

# Building the Flutter app

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) installed 
- Connected Android device or Android emulator

### Set-up local directories

Assuming that you have cloned this repository and navigated to the root of the project, navigate to this folder (`/mobile`)

> e.g. if project root path is `/usr/lib/gobbler`

```bash
cd /usr/lib/gobbler/mobile
```

### Provide secrets

We require several secrets across each of our services.
Make a copy of `.env.example`, rename it to `.env` and provide the information as stated using any text editor (`vi .env.example`).

1. `cp .env.sample .env`
2. Replace `<>` fields with the respective information (BASE_API_URL, FIREBASE_PROJECT_ID etc.).

**Note: `.env` is automatically ignored by git**

```yaml
BASE_API_URL=your_base_api_url
FIREBASE_ANDROID_API_KEY=your_firebase_android_api_key
FIREBASE_ANDROID_APP_ID=your_firebase_android_app_id
FIREBASE_MESSAGING_SENDER_ID=your_firebase_messaging_sender_id
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
FIREBASE_IOS_CLIENT_ID=your_firebase_ios_client_id
FIREBASE_IOS_API_KEY=your_firebase_ios_api_key
FIREBASE_IOS_APP_ID=your_firebase_ios_app_id
```

### Building the flutter app

Environment variables in the `.env` created earlier will be loaded automatically (as long as the commands are run in the same folder as the `.env` file).

1. Run the following command to get the required dependencies

   ```bash
   flutter pub get
   ```

2. Run the following command to build the app on your device:

   ```bash
   flutter run --release
   ```

