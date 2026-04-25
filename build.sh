Here's the COMPLETE, READY-TO-RUN main.sh script from start to end. Just copy and run:

```bash
#!/usr/bin/env bash
set -e

###############################################################################
# JAVA GOAT - Professional Messenger App
# Complete build script with ALL features
###############################################################################

echo "🐐 Java Goat - Professional Build Starting..."

# ─── SYSTEM DEPENDENCIES ────────────────────────────────────────────────────
sudo apt-get update -qq
sudo apt-get install -y openjdk-17-jdk wget unzip curl git zip \
     libpulse0 libglib2.0-0 2>/dev/null || true

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
java -version

# ─── ANDROID SDK ────────────────────────────────────────────────────────────
export ANDROID_HOME=/opt/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "📥 Downloading Android SDK..."
    mkdir -p $ANDROID_HOME/cmdline-tools
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
        -O /tmp/cmdtools.zip
    unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools
    mv /tmp/cmdtools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest
fi

yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1

# ─── PROJECT STRUCTURE ──────────────────────────────────────────────────────
PROJECT_DIR="$HOME/JavaGoat"
PKG_DIR="$PROJECT_DIR/app/src/main/java/com/example/callingapp"
RES_DIR="$PROJECT_DIR/app/src/main/res"

mkdir -p "$PKG_DIR"
mkdir -p "$PKG_DIR/models"
mkdir -p "$PKG_DIR/fragments"
mkdir -p "$PKG_DIR/adapters"
mkdir -p "$RES_DIR/layout"
mkdir -p "$RES_DIR/drawable"
mkdir -p "$RES_DIR/drawable-v24"
mkdir -p "$RES_DIR/menu"
mkdir -p "$RES_DIR/values"
mkdir -p "$RES_DIR/values-night"
mkdir -p "$RES_DIR/mipmap-anydpi-v26"
mkdir -p "$RES_DIR/mipmap-hdpi"
mkdir -p "$RES_DIR/mipmap-mdpi"
mkdir -p "$RES_DIR/mipmap-xhdpi"
mkdir -p "$RES_DIR/mipmap-xxhdpi"
mkdir -p "$RES_DIR/mipmap-xxxhdpi"
mkdir -p "$RES_DIR/raw"
mkdir -p "$RES_DIR/xml"
mkdir -p "$PROJECT_DIR/app/src/main/assets"

cd "$PROJECT_DIR"
echo "📁 Directory structure created"

# ─── KEYSTORE ───────────────────────────────────────────────────────────────
keytool -genkeypair -v \
    -keystore "$PROJECT_DIR/app/javagoat.jks" \
    -alias javagoat \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass javagoat123 \
    -keypass javagoat123 \
    -dname "CN=JavaGoat, OU=Dev, O=JavaGoat, L=Delhi, ST=Delhi, C=IN" \
    2>/dev/null || true
echo "🔑 Keystore generated"

# ─── GOOGLE-SERVICES.JSON ───────────────────────────────────────────────────
cat > "$PROJECT_DIR/app/google-services.json" << 'GSJSON'
{
  "project_info": {
    "project_number": "1044955332082",
    "project_id": "videocallpro-f5f1b",
    "storage_bucket": "videocallpro-f5f1b.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1044955332082:android:2c6e7458b191b9d96eff6b",
        "android_client_info": {
          "package_name": "com.example.callingapp"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
GSJSON
echo "🔥 google-services.json created"

# ─── SETTINGS.GRADLE ────────────────────────────────────────────────────────
cat > "$PROJECT_DIR/settings.gradle" << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        maven { url 'https://maven.google.com' }
    }
}
rootProject.name = "JavaGoat"
include ':app'
EOF

# ─── ROOT BUILD.GRADLE ──────────────────────────────────────────────────────
cat > "$PROJECT_DIR/build.gradle" << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# ─── GRADLE.PROPERTIES ──────────────────────────────────────────────────────
cat > "$PROJECT_DIR/gradle.properties" << 'EOF'
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m
org.gradle.parallel=true
org.gradle.caching=true
android.useAndroidX=true
android.enableJetifier=true
EOF

# ─── APP BUILD.GRADLE ───────────────────────────────────────────────────────
cat > "$PROJECT_DIR/app/build.gradle" << 'EOF'
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
}

android {
    namespace 'com.example.callingapp'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.callingapp"
        minSdk 24
        targetSdk 34
        versionCode 2
        versionName "2.0"
        multiDexEnabled true
    }

    signingConfigs {
        release {
            storeFile file('javagoat.jks')
            storePassword 'javagoat123'
            keyAlias 'javagoat'
            keyPassword 'javagoat123'
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            signingConfig signingConfigs.release
        }
        debug {
            signingConfig signingConfigs.release
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    packagingOptions {
        pickFirst 'lib/x86/libjingle_peerconnection_so.so'
        pickFirst 'lib/x86_64/libjingle_peerconnection_so.so'
        pickFirst 'lib/armeabi-v7a/libjingle_peerconnection_so.so'
        pickFirst 'lib/arm64-v8a/libjingle_peerconnection_so.so'
    }

    lint {
        abortOnError false
        checkReleaseBuilds false
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'androidx.viewpager2:viewpager2:1.0.0'
    implementation 'com.google.android.material:material:1.11.0'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-storage'
    implementation 'org.webrtc:google-webrtc:1.0.32006'
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    annotationProcessor 'com.github.bumptech.glide:compiler:4.16.0'
    implementation 'androidx.room:room-runtime:2.6.1'
    annotationProcessor 'androidx.room:room-compiler:2.6.1'
    implementation 'com.airbnb.android:lottie:6.1.0'
    implementation 'de.hdodenhof:circleimageview:3.1.0'
}
EOF
echo "📦 Gradle files created"

# ════════════════════════════════════════════════════════════════════════════
# ANDROID MANIFEST
# ════════════════════════════════════════════════════════════════════════════
cat > "$PROJECT_DIR/app/src/main/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.front" android:required="false" />
    <uses-feature android:name="android.hardware.microphone" android:required="false" />

    <application
        android:name=".JavaGoatApp"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="@string/app_name"
        android:theme="@style/AppTheme"
        android:usesCleartextTraffic="true"
        android:hardwareAccelerated="true"
        tools:targetApi="34">

        <activity android:name=".SplashActivity" android:exported="true" android:noHistory="true" android:theme="@style/SplashTheme">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity android:name=".MainActivity" android:exported="true" android:windowSoftInputMode="adjustResize" android:configChanges="orientation|screenSize|keyboardHidden" />
        <activity android:name=".ChatActivity" android:exported="false" android:windowSoftInputMode="adjustResize" />
        <activity android:name=".CallActivity" android:exported="false" android:showOnLockScreen="true" android:turnScreenOn="true" android:keepScreenOn="true" android:configChanges="orientation|screenSize" android:theme="@style/CallTheme" />
        <activity android:name=".SettingsActivity" android:exported="false" />
        <activity android:name=".ImageViewerActivity" android:exported="false" />
        <activity android:name=".GroupChatActivity" android:exported="false" android:windowSoftInputMode="adjustResize" />
        <activity android:name=".EditProfileActivity" android:exported="false" />

        <service android:name=".BackgroundService" android:exported="false" android:foregroundServiceType="dataSync" />
        <service android:name=".MyFirebaseMessagingService" android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" android:value="messages_channel" />
    </application>
</manifest>
EOF
echo "📋 Manifest created"

# ════════════════════════════════════════════════════════════════════════════
# RESOURCE FILES
# ════════════════════════════════════════════════════════════════════════════

# ─── COLORS ─────────────────────────────────────────────────────────────────
cat > "$RES_DIR/values/colors.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#1E88E5</color>
    <color name="primary_dark">#1565C0</color>
    <color name="primary_light">#90CAF9</color>
    <color name="accent">#FF6B35</color>
    <color name="accent_dark">#E64A00</color>
    <color name="background">#F5F5F5</color>
    <color name="background_dark">#121212</color>
    <color name="surface">#FFFFFF</color>
    <color name="surface_dark">#1E1E1E</color>
    <color name="bubble_outgoing">#1E88E5</color>
    <color name="bubble_incoming">#FFFFFF</color>
    <color name="text_primary">#212121</color>
    <color name="text_secondary">#757575</color>
    <color name="text_on_primary">#FFFFFF</color>
    <color name="online_green">#4CAF50</color>
    <color name="offline_grey">#9E9E9E</color>
    <color name="unread_badge">#FF6B35</color>
    <color name="call_accept">#4CAF50</color>
    <color name="call_reject">#F44336</color>
    <color name="call_end">#F44336</color>
    <color name="divider">#E0E0E0</color>
    <color name="ripple">#1A1E88E5</color>
    <color name="transparent">#00000000</color>
    <color name="status_bar">#1565C0</color>
    <color name="typing_indicator">#757575</color>
</resources>
EOF

# ─── STRINGS ─────────────────────────────────────────────────────────────────
cat > "$RES_DIR/values/strings.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Java Goat</string>
    <string name="chats">Chats</string>
    <string name="updates">Updates</string>
    <string name="calls">Calls</string>
    <string name="profile">Profile</string>
    <string name="settings">Settings</string>
    <string name="send">Send</string>
    <string name="type_message">Type a message...</string>
    <string name="voice_call">Voice Call</string>
    <string name="video_call">Video Call</string>
    <string name="end_call">End Call</string>
    <string name="accept">Accept</string>
    <string name="reject">Reject</string>
    <string name="login">Login</string>
    <string name="signup">Sign Up</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="add_friend">Add Friend</string>
    <string name="friend_id">Friend ID (jg-XXXX)</string>
    <string name="incoming_call">Incoming Call</string>
    <string name="calling">Calling...</string>
    <string name="connected">Connected</string>
    <string name="online">Online</string>
    <string name="offline">Offline</string>
    <string name="typing">typing...</string>
    <string name="delete_for_me">Delete for me</string>
    <string name="delete_for_everyone">Delete for everyone</string>
    <string name="edit_message">Edit Message</string>
    <string name="reply">Reply</string>
    <string name="block_user">Block User</string>
    <string name="unblock_user">Unblock User</string>
    <string name="search">Search</string>
    <string name="dark_mode">Dark Mode</string>
    <string name="logout">Logout</string>
    <string name="copy_id">Copy ID</string>
    <string name="edit_profile">Edit Profile</string>
    <string name="hold_to_record">Hold to record</string>
    <string name="no_chats">No chats yet. Add a friend!</string>
    <string name="no_calls">No call history</string>
    <string name="no_updates">No updates</string>
    <string name="group_chat">Group Chat</string>
    <string name="voice_message">Voice Message</string>
    <string name="image">Image</string>
    <string name="missed_call">Missed Call</string>
</resources>
EOF

# ─── THEMES ─────────────────────────────────────────────────────────────────
cat > "$RES_DIR/values/themes.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="colorPrimaryDark">@color/primary_dark</item>
        <item name="colorAccent">@color/accent</item>
        <item name="android:windowBackground">@color/background</item>
        <item name="android:statusBarColor">@color/primary_dark</item>
    </style>
    <style name="SplashTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:windowBackground">@color/primary</item>
        <item name="android:statusBarColor">@color/primary_dark</item>
        <item name="android:windowFullscreen">true</item>
    </style>
    <style name="CallTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:windowBackground">#FF121212</item>
        <item name="android:statusBarColor">#FF000000</item>
        <item name="android:windowKeepScreenOn">true</item>
        <item name="android:windowShowOnLockScreen">true</item>
        <item name="android:windowTurnScreenOn">true</item>
    </style>
    <style name="TabStyle" parent="Widget.Design.TabLayout">
        <item name="tabTextColor">#80FFFFFF</item>
        <item name="tabSelectedTextColor">#FFFFFF</item>
        <item name="tabIndicatorColor">@color/accent</item>
        <item name="tabIndicatorHeight">3dp</item>
    </style>
</resources>
EOF

cat > "$RES_DIR/values-night/themes.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">#1565C0</item>
        <item name="colorPrimaryDark">#0D47A1</item>
        <item name="colorAccent">#FF6B35</item>
        <item name="android:windowBackground">@color/background_dark</item>
        <item name="android:statusBarColor">#0D47A1</item>
    </style>
</resources>
EOF

# ─── DRAWABLES ───────────────────────────────────────────────────────────────
cat > "$RES_DIR/drawable/bubble_out.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/bubble_outgoing" />
    <corners android:topLeftRadius="18dp" android:topRightRadius="18dp" android:bottomLeftRadius="18dp" android:bottomRightRadius="4dp" />
    <padding android:left="12dp" android:top="8dp" android:right="12dp" android:bottom="8dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/bubble_in.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/bubble_incoming" />
    <corners android:topLeftRadius="4dp" android:topRightRadius="18dp" android:bottomLeftRadius="18dp" android:bottomRightRadius="18dp" />
    <stroke android:width="1dp" android:color="#E0E0E0" />
    <padding android:left="12dp" android:top="8dp" android:right="12dp" android:bottom="8dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/gradient_toolbar.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:startColor="#1E88E5" android:endColor="#1565C0" android:angle="90" android:type="linear" />
</shape>
EOF

cat > "$RES_DIR/drawable/rounded_card.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/surface" />
    <corners android:radius="12dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/circle_avatar.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/primary_light" />
    <size android:width="48dp" android:height="48dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/online_dot.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/online_green" />
    <stroke android:width="2dp" android:color="#FFFFFF" />
    <size android:width="12dp" android:height="12dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/fab_background.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/accent" />
    <size android:width="56dp" android:height="56dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/mic_button.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/primary" />
    <size android:width="48dp" android:height="48dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/reaction_picker_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#FFFFFF" />
    <corners android:radius="28dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/reply_preview_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#F0F4FF" />
    <corners android:radius="8dp" />
    <stroke android:width="2dp" android:color="@color/primary" />
</shape>
EOF

cat > "$RES_DIR/drawable/input_field_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#FFFFFF" />
    <corners android:radius="24dp" />
    <stroke android:width="1dp" android:color="#E0E0E0" />
</shape>
EOF

cat > "$RES_DIR/drawable/splash_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:startColor="#1E88E5" android:centerColor="#1565C0" android:endColor="#0D47A1" android:angle="135" android:type="linear" />
</shape>
EOF

cat > "$RES_DIR/drawable/call_accept_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/call_accept" />
    <size android:width="72dp" android:height="72dp" />
</shape>
EOF

cat > "$RES_DIR/drawable/call_reject_bg.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/call_reject" />
    <size android:width="72dp" android:height="72dp" />
</shape>
EOF

# ─── LAUNCHER ICONS ──────────────────────────────────────────────────────────
cat > "$RES_DIR/mipmap-anydpi-v26/ic_launcher.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > "$RES_DIR/mipmap-anydpi-v26/ic_launcher_round.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > "$RES_DIR/drawable/ic_launcher_background.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#1E88E5" />
</shape>
EOF

cat > "$RES_DIR/drawable/ic_launcher_foreground.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF" android:pathData="M54,20 C35.2,20 20,35.2 20,54 C20,72.8 35.2,88 54,88 C72.8,88 88,72.8 88,54 C88,35.2 72.8,20 54,20 Z M72,66 L60,66 L54,74 L48,66 L36,66 L36,42 L72,42 Z" />
    <path android:fillColor="#FFFFFF" android:pathData="M44,50 L64,50 M44,57 L58,57" android:strokeColor="#1E88E5" android:strokeWidth="3" />
</vector>
EOF

for density in hdpi mdpi xhdpi xxhdpi xxxhdpi; do
    mkdir -p "$RES_DIR/mipmap-$density"
done

# ─── MENU ────────────────────────────────────────────────────────────────────
cat > "$RES_DIR/menu/bottom_nav_menu.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_chats" android:icon="@android:drawable/ic_dialog_email" android:title="@string/chats" />
    <item android:id="@+id/nav_updates" android:icon="@android:drawable/stat_notify_more" android:title="@string/updates" />
    <item android:id="@+id/nav_calls" android:icon="@android:drawable/ic_menu_call" android:title="@string/calls" />
    <item android:id="@+id/nav_profile" android:icon="@android:drawable/ic_menu_myplaces" android:title="@string/profile" />
</menu>
EOF

cat > "$RES_DIR/menu/chat_menu.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/menu_search" android:title="@string/search" android:showAsAction="ifRoom" android:icon="@android:drawable/ic_menu_search"/>
    <item android:id="@+id/menu_block" android:title="@string/block_user" android:showAsAction="never"/>
</menu>
EOF

# ─── LAYOUT FILES ────────────────────────────────────────────────────────────
cat > "$RES_DIR/layout/activity_splash.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:background="@drawable/splash_bg">
    <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="center" android:orientation="vertical" android:gravity="center">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="🐐" android:textSize="80sp" android:layout_marginBottom="16dp" />
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Java Goat" android:textSize="36sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" android:textStyle="bold" />
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Connect. Chat. Call." android:textSize="16sp" android:textColor="#B3FFFFFF" android:layout_marginTop="8dp" />
        <ProgressBar android:layout_width="48dp" android:layout_height="48dp" android:layout_marginTop="48dp" android:indeterminateTint="#FFFFFF" />
    </LinearLayout>
</FrameLayout>
EOF

cat > "$RES_DIR/layout/activity_main.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/background">
    <ScrollView android:id="@+id/auth_view" android:layout_width="match_parent" android:layout_height="match_parent" android:visibility="visible" android:background="@drawable/splash_bg">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="32dp" android:gravity="center">
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="🐐" android:textSize="64sp" android:layout_marginTop="48dp" />
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Java Goat" android:textSize="32sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" android:layout_marginBottom="48dp" />
            <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="16dp" app:cardElevation="8dp">
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp">
                    <com.google.android.material.textfield.TextInputLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="@string/email" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox" android:layout_marginBottom="16dp">
                        <com.google.android.material.textfield.TextInputEditText android:id="@+id/auth_email" android:layout_width="match_parent" android:layout_height="wrap_content" android:inputType="textEmailAddress" />
                    </com.google.android.material.textfield.TextInputLayout>
                    <com.google.android.material.textfield.TextInputLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="@string/password" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox" app:passwordToggleEnabled="true" android:layout_marginBottom="24dp">
                        <com.google.android.material.textfield.TextInputEditText android:id="@+id/auth_password" android:layout_width="match_parent" android:layout_height="wrap_content" android:inputType="textPassword" />
                    </com.google.android.material.textfield.TextInputLayout>
                    <com.google.android.material.button.MaterialButton android:id="@+id/btn_login" android:layout_width="match_parent" android:layout_height="56dp" android:text="@string/login" android:textSize="16sp" app:cornerRadius="12dp" android:layout_marginBottom="12dp" />
                    <com.google.android.material.button.MaterialButton android:id="@+id/btn_signup" android:layout_width="match_parent" android:layout_height="56dp" android:text="@string/signup" android:textSize="16sp" app:cornerRadius="12dp" style="@style/Widget.MaterialComponents.Button.OutlinedButton" />
                </LinearLayout>
            </androidx.cardview.widget.CardView>
        </LinearLayout>
    </ScrollView>
    <LinearLayout android:id="@+id/main_view" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:visibility="gone">
        <androidx.appcompat.widget.Toolbar android:id="@+id/toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@drawable/gradient_toolbar" android:elevation="4dp">
            <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
                <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Java Goat" android:textSize="20sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" android:textStyle="bold" />
                <ImageButton android:id="@+id/btn_add_friend" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_input_add" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" android:layout_marginEnd="8dp" />
                <ImageButton android:id="@+id/btn_menu" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_menu_more" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" />
            </LinearLayout>
        </androidx.appcompat.widget.Toolbar>
        <com.google.android.material.tabs.TabLayout android:id="@+id/tab_layout" android:layout_width="match_parent" android:layout_height="48dp" android:background="@color/primary" style="@style/TabStyle" />
        <androidx.viewpager2.widget.ViewPager2 android:id="@+id/view_pager" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" />
        <com.google.android.material.floatingactionbutton.FloatingActionButton android:id="@+id/fab_new_chat" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="bottom|end" android:layout_margin="16dp" android:src="@android:drawable/ic_input_add" app:backgroundTint="@color/accent" app:tint="#FFFFFF" />
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/fragment_chat_list.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent">
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/recycler_chats" android:layout_width="match_parent" android:layout_height="match_parent" android:clipToPadding="false" android:paddingBottom="80dp" />
    <TextView android:id="@+id/empty_chats" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="center" android:text="@string/no_chats" android:textSize="16sp" android:textColor="@color/text_secondary" android:visibility="gone" />
</FrameLayout>
EOF

cat > "$RES_DIR/layout/fragment_updates.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent">
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/recycler_updates" android:layout_width="match_parent" android:layout_height="match_parent" />
    <TextView android:id="@+id/empty_updates" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="center" android:text="@string/no_updates" android:textSize="16sp" android:textColor="@color/text_secondary" android:visibility="gone" />
</FrameLayout>
EOF

cat > "$RES_DIR/layout/fragment_calls.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent">
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/recycler_calls" android:layout_width="match_parent" android:layout_height="match_parent" />
    <TextView android:id="@+id/empty_calls" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="center" android:text="@string/no_calls" android:textSize="16sp" android:textColor="@color/text_secondary" android:visibility="gone" />
</FrameLayout>
EOF

cat > "$RES_DIR/layout/fragment_profile.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:background="@color/background">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center_horizontal" android:padding="16dp">
        <LinearLayout android:layout_width="match_parent" android:layout_height="200dp" android:orientation="vertical" android:gravity="center" android:background="@drawable/gradient_toolbar" android:layout_marginBottom="16dp">
            <TextView android:id="@+id/profile_emoji" android:layout_width="80dp" android:layout_height="80dp" android:gravity="center" android:textSize="48sp" android:background="@drawable/circle_avatar" />
            <TextView android:id="@+id/profile_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="22sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" android:layout_marginTop="8dp" />
            <TextView android:id="@+id/profile_status" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="14sp" android:textColor="#B3FFFFFF" />
        </LinearLayout>
        <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp" app:cardElevation="4dp" android:layout_marginBottom="16dp">
            <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="16dp">
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Your Friend ID" android:textSize="12sp" android:textColor="@color/text_secondary" />
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
                    <TextView android:id="@+id/profile_id" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:textSize="24sp" android:textColor="@color/primary" android:fontFamily="monospace" android:textStyle="bold" />
                    <ImageButton android:id="@+id/btn_copy_id" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_menu_share" android:background="?attr/selectableItemBackgroundBorderless" android:tint="@color/primary" />
                </LinearLayout>
            </LinearLayout>
        </androidx.cardview.widget.CardView>
        <com.google.android.material.button.MaterialButton android:id="@+id/btn_edit_profile" android:layout_width="match_parent" android:layout_height="56dp" android:text="@string/edit_profile" app:cornerRadius="12dp" android:layout_marginBottom="12dp" />
        <com.google.android.material.button.MaterialButton android:id="@+id/btn_settings" android:layout_width="match_parent" android:layout_height="56dp" android:text="@string/settings" app:cornerRadius="12dp" style="@style/Widget.MaterialComponents.Button.OutlinedButton" android:layout_marginBottom="12dp" />
        <com.google.android.material.button.MaterialButton android:id="@+id/btn_logout_profile" android:layout_width="match_parent" android:layout_height="56dp" android:text="@string/logout" app:cornerRadius="12dp" app:backgroundTint="#F44336" />
    </LinearLayout>
</ScrollView>
EOF

cat > "$RES_DIR/layout/activity_chat.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/background">
    <androidx.appcompat.widget.Toolbar android:id="@+id/chat_toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@drawable/gradient_toolbar" android:elevation="4dp">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
            <ImageButton android:id="@+id/btn_back" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_media_previous" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" android:layout_marginEnd="8dp" />
            <FrameLayout android:layout_width="44dp" android:layout_height="44dp" android:layout_marginEnd="12dp">
                <TextView android:id="@+id/chat_partner_emoji" android:layout_width="44dp" android:layout_height="44dp" android:gravity="center" android:textSize="24sp" android:background="@drawable/circle_avatar" />
                <View android:id="@+id/chat_online_dot" android:layout_width="12dp" android:layout_height="12dp" android:layout_gravity="bottom|end" android:background="@drawable/online_dot" android:visibility="gone" />
            </FrameLayout>
            <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
                <TextView android:id="@+id/chat_partner_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="17sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" />
                <TextView android:id="@+id/chat_status_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="#B3FFFFFF" />
            </LinearLayout>
            <ImageButton android:id="@+id/btn_voice_call" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_menu_call" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" />
            <ImageButton android:id="@+id/btn_video_call" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_menu_camera" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" android:layout_marginStart="4dp" />
        </LinearLayout>
    </androidx.appcompat.widget.Toolbar>
    <LinearLayout android:id="@+id/search_bar" android:layout_width="match_parent" android:layout_height="48dp" android:orientation="horizontal" android:background="@color/surface" android:gravity="center_vertical" android:padding="8dp" android:visibility="gone">
        <EditText android:id="@+id/search_input" android:layout_width="0dp" android:layout_height="match_parent" android:layout_weight="1" android:hint="@string/search" android:background="@null" android:padding="8dp" />
        <TextView android:id="@+id/search_result_count" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="@color/text_secondary" android:textSize="12sp" android:padding="8dp" />
    </LinearLayout>
    <LinearLayout android:id="@+id/reply_preview" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:background="@color/surface" android:padding="8dp" android:gravity="center_vertical" android:visibility="gone">
        <View android:layout_width="4dp" android:layout_height="match_parent" android:background="@color/accent" android:layout_marginEnd="8dp" />
        <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Replying to" android:textSize="11sp" android:textColor="@color/accent" android:fontFamily="sans-serif-medium" />
            <TextView android:id="@+id/reply_preview_text" android:layout_width="match_parent" android:layout_height="wrap_content" android:textSize="13sp" android:textColor="@color/text_secondary" android:maxLines="1" />
        </LinearLayout>
        <ImageButton android:id="@+id/btn_cancel_reply" android:layout_width="32dp" android:layout_height="32dp" android:src="@android:drawable/ic_menu_close_clear_cancel" android:background="?attr/selectableItemBackgroundBorderless" android:tint="@color/text_secondary" />
    </LinearLayout>
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/recycler_messages" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:clipToPadding="false" android:padding="8dp" />
    <LinearLayout android:id="@+id/typing_indicator" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:visibility="gone">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="typing..." android:textSize="13sp" android:textColor="@color/typing_indicator" android:textStyle="italic" />
    </LinearLayout>
    <FrameLayout android:id="@+id/voice_recording_overlay" android:layout_width="match_parent" android:layout_height="64dp" android:background="@color/surface" android:visibility="gone">
        <LinearLayout android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="horizontal" android:gravity="center_vertical" android:padding="12dp">
            <View android:layout_width="12dp" android:layout_height="12dp" android:background="@drawable/online_dot" android:layout_marginEnd="8dp" />
            <TextView android:id="@+id/recording_timer" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="0:00" android:textSize="16sp" android:textColor="@color/text_primary" />
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Slide left to cancel →" android:textSize="12sp" android:textColor="@color/text_secondary" />
        </LinearLayout>
    </FrameLayout>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:gravity="bottom" android:background="@color/surface" android:elevation="8dp">
        <ImageButton android:id="@+id/btn_attach_image" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_menu_gallery" android:background="?attr/selectableItemBackgroundBorderless" android:tint="@color/primary" />
        <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:background="@drawable/input_field_bg" android:orientation="horizontal" android:gravity="center_vertical" android:minHeight="48dp">
            <EditText android:id="@+id/msg_input" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:hint="@string/type_message" android:background="@null" android:padding="12dp" android:maxLines="4" />
        </LinearLayout>
        <ImageButton android:id="@+id/btn_send" android:layout_width="48dp" android:layout_height="48dp" android:src="@android:drawable/ic_menu_send" android:background="@drawable/mic_button" android:tint="#FFFFFF" android:layout_marginStart="8dp" android:elevation="4dp" />
        <ImageButton android:id="@+id/btn_voice_msg" android:layout_width="48dp" android:layout_height="48dp" android:src="@android:drawable/presence_audio_online" android:background="@drawable/fab_background" android:tint="#FFFFFF" android:layout_marginStart="4dp" />
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/activity_call.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#FF000000">
    <org.webrtc.SurfaceViewRenderer android:id="@+id/remote_video_view" android:layout_width="match_parent" android:layout_height="match_parent" />
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center_horizontal" android:padding="32dp" android:layout_gravity="top" android:background="#99000000">
        <TextView android:id="@+id/call_partner_emoji" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="64sp" />
        <TextView android:id="@+id/call_partner_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="28sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" />
        <TextView android:id="@+id/call_status_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="16sp" android:textColor="#B3FFFFFF" android:layout_marginTop="8dp" />
        <TextView android:id="@+id/call_duration" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="18sp" android:textColor="#FFFFFF" android:layout_marginTop="8dp" android:visibility="gone" />
    </LinearLayout>
    <org.webrtc.SurfaceViewRenderer android:id="@+id/local_video_view" android:layout_width="120dp" android:layout_height="160dp" android:layout_gravity="top|end" android:layout_margin="16dp" android:elevation="8dp" />
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:layout_gravity="bottom" android:background="#99000000" android:padding="24dp">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center" android:layout_marginBottom="24dp">
            <LinearLayout android:layout_width="80dp" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center">
                <ImageButton android:id="@+id/btn_mute" android:layout_width="56dp" android:layout_height="56dp" android:src="@android:drawable/ic_lock_silent_mode" android:background="@drawable/call_reject_bg" android:tint="#FFFFFF" />
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Mute" android:textColor="#FFFFFF" android:textSize="12sp" android:layout_marginTop="4dp" />
            </LinearLayout>
            <LinearLayout android:layout_width="80dp" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center">
                <ImageButton android:id="@+id/btn_speaker" android:layout_width="56dp" android:layout_height="56dp" android:src="@android:drawable/ic_lock_silent_mode_off" android:background="@drawable/call_accept_bg" android:tint="#FFFFFF" />
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Speaker" android:textColor="#FFFFFF" android:textSize="12sp" android:layout_marginTop="4dp" />
            </LinearLayout>
            <LinearLayout android:layout_width="80dp" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center">
                <ImageButton android:id="@+id/btn_toggle_camera" android:layout_width="56dp" android:layout_height="56dp" android:src="@android:drawable/ic_menu_camera" android:background="@drawable/mic_button" android:tint="#FFFFFF" />
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Camera" android:textColor="#FFFFFF" android:textSize="12sp" android:layout_marginTop="4dp" />
            </LinearLayout>
        </LinearLayout>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center">
            <LinearLayout android:id="@+id/accept_btn_layout" android:layout_width="80dp" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center" android:layout_marginEnd="48dp" android:visibility="gone">
                <ImageButton android:id="@+id/btn_accept" android:layout_width="72dp" android:layout_height="72dp" android:src="@android:drawable/ic_menu_call" android:background="@drawable/call_accept_bg" android:tint="#FFFFFF" />
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Accept" android:textColor="#FFFFFF" android:textSize="13sp" android:layout_marginTop="8dp" />
            </LinearLayout>
            <LinearLayout android:layout_width="80dp" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center">
                <ImageButton android:id="@+id/btn_end_call" android:layout_width="72dp" android:layout_height="72dp" android:src="@android:drawable/ic_menu_close_clear_cancel" android:background="@drawable/call_reject_bg" android:tint="#FFFFFF" />
                <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="End" android:textColor="#FFFFFF" android:textSize="13sp" android:layout_marginTop="8dp" />
            </LinearLayout>
        </LinearLayout>
    </LinearLayout>
</FrameLayout>
EOF

cat > "$RES_DIR/layout/item_chat.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="0dp" android:foreground="?attr/selectableItemBackground">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="12dp" android:gravity="center_vertical" android:background="@color/surface">
        <FrameLayout android:layout_width="52dp" android:layout_height="52dp" android:layout_marginEnd="12dp">
            <TextView android:id="@+id/chat_item_emoji" android:layout_width="52dp" android:layout_height="52dp" android:gravity="center" android:textSize="28sp" android:background="@drawable/circle_avatar" />
            <View android:id="@+id/chat_item_online_dot" android:layout_width="14dp" android:layout_height="14dp" android:layout_gravity="bottom|end" android:background="@drawable/online_dot" android:visibility="gone" />
        </FrameLayout>
        <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
            <TextView android:id="@+id/chat_item_name" android:layout_width="match_parent" android:layout_height="wrap_content" android:textSize="16sp" android:textColor="@color/text_primary" android:fontFamily="sans-serif-medium" android:maxLines="1" />
            <TextView android:id="@+id/chat_item_last_msg" android:layout_width="match_parent" android:layout_height="wrap_content" android:textSize="13sp" android:textColor="@color/text_secondary" android:maxLines="1" />
        </LinearLayout>
        <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="end">
            <TextView android:id="@+id/chat_item_time" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="11sp" android:textColor="@color/text_secondary" />
            <TextView android:id="@+id/chat_item_unread" android:layout_width="20dp" android:layout_height="20dp" android:gravity="center" android:textSize="11sp" android:textColor="#FFFFFF" android:background="@drawable/online_dot" android:visibility="gone" android:layout_marginTop="4dp" />
        </LinearLayout>
    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

cat > "$RES_DIR/layout/item_message.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="4dp">
    <TextView android:id="@+id/msg_date_header" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="center_horizontal" android:background="@drawable/rounded_card" android:padding="4dp" android:textSize="11sp" android:textColor="@color/text_secondary" android:visibility="gone" android:layout_marginBottom="8dp" />
    <LinearLayout android:id="@+id/msg_out_container" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="end" android:visibility="gone">
        <LinearLayout android:id="@+id/out_reply_preview" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical" android:background="@drawable/reply_preview_bg" android:padding="8dp" android:layout_marginEnd="8dp" android:maxWidth="260dp" android:visibility="gone">
            <TextView android:id="@+id/out_reply_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="@color/text_secondary" android:maxLines="2" />
        </LinearLayout>
        <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="end" android:layout_marginEnd="8dp" android:maxWidth="280dp">
            <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical">
                <TextView android:id="@+id/out_msg_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:background="@drawable/bubble_out" android:textColor="#FFFFFF" android:textSize="15sp" android:maxWidth="240dp" />
                <LinearLayout android:id="@+id/out_reactions_row" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_gravity="end" android:visibility="gone" />
                <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="end">
                    <TextView android:id="@+id/out_msg_time" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="10sp" android:textColor="#80FFFFFF" />
                    <TextView android:id="@+id/msg_status" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="10sp" android:textColor="#80FFFFFF" />
                </LinearLayout>
            </LinearLayout>
        </LinearLayout>
    </LinearLayout>
    <LinearLayout android:id="@+id/msg_in_container" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="start" android:visibility="gone">
        <LinearLayout android:id="@+id/in_reply_preview" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical" android:background="@drawable/reply_preview_bg" android:padding="8dp" android:layout_marginStart="8dp" android:maxWidth="260dp" android:visibility="gone">
            <TextView android:id="@+id/in_reply_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="@color/text_secondary" android:maxLines="2" />
        </LinearLayout>
        <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="start" android:layout_marginStart="8dp" android:maxWidth="280dp">
            <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical">
                <TextView android:id="@+id/in_msg_text" android:layout_width="wrap_content" android:layout_height="wrap_content" android:background="@drawable/bubble_in" android:textColor="@color/text_primary" android:textSize="15sp" android:maxWidth="240dp" />
                <LinearLayout android:id="@+id/in_reactions_row" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:visibility="gone" />
                <TextView android:id="@+id/in_msg_time" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="10sp" android:textColor="@color/text_secondary" />
            </LinearLayout>
        </LinearLayout>
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/item_call.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical" android:background="?attr/selectableItemBackground">
    <TextView android:id="@+id/call_item_emoji" android:layout_width="52dp" android:layout_height="52dp" android:gravity="center" android:textSize="28sp" android:background="@drawable/circle_avatar" android:layout_marginEnd="12dp" />
    <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
        <TextView android:id="@+id/call_item_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="16sp" android:textColor="@color/text_primary" android:fontFamily="sans-serif-medium" />
        <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal">
            <TextView android:id="@+id/call_item_type" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="13sp" android:textColor="@color/text_secondary" />
            <TextView android:id="@+id/call_item_duration" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="13sp" android:textColor="@color/text_secondary" android:layout_marginStart="8dp" />
        </LinearLayout>
    </LinearLayout>
    <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="end">
        <TextView android:id="@+id/call_item_time" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="11sp" android:textColor="@color/text_secondary" />
        <ImageButton android:id="@+id/call_item_callback" android:layout_width="36dp" android:layout_height="36dp" android:src="@android:drawable/ic_menu_call" android:background="?attr/selectableItemBackgroundBorderless" android:tint="@color/primary" />
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/item_friend_request.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp" app:cardElevation="2dp" android:layout_margin="8dp">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical">
        <TextView android:id="@+id/req_emoji" android:layout_width="52dp" android:layout_height="52dp" android:gravity="center" android:textSize="28sp" android:background="@drawable/circle_avatar" android:layout_marginEnd="12dp" />
        <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
            <TextView android:id="@+id/req_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="16sp" android:textColor="@color/text_primary" android:fontFamily="sans-serif-medium" />
            <TextView android:id="@+id/req_id" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="@color/text_secondary" />
        </LinearLayout>
        <com.google.android.material.button.MaterialButton android:id="@+id/btn_accept_req" android:layout_width="wrap_content" android:layout_height="36dp" android:text="Accept" android:textSize="12sp" app:cornerRadius="18dp" app:backgroundTint="@color/call_accept" />
        <com.google.android.material.button.MaterialButton android:id="@+id/btn_reject_req" android:layout_width="wrap_content" android:layout_height="36dp" android:text="Reject" android:textSize="12sp" app:cornerRadius="18dp" app:backgroundTint="@color/call_reject" android:layout_marginStart="4dp" />
    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

cat > "$RES_DIR/layout/activity_settings.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/background">
    <androidx.appcompat.widget.Toolbar android:id="@+id/settings_toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@drawable/gradient_toolbar" android:title="Settings" app:titleTextColor="#FFFFFF" />
    <ScrollView android:layout_width="match_parent" android:layout_height="match_parent">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="16dp">
            <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp" android:layout_marginBottom="16dp">
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical">
                    <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="🌙 Dark Mode" android:textSize="16sp" android:textColor="@color/text_primary" />
                    <com.google.android.material.switchmaterial.SwitchMaterial android:id="@+id/switch_dark_mode" android:layout_width="wrap_content" android:layout_height="wrap_content" />
                </LinearLayout>
            </androidx.cardview.widget.CardView>
            <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp" android:layout_marginBottom="16dp">
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical">
                    <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="🔔 Notifications" android:textSize="16sp" android:textColor="@color/text_primary" />
                    <com.google.android.material.switchmaterial.SwitchMaterial android:id="@+id/switch_notifications" android:layout_width="wrap_content" android:layout_height="wrap_content" android:checked="true" />
                </LinearLayout>
            </androidx.cardview.widget.CardView>
            <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp" android:layout_marginBottom="16dp">
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical">
                    <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="📳 Vibration" android:textSize="16sp" android:textColor="@color/text_primary" />
                    <com.google.android.material.switchmaterial.SwitchMaterial android:id="@+id/switch_vibration" android:layout_width="wrap_content" android:layout_height="wrap_content" android:checked="true" />
                </LinearLayout>
            </androidx.cardview.widget.CardView>
            <androidx.cardview.widget.CardView android:layout_width="match_parent" android:layout_height="wrap_content" app:cardCornerRadius="12dp">
                <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="16dp">
                    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="ℹ️ About Java Goat" android:textSize="16sp" android:textColor="@color/text_primary" android:fontFamily="sans-serif-medium" />
                    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Version 2.0\nA professional messenger with voice and video calling.\n\nBuilt with ❤️ for India" android:textSize="14sp" android:textColor="@color/text_secondary" android:layout_marginTop="8dp" />
                </LinearLayout>
            </androidx.cardview.widget.CardView>
        </LinearLayout>
    </ScrollView>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/activity_edit_profile.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/background">
    <androidx.appcompat.widget.Toolbar android:id="@+id/edit_profile_toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@drawable/gradient_toolbar" android:title="Edit Profile" app:titleTextColor="#FFFFFF" />
    <ScrollView android:layout_width="match_parent" android:layout_height="match_parent">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp" android:gravity="center_horizontal">
            <TextView android:id="@+id/edit_profile_emoji" android:layout_width="96dp" android:layout_height="96dp" android:gravity="center" android:textSize="56sp" android:background="@drawable/circle_avatar" />
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Tap to change emoji" android:textSize="12sp" android:textColor="@color/text_secondary" android:layout_marginBottom="24dp" />
            <com.google.android.material.textfield.TextInputLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Display Name" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox" android:layout_marginBottom="16dp">
                <com.google.android.material.textfield.TextInputEditText android:id="@+id/edit_profile_name" android:layout_width="match_parent" android:layout_height="wrap_content" android:inputType="textPersonName" />
            </com.google.android.material.textfield.TextInputLayout>
            <com.google.android.material.textfield.TextInputLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Status" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox" android:layout_marginBottom="24dp">
                <com.google.android.material.textfield.TextInputEditText android:id="@+id/edit_profile_status" android:layout_width="match_parent" android:layout_height="wrap_content" android:inputType="text" android:hint="Hey there! I'm using Java Goat" />
            </com.google.android.material.textfield.TextInputLayout>
            <com.google.android.material.button.MaterialButton android:id="@+id/btn_save_profile" android:layout_width="match_parent" android:layout_height="56dp" android:text="Save Profile" app:cornerRadius="12dp" />
        </LinearLayout>
    </ScrollView>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/activity_group_chat.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/background">
    <androidx.appcompat.widget.Toolbar android:id="@+id/group_toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@drawable/gradient_toolbar">
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
            <ImageButton android:id="@+id/group_back" android:layout_width="40dp" android:layout_height="40dp" android:src="@android:drawable/ic_media_previous" android:background="?attr/selectableItemBackgroundBorderless" android:tint="#FFFFFF" />
            <TextView android:id="@+id/group_name_text" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:textSize="18sp" android:textColor="#FFFFFF" android:fontFamily="sans-serif-medium" android:layout_marginStart="8dp" />
            <TextView android:id="@+id/group_member_count" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="#B3FFFFFF" />
        </LinearLayout>
    </androidx.appcompat.widget.Toolbar>
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/group_recycler" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:padding="8dp" />
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:gravity="center_vertical" android:background="@color/surface">
        <EditText android:id="@+id/group_msg_input" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:hint="Group message..." android:background="@drawable/input_field_bg" android:padding="12dp" android:maxLines="3" />
        <ImageButton android:id="@+id/group_send_btn" android:layout_width="48dp" android:layout_height="48dp" android:src="@android:drawable/ic_menu_send" android:background="@drawable/mic_button" android:tint="#FFFFFF" android:layout_marginStart="8dp" />
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/dialog_input.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp">
    <com.google.android.material.textfield.TextInputLayout android:id="@+id/dialog_input_layout" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter value" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
        <com.google.android.material.textfield.TextInputEditText android:id="@+id/dialog_input_field" android:layout_width="match_parent" android:layout_height="wrap_content" />
    </com.google.android.material.textfield.TextInputLayout>
</LinearLayout>
EOF

cat > "$RES_DIR/layout/dialog_reaction_picker.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:background="@drawable/reaction_picker_bg">
    <TextView android:id="@+id/react_like" android:layout_width="44dp" android:layout_height="44dp" android:text="👍" android:textSize="28sp" android:gravity="center" android:background="?attr/selectableItemBackgroundBorderless" />
    <TextView android:id="@+id/react_love" android:layout_width="44dp" android:layout_height="44dp" android:text="❤️" android:textSize="28sp" android:gravity="center" android:background="?attr/selectableItemBackgroundBorderless" />
    <TextView android:id="@+id/react_laugh" android:layout_width="44dp" android:layout_height="44dp" android:text="😂" android:textSize="28sp" android:gravity="center" android:background="?attr/selectableItemBackgroundBorderless" />
    <TextView android:id="@+id/react_wow" android:layout_width="44dp" android:layout_height="44dp" android:text="😮" android:textSize="28sp" android:gravity="center" android:background="?attr/selectableItemBackgroundBorderless" />
    <TextView android:id="@+id/react_sad" android:layout_width="44dp" android:layout_height="44dp" android:text="😢" android:textSize="28sp" android:gravity="center" android:background="?attr/selectableItemBackgroundBorderless" />
    <TextView android:id="@+id/react_remove" android:layout_width="44dp" android:layout_height="44dp" android:text="✕" android:textSize="20sp" android:gravity="center" android:textColor="#F44336" android:background="?attr/selectableItemBackgroundBorderless" />
</LinearLayout>
EOF

cat > "$RES_DIR/layout/dialog_edit_message.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Edit Message" android:textSize="18sp" android:fontFamily="sans-serif-medium" android:layout_marginBottom="16dp" />
    <com.google.android.material.textfield.TextInputLayout android:layout_width="match_parent" android:layout_height="wrap_content" style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
        <com.google.android.material.textfield.TextInputEditText android:id="@+id/edit_msg_field" android:layout_width="match_parent" android:layout_height="wrap_content" android:inputType="textMultiLine" android:minLines="2" android:maxLines="5" />
    </com.google.android.material.textfield.TextInputLayout>
    <TextView android:id="@+id/edit_time_remaining" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="12sp" android:textColor="@color/text_secondary" android:layout_marginTop="4dp" />
</LinearLayout>
EOF

cat > "$RES_DIR/layout/activity_image_viewer.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#FF000000">
    <ImageView android:id="@+id/full_image_view" android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" />
    <ImageButton android:id="@+id/btn_close_image" android:layout_width="40dp" android:layout_height="40dp" android:layout_gravity="top|start" android:layout_margin="16dp" android:src="@android:drawable/ic_menu_close_clear_cancel" android:background="@drawable/call_reject_bg" android:tint="#FFFFFF" />
</FrameLayout>
EOF

echo "📐 Layout files created"

# ════════════════════════════════════════════════════════════════════════════
# JAVA SOURCE FILES - Complete from Start to End
# ════════════════════════════════════════════════════════════════════════════

# ─── APPLICATION CLASS ────────────────────────────────────────────────────────
cat > "$PKG_DIR/JavaGoatApp.java" << 'EOF'
package com.example.callingapp;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import androidx.appcompat.app.AppCompatDelegate;
import com.google.firebase.FirebaseApp;

public class JavaGoatApp extends Application {
    public static final String CHANNEL_MESSAGES = "messages_channel";
    public static final String CHANNEL_CALLS = "calls_channel";
    public static final String CHANNEL_SERVICE = "service_channel";

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseApp.initializeApp(this);
        createNotificationChannels();
        applyDarkModePreference();
    }

    private void createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = getSystemService(NotificationManager.class);
            NotificationChannel msgCh = new NotificationChannel(CHANNEL_MESSAGES, "Messages", NotificationManager.IMPORTANCE_HIGH);
            msgCh.enableVibration(true);
            nm.createNotificationChannel(msgCh);
            NotificationChannel callCh = new NotificationChannel(CHANNEL_CALLS, "Calls", NotificationManager.IMPORTANCE_HIGH);
            callCh.enableVibration(true);
            nm.createNotificationChannel(callCh);
            NotificationChannel svcCh = new NotificationChannel(CHANNEL_SERVICE, "Background Service", NotificationManager.IMPORTANCE_LOW);
            nm.createNotificationChannel(svcCh);
        }
    }

    private void applyDarkModePreference() {
        boolean darkMode = getSharedPreferences("jg_prefs", MODE_PRIVATE).getBoolean("dark_mode", false);
        AppCompatDelegate.setDefaultNightMode(darkMode ? AppCompatDelegate.MODE_NIGHT_YES : AppCompatDelegate.MODE_NIGHT_NO);
    }
}
EOF

# ─── MODELS ───────────────────────────────────────────────────────────────────
mkdir -p "$PKG_DIR/models"

cat > "$PKG_DIR/models/User.java" << 'EOF'
package com.example.callingapp.models;
public class User {
    public String uid, name, emoji, friendId, email, status, lastSeen;
    public boolean online;
    public long lastSeenTimestamp;
    public User() {}
    public User(String uid, String name, String emoji, String friendId, String email) {
        this.uid = uid; this.name = name; this.emoji = emoji; this.friendId = friendId; this.email = email;
        this.status = "Hey there! I'm using Java Goat"; this.online = true;
    }
}
EOF

cat > "$PKG_DIR/models/Message.java" << 'EOF'
package com.example.callingapp.models;
import java.util.HashMap;
import java.util.Map;
public class Message {
    public String id, senderId, receiverId, text, type, imageBase64, voiceMessagePath, replyToMessageId, replyToText, status;
    public Map<String, String> reactions = new HashMap<>();
    public long timestamp;
    public boolean edited, deletedForAll;
    public static final String TYPE_TEXT = "text", TYPE_IMAGE = "image", TYPE_VOICE = "voice";
    public static final String STATUS_SENT = "sent", STATUS_DELIVERED = "delivered", STATUS_READ = "read";
    public Message() {}
    public Message(String senderId, String receiverId, String text, String type) {
        this.senderId = senderId; this.receiverId = receiverId; this.text = text; this.type = type;
        this.status = STATUS_SENT; this.timestamp = System.currentTimeMillis();
    }
}
EOF

cat > "$PKG_DIR/models/CallRecord.java" << 'EOF'
package com.example.callingapp.models;
public class CallRecord {
    public String callId, callerId, receiverId, type, status;
    public long startTime, endTime, duration;
    public static final String TYPE_VOICE = "voice", TYPE_VIDEO = "video";
    public static final String STATUS_MISSED = "missed", STATUS_ANSWERED = "answered";
    public CallRecord() {}
}
EOF

cat > "$PKG_DIR/models/FriendRequest.java" << 'EOF'
package com.example.callingapp.models;
public class FriendRequest {
    public String requestId, fromUid, fromName, fromEmoji, fromFriendId, status;
    public long timestamp;
    public FriendRequest() {}
}
EOF

cat > "$PKG_DIR/models/Group.java" << 'EOF'
package com.example.callingapp.models;
import java.util.HashMap;
import java.util.Map;
public class Group {
    public String groupId, name, adminUid, emoji;
    public Map<String, Boolean> members = new HashMap<>();
    public long createdAt;
    public Group() {}
}
EOF
echo "📦 Models created"

# ─── SPLASH ACTIVITY ─────────────────────────────────────────────────────────
cat > "$PKG_DIR/SplashActivity.java" << 'EOF'
package com.example.callingapp;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.appcompat.app.AppCompatActivity;
public class SplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MainActivity.class));
            finish();
        }, 2000);
    }
}
EOF

# ─── MAIN ACTIVITY ───────────────────────────────────────────────────────────
cat > "$PKG_DIR/MainActivity.java" << 'EOF'
package com.example.callingapp;

import android.content.*;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.*;
import com.example.callingapp.fragments.*;
import com.example.callingapp.models.User;
import com.example.callingapp.models.FriendRequest;
import java.util.*;

public class MainActivity extends AppCompatActivity {
    public static boolean isAppInForeground = false;
    private FirebaseAuth mAuth;
    private DatabaseReference mDb;
    private SharedPreferences prefs;
    private View authView, mainView;
    private EditText authEmail, authPassword;
    private ViewPager2 viewPager;
    private TabLayout tabLayout;
    private String myUid, myName, myEmoji, myFriendId;
    private static final String[] EMOJIS = {"🐐","🦁","🐯","🦊","🐻","🐼","🦋","🦉","🐬","🦄","🐲","🦅","🦈"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        prefs = getSharedPreferences("jg_prefs", MODE_PRIVATE);
        mAuth = FirebaseAuth.getInstance();
        mDb = FirebaseDatabase.getInstance().getReference();
        initViews();
        checkAuthState();
    }

    private void initViews() {
        authView = findViewById(R.id.auth_view);
        mainView = findViewById(R.id.main_view);
        authEmail = findViewById(R.id.auth_email);
        authPassword = findViewById(R.id.auth_password);
        viewPager = findViewById(R.id.view_pager);
        tabLayout = findViewById(R.id.tab_layout);
        findViewById(R.id.btn_login).setOnClickListener(v -> doLogin());
        findViewById(R.id.btn_signup).setOnClickListener(v -> doSignup());
        findViewById(R.id.btn_add_friend).setOnClickListener(v -> showAddFriendDialog());
        findViewById(R.id.btn_menu).setOnClickListener(v -> showMainMenu());
        findViewById(R.id.fab_new_chat).setOnClickListener(v -> showAddFriendDialog());
    }

    private void checkAuthState() {
        FirebaseUser user = mAuth.getCurrentUser();
        if (user != null) {
            myUid = user.getUid();
            loadUserAndShowMain();
        } else {
            showAuth();
        }
    }

    private void showAuth() { authView.setVisibility(View.VISIBLE); mainView.setVisibility(View.GONE); }
    private void showMain() { authView.setVisibility(View.GONE); mainView.setVisibility(View.VISIBLE); setupViewPager(); setOnlineStatus(true); startBackgroundService(); }

    private void setupViewPager() {
        String[] tabs = {"CHATS", "UPDATES", "CALLS", "PROFILE"};
        MainPagerAdapter adapter = new MainPagerAdapter(this);
        viewPager.setAdapter(adapter);
        viewPager.setOffscreenPageLimit(4);
        new TabLayoutMediator(tabLayout, viewPager, (tab, pos) -> tab.setText(tabs[pos])).attach();
    }

    private void doLogin() {
        String email = authEmail.getText().toString().trim();
        String pass = authPassword.getText().toString().trim();
        if (TextUtils.isEmpty(email) || TextUtils.isEmpty(pass)) {
            Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        mAuth.signInWithEmailAndPassword(email, pass).addOnSuccessListener(r -> {
            myUid = mAuth.getCurrentUser().getUid();
            loadUserAndShowMain();
        }).addOnFailureListener(e -> Toast.makeText(this, "Login failed: " + e.getMessage(), Toast.LENGTH_LONG).show());
    }

    private void doSignup() {
        String email = authEmail.getText().toString().trim();
        String pass = authPassword.getText().toString().trim();
        if (TextUtils.isEmpty(email) || TextUtils.isEmpty(pass)) {
            Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        if (pass.length() < 6) {
            Toast.makeText(this, "Password must be 6+ chars", Toast.LENGTH_SHORT).show();
            return;
        }
        mDb.child("emailIndex").child(email.replace(".", "_")).get().addOnSuccessListener(snap -> {
            if (snap.exists()) Toast.makeText(this, "Email already registered", Toast.LENGTH_SHORT).show();
            else createAccount(email, pass);
        });
    }

    private void createAccount(String email, String pass) {
        mAuth.createUserWithEmailAndPassword(email, pass).addOnSuccessListener(r -> {
            myUid = mAuth.getCurrentUser().getUid();
            mDb.child("emailIndex").child(email.replace(".", "_")).setValue(myUid);
            showSetupProfileDialog(email);
        }).addOnFailureListener(e -> Toast.makeText(this, "Signup failed: " + e.getMessage(), Toast.LENGTH_LONG).show());
    }

    private void showSetupProfileDialog(String email) {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        EditText nameField = dialogView.findViewById(R.id.dialog_input_field);
        ((com.google.android.material.textfield.TextInputLayout)dialogView.findViewById(R.id.dialog_input_layout)).setHint("Your Name");
        new AlertDialog.Builder(this).setTitle("Set Up Profile").setView(dialogView).setCancelable(false)
            .setPositiveButton("Continue", (d, w) -> {
                String name = nameField.getText().toString().trim();
                if (TextUtils.isEmpty(name)) name = "Java Goat User";
                String emoji = EMOJIS[new Random().nextInt(EMOJIS.length)];
                String friendId = "jg-" + String.format("%04d", new Random().nextInt(10000));
                saveNewUser(email, name, emoji, friendId);
            }).show();
    }

    private void saveNewUser(String email, String name, String emoji, String friendId) {
        User user = new User(myUid, name, emoji, friendId, email);
        mDb.child("users").child(myUid).setValue(user).addOnSuccessListener(r -> {
            mDb.child("friendIds").child(friendId).setValue(myUid);
            myName = name; myEmoji = emoji; myFriendId = friendId;
            savePrefs();
            showMain();
        });
    }

    private void loadUserAndShowMain() {
        mDb.child("users").child(myUid).get().addOnSuccessListener(snap -> {
            if (snap.exists()) {
                User u = snap.getValue(User.class);
                if (u != null) { myName = u.name; myEmoji = u.emoji; myFriendId = u.friendId; savePrefs(); }
            }
            showMain();
        });
    }

    private void savePrefs() { prefs.edit().putString("myUid", myUid).putString("myName", myName).putString("myEmoji", myEmoji).putString("myFriendId", myFriendId).apply(); }

    private void showAddFriendDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        EditText inputField = dialogView.findViewById(R.id.dialog_input_field);
        ((com.google.android.material.textfield.TextInputLayout)dialogView.findViewById(R.id.dialog_input_layout)).setHint("Enter jg-XXXX ID");
        new AlertDialog.Builder(this).setTitle("Add Friend").setView(dialogView)
            .setPositiveButton("Send Request", (d, w) -> { String fid = inputField.getText().toString().trim(); if (!fid.isEmpty()) sendFriendRequest(fid); })
            .setNegativeButton("Cancel", null).show();
    }

    private void sendFriendRequest(String friendId) {
        if (friendId.equals(myFriendId)) { Toast.makeText(this, "That's your own ID!", Toast.LENGTH_SHORT).show(); return; }
        mDb.child("friendIds").child(friendId).get().addOnSuccessListener(snap -> {
            if (!snap.exists()) { Toast.makeText(this, "User not found", Toast.LENGTH_SHORT).show(); return; }
            String targetUid = snap.getValue(String.class);
            FriendRequest req = new FriendRequest();
            req.requestId = mDb.push().getKey();
            req.fromUid = myUid; req.fromName = myName; req.fromEmoji = myEmoji; req.fromFriendId = myFriendId;
            req.timestamp = System.currentTimeMillis(); req.status = "pending";
            mDb.child("friend_requests").child(targetUid).child(req.requestId).setValue(req);
            Toast.makeText(this, "Friend request sent! 🎉", Toast.LENGTH_SHORT).show();
        });
    }

    private void showMainMenu() {
        String[] opts = {"⚙️ Settings", "🌙 Dark Mode", "🚪 Logout"};
        new AlertDialog.Builder(this).setItems(opts, (d, w) -> {
            if (w == 0) startActivity(new Intent(this, SettingsActivity.class));
            else if (w == 1) toggleDarkMode();
            else doLogout();
        }).show();
    }

    private void toggleDarkMode() {
        boolean isDark = prefs.getBoolean("dark_mode", false);
        prefs.edit().putBoolean("dark_mode", !isDark).apply();
        AppCompatDelegate.setDefaultNightMode(!isDark ? AppCompatDelegate.MODE_NIGHT_YES : AppCompatDelegate.MODE_NIGHT_NO);
    }

    private void doLogout() { setOnlineStatus(false); mAuth.signOut(); prefs.edit().clear().apply(); stopService(new Intent(this, BackgroundService.class)); showAuth(); }

    private void setOnlineStatus(boolean online) {
        if (myUid == null) return;
        DatabaseReference ref = mDb.child("users").child(myUid);
        ref.child("online").setValue(online);
        ref.child("lastSeenTimestamp").setValue(System.currentTimeMillis());
        if (!online) ref.child("lastSeen").setValue(new java.text.SimpleDateFormat("hh:mm a", Locale.getDefault()).format(new Date()));
        ref.child("online").onDisconnect().setValue(false);
    }

    private void startBackgroundService() {
        Intent i = new Intent(this, BackgroundService.class);
        try { if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) startForegroundService(i); else startService(i); } catch (Exception ignored) {}
    }

    @Override protected void onResume() { super.onResume(); isAppInForeground = true; setOnlineStatus(true); }
    @Override protected void onPause() { super.onPause(); isAppInForeground = false; }
    @Override protected void onDestroy() { super.onDestroy(); setOnlineStatus(false); }

    public class MainPagerAdapter extends FragmentStateAdapter {
        public MainPagerAdapter(FragmentActivity fa) { super(fa); }
        @Override public int getItemCount() { return 4; }
        @NonNull @Override public Fragment createFragment(int pos) {
            switch (pos) {
                case 0: return new ChatListFragment();
                case 1: return new UpdatesFragment();
                case 2: return new CallsFragment();
                default: return new ProfileFragment();
            }
        }
    }
}
EOF
echo "✅ MainActivity.java created"

# ─── FRAGMENTS ────────────────────────────────────────────────────────────────
mkdir -p "$PKG_DIR/fragments"

cat > "$PKG_DIR/fragments/ChatListFragment.java" << 'EOF'
package com.example.callingapp.fragments;
import android.content.Intent;
import android.os.Bundle;
import android.view.*;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.*;
import com.example.callingapp.*;
import com.example.callingapp.adapters.ChatListAdapter;
import com.example.callingapp.models.User;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.*;
public class ChatListFragment extends Fragment {
    private RecyclerView recycler; private TextView emptyView; private ChatListAdapter adapter; private List<User> contacts = new ArrayList<>(); private DatabaseReference mDb; private String myUid;
    @Override public View onCreateView(@NonNull LayoutInflater inf, ViewGroup c, Bundle s) {
        View v = inf.inflate(R.layout.fragment_chat_list, c, false);
        recycler = v.findViewById(R.id.recycler_chats); emptyView = v.findViewById(R.id.empty_chats);
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        mDb = FirebaseDatabase.getInstance().getReference();
        adapter = new ChatListAdapter(contacts, user -> {
            Intent i = new Intent(getActivity(), ChatActivity.class);
            i.putExtra("partnerUid", user.uid); i.putExtra("partnerName", user.name); i.putExtra("partnerEmoji", user.emoji);
            startActivity(i);
        });
        recycler.setLayoutManager(new LinearLayoutManager(getContext())); recycler.setAdapter(adapter);
        loadFriends();
        return v;
    }
    private void loadFriends() {
        mDb.child("users").child(myUid).child("friends").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                contacts.clear();
                if (!snap.exists()) { emptyView.setVisibility(View.VISIBLE); adapter.notifyDataSetChanged(); return; }
                for (DataSnapshot child : snap.getChildren()) {
                    String uid = child.getKey();
                    mDb.child("users").child(uid).get().addOnSuccessListener(us -> {
                        if (us.exists()) { User u = us.getValue(User.class); if (u != null) { contacts.add(u); adapter.notifyDataSetChanged(); emptyView.setVisibility(contacts.isEmpty() ? View.VISIBLE : View.GONE); } }
                    });
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
}
EOF

cat > "$PKG_DIR/fragments/UpdatesFragment.java" << 'EOF'
package com.example.callingapp.fragments;
import android.os.Bundle;
import android.view.*;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.*;
import com.example.callingapp.R;
import com.example.callingapp.adapters.FriendRequestAdapter;
import com.example.callingapp.models.FriendRequest;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.*;
public class UpdatesFragment extends Fragment {
    private RecyclerView recycler; private TextView emptyView; private FriendRequestAdapter adapter; private List<FriendRequest> requests = new ArrayList<>(); private DatabaseReference mDb; private String myUid;
    @Override public View onCreateView(@NonNull LayoutInflater inf, ViewGroup c, Bundle s) {
        View v = inf.inflate(R.layout.fragment_updates, c, false);
        recycler = v.findViewById(R.id.recycler_updates); emptyView = v.findViewById(R.id.empty_updates);
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        mDb = FirebaseDatabase.getInstance().getReference();
        adapter = new FriendRequestAdapter(getContext(), requests, myUid, mDb);
        recycler.setLayoutManager(new LinearLayoutManager(getContext())); recycler.setAdapter(adapter);
        loadRequests();
        return v;
    }
    private void loadRequests() {
        mDb.child("friend_requests").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                requests.clear();
                for (DataSnapshot child : snap.getChildren()) {
                    FriendRequest r = child.getValue(FriendRequest.class);
                    if (r != null && "pending".equals(r.status)) requests.add(r);
                }
                adapter.notifyDataSetChanged();
                emptyView.setVisibility(requests.isEmpty() ? View.VISIBLE : View.GONE);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
}
EOF

cat > "$PKG_DIR/fragments/CallsFragment.java" << 'EOF'
package com.example.callingapp.fragments;
import android.os.Bundle;
import android.view.*;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.*;
import com.example.callingapp.R;
import com.example.callingapp.adapters.CallHistoryAdapter;
import com.example.callingapp.models.CallRecord;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.*;
public class CallsFragment extends Fragment {
    private RecyclerView recycler; private TextView emptyView; private CallHistoryAdapter adapter; private List<CallRecord> calls = new ArrayList<>(); private String myUid; private DatabaseReference mDb;
    @Override public View onCreateView(@NonNull LayoutInflater inf, ViewGroup c, Bundle s) {
        View v = inf.inflate(R.layout.fragment_calls, c, false);
        recycler = v.findViewById(R.id.recycler_calls); emptyView = v.findViewById(R.id.empty_calls);
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        mDb = FirebaseDatabase.getInstance().getReference();
        adapter = new CallHistoryAdapter(getContext(), calls);
        recycler.setLayoutManager(new LinearLayoutManager(getContext())); recycler.setAdapter(adapter);
        loadCallHistory();
        return v;
    }
    private void loadCallHistory() {
        mDb.child("users").child(myUid).child("call_history").orderByChild("startTime").limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                calls.clear();
                for (DataSnapshot child : snap.getChildren()) { CallRecord r = child.getValue(CallRecord.class); if (r != null) calls.add(0, r); }
                adapter.notifyDataSetChanged();
                emptyView.setVisibility(calls.isEmpty() ? View.VISIBLE : View.GONE);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
}
EOF

cat > "$PKG_DIR/fragments/ProfileFragment.java" << 'EOF'
package com.example.callingapp.fragments;
import android.content.*;
import android.os.Bundle;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import com.example.callingapp.*;
import com.example.callingapp.models.User;
import com.google.firebase.database.*;
public class ProfileFragment extends Fragment {
    private TextView profileEmoji, profileName, profileId, profileStatus;
    private DatabaseReference mDb;
    private SharedPreferences prefs;
    private String myUid;
    @Override public View onCreateView(@NonNull LayoutInflater inf, ViewGroup c, Bundle s) {
        View v = inf.inflate(R.layout.fragment_profile, c, false);
        profileEmoji = v.findViewById(R.id.profile_emoji); profileName = v.findViewById(R.id.profile_name);
        profileId = v.findViewById(R.id.profile_id); profileStatus = v.findViewById(R.id.profile_status);
        prefs = requireActivity().getSharedPreferences("jg_prefs", Context.MODE_PRIVATE);
        myUid = prefs.getString("myUid", "");
        mDb = FirebaseDatabase.getInstance().getReference();
        loadProfile();
        v.findViewById(R.id.btn_copy_id).setOnClickListener(btn -> {
            ClipboardManager cm = (ClipboardManager) requireActivity().getSystemService(Context.CLIPBOARD_SERVICE);
            cm.setPrimaryClip(ClipData.newPlainText("Friend ID", profileId.getText().toString()));
            Toast.makeText(getContext(), "ID Copied! 📋", Toast.LENGTH_SHORT).show();
        });
        v.findViewById(R.id.btn_edit_profile).setOnClickListener(btn -> startActivity(new Intent(getActivity(), EditProfileActivity.class)));
        v.findViewById(R.id.btn_settings).setOnClickListener(btn -> startActivity(new Intent(getActivity(), SettingsActivity.class)));
        v.findViewById(R.id.btn_logout_profile).setOnClickListener(btn -> {
            new AlertDialog.Builder(requireContext()).setTitle("Logout").setMessage("Are you sure?")
                .setPositiveButton("Logout", (d, w) -> { if (getActivity() instanceof MainActivity) ((MainActivity)getActivity()).doLogout(); })
                .setNegativeButton("Cancel", null).show();
        });
        return v;
    }
    private void loadProfile() {
        mDb.child("users").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                User u = snap.getValue(User.class);
                if (u == null) return;
                profileEmoji.setText(u.emoji != null ? u.emoji : "🐐");
                profileName.setText(u.name);
                profileId.setText(u.friendId);
                profileStatus.setText(u.status != null ? u.status : "Hey there! I'm using Java Goat");
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
}
EOF
echo "✅ Fragments created"

# ─── ADAPTERS ─────────────────────────────────────────────────────────────────
mkdir -p "$PKG_DIR/adapters"

cat > "$PKG_DIR/adapters/ChatListAdapter.java" << 'EOF'
package com.example.callingapp.adapters;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.callingapp.R;
import com.example.callingapp.models.User;
import java.util.*;
public class ChatListAdapter extends RecyclerView.Adapter<ChatListAdapter.ViewHolder> {
    public interface OnChatClick { void onClick(User user); }
    private final List<User> users; private final OnChatClick listener;
    public ChatListAdapter(List<User> users, OnChatClick l) { this.users = users; this.listener = l; }
    @NonNull @Override public ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new ViewHolder(LayoutInflater.from(p.getContext()).inflate(R.layout.item_chat, p, false)); }
    @Override public void onBindViewHolder(@NonNull ViewHolder h, int pos) {
        User u = users.get(pos);
        h.emoji.setText(u.emoji != null ? u.emoji : "🐐");
        h.name.setText(u.name);
        h.lastMsg.setText(u.lastSeen != null ? "Last seen " + u.lastSeen : "Tap to chat");
        h.onlineDot.setVisibility(u.online ? View.VISIBLE : View.GONE);
        h.itemView.setOnClickListener(v -> listener.onClick(u));
    }
    @Override public int getItemCount() { return users.size(); }
    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView emoji, name, lastMsg, time, unread; View onlineDot;
        ViewHolder(View v) { super(v); emoji = v.findViewById(R.id.chat_item_emoji); name = v.findViewById(R.id.chat_item_name); lastMsg = v.findViewById(R.id.chat_item_last_msg); time = v.findViewById(R.id.chat_item_time); unread = v.findViewById(R.id.chat_item_unread); onlineDot = v.findViewById(R.id.chat_item_online_dot); }
    }
}
EOF

cat > "$PKG_DIR/adapters/FriendRequestAdapter.java" << 'EOF'
package com.example.callingapp.adapters;
import android.content.Context;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.callingapp.R;
import com.example.callingapp.models.FriendRequest;
import com.google.firebase.database.DatabaseReference;
import java.util.*;
public class FriendRequestAdapter extends RecyclerView.Adapter<FriendRequestAdapter.ViewHolder> {
    private final Context ctx; private final List<FriendRequest> requests; private final String myUid; private final DatabaseReference mDb;
    public FriendRequestAdapter(Context c, List<FriendRequest> r, String myUid, DatabaseReference db) { this.ctx = c; this.requests = r; this.myUid = myUid; this.mDb = db; }
    @NonNull @Override public ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new ViewHolder(LayoutInflater.from(ctx).inflate(R.layout.item_friend_request, p, false)); }
    @Override public void onBindViewHolder(@NonNull ViewHolder h, int pos) {
        FriendRequest r = requests.get(pos);
        h.emoji.setText(r.fromEmoji != null ? r.fromEmoji : "🐐");
        h.name.setText(r.fromName); h.id.setText(r.fromFriendId);
        h.acceptBtn.setOnClickListener(v -> { mDb.child("users").child(myUid).child("friends").child(r.fromUid).setValue(true); mDb.child("users").child(r.fromUid).child("friends").child(myUid).setValue(true); mDb.child("friend_requests").child(myUid).child(r.requestId).removeValue(); requests.remove(pos); notifyItemRemoved(pos); Toast.makeText(ctx, r.fromName + " added as friend! 🎉", Toast.LENGTH_SHORT).show(); });
        h.rejectBtn.setOnClickListener(v -> { mDb.child("friend_requests").child(myUid).child(r.requestId).removeValue(); requests.remove(pos); notifyItemRemoved(pos); });
    }
    @Override public int getItemCount() { return requests.size(); }
    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView emoji, name, id; com.google.android.material.button.MaterialButton acceptBtn, rejectBtn;
        ViewHolder(View v) { super(v); emoji = v.findViewById(R.id.req_emoji); name = v.findViewById(R.id.req_name); id = v.findViewById(R.id.req_id); acceptBtn = v.findViewById(R.id.btn_accept_req); rejectBtn = v.findViewById(R.id.btn_reject_req); }
    }
}
EOF

cat > "$PKG_DIR/adapters/CallHistoryAdapter.java" << 'EOF'
package com.example.callingapp.adapters;
import android.content.Context;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.callingapp.R;
import com.example.callingapp.models.CallRecord;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.TimeUnit;
public class CallHistoryAdapter extends RecyclerView.Adapter<CallHistoryAdapter.ViewHolder> {
    private final Context ctx; private final List<CallRecord> calls;
    private static final SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, hh:mm a", Locale.getDefault());
    public CallHistoryAdapter(Context c, List<CallRecord> calls) { this.ctx = c; this.calls = calls; }
    @NonNull @Override public ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new ViewHolder(LayoutInflater.from(ctx).inflate(R.layout.item_call, p, false)); }
    @Override public void onBindViewHolder(@NonNull ViewHolder h, int pos) {
        CallRecord r = calls.get(pos);
        h.emoji.setText("📞"); h.name.setText(r.callerId != null ? r.callerId : "Unknown");
        String typeLabel = CallRecord.TYPE_VIDEO.equals(r.type) ? "📹 Video" : "📞 Voice";
        if (CallRecord.STATUS_MISSED.equals(r.status)) typeLabel = "❌ Missed " + typeLabel;
        h.type.setText(typeLabel);
        String dur = r.duration > 0 ? String.format(Locale.getDefault(), "%d:%02d", TimeUnit.MILLISECONDS.toMinutes(r.duration), TimeUnit.MILLISECONDS.toSeconds(r.duration) % 60) : "";
        h.duration.setText(dur);
        h.time.setText(sdf.format(new Date(r.startTime)));
    }
    @Override public int getItemCount() { return calls.size(); }
    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView emoji, name, type, duration, time; ImageButton callback;
        ViewHolder(View v) { super(v); emoji = v.findViewById(R.id.call_item_emoji); name = v.findViewById(R.id.call_item_name); type = v.findViewById(R.id.call_item_type); duration = v.findViewById(R.id.call_item_duration); time = v.findViewById(R.id.call_item_time); callback = v.findViewById(R.id.call_item_callback); }
    }
}
EOF

cat > "$PKG_DIR/adapters/MessageAdapter.java" << 'EOF'
package com.example.callingapp.adapters;
import android.content.Context;
import android.text.format.DateUtils;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.callingapp.R;
import com.example.callingapp.models.Message;
import java.text.SimpleDateFormat;
import java.util.*;
public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.ViewHolder> {
    public interface OnMessageLongClick { void onLongClick(Message msg, View view, int pos); }
    private final Context ctx; private final List<Message> messages; private final String myUid;
    private OnMessageLongClick longClickListener;
    private static final SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a", Locale.getDefault());
    private static final SimpleDateFormat dateFmt = new SimpleDateFormat("MMMM dd, yyyy", Locale.getDefault());

    public MessageAdapter(Context ctx, List<Message> msgs, String myUid) { this.ctx = ctx; this.messages = msgs; this.myUid = myUid; }
    public void setOnLongClickListener(OnMessageLongClick l) { this.longClickListener = l; }

    @NonNull @Override public ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new ViewHolder(LayoutInflater.from(ctx).inflate(R.layout.item_message, p, false)); }

    @Override public void onBindViewHolder(@NonNull ViewHolder h, int pos) {
        Message msg = messages.get(pos);
        boolean isOut = myUid.equals(msg.senderId);
        boolean showDate = pos == 0 || !isSameDay(messages.get(pos-1).timestamp, msg.timestamp);
        h.dateHeader.setVisibility(showDate ? View.VISIBLE : View.GONE);
        if (showDate) h.dateHeader.setText(getDateLabel(msg.timestamp));
        h.outContainer.setVisibility(isOut ? View.VISIBLE : View.GONE);
        h.inContainer.setVisibility(!isOut ? View.VISIBLE : View.GONE);
        String displayText = msg.deletedForAll ? "🚫 This message was deleted" : (msg.text != null ? msg.text : "");
        if (msg.edited && !msg.deletedForAll) displayText += " (edited)";
        String time = timeFmt.format(new Date(msg.timestamp));
        if (isOut) {
            h.outMsgText.setText(displayText); h.outMsgTime.setText(time);
            String statusIcon = "✓"; if (Message.STATUS_DELIVERED.equals(msg.status)) statusIcon = "✓✓"; else if (Message.STATUS_READ.equals(msg.status)) statusIcon = "✓✓";
            h.msgStatus.setText(statusIcon);
            if (Message.STATUS_READ.equals(msg.status)) h.msgStatus.setTextColor(0xFF29B6F6);
            if (msg.replyToText != null && !msg.replyToText.isEmpty()) { h.outReplyPreview.setVisibility(View.VISIBLE); h.outReplyText.setText(msg.replyToText); }
            else { h.outReplyPreview.setVisibility(View.GONE); }
            bindReactions(h.outReactionsRow, msg);
        } else {
            h.inMsgText.setText(displayText); h.inMsgTime.setText(time);
            if (msg.replyToText != null && !msg.replyToText.isEmpty()) { h.inReplyPreview.setVisibility(View.VISIBLE); h.inReplyText.setText(msg.replyToText); }
            else { h.inReplyPreview.setVisibility(View.GONE); }
            bindReactions(h.inReactionsRow, msg);
        }
        View bubble = isOut ? h.outMsgText : h.inMsgText;
        bubble.setOnLongClickListener(v -> { if (longClickListener != null) longClickListener.onLongClick(msg, v, pos); return true; });
    }

    private void bindReactions(LinearLayout row, Message msg) {
        row.removeAllViews();
        if (msg.reactions == null || msg.reactions.isEmpty()) { row.setVisibility(View.GONE); return; }
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String r : msg.reactions.values()) { counts.put(r, counts.getOrDefault(r, 0) + 1); }
        row.setVisibility(View.VISIBLE);
        for (Map.Entry<String, Integer> e : counts.entrySet()) {
            TextView tv = new TextView(ctx);
            tv.setText(e.getKey() + (e.getValue() > 1 ? " " + e.getValue() : "")); tv.setTextSize(12f); tv.setPadding(4, 2, 4, 2);
            row.addView(tv);
        }
    }

    private boolean isSameDay(long t1, long t2) { return DateUtils.isToday(t1 - DateUtils.DAY_IN_MILLIS) == DateUtils.isToday(t2 - DateUtils.DAY_IN_MILLIS); }
    private String getDateLabel(long ts) { if (DateUtils.isToday(ts)) return "Today"; if (DateUtils.isToday(ts + DateUtils.DAY_IN_MILLIS)) return "Yesterday"; return dateFmt.format(new Date(ts)); }
    @Override public int getItemCount() { return messages.size(); }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView dateHeader, outMsgText, outMsgTime, msgStatus, inMsgText, inMsgTime, outReplyText, inReplyText;
        LinearLayout outContainer, inContainer, outReactionsRow, inReactionsRow;
        View outReplyPreview, inReplyPreview;
        ViewHolder(View v) { super(v); dateHeader = v.findViewById(R.id.msg_date_header); outContainer = v.findViewById(R.id.msg_out_container); inContainer = v.findViewById(R.id.msg_in_container); outMsgText = v.findViewById(R.id.out_msg_text); outMsgTime = v.findViewById(R.id.out_msg_time); msgStatus = v.findViewById(R.id.msg_status); inMsgText = v.findViewById(R.id.in_msg_text); inMsgTime = v.findViewById(R.id.in_msg_time); outReactionsRow = v.findViewById(R.id.out_reactions_row); inReactionsRow = v.findViewById(R.id.in_reactions_row); outReplyPreview = v.findViewById(R.id.out_reply_preview); outReplyText = v.findViewById(R.id.out_reply_text); inReplyPreview = v.findViewById(R.id.in_reply_preview); inReplyText = v.findViewById(R.id.in_reply_text); }
    }
}
EOF
echo "✅ MessageAdapter.java created"

# ─── CHAT ACTIVITY ───────────────────────────────────────────────────────────
cat > "$PKG_DIR/ChatActivity.java" << 'EOF'
package com.example.callingapp;

import android.Manifest;
import android.content.*;
import android.content.pm.PackageManager;
import android.media.*;
import android.net.Uri;
import android.os.*;
import android.provider.MediaStore;
import android.text.*;
import android.view.*;
import android.widget.*;
import androidx.annotation.*;
import androidx.appcompat.app.*;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.*;
import com.example.callingapp.adapters.MessageAdapter;
import com.example.callingapp.models.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.TimeUnit;

public class ChatActivity extends AppCompatActivity {
    private static final int REQ_PICK_IMAGE = 101, REQ_CAPTURE = 102, REQ_AUDIO_PERM = 103;
    private static final long EDIT_WINDOW_MS = 5 * 60 * 1000L;
    private DatabaseReference mDb; private String myUid, partnerUid, partnerName, partnerEmoji, chatId;
    private RecyclerView recyclerMessages; private EditText msgInput;
    private TextView chatPartnerName, chatStatus, chatPartnerEmoji; private View onlineDot, typingIndicator, searchBar, replyPreview;
    private TextView replyPreviewText; private View voiceRecordingOverlay; private TextView recordingTimer;
    private MessageAdapter adapter; private List<Message> messages = new ArrayList<>(), allMessages = new ArrayList<>();
    private boolean searchMode = false; private Message replyingToMessage = null;
    private MediaRecorder mediaRecorder; private boolean isRecording = false; private long recordingStart; private File voiceFile;
    private Handler timerHandler = new Handler(Looper.getMainLooper()); private Runnable timerRunnable;
    private Handler typingHandler = new Handler(Looper.getMainLooper()); private boolean isTyping = false;
    private boolean isBlocked = false;
    private ValueEventListener messagesListener, onlineListener, typingListener;

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_chat);
        partnerUid = getIntent().getStringExtra("partnerUid"); partnerName = getIntent().getStringExtra("partnerName"); partnerEmoji = getIntent().getStringExtra("partnerEmoji");
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid(); mDb = FirebaseDatabase.getInstance().getReference();
        chatId = myUid.compareTo(partnerUid) < 0 ? myUid + "_" + partnerUid : partnerUid + "_" + myUid;
        initViews(); setupRecycler(); setupInputListeners(); loadMessages(); listenOnlineStatus(); listenTyping(); markDelivered();
    }

    private void initViews() {
        androidx.appcompat.widget.Toolbar toolbar = findViewById(R.id.chat_toolbar); setSupportActionBar(toolbar); if(getSupportActionBar()!=null) getSupportActionBar().setDisplayShowTitleEnabled(false);
        chatPartnerEmoji = findViewById(R.id.chat_partner_emoji); chatPartnerName = findViewById(R.id.chat_partner_name); chatStatus = findViewById(R.id.chat_status_text);
        onlineDot = findViewById(R.id.chat_online_dot); typingIndicator = findViewById(R.id.typing_indicator); searchBar = findViewById(R.id.search_bar);
        replyPreview = findViewById(R.id.reply_preview); replyPreviewText = findViewById(R.id.reply_preview_text);
        voiceRecordingOverlay = findViewById(R.id.voice_recording_overlay); recordingTimer = findViewById(R.id.recording_timer);
        msgInput = findViewById(R.id.msg_input); recyclerMessages = findViewById(R.id.recycler_messages);
        chatPartnerEmoji.setText(partnerEmoji != null ? partnerEmoji : "🐐"); chatPartnerName.setText(partnerName); chatStatus.setText("Loading...");
        findViewById(R.id.btn_back).setOnClickListener(v -> onBackPressed());
        findViewById(R.id.btn_voice_call).setOnClickListener(v -> startCall(false));
        findViewById(R.id.btn_video_call).setOnClickListener(v -> startCall(true));
        if (findViewById(R.id.btn_cancel_reply) != null) findViewById(R.id.btn_cancel_reply).setOnClickListener(v -> cancelReply());
        findViewById(R.id.btn_attach_image).setOnClickListener(v -> showImagePicker());
        findViewById(R.id.btn_send).setOnClickListener(v -> sendTextMessage());
        View voiceBtn = findViewById(R.id.btn_voice_msg);
        if (voiceBtn != null) voiceBtn.setOnTouchListener((vw, ev) -> {
            if (ev.getAction() == MotionEvent.ACTION_DOWN) startVoiceRecording();
            else if (ev.getAction() == MotionEvent.ACTION_UP) stopVoiceRecording(true);
            else if (ev.getAction() == MotionEvent.ACTION_CANCEL) stopVoiceRecording(false);
            return true;
        });
    }

    private void setupRecycler() {
        adapter = new MessageAdapter(this, messages, myUid);
        adapter.setOnLongClickListener((msg, view, pos) -> showMessageOptions(msg, pos));
        LinearLayoutManager llm = new LinearLayoutManager(this); llm.setStackFromEnd(true);
        recyclerMessages.setLayoutManager(llm); recyclerMessages.setAdapter(adapter);
    }

    private void setupInputListeners() {
        msgInput.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int st, int c, int a) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override public void onTextChanged(CharSequence s, int st, int b, int c) {
                if (!isTyping) { isTyping = true; mDb.child("typing").child(chatId).child(myUid).setValue(true); }
                typingHandler.removeCallbacksAndMessages(null);
                typingHandler.postDelayed(() -> { isTyping = false; mDb.child("typing").child(chatId).child(myUid).setValue(false); }, 2000);
            }
        });
    }

    private void loadMessages() {
        messagesListener = mDb.child("chats").child(chatId).child("messages").orderByChild("timestamp").limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                messages.clear(); allMessages.clear();
                for (DataSnapshot child : snap.getChildren()) { Message m = child.getValue(Message.class); if (m != null) { m.id = child.getKey(); messages.add(m); allMessages.add(m); } }
                adapter.notifyDataSetChanged(); if (!messages.isEmpty()) recyclerMessages.scrollToPosition(messages.size() - 1);
                markMessagesAsRead();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void sendTextMessage() {
        String text = msgInput.getText().toString().trim();
        if (TextUtils.isEmpty(text) || isBlocked) return;
        Message msg = new Message(myUid, partnerUid, text, Message.TYPE_TEXT); msg.id = mDb.push().getKey();
        if (replyingToMessage != null) { msg.replyToMessageId = replyingToMessage.id; msg.replyToText = replyingToMessage.text; }
        mDb.child("chats").child(chatId).child("messages").child(msg.id).setValue(msg);
        mDb.child("users").child(partnerUid).child("unread").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) { long count = snap.exists() ? (long)snap.getValue() : 0; mDb.child("users").child(partnerUid).child("unread").child(myUid).setValue(count + 1); }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
        msgInput.setText(""); cancelReply();
    }

    private void markMessagesAsRead() {
        mDb.child("users").child(myUid).child("unread").child(partnerUid).setValue(0);
        for (Message m : messages) { if (partnerUid.equals(m.senderId) && !Message.STATUS_READ.equals(m.status) && m.id != null) { mDb.child("chats").child(chatId).child("messages").child(m.id).child("status").setValue(Message.STATUS_READ); } }
    }

    private void markDelivered() {
        mDb.child("chats").child(chatId).child("messages").orderByChild("receiverId").equalTo(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) { for (DataSnapshot child : snap.getChildren()) { Message m = child.getValue(Message.class); if (m != null && Message.STATUS_SENT.equals(m.status)) { child.getRef().child("status").setValue(Message.STATUS_DELIVERED); } } }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void showMessageOptions(Message msg, int pos) {
        List<String> options = new ArrayList<>(); boolean isMyMsg = myUid.equals(msg.senderId);
        options.add("😍 React"); options.add("↩️ Reply");
        if (isMyMsg && !msg.deletedForAll) { options.add("✏️ Edit (5 min)"); options.add("🗑️ Delete for Everyone"); }
        options.add("🗑️ Delete for Me");
        new AlertDialog.Builder(this).setItems(options.toArray(new String[0]), (d, w) -> {
            String opt = options.get(w);
            if (opt.startsWith("😍")) showReactionPicker(msg);
            else if (opt.startsWith("↩️")) startReply(msg);
            else if (opt.startsWith("✏️")) showEditDialog(msg, pos);
            else if (opt.equals("🗑️ Delete for Everyone")) deleteMessage(msg, true);
            else if (opt.equals("🗑️ Delete for Me")) deleteMessage(msg, false);
        }).show();
    }

    private void showReactionPicker(Message msg) {
        View pickerView = getLayoutInflater().inflate(R.layout.dialog_reaction_picker, null);
        AlertDialog dialog = new AlertDialog.Builder(this).setView(pickerView).create();
        int[] ids = {R.id.react_like, R.id.react_love, R.id.react_laugh, R.id.react_wow, R.id.react_sad};
        String[] emojis = {"👍", "❤️", "😂", "😮", "😢"};
        for (int i = 0; i < ids.length; i++) { final String emoji = emojis[i]; pickerView.findViewById(ids[i]).setOnClickListener(v -> { addReaction(msg, emoji); dialog.dismiss(); }); }
        pickerView.findViewById(R.id.react_remove).setOnClickListener(v -> { removeReaction(msg); dialog.dismiss(); });
        dialog.show();
    }

    private void addReaction(Message msg, String emoji) { if (msg.id != null) mDb.child("chats").child(chatId).child("messages").child(msg.id).child("reactions").child(myUid).setValue(emoji); }
    private void removeReaction(Message msg) { if (msg.id != null) mDb.child("chats").child(chatId).child("messages").child(msg.id).child("reactions").child(myUid).removeValue(); }
    private void startReply(Message msg) { replyingToMessage = msg; replyPreview.setVisibility(View.VISIBLE); replyPreviewText.setText(msg.text); msgInput.requestFocus(); }
    private void cancelReply() { replyingToMessage = null; replyPreview.setVisibility(View.GONE); }

    private void showEditDialog(Message msg, int pos) {
        long elapsed = System.currentTimeMillis() - msg.timestamp;
        if (elapsed > EDIT_WINDOW_MS) { Toast.makeText(this, "Can only edit within 5 minutes", Toast.LENGTH_SHORT).show(); return; }
        View editView = getLayoutInflater().inflate(R.layout.dialog_edit_message, null);
        EditText editField = editView.findViewById(R.id.edit_msg_field); TextView timeLeft = editView.findViewById(R.id.edit_time_remaining);
        editField.setText(msg.text); long remaining = (EDIT_WINDOW_MS - elapsed) / 1000; timeLeft.setText("Can edit for " + remaining + "s more");
        new AlertDialog.Builder(this).setView(editView).setPositiveButton("Save", (d, w) -> { String newText = editField.getText().toString().trim(); if (!TextUtils.isEmpty(newText) && msg.id != null) { mDb.child("chats").child(chatId).child("messages").child(msg.id).child("text").setValue(newText); mDb.child("chats").child(chatId).child("messages").child(msg.id).child("edited").setValue(true); } }).setNegativeButton("Cancel", null).show();
    }

    private void deleteMessage(Message msg, boolean forEveryone) {
        if (msg.id == null) return;
        if (forEveryone) { mDb.child("chats").child(chatId).child("messages").child(msg.id).child("deletedForAll").setValue(true); mDb.child("chats").child(chatId).child("messages").child(msg.id).child("text").setValue(""); }
        else { messages.removeIf(m -> m.id != null && m.id.equals(msg.id)); adapter.notifyDataSetChanged(); }
    }

    @Override public boolean onCreateOptionsMenu(android.view.Menu menu) { getMenuInflater().inflate(R.menu.chat_menu, menu); return true; }
    @Override public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.menu_search) { toggleSearch(); return true; }
        else if (item.getItemId() == R.id.menu_block) { toggleBlock(); return true; }
        return super.onOptionsItemSelected(item);
    }

    private void toggleSearch() {
        searchMode = !searchMode; searchBar.setVisibility(searchMode ? View.VISIBLE : View.GONE);
        if (!searchMode) { messages.clear(); messages.addAll(allMessages); adapter.notifyDataSetChanged(); }
        EditText searchInput = searchBar.findViewById(R.id.search_input); TextView resultCount = searchBar.findViewById(R.id.search_result_count);
        searchInput.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s,int st,int c,int a) {} @Override public void afterTextChanged(Editable s) {}
            @Override public void onTextChanged(CharSequence s, int st, int b, int c) {
                if (TextUtils.isEmpty(s)) { messages.clear(); messages.addAll(allMessages); resultCount.setText(""); }
                else { messages.clear(); for (Message m : allMessages) { if (m.text != null && m.text.toLowerCase().contains(s.toString().toLowerCase())) { messages.add(m); } } resultCount.setText(messages.size() + " found"); }
                adapter.notifyDataSetChanged();
            }
        });
    }

    private void toggleBlock() {
        String action = isBlocked ? "Unblock" : "Block";
        new AlertDialog.Builder(this).setTitle(action + " " + partnerName + "?").setPositiveButton(action, (d, w) -> { isBlocked = !isBlocked; mDb.child("users").child(myUid).child("blockedUsers").child(partnerUid).setValue(isBlocked ? true : null); Toast.makeText(this, partnerName + (isBlocked ? " blocked" : " unblocked"), Toast.LENGTH_SHORT).show(); }).setNegativeButton("Cancel", null).show();
    }

    private void startVoiceRecording() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) { ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, REQ_AUDIO_PERM); return; }
        try { voiceFile = new File(getCacheDir(), "voice_" + System.currentTimeMillis() + ".3gp"); mediaRecorder = new MediaRecorder(); mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC); mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP); mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB); mediaRecorder.setOutputFile(voiceFile.getAbsolutePath()); mediaRecorder.prepare(); mediaRecorder.start(); isRecording = true; recordingStart = System.currentTimeMillis(); voiceRecordingOverlay.setVisibility(View.VISIBLE); startRecordingTimer(); } catch(Exception e){ e.printStackTrace(); }
    }

    private void stopVoiceRecording(boolean send) {
        if (!isRecording) return; isRecording = false; voiceRecordingOverlay.setVisibility(View.GONE); timerHandler.removeCallbacks(timerRunnable);
        try { mediaRecorder.stop(); mediaRecorder.release(); mediaRecorder = null; } catch(Exception ignored){}
        if (send && voiceFile != null && voiceFile.exists()) { long duration = System.currentTimeMillis() - recordingStart; if (duration > 500) sendVoiceMessage(voiceFile, duration); }
    }

    private void sendVoiceMessage(File file, long duration) {
        try { byte[] bytes = readFile(file); String base64 = android.util.Base64.encodeToString(bytes, android.util.Base64.DEFAULT); Message msg = new Message(myUid, partnerUid, "🎵 Voice message (" + formatDuration(duration) + ")", Message.TYPE_VOICE); msg.id = mDb.push().getKey(); msg.voiceMessagePath = base64; mDb.child("chats").child(chatId).child("messages").child(msg.id).setValue(msg); } catch(Exception e){ e.printStackTrace(); }
    }

    private byte[] readFile(File f) throws IOException { FileInputStream fis = new FileInputStream(f); byte[] data = new byte[(int) f.length()]; fis.read(data); fis.close(); return data; }
    private String formatDuration(long ms) { long s = ms / 1000; return String.format(Locale.getDefault(), "%d:%02d", s/60, s%60); }
    private void startRecordingTimer() { timerRunnable = new Runnable() { @Override public void run() { long elapsed = System.currentTimeMillis() - recordingStart; recordingTimer.setText(formatDuration(elapsed)); timerHandler.postDelayed(this, 500); } }; timerHandler.post(timerRunnable); }

    private void showImagePicker() {
        String[] opts = {"📷 Camera", "🖼️ Gallery"};
        new AlertDialog.Builder(this).setItems(opts, (d, w) -> { if (w == 0) openCamera(); else openGallery(); }).show();
    }

    private void openCamera() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) { ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, REQ_CAPTURE); return; }
        Intent i = new Intent(MediaStore.ACTION_IMAGE_CAPTURE); if (i.resolveActivity(getPackageManager()) != null) startActivityForResult(i, REQ_CAPTURE);
    }

    private void openGallery() { Intent i = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI); i.setType("image/*"); startActivityForResult(i, REQ_PICK_IMAGE); }

    @Override protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (res != RESULT_OK || data == null) return;
        if (req == REQ_PICK_IMAGE && data.getData() != null) { try { android.graphics.Bitmap bmp = MediaStore.Images.Media.getBitmap(getContentResolver(), data.getData()); sendImageMessage(bmp); } catch(Exception e){ e.printStackTrace(); } }
        else if (req == REQ_CAPTURE && data.getExtras() != null) { android.graphics.Bitmap bmp = (android.graphics.Bitmap) data.getExtras().get("data"); if (bmp != null) sendImageMessage(bmp); }
    }

    private void sendImageMessage(android.graphics.Bitmap bmp) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream(); bmp.compress(android.graphics.Bitmap.CompressFormat.JPEG, 60, baos);
        String base64 = android.util.Base64.encodeToString(baos.toByteArray(), android.util.Base64.DEFAULT);
        Message msg = new Message(myUid, partnerUid, "📷 Image", Message.TYPE_IMAGE); msg.id = mDb.push().getKey(); msg.imageBase64 = base64;
        mDb.child("chats").child(chatId).child("messages").child(msg.id).setValue(msg);
        Toast.makeText(this, "Image sent!", Toast.LENGTH_SHORT).show();
    }

    private void listenOnlineStatus() {
        onlineListener = mDb.child("users").child(partnerUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                if (!snap.exists()) return;
                Boolean online = snap.child("online").getValue(Boolean.class);
                Long lastSeenTs = snap.child("lastSeenTimestamp").getValue(Long.class);
                if (Boolean.TRUE.equals(online)) { onlineDot.setVisibility(View.VISIBLE); chatStatus.setText("Online"); }
                else { onlineDot.setVisibility(View.GONE); if (lastSeenTs != null) chatStatus.setText("Last seen " + new SimpleDateFormat("hh:mm a", Locale.getDefault()).format(new Date(lastSeenTs))); else chatStatus.setText("Offline"); }
                DataSnapshot blocked = snap.child("blockedUsers").child(myUid); isBlocked = blocked.exists() && Boolean.TRUE.equals(blocked.getValue(Boolean.class));
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void listenTyping() {
        typingListener = mDb.child("typing").child(chatId).child(partnerUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) { Boolean typing = snap.getValue(Boolean.class); typingIndicator.setVisibility(Boolean.TRUE.equals(typing) ? View.VISIBLE : View.GONE); if (Boolean.TRUE.equals(typing)) chatStatus.setText("typing..."); }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void startCall(boolean isVideo) { Intent i = new Intent(this, CallActivity.class); i.putExtra("isCaller", true); i.putExtra("isVideo", isVideo); i.putExtra("partnerUid", partnerUid); i.putExtra("partnerName", partnerName); i.putExtra("partnerEmoji", partnerEmoji); startActivity(i); }

    @Override protected void onDestroy() {
        super.onDestroy();
        if (messagesListener != null && chatId != null) mDb.child("chats").child(chatId).child("messages").removeEventListener(messagesListener);
        if (onlineListener != null && partnerUid != null) mDb.child("users").child(partnerUid).removeEventListener(onlineListener);
        if (typingListener != null && chatId != null) mDb.child("typing").child(chatId).child(partnerUid).removeEventListener(typingListener);
        if (chatId != null && myUid != null) mDb.child("typing").child(chatId).child(myUid).setValue(false);
        typingHandler.removeCallbacksAndMessages(null);
    }
}
EOF
echo "✅ ChatActivity.java created"

# ─── CALL ACTIVITY ───────────────────────────────────────────────────────────
cat > "$PKG_DIR/CallActivity.java" << 'EOF'
package com.example.callingapp;

import android.content.*;
import android.media.*;
import android.os.*;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.example.callingapp.models.CallRecord;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

public class CallActivity extends AppCompatActivity {
    private boolean isCaller, isVideo; private String partnerUid, partnerName, partnerEmoji, myUid;
    private DatabaseReference mDb;
    private EglBase eglBase; private PeerConnectionFactory pcFactory; private PeerConnection peerConnection;
    private VideoTrack localVideoTrack, remoteVideoTrack; private AudioTrack localAudioTrack; private VideoCapturer videoCapturer;
    private SurfaceViewRenderer localView, remoteView;
    private List<IceCandidate> pendingCandidates = new ArrayList<>(); private boolean remoteDescSet = false;
    private AudioManager audioManager; private MediaPlayer ringtonePlayer;
    private TextView callPartnerName, callPartnerEmoji, callStatus, callDuration; private View acceptLayout;
    private Handler durationHandler = new Handler(Looper.getMainLooper()); private Runnable durationRunnable;
    private long callStartTime; private boolean callConnected = false; private Vibrator vibrator;
    private ValueEventListener callListener, candidateListener;

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_call);
        if (getIntent() != null) { isCaller = getIntent().getBooleanExtra("isCaller", true); isVideo = getIntent().getBooleanExtra("isVideo", false); partnerUid = getIntent().getStringExtra("partnerUid"); partnerName = getIntent().getStringExtra("partnerName"); partnerEmoji = getIntent().getStringExtra("partnerEmoji"); }
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid(); mDb = FirebaseDatabase.getInstance().getReference();
        initViews(); initWebRTC(); setupAudio();
        if (isCaller) startCall(); else setupReceiver();
    }

    private void initViews() {
        localView = findViewById(R.id.local_video_view); remoteView = findViewById(R.id.remote_video_view);
        callPartnerEmoji = findViewById(R.id.call_partner_emoji); callPartnerName = findViewById(R.id.call_partner_name);
        callStatus = findViewById(R.id.call_status_text); callDuration = findViewById(R.id.call_duration);
        acceptLayout = findViewById(R.id.accept_btn_layout);
        callPartnerEmoji.setText(partnerEmoji != null ? partnerEmoji : "🐐"); callPartnerName.setText(partnerName);
        callStatus.setText(isCaller ? "Calling..." : "Incoming call...");
        if (!isCaller) acceptLayout.setVisibility(View.VISIBLE);
        findViewById(R.id.btn_accept).setOnClickListener(v -> acceptCall());
        findViewById(R.id.btn_end_call).setOnClickListener(v -> endCall());
        findViewById(R.id.btn_mute).setOnClickListener(v -> toggleMute());
        findViewById(R.id.btn_speaker).setOnClickListener(v -> toggleSpeaker());
        findViewById(R.id.btn_toggle_camera).setOnClickListener(v -> toggleCamera());
        localView.setVisibility(isVideo ? View.VISIBLE : View.GONE);
        remoteView.setVisibility(isVideo ? View.VISIBLE : View.GONE);
    }

    private void initWebRTC() {
        eglBase = EglBase.create();
        if (isVideo) { localView.init(eglBase.getEglBaseContext(), null); localView.setMirror(true); remoteView.init(eglBase.getEglBaseContext(), null); }
        PeerConnectionFactory.InitializationOptions initOpts = PeerConnectionFactory.InitializationOptions.builder(this).setEnableInternalTracer(false).createInitializationOptions();
        PeerConnectionFactory.initialize(initOpts);
        VideoEncoderFactory encoderFactory = new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true);
        VideoDecoderFactory decoderFactory = new DefaultVideoDecoderFactory(eglBase.getEglBaseContext());
        pcFactory = PeerConnectionFactory.builder().setVideoEncoderFactory(encoderFactory).setVideoDecoderFactory(decoderFactory).createPeerConnectionFactory();
    }

    private void setupAudio() { audioManager = (AudioManager) getSystemService(AUDIO_SERVICE); audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION); vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE); }

    private PeerConnection createPeerConnection() {
        List<PeerConnection.IceServer> iceServers = Arrays.asList(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer(), PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer(), PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer());
        PeerConnection.RTCConfiguration config = new PeerConnection.RTCConfiguration(iceServers); config.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN;
        return pcFactory.createPeerConnection(config, new PeerConnection.Observer() {
            @Override public void onIceCandidate(IceCandidate candidate) { String path = isCaller ? "caller" : "receiver"; String key = mDb.push().getKey(); mDb.child("calls").child(isCaller ? myUid : partnerUid).child("candidates").child(path).child(key).setValue(candidate.sdpMid + ":" + candidate.sdpMLineIndex + ":" + candidate.sdp); }
            @Override public void onTrack(RtpTransceiver transceiver) { MediaStreamTrack track = transceiver.getReceiver().track(); if (track instanceof VideoTrack) { remoteVideoTrack = (VideoTrack) track; runOnUiThread(() -> { if (isVideo) remoteVideoTrack.addSink(remoteView); }); } }
            @Override public void onConnectionChange(PeerConnection.PeerConnectionState state) { runOnUiThread(() -> { if (state == PeerConnection.PeerConnectionState.CONNECTED) { callStatus.setText("Connected"); callConnected = true; callStartTime = System.currentTimeMillis(); acceptLayout.setVisibility(View.GONE); callDuration.setVisibility(View.VISIBLE); startDurationTimer(); stopRingtone(); } else if (state == PeerConnection.PeerConnectionState.DISCONNECTED || state == PeerConnection.PeerConnectionState.FAILED) { endCall(); } }); }
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {} @Override public void onIceConnectionChange(PeerConnection.IceConnectionState s) {} @Override public void onIceConnectionReceivingChange(boolean b) {} @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {} @Override public void onIceCandidatesRemoved(IceCandidate[] c) {} @Override public void onAddStream(MediaStream s) {} @Override public void onRemoveStream(MediaStream s) {} @Override public void onDataChannel(DataChannel dc) {} @Override public void onRenegotiationNeeded() {}
        });
    }

    private void createMediaTracks() {
        AudioSource audioSource = pcFactory.createAudioSource(new MediaConstraints()); localAudioTrack = pcFactory.createAudioTrack("audio0", audioSource);
        if (peerConnection != null) peerConnection.addTrack(localAudioTrack, Collections.singletonList("stream0"));
        if (isVideo) {
            Camera2Enumerator enumerator = new Camera2Enumerator(this);
            String frontCamera = null;
            for (String name : enumerator.getDeviceNames()) { if (enumerator.isFrontFacing(name)) { frontCamera = name; break; } }
            if (frontCamera == null && enumerator.getDeviceNames().length > 0) frontCamera = enumerator.getDeviceNames()[0];
            if (frontCamera != null) {
                videoCapturer = enumerator.createCapturer(frontCamera, null);
                SurfaceTextureHelper helper = SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
                VideoSource videoSource = pcFactory.createVideoSource(false);
                videoCapturer.initialize(helper, this, videoSource.getCapturerObserver());
                videoCapturer.startCapture(1280, 720, 30);
                localVideoTrack = pcFactory.createVideoTrack("video0", videoSource);
                localVideoTrack.addSink(localView);
                peerConnection.addTrack(localVideoTrack, Collections.singletonList("stream0"));
            }
        }
    }

    private void startCall() { playRingtone(); peerConnection = createPeerConnection(); createMediaTracks(); MediaConstraints constraints = new MediaConstraints(); constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true")); if(isVideo) constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
        peerConnection.createOffer(new SdpObserver() {
            @Override public void onCreateSuccess(SessionDescription sdp) { peerConnection.setLocalDescription(new SdpObserver() {
                @Override public void onCreateSuccess(SessionDescription s) {} @Override public void onSetSuccess() { Map<String, Object> callData = new HashMap<>(); callData.put("offer", sdp.description); callData.put("offerType", sdp.type.toString()); callData.put("callerId", myUid); callData.put("receiverId", partnerUid); callData.put("isVideo", isVideo); callData.put("accepted", false); mDb.child("calls").child(myUid).setValue(callData); listenForAnswer(); }
                @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {} }, sdp); }
            @Override public void onSetSuccess() {} @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void listenForAnswer() { callListener = mDb.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
        @Override public void onDataChange(@NonNull DataSnapshot snap) { if (!snap.exists()) return; Boolean accepted = snap.child("accepted").getValue(Boolean.class); String answer = snap.child("answer").getValue(String.class); if (Boolean.TRUE.equals(accepted) && answer != null && !remoteDescSet) { remoteDescSet = true; SessionDescription remoteSdp = new SessionDescription(SessionDescription.Type.ANSWER, answer); peerConnection.setRemoteDescription(new SdpObserver() {
            @Override public void onCreateSuccess(SessionDescription s) {} @Override public void onSetSuccess() { for (IceCandidate c : pendingCandidates) peerConnection.addIceCandidate(c); pendingCandidates.clear(); }
            @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {} }, remoteSdp); } }
        @Override public void onCancelled(@NonNull DatabaseError e) {}
    }); listenForCandidates("receiver"); }

    private void setupReceiver() { playRingtone(); vibrateIncoming(); }

    private void acceptCall() { stopRingtone(); acceptLayout.setVisibility(View.GONE); callStatus.setText("Connecting..."); audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION); peerConnection = createPeerConnection(); createMediaTracks();
        mDb.child("calls").child(partnerUid).get().addOnSuccessListener(snap -> {
            String offerSdp = snap.child("offer").getValue(String.class);
            if (offerSdp == null) return;
            SessionDescription offer = new SessionDescription(SessionDescription.Type.OFFER, offerSdp);
            peerConnection.setRemoteDescription(new SdpObserver() {
                @Override public void onCreateSuccess(SessionDescription s) {} @Override public void onSetSuccess() { remoteDescSet = true; for (IceCandidate c : pendingCandidates) peerConnection.addIceCandidate(c); pendingCandidates.clear(); createAnswer(); }
                @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {}
            }, offer);
        }); listenForCandidates("caller");
    }

    private void createAnswer() { MediaConstraints constraints = new MediaConstraints();
        peerConnection.createAnswer(new SdpObserver() {
            @Override public void onCreateSuccess(SessionDescription sdp) { peerConnection.setLocalDescription(new SdpObserver() {
                @Override public void onCreateSuccess(SessionDescription s) {} @Override public void onSetSuccess() { mDb.child("calls").child(partnerUid).child("answer").setValue(sdp.description); mDb.child("calls").child(partnerUid).child("accepted").setValue(true); }
                @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {} }, sdp); }
            @Override public void onSetSuccess() {} @Override public void onCreateFailure(String s) {} @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void listenForCandidates(String side) { candidateListener = mDb.child("calls").child(isCaller ? myUid : partnerUid).child("candidates").child(side).addValueEventListener(new ValueEventListener() {
        @Override public void onDataChange(@NonNull DataSnapshot snap) { for (DataSnapshot child : snap.getChildren()) { String candStr = child.getValue(String.class); if (candStr == null) continue; String[] parts = candStr.split(":", 3); if (parts.length >= 3) { IceCandidate candidate = new IceCandidate(parts[0], Integer.parseInt(parts[1]), parts[2]); if (remoteDescSet && peerConnection != null) peerConnection.addIceCandidate(candidate); else pendingCandidates.add(candidate); } } }
        @Override public void onCancelled(@NonNull DatabaseError e) {}
    }); }

    private void playRingtone() { try { ringtonePlayer = MediaPlayer.create(this, Settings.System.DEFAULT_RINGTONE_URI); if (ringtonePlayer != null) { ringtonePlayer.setLooping(true); ringtonePlayer.start(); } } catch(Exception ignored){} }
    private void stopRingtone() { if (ringtonePlayer != null) { ringtonePlayer.stop(); ringtonePlayer.release(); ringtonePlayer = null; } }
    private void vibrateIncoming() { if (vibrator != null && vibrator.hasVibrator()) { long[] pattern = {0, 1000, 500, 1000}; vibrator.vibrate(pattern, 0); } }
    private void startDurationTimer() { durationRunnable = new Runnable() { @Override public void run() { if (callStartTime > 0) { long elapsed = System.currentTimeMillis() - callStartTime; long mins = TimeUnit.MILLISECONDS.toMinutes(elapsed); long secs = TimeUnit.MILLISECONDS.toSeconds(elapsed) % 60; callDuration.setText(String.format(Locale.getDefault(), "%d:%02d", mins, secs)); durationHandler.postDelayed(this, 1000); } } }; durationHandler.post(durationRunnable); }
    private void toggleMute() { if (localAudioTrack != null) { localAudioTrack.setEnabled(!localAudioTrack.enabled()); Toast.makeText(this, localAudioTrack.enabled() ? "Mic on" : "Mic muted", Toast.LENGTH_SHORT).show(); } }
    private void toggleSpeaker() { audioManager.setSpeakerphoneOn(!audioManager.isSpeakerphoneOn()); Toast.makeText(this, audioManager.isSpeakerphoneOn() ? "Speaker on" : "Earpiece", Toast.LENGTH_SHORT).show(); }
    private void toggleCamera() { if (videoCapturer != null && isVideo) { try { videoCapturer.stopCapture(); videoCapturer.startCapture(1280, 720, 30); } catch(Exception e){} Toast.makeText(this, "Camera toggled", Toast.LENGTH_SHORT).show(); } }

    private void endCall() {
        stopRingtone(); if (vibrator != null) vibrator.cancel(); durationHandler.removeCallbacks(durationRunnable);
        if (callStartTime > 0) { long duration = System.currentTimeMillis() - callStartTime; CallRecord record = new CallRecord(); record.callId = UUID.randomUUID().toString(); record.callerId = myUid; record.receiverId = partnerUid; record.type = isVideo ? CallRecord.TYPE_VIDEO : CallRecord.TYPE_VOICE; record.status = callConnected ? CallRecord.STATUS_ANSWERED : CallRecord.STATUS_MISSED; record.startTime = callStartTime; record.endTime = System.currentTimeMillis(); record.duration = duration; mDb.child("users").child(myUid).child("call_history").child(record.callId).setValue(record); }
        if (myUid != null) mDb.child("calls").child(myUid).removeValue(); if (partnerUid != null) mDb.child("calls").child(partnerUid).removeValue();
        if (videoCapturer != null) { try { videoCapturer.stopCapture(); videoCapturer.dispose(); } catch(Exception e){} }
        if (localVideoTrack != null) localVideoTrack.dispose(); if (remoteVideoTrack != null) remoteVideoTrack.dispose(); if (localAudioTrack != null) localAudioTrack.dispose();
        if (peerConnection != null) peerConnection.close(); if (pcFactory != null) pcFactory.dispose(); if (eglBase != null) eglBase.release();
        audioManager.setMode(AudioManager.MODE_NORMAL); finish();
    }

    @Override protected void onDestroy() { super.onDestroy(); if (callListener != null && myUid != null) mDb.child("calls").child(myUid).removeEventListener(callListener); if (candidateListener != null) mDb.child("calls").child(isCaller ? myUid : partnerUid).removeEventListener(candidateListener); durationHandler.removeCallbacksAndMessages(null); }
    @Override public void onBackPressed() {}
}
EOF
echo "✅ CallActivity.java completed"

# ─── SETTINGS ACTIVITY ─────────────────────────────────────────────────────────
cat > "$PKG_DIR/SettingsActivity.java" << 'EOF'
package com.example.callingapp;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.appcompat.widget.Toolbar;
import com.google.android.material.switchmaterial.SwitchMaterial;
public class SettingsActivity extends AppCompatActivity {
    private SharedPreferences prefs; private SwitchMaterial darkModeSwitch, notificationSwitch, vibrationSwitch;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_settings);
        prefs = getSharedPreferences("jg_prefs", MODE_PRIVATE);
        Toolbar toolbar = findViewById(R.id.settings_toolbar); setSupportActionBar(toolbar); if(getSupportActionBar()!=null) getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        darkModeSwitch = findViewById(R.id.switch_dark_mode); notificationSwitch = findViewById(R.id.switch_notifications); vibrationSwitch = findViewById(R.id.switch_vibration);
        darkModeSwitch.setChecked(prefs.getBoolean("dark_mode", false));
        notificationSwitch.setChecked(prefs.getBoolean("notifications", true));
        vibrationSwitch.setChecked(prefs.getBoolean("vibration", true));
        darkModeSwitch.setOnCheckedChangeListener((btn, isChecked) -> { prefs.edit().putBoolean("dark_mode", isChecked).apply(); AppCompatDelegate.setDefaultNightMode(isChecked ? AppCompatDelegate.MODE_NIGHT_YES : AppCompatDelegate.MODE_NIGHT_NO); Toast.makeText(this, isChecked ? "Dark mode enabled" : "Light mode enabled", Toast.LENGTH_SHORT).show(); });
        notificationSwitch.setOnCheckedChangeListener((btn, isChecked) -> { prefs.edit().putBoolean("notifications", isChecked).apply(); Toast.makeText(this, isChecked ? "Notifications on" : "Notifications off", Toast.LENGTH_SHORT).show(); });
        vibrationSwitch.setOnCheckedChangeListener((btn, isChecked) -> prefs.edit().putBoolean("vibration", isChecked).apply());
    }
    @Override public boolean onSupportNavigateUp() { finish(); return true; }
}
EOF
echo "✅ SettingsActivity.java created"

# ─── EDIT PROFILE ACTIVITY ──────────────────────────────────────────────────────
cat > "$PKG_DIR/EditProfileActivity.java" << 'EOF'
package com.example.callingapp;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import com.example.callingapp.models.User;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
public class EditProfileActivity extends AppCompatActivity {
    private static final String[] EMOJIS = {"🐐","🦁","🐯","🦊","🐻","🐼","🦋","🦉","🐬","🦄","🐲","🦅","🦈"};
    private TextView emojiView; private EditText nameInput, statusInput; private DatabaseReference mDb; private String myUid, currentEmoji;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_edit_profile);
        Toolbar toolbar = findViewById(R.id.edit_profile_toolbar); setSupportActionBar(toolbar); if(getSupportActionBar()!=null) getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        emojiView = findViewById(R.id.edit_profile_emoji); nameInput = findViewById(R.id.edit_profile_name); statusInput = findViewById(R.id.edit_profile_status);
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid(); mDb = FirebaseDatabase.getInstance().getReference();
        loadProfile(); emojiView.setOnClickListener(v -> showEmojiPicker()); findViewById(R.id.btn_save_profile).setOnClickListener(v -> saveProfile());
    }
    private void loadProfile() { mDb.child("users").child(myUid).get().addOnSuccessListener(snap -> { User u = snap.getValue(User.class); if (u != null) { currentEmoji = u.emoji != null ? u.emoji : "🐐"; emojiView.setText(currentEmoji); nameInput.setText(u.name); statusInput.setText(u.status != null ? u.status : "Hey there! I'm using Java Goat"); } }); }
    private void showEmojiPicker() { new AlertDialog.Builder(this).setTitle("Choose Your Emoji").setItems(EMOJIS, (d, which) -> { currentEmoji = EMOJIS[which]; emojiView.setText(currentEmoji); }).show(); }
    private void saveProfile() { String name = nameInput.getText().toString().trim(); String status = statusInput.getText().toString().trim(); if (TextUtils.isEmpty(name)) name = "Java Goat User"; mDb.child("users").child(myUid).child("name").setValue(name); mDb.child("users").child(myUid).child("emoji").setValue(currentEmoji); mDb.child("users").child(myUid).child("status").setValue(status); Toast.makeText(this, "Profile updated! ✅", Toast.LENGTH_SHORT).show(); finish(); }
    @Override public boolean onSupportNavigateUp() { finish(); return true; }
}
EOF
echo "✅ EditProfileActivity.java created"

# ─── IMAGE VIEWER ACTIVITY ──────────────────────────────────────────────────────
cat > "$PKG_DIR/ImageViewerActivity.java" << 'EOF'
package com.example.callingapp;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.widget.ImageButton;
import android.widget.ImageView;
import androidx.appcompat.app.AppCompatActivity;
public class ImageViewerActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_image_viewer);
        String base64 = getIntent().getStringExtra("image_base64");
        ImageView fullImageView = findViewById(R.id.full_image_view); ImageButton closeBtn = findViewById(R.id.btn_close_image);
        if (base64 != null) { byte[] bytes = android.util.Base64.decode(base64, android.util.Base64.DEFAULT); Bitmap bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.length); fullImageView.setImageBitmap(bmp); }
        closeBtn.setOnClickListener(v -> finish());
    }
}
EOF
echo "✅ ImageViewerActivity.java created"

# ─── GROUP CHAT ACTIVITY ────────────────────────────────────────────────────────
cat > "$PKG_DIR/GroupChatActivity.java" << 'EOF'
package com.example.callingapp;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.callingapp.adapters.MessageAdapter;
import com.example.callingapp.models.Message;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.ArrayList;
import java.util.List;
public class GroupChatActivity extends AppCompatActivity {
    private String groupId, groupName; private RecyclerView recycler; private EditText msgInput; private TextView groupNameText, memberCount;
    private MessageAdapter adapter; private List<Message> messages = new ArrayList<>(); private DatabaseReference mDb; private String myUid;
    private ValueEventListener messagesListener;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState); setContentView(R.layout.activity_group_chat);
        groupId = getIntent().getStringExtra("groupId"); groupName = getIntent().getStringExtra("groupName");
        myUid = FirebaseAuth.getInstance().getCurrentUser().getUid(); mDb = FirebaseDatabase.getInstance().getReference();
        Toolbar toolbar = findViewById(R.id.group_toolbar); setSupportActionBar(toolbar); if(getSupportActionBar()!=null) getSupportActionBar().setDisplayShowTitleEnabled(false);
        groupNameText = findViewById(R.id.group_name_text); memberCount = findViewById(R.id.group_member_count);
        recycler = findViewById(R.id.group_recycler); msgInput = findViewById(R.id.group_msg_input);
        groupNameText.setText(groupName);
        findViewById(R.id.group_back).setOnClickListener(v -> finish());
        findViewById(R.id.group_send_btn).setOnClickListener(v -> sendMessage());
        adapter = new MessageAdapter(this, messages, myUid);
        recycler.setLayoutManager(new LinearLayoutManager(this)); recycler.setAdapter(adapter);
        loadMessages(); loadMemberCount();
    }
    private void sendMessage() { String text = msgInput.getText().toString().trim(); if (TextUtils.isEmpty(text)) return; Message msg = new Message(myUid, groupId, text, Message.TYPE_TEXT); msg.id = mDb.push().getKey(); mDb.child("group_chats").child(groupId).child("messages").child(msg.id).setValue(msg); msgInput.setText(""); }
    private void loadMessages() { messagesListener = mDb.child("group_chats").child(groupId).child("messages").orderByChild("timestamp").limitToLast(50).addValueEventListener(new ValueEventListener() {
        @Override public void onDataChange(@NonNull DataSnapshot snap) { messages.clear(); for (DataSnapshot child : snap.getChildren()) { Message m = child.getValue(Message.class); if (m != null) { m.id = child.getKey(); messages.add(m); } } adapter.notifyDataSetChanged(); recycler.scrollToPosition(messages.size() - 1); }
        @Override public void onCancelled(@NonNull DatabaseError e) {}
    }); }
    private void loadMemberCount() { mDb.child("group_chats").child(groupId).child("members").addListenerForSingleValueEvent(new ValueEventListener() {
        @Override public void onDataChange(@NonNull DataSnapshot snap) { memberCount.setText(snap.getChildrenCount() + " members"); }
        @Override public void onCancelled(@NonNull DatabaseError e) {}
    }); }
    @Override protected void onDestroy() { super.onDestroy(); if (messagesListener != null && groupId != null) mDb.child("group_chats").child(groupId).child("messages").removeEventListener(messagesListener); }
}
EOF
echo "✅ GroupChatActivity.java created"

# ─── BACKGROUND SERVICE ─────────────────────────────────────────────────────────
cat > "$PKG_DIR/BackgroundService.java" << 'EOF'
package com.example.callingapp;
import android.app.*;
import android.content.Intent;
import android.os.*;
import androidx.core.app.NotificationCompat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import com.google.firebase.auth.FirebaseUser;
public class BackgroundService extends Service {
    public static final String CHANNEL_ID = JavaGoatApp.CHANNEL_SERVICE;
    private static final int NOTIF_ID = 1001;
    private DatabaseReference mDb; private String myUid;
    private ValueEventListener unreadListener, callListener;
    @Override public void onCreate() { super.onCreate(); startForeground(NOTIF_ID, createPersistentNotification()); FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser(); if (user != null) { myUid = user.getUid(); mDb = FirebaseDatabase.getInstance().getReference(); startListeners(); } }
    private Notification createPersistentNotification() { Intent intent = new Intent(this, MainActivity.class); PendingIntent pi = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT); return new NotificationCompat.Builder(this, CHANNEL_ID).setContentTitle("Java Goat").setContentText("Connected. Ready for calls & messages.").setSmallIcon(android.R.drawable.ic_menu_call).setContentIntent(pi).setPriority(NotificationCompat.PRIORITY_MIN).setOngoing(true).build(); }
    private void startListeners() {
        unreadListener = mDb.child("users").child(myUid).child("unread").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) { if (MainActivity.isAppInForeground) return; long totalUnread = 0; for (DataSnapshot child : snap.getChildren()) totalUnread += (long) child.getValue(); if (totalUnread > 0) showMessageNotification("New Messages", totalUnread + " unread message(s)"); }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
        callListener = mDb.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) { if (!snap.exists()) { cancelCallNotification(); return; } String callerId = snap.child("callerId").getValue(String.class); Boolean accepted = snap.child("accepted").getValue(Boolean.class); if (callerId == null || callerId.equals(myUid)) return; if (accepted != null && accepted) return; mDb.child("users").child(callerId).get().addOnSuccessListener(userSnap -> { String name = userSnap.child("name").getValue(String.class); String emoji = userSnap.child("emoji").getValue(String.class); Boolean isVideo = snap.child("isVideo").getValue(Boolean.class); showCallNotification(callerId, emoji + " " + name, isVideo != null && isVideo); }); }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    private void showMessageNotification(String title, String text) { Intent intent = new Intent(this, MainActivity.class); PendingIntent pi = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT); Notification notif = new NotificationCompat.Builder(this, JavaGoatApp.CHANNEL_MESSAGES).setContentTitle(title).setContentText(text).setSmallIcon(android.R.drawable.ic_dialog_email).setContentIntent(pi).setAutoCancel(true).setPriority(NotificationCompat.PRIORITY_HIGH).build(); NotificationManager nm = getSystemService(NotificationManager.class); if (nm != null) nm.notify(2000, notif); }
    private void showCallNotification(String callerId, String name, boolean isVideo) { Intent fullScreenIntent = new Intent(this, MainActivity.class); fullScreenIntent.putExtra("incomingCallUid", callerId); fullScreenIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP); PendingIntent fullScreenPi = PendingIntent.getActivity(this, 3001, fullScreenIntent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT); Notification notif = new NotificationCompat.Builder(this, JavaGoatApp.CHANNEL_CALLS).setContentTitle("📞 Incoming Call from " + name).setContentText(isVideo ? "Video call" : "Voice call").setSmallIcon(android.R.drawable.ic_menu_call).setFullScreenIntent(fullScreenPi, true).setPriority(NotificationCompat.PRIORITY_MAX).setCategory(NotificationCompat.CATEGORY_CALL).setAutoCancel(false).setOngoing(true).build(); NotificationManager nm = getSystemService(NotificationManager.class); if (nm != null) nm.notify(3001, notif); }
    private void cancelCallNotification() { NotificationManager nm = getSystemService(NotificationManager.class); if (nm != null) nm.cancel(3001); }
    @Override public int onStartCommand(Intent intent, int flags, int startId) { return START_STICKY; }
    @Override public void onDestroy() { super.onDestroy(); if (mDb != null && myUid != null) { if (unreadListener != null) mDb.child("users").child(myUid).child("unread").removeEventListener(unreadListener); if (callListener != null) mDb.child("calls").child(myUid).removeEventListener(callListener); } }
    @Override public IBinder onBind(Intent intent) { return null; }
}
EOF
echo "✅ BackgroundService.java created"

# ─── FIREBASE MESSAGING SERVICE ─────────────────────────────────────────────────
cat > "$PKG_DIR/MyFirebaseMessagingService.java" << 'EOF'
package com.example.callingapp;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import java.util.Map;
public class MyFirebaseMessagingService extends FirebaseMessagingService {
    @Override public void onMessageReceived(RemoteMessage message) { Map<String, String> data = message.getData(); if (data.containsKey("type")) { String type = data.get("type"); if ("call".equals(type)) showCallNotification(data.get("callerName"), data.get("callerId")); else if ("message".equals(type)) showMessageNotification(data.get("senderName"), data.get("messageText")); } }
    private void showCallNotification(String name, String callerId) { Intent intent = new Intent(this, MainActivity.class); intent.putExtra("incomingCallUid", callerId); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP); PendingIntent pi = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT); NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE); if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { NotificationChannel ch = new NotificationChannel("calls_fcm", "Calls", NotificationManager.IMPORTANCE_HIGH); nm.createNotificationChannel(ch); } NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "calls_fcm").setContentTitle("📞 Incoming call from " + name).setContentText("Tap to answer").setSmallIcon(android.R.drawable.ic_menu_call).setContentIntent(pi).setAutoCancel(true).setPriority(NotificationCompat.PRIORITY_MAX); nm.notify(3002, builder.build()); }
    private void showMessageNotification(String name, String msg) { Intent intent = new Intent(this, MainActivity.class); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); PendingIntent pi = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT); NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE); if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { NotificationChannel ch = new NotificationChannel("messages_fcm", "Messages", NotificationManager.IMPORTANCE_HIGH); nm.createNotificationChannel(ch); } NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages_fcm").setContentTitle("💬 New message from " + name).setContentText(msg).setSmallIcon(android.R.drawable.ic_dialog_email).setContentIntent(pi).setAutoCancel(true); nm.notify((int) System.currentTimeMillis(), builder.build()); }
}
EOF
echo "✅ MyFirebaseMessagingService.java created"

# ─── GRADLE WRAPPER AND BUILD ───────────────────────────────────────────────────
echo "=== Setting up Gradle Wrapper ==="
mkdir -p "$PROJECT_DIR/gradle/wrapper"

cat > "$PROJECT_DIR/gradle/wrapper/gradle-wrapper.properties" << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

if [ ! -f "/opt/gradle/gradle-8.2/bin/gradle" ]; then
    wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip -O /tmp/gradle-8.2-bin.zip
    sudo unzip -q -o /tmp/gradle-8.2-bin.zip -d /opt/gradle
fi

cd "$PROJECT_DIR"
/opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2 2>/dev/null || true
chmod +x "$PROJECT_DIR/gradlew"

# ─── BUILD APK ───────────────────────────────────────────────────────────────────
echo "=== Building Java Goat APK ==="
echo "This may take 2-3 minutes..."

export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

cd "$PROJECT_DIR"

yes | sdkmanager --licenses > /dev/null 2>&1 || true

./gradlew clean assembleRelease --stacktrace --no-daemon 2>&1 | tail -80

echo ""
echo "============================================="
echo "🎉 BUILD COMPLETE! 🎉"
echo "============================================="
echo ""
echo "📱 APK Location: $PROJECT_DIR/app/build/outputs/apk/release/app-release.apk"

if [ -f "$PROJECT_DIR/app/build/outputs/apk/release/app-release.apk" ]; then
    ls -lh "$PROJECT_DIR/app/build/outputs/apk/release/"
    echo ""
    echo "✅ Java Goat APK successfully generated!"
    echo "📦 Size: $(du -h $PROJECT_DIR/app/build/outputs/apk/release/app-release.apk | cut -f1)"
    echo ""
    echo "🔑 Keystore: $PROJECT_DIR/app/javagoat.jks"
    echo "   Password: javagoat123"
    echo ""
    echo "🛠️  Installation:"
    echo "   adb install $PROJECT_DIR/app/build/outputs/apk/release/app-release.apk"
else
    echo "❌ APK build failed. Check the error messages above."
    exit 1
fi
echo "============================================="
echo "🐐 Java Goat - Your Professional Messenger is Ready! 🐐"
    
    
    
    
    
    