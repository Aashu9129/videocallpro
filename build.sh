#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(pwd)"
APP_PACKAGE_DIR="$PROJECT_ROOT/app/src/main/java/com/example/callingapp"
RES_DIR="$PROJECT_ROOT/app/src/main/res"

echo "=== Creating Java Goat Android Project ==="

# Install dependencies
sudo apt-get update -qq
sudo apt-get install -y wget unzip openjdk-17-jdk zipalign apksigner 2>/dev/null || true

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

mkdir -p "$PROJECT_ROOT"
mkdir -p "$APP_PACKAGE_DIR"
mkdir -p "$RES_DIR/layout"
mkdir -p "$RES_DIR/values"
mkdir -p "$RES_DIR/drawable"
mkdir -p "$RES_DIR/menu"
mkdir -p "$RES_DIR/mipmap-anydpi-v26"
mkdir -p "$RES_DIR/mipmap-hdpi"
mkdir -p "$RES_DIR/mipmap-mdpi"
mkdir -p "$RES_DIR/mipmap-xhdpi"
mkdir -p "$RES_DIR/mipmap-xxhdpi"
mkdir -p "$RES_DIR/mipmap-xxxhdpi"
mkdir -p "$RES_DIR/xml"
mkdir -p "$PROJECT_ROOT/app/src/main/assets"
mkdir -p "$PROJECT_ROOT/gradle/wrapper"

# ─── ANDROID SDK SETUP ───────────────────────────────────────────────────────
echo "=== Setting up Android SDK ==="
export ANDROID_SDK_ROOT="$HOME/android-sdk"
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

if [ ! -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip
    unzip -q -o /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extract
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/latest"
    cp -r /tmp/cmdline-tools-extract/cmdline-tools/* "$ANDROID_SDK_ROOT/cmdline-tools/latest/"
fi

export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools" > /dev/null 2>&1 || true

# ─── KEYSTORE ────────────────────────────────────────────────────────────────
echo "=== Generating Keystore ==="
KEYSTORE_PATH="$PROJECT_ROOT/app/javagoat-release.jks"
keytool -genkeypair -v \
  -keystore "$KEYSTORE_PATH" \
  -alias javagoat \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass javagoat123 \
  -keypass javagoat123 \
  -dname "CN=JavaGoat,OU=Dev,O=JavaGoat,L=City,S=State,C=US" \
  -storetype JKS 2>/dev/null || true

# ─── GOOGLE-SERVICES.JSON ────────────────────────────────────────────────────
echo "=== Creating google-services.json ==="
cat <<'EOF' > "$PROJECT_ROOT/app/google-services.json"
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
EOF

# ─── SETTINGS.GRADLE ─────────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/settings.gradle"
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
    }
}
rootProject.name = "JavaGoat"
include ':app'
EOF

# ─── ROOT BUILD.GRADLE ────────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/build.gradle"
plugins {
    id 'com.android.application' version '8.2.0' apply false
    id 'com.google.gms.google-services' version '4.4.0' apply false
}
EOF

# ─── GRADLE.PROPERTIES ───────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/gradle.properties"
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
org.gradle.parallel=true
org.gradle.caching=true
EOF

# ─── APP BUILD.GRADLE ─────────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/app/build.gradle"
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
        versionCode 1
        versionName "1.0"
    }

    signingConfigs {
        release {
            storeFile file('javagoat-release.jks')
            storePassword 'javagoat123'
            keyAlias 'javagoat'
            keyPassword 'javagoat123'
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            signingConfig signingConfigs.release
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
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
        pickFirst 'META-INF/INDEX.LIST'
        pickFirst 'META-INF/io.netty.versions.properties'
        exclude 'META-INF/DEPENDENCIES'
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'

    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'

    implementation 'io.getstream:stream-webrtc-android:1.1.1'

    implementation 'androidx.core:core:1.12.0'
    implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.1.0'
}
EOF

# ─── PROGUARD RULES ──────────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/app/proguard-rules.pro"
-keep class com.example.callingapp.** { *; }
-keep class org.webrtc.** { *; }
-keep class io.getstream.** { *; }
-dontwarn org.webrtc.**
EOF

# ─── GRADLE WRAPPER SETUP ────────────────────────────────────────────────────
echo "=== Setting up Gradle Wrapper ==="
mkdir -p "$PROJECT_ROOT/gradle/wrapper"

cat <<'EOF' > "$PROJECT_ROOT/gradle/wrapper/gradle-wrapper.properties"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip -O /tmp/gradle-8.2-bin.zip
sudo mkdir -p /opt/gradle
sudo unzip -q -o /tmp/gradle-8.2-bin.zip -d /opt/gradle

cd "$PROJECT_ROOT"
/opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2 2>/dev/null || true
chmod +x "$PROJECT_ROOT/gradlew"

# ─── ANDROIDMANIFEST.XML ─────────────────────────────────────────────────────
cat <<'EOF' > "$PROJECT_ROOT/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>

    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.front" android:required="false"/>
    <uses-feature android:name="android.hardware.microphone" android:required="false"/>

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="Java Goat"
        android:theme="@style/Theme.JavaGoat"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize"
            android:screenOrientation="portrait"
            android:showOnLockScreen="true"
            android:turnScreenOn="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <service
            android:name=".BackgroundService"
            android:exported="false"
            android:foregroundServiceType="dataSync"/>

        <receiver
            android:name=".CallActionReceiver"
            android:exported="false"/>

    </application>
</manifest>
EOF

# ─── COLORS.XML ──────────────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/values/colors.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="colorPrimary">#075E54</color>
    <color name="colorPrimaryDark">#054C44</color>
    <color name="colorAccent">#25D366</color>
    <color name="colorBlue">#34B7F1</color>
    <color name="colorOrange">#FF6B35</color>
    <color name="colorBackground">#F0F0F0</color>
    <color name="colorSurface">#FFFFFF</color>
    <color name="colorMsgOut">#DCF8C6</color>
    <color name="colorMsgIn">#FFFFFF</color>
    <color name="colorMsgOutText">#000000</color>
    <color name="colorMsgInText">#000000</color>
    <color name="colorTimestamp">#999999</color>
    <color name="colorCallGreen">#25D366</color>
    <color name="colorCallRed">#F44336</color>
    <color name="colorOnline">#25D366</color>
    <color name="colorOffline">#BBBBBB</color>
    <color name="colorBadge">#F44336</color>
    <color name="colorToolbar">#075E54</color>
    <color name="colorToolbarText">#FFFFFF</color>
    <color name="colorDivider">#E0E0E0</color>
    <color name="colorUnread">#25D366</color>
    <color name="colorCallBackground">#1A1A2E</color>
    <color name="colorWhite">#FFFFFF</color>
    <color name="colorBlack">#000000</color>
    <color name="colorTransparent">#00000000</color>
    <color name="colorEmojiBackground">#E8F5E9</color>
    <color name="statusBarColor">#054C44</color>
</resources>
EOF

# ─── STRINGS.XML ─────────────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/values/strings.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Java Goat</string>
    <string name="tab_chats">Chats</string>
    <string name="tab_updates">Updates</string>
    <string name="tab_calls">Calls</string>
    <string name="login">Login</string>
    <string name="signup">Sign Up</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="send">Send</string>
    <string name="message_hint">Type a message</string>
    <string name="accept">Accept</string>
    <string name="reject">Decline</string>
    <string name="end_call">End</string>
    <string name="incoming_call">Incoming Call</string>
    <string name="calling">Calling…</string>
    <string name="connecting">Connecting…</string>
    <string name="logout">Logout</string>
    <string name="add_friend">Add Friend</string>
    <string name="enter_friend_id">Enter jg-XXXX ID</string>
    <string name="profile">Profile</string>
    <string name="your_id">Your ID</string>
    <string name="no_chats">No chats yet. Add a friend!</string>
    <string name="no_updates">No updates</string>
    <string name="no_calls">No call history</string>
    <string name="channel_messages">Messages</string>
    <string name="channel_calls">Calls</string>
    <string name="channel_persistent">Background</string>
    <string name="notification_new_message">New message</string>
    <string name="notification_incoming_call">Incoming call from</string>
    <string name="voice_call">Voice Call</string>
    <string name="video_call">Video Call</string>
    <string name="set_name">Set Your Name</string>
    <string name="choose_emoji">Choose Your Emoji Avatar</string>
    <string name="name_hint">Your name</string>
    <string name="ok">OK</string>
    <string name="cancel">Cancel</string>
    <string name="friend_request_sent">Friend request sent!</string>
    <string name="user_not_found">User not found</string>
    <string name="friend_request_from">Friend request from</string>
</resources>
EOF

# ─── STYLES.XML ──────────────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/values/styles.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.JavaGoat" parent="Theme.MaterialComponents.Light.NoActionBar">
        <item name="colorPrimary">@color/colorPrimary</item>
        <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
        <item name="colorAccent">@color/colorAccent</item>
        <item name="android:statusBarColor">@color/statusBarColor</item>
        <item name="android:windowBackground">@color/colorBackground</item>
    </style>

    <style name="ToolbarTitleOrange">
        <item name="android:textColor">@color/colorOrange</item>
        <item name="android:textSize">20sp</item>
        <item name="android:fontFamily">sans-serif-medium</item>
    </style>

    <style name="ToolbarTitleBlue">
        <item name="android:textColor">@color/colorBlue</item>
        <item name="android:textSize">20sp</item>
        <item name="android:fontFamily">sans-serif-medium</item>
    </style>

    <style name="CallButton">
        <item name="android:layout_width">64dp</item>
        <item name="android:layout_height">64dp</item>
        <item name="android:elevation">4dp</item>
    </style>
</resources>
EOF

# ─── DIMENS.XML ──────────────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/values/dimens.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="activity_horizontal_margin">16dp</dimen>
    <dimen name="activity_vertical_margin">16dp</dimen>
    <dimen name="toolbar_height">56dp</dimen>
    <dimen name="bubble_padding">10dp</dimen>
    <dimen name="bubble_margin">4dp</dimen>
    <dimen name="message_text_size">15sp</dimen>
    <dimen name="timestamp_text_size">11sp</dimen>
    <dimen name="avatar_size">46dp</dimen>
    <dimen name="avatar_emoji_size">28sp</dimen>
    <dimen name="badge_size">18dp</dimen>
    <dimen name="local_video_width">120dp</dimen>
    <dimen name="local_video_height">160dp</dimen>
    <dimen name="call_button_size">64dp</dimen>
    <dimen name="online_dot_size">10dp</dimen>
</resources>
EOF

# ─── DRAWABLE: MSG_OUT_BG ────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/msg_out_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/colorMsgOut"/>
    <corners
        android:topLeftRadius="12dp"
        android:topRightRadius="12dp"
        android:bottomLeftRadius="12dp"
        android:bottomRightRadius="2dp"/>
    <padding
        android:left="10dp"
        android:top="6dp"
        android:right="10dp"
        android:bottom="6dp"/>
</shape>
EOF

# ─── DRAWABLE: MSG_IN_BG ─────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/msg_in_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/colorMsgIn"/>
    <corners
        android:topLeftRadius="2dp"
        android:topRightRadius="12dp"
        android:bottomLeftRadius="12dp"
        android:bottomRightRadius="12dp"/>
    <padding
        android:left="10dp"
        android:top="6dp"
        android:right="10dp"
        android:bottom="6dp"/>
</shape>
EOF

# ─── DRAWABLE: EMOJI_BG ──────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/emoji_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorEmojiBackground"/>
</shape>
EOF

# ─── DRAWABLE: CIRCLE_GREEN ──────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/circle_green.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorCallGreen"/>
</shape>
EOF

# ─── DRAWABLE: CIRCLE_RED ────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/circle_red.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorCallRed"/>
</shape>
EOF

# ─── DRAWABLE: CIRCLE_BADGE ──────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/circle_badge.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorBadge"/>
</shape>
EOF

# ─── DRAWABLE: ROUNDED_BUTTON ────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/rounded_button.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/colorAccent"/>
    <corners android:radius="24dp"/>
</shape>
EOF

# ─── DRAWABLE: ONLINE_DOT ────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/online_dot.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorOnline"/>
    <stroke android:width="1dp" android:color="@color/colorWhite"/>
</shape>
EOF

# ─── DRAWABLE: OFFLINE_DOT ───────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/offline_dot.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorOffline"/>
    <stroke android:width="1dp" android:color="@color/colorWhite"/>
</shape>
EOF

# ─── DRAWABLE: CHAT_ITEM_BG ──────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/chat_item_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_pressed="true">
        <shape>
            <solid android:color="#E0E0E0"/>
        </shape>
    </item>
    <item>
        <shape>
            <solid android:color="@color/colorSurface"/>
        </shape>
    </item>
</selector>
EOF

# ─── DRAWABLE: IC_LAUNCHER_BACKGROUND ────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/ic_launcher_background.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#075E54"/>
</shape>
EOF

# ─── DRAWABLE: IC_LAUNCHER_FOREGROUND ────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/drawable/ic_launcher_foreground.xml"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M54,30 C43,30 34,39 34,50 C34,55 36,59.5 39.5,62.8 L38,74 L49.5,68.5 C51,69 52.5,69.2 54,69.2 C65,69.2 74,60.2 74,49.2 C74,38.2 65,30 54,30 Z M45,46 L63,46 C64.1,46 65,46.9 65,48 C65,49.1 64.1,50 63,50 L45,50 C43.9,50 43,49.1 43,48 C43,46.9 43.9,46 45,46 Z M45,54 L57,54 C58.1,54 59,54.9 59,56 C59,57.1 58.1,58 57,58 L45,58 C43.9,58 43,57.1 43,56 C43,54.9 43.9,54 45,54 Z"/>
</vector>
EOF

# ─── MIPMAP: IC_LAUNCHER (anydpi-v26) ────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/mipmap-anydpi-v26/ic_launcher.xml"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

cat <<'EOF' > "$RES_DIR/mipmap-anydpi-v26/ic_launcher_round.xml"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

# Create simple PNG placeholder icons using Python
python3 -c "
import struct, zlib, os

def create_png(width, height, color):
    def write_chunk(chunk_type, data):
        c = chunk_type + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    
    png_header = b'\\x89PNG\\r\\n\\x1a\\n'
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = write_chunk(b'IHDR', ihdr_data)
    
    raw_data = b''
    for y in range(height):
        raw_data += b'\\x00'
        for x in range(width):
            raw_data += bytes(color)
    
    compressed = zlib.compress(raw_data)
    idat = write_chunk(b'IDAT', compressed)
    iend = write_chunk(b'IEND', b'')
    
    return png_header + ihdr + idat + iend

sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}

base = '$RES_DIR'
for density, size in sizes.items():
    for name in ['ic_launcher', 'ic_launcher_round']:
        path = f'{base}/mipmap-{density}/{name}.png'
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'wb') as f:
            f.write(create_png(size, size, [7, 94, 84]))
print('Icons created')
" 2>/dev/null || echo "Python icon generation skipped"

# ─── MENU: BOTTOM_NAV ────────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/menu/bottom_nav_menu.xml"
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/nav_chats"
        android:icon="@android:drawable/ic_menu_recent_history"
        android:title="@string/tab_chats"/>
    <item
        android:id="@+id/nav_updates"
        android:icon="@android:drawable/ic_menu_agenda"
        android:title="@string/tab_updates"/>
    <item
        android:id="@+id/nav_calls"
        android:icon="@android:drawable/ic_menu_call"
        android:title="@string/tab_calls"/>
</menu>
EOF

# ─── LAYOUT: ACTIVITY_MAIN ───────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/rootContainer"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/colorBackground">

    <!-- AUTH VIEW -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/authView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/colorPrimary"
        android:visibility="visible">

        <TextView
            android:id="@+id/tvAppNameAuth"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Java Goat"
            android:textSize="36sp"
            android:textColor="@color/colorWhite"
            android:fontFamily="sans-serif-medium"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintBottom_toTopOf="@id/authCard"
            android:layout_marginBottom="24dp"/>

        <androidx.cardview.widget.CardView
            android:id="@+id/authCard"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_margin="24dp"
            app:cardCornerRadius="16dp"
            app:cardElevation="8dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="24dp">

                <TextView
                    android:id="@+id/tvAuthTitle"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Welcome Back"
                    android:textSize="22sp"
                    android:textColor="@color/colorPrimary"
                    android:fontFamily="sans-serif-medium"
                    android:layout_marginBottom="16dp"/>

                <com.google.android.material.textfield.TextInputLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="Email"
                    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                    android:layout_marginBottom="12dp">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etEmail"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textEmailAddress"
                        android:maxLines="1"/>
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="Password"
                    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                    app:passwordToggleEnabled="true"
                    android:layout_marginBottom="20dp">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etPassword"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPassword"
                        android:maxLines="1"/>
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnLogin"
                    android:layout_width="match_parent"
                    android:layout_height="48dp"
                    android:text="Login"
                    android:textColor="@color/colorWhite"
                    app:backgroundTint="@color/colorPrimary"
                    android:layout_marginBottom="8dp"/>

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnSignup"
                    android:layout_width="match_parent"
                    android:layout_height="48dp"
                    android:text="Sign Up"
                    android:textColor="@color/colorPrimary"
                    app:backgroundTint="@color/colorWhite"
                    app:strokeColor="@color/colorPrimary"
                    app:strokeWidth="1dp"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"/>

                <TextView
                    android:id="@+id/tvAuthError"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textColor="#F44336"
                    android:textSize="13sp"
                    android:layout_marginTop="8dp"
                    android:visibility="gone"/>

            </LinearLayout>
        </androidx.cardview.widget.CardView>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- MAIN VIEW -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/mainView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:visibility="gone">

        <androidx.appcompat.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@color/colorToolbar"
            android:elevation="4dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">

            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal">

                <TextView
                    android:id="@+id/tvToolbarJava"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Java "
                    android:textColor="@color/colorOrange"
                    android:textSize="20sp"
                    android:fontFamily="sans-serif-medium"/>

                <TextView
                    android:id="@+id/tvToolbarGoat"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Goat"
                    android:textColor="@color/colorBlue"
                    android:textSize="20sp"
                    android:fontFamily="sans-serif-medium"/>
            </LinearLayout>

        </androidx.appcompat.widget.Toolbar>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/mainRecyclerView"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:background="@color/colorBackground"
            app:layout_constraintTop_toBottomOf="@id/toolbar"
            app:layout_constraintBottom_toTopOf="@id/bottomNav"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottomNav"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@color/colorSurface"
            app:menu="@menu/bottom_nav_menu"
            app:itemIconTint="@color/colorPrimary"
            app:itemTextColor="@color/colorPrimary"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- CHAT VIEW -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/chatView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/colorBackground"
        android:visibility="gone">

        <androidx.appcompat.widget.Toolbar
            android:id="@+id/chatToolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@color/colorToolbar"
            android:elevation="4dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical">

                <ImageButton
                    android:id="@+id/btnChatBack"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_media_previous"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:tint="@color/colorWhite"
                    android:contentDescription="Back"/>

                <TextView
                    android:id="@+id/tvChatEmoji"
                    android:layout_width="38dp"
                    android:layout_height="38dp"
                    android:gravity="center"
                    android:background="@drawable/emoji_bg"
                    android:textSize="20sp"
                    android:layout_marginStart="4dp"/>

                <LinearLayout
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:orientation="vertical"
                    android:layout_marginStart="8dp">

                    <TextView
                        android:id="@+id/tvChatName"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:textColor="@color/colorWhite"
                        android:textSize="16sp"
                        android:fontFamily="sans-serif-medium"
                        android:maxLines="1"
                        android:ellipsize="end"/>

                    <TextView
                        android:id="@+id/tvChatStatus"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:textColor="#CCFFFFFF"
                        android:textSize="12sp"/>
                </LinearLayout>

                <ImageButton
                    android:id="@+id/btnVoiceCall"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_menu_call"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:tint="@color/colorWhite"
                    android:contentDescription="Voice Call"/>

                <ImageButton
                    android:id="@+id/btnVideoCall"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_menu_camera"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:tint="@color/colorWhite"
                    android:layout_marginStart="4dp"
                    android:contentDescription="Video Call"/>

            </LinearLayout>
        </androidx.appcompat.widget.Toolbar>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/chatRecyclerView"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:paddingStart="8dp"
            android:paddingEnd="8dp"
            android:paddingTop="8dp"
            android:paddingBottom="8dp"
            android:clipToPadding="false"
            app:layout_constraintTop_toBottomOf="@id/chatToolbar"
            app:layout_constraintBottom_toTopOf="@id/chatInputLayout"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <LinearLayout
            android:id="@+id/chatInputLayout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:background="@color/colorSurface"
            android:padding="8dp"
            android:gravity="center_vertical"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">

            <com.google.android.material.textfield.TextInputLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                android:hint="@string/message_hint">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/etMessage"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:maxLines="4"
                    android:inputType="textMultiLine|textCapSentences"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.floatingactionbutton.FloatingActionButton
                android:id="@+id/btnSend"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:src="@android:drawable/ic_menu_send"
                android:layout_marginStart="8dp"
                app:backgroundTint="@color/colorPrimary"
                app:fabSize="mini"
                android:contentDescription="Send"/>

        </LinearLayout>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- CALL VIEW -->
    <FrameLayout
        android:id="@+id/callView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/colorCallBackground"
        android:visibility="gone">

        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/remoteVideoView"
            android:layout_width="match_parent"
            android:layout_height="match_parent"/>

        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/localVideoView"
            android:layout_width="@dimen/local_video_width"
            android:layout_height="@dimen/local_video_height"
            android:layout_gravity="top|end"
            android:layout_margin="16dp"
            android:elevation="8dp"/>

        <androidx.constraintlayout.widget.ConstraintLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent">

            <TextView
                android:id="@+id/tvCallerEmoji"
                android:layout_width="80dp"
                android:layout_height="80dp"
                android:gravity="center"
                android:background="@drawable/emoji_bg"
                android:textSize="40sp"
                app:layout_constraintTop_toTopOf="parent"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintEnd_toEndOf="parent"
                android:layout_marginTop="120dp"/>

            <TextView
                android:id="@+id/tvCallerName"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/colorWhite"
                android:textSize="24sp"
                android:fontFamily="sans-serif-medium"
                app:layout_constraintTop_toBottomOf="@id/tvCallerEmoji"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintEnd_toEndOf="parent"
                android:layout_marginTop="16dp"/>

            <TextView
                android:id="@+id/tvCallStatus"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="#CCFFFFFF"
                android:textSize="16sp"
                app:layout_constraintTop_toBottomOf="@id/tvCallerName"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintEnd_toEndOf="parent"
                android:layout_marginTop="8dp"/>

            <LinearLayout
                android:id="@+id/callButtonsLayout"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintEnd_toEndOf="parent"
                android:layout_marginBottom="80dp">

                <LinearLayout
                    android:id="@+id/btnAcceptLayout"
                    android:layout_width="64dp"
                    android:layout_height="64dp"
                    android:background="@drawable/circle_green"
                    android:gravity="center"
                    android:layout_marginEnd="48dp"
                    android:visibility="gone">
                    <ImageView
                        android:id="@+id/btnAccept"
                        android:layout_width="32dp"
                        android:layout_height="32dp"
                        android:src="@android:drawable/ic_menu_call"
                        android:tint="@color/colorWhite"
                        android:contentDescription="Accept"/>
                </LinearLayout>

                <LinearLayout
                    android:id="@+id/btnEndLayout"
                    android:layout_width="64dp"
                    android:layout_height="64dp"
                    android:background="@drawable/circle_red"
                    android:gravity="center">
                    <ImageView
                        android:id="@+id/btnEnd"
                        android:layout_width="32dp"
                        android:layout_height="32dp"
                        android:src="@android:drawable/ic_delete"
                        android:tint="@color/colorWhite"
                        android:contentDescription="End Call"/>
                </LinearLayout>

            </LinearLayout>

        </androidx.constraintlayout.widget.ConstraintLayout>
    </FrameLayout>

</FrameLayout>
EOF

# ─── LAYOUT: ITEM_LIST ───────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/layout/item_list.xml"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@drawable/chat_item_bg"
    android:paddingStart="16dp"
    android:paddingEnd="16dp"
    android:paddingTop="10dp"
    android:paddingBottom="10dp">

    <!-- Avatar with online dot -->
    <FrameLayout
        android:id="@+id/avatarContainer"
        android:layout_width="46dp"
        android:layout_height="46dp"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent">

        <TextView
            android:id="@+id/tvEmoji"
            android:layout_width="46dp"
            android:layout_height="46dp"
            android:gravity="center"
            android:background="@drawable/emoji_bg"
            android:textSize="24sp"/>

        <View
            android:id="@+id/onlineDot"
            android:layout_width="10dp"
            android:layout_height="10dp"
            android:layout_gravity="bottom|end"
            android:background="@drawable/offline_dot"
            android:visibility="gone"/>
    </FrameLayout>

    <!-- Name + last message -->
    <LinearLayout
        android:id="@+id/textContainer"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:layout_marginStart="12dp"
        app:layout_constraintStart_toEndOf="@id/avatarContainer"
        app:layout_constraintEnd_toStartOf="@id/rightContainer"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent">

        <TextView
            android:id="@+id/tvName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="16sp"
            android:textColor="@color/colorBlack"
            android:fontFamily="sans-serif-medium"
            android:maxLines="1"
            android:ellipsize="end"/>

        <TextView
            android:id="@+id/tvSubtitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="13sp"
            android:textColor="@color/colorTimestamp"
            android:maxLines="1"
            android:ellipsize="end"
            android:layout_marginTop="2dp"/>
    </LinearLayout>

    <!-- Time + badge + buttons -->
    <LinearLayout
        android:id="@+id/rightContainer"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:gravity="end|center_vertical"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent">

        <TextView
            android:id="@+id/tvTime"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textSize="11sp"
            android:textColor="@color/colorTimestamp"/>

        <TextView
            android:id="@+id/tvBadge"
            android:layout_width="20dp"
            android:layout_height="20dp"
            android:gravity="center"
            android:background="@drawable/circle_badge"
            android:textColor="@color/colorWhite"
            android:textSize="11sp"
            android:layout_marginTop="4dp"
            android:visibility="gone"/>

        <!-- Accept/Reject buttons for friend requests -->
        <LinearLayout
            android:id="@+id/requestButtons"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:visibility="gone">

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnAcceptRequest"
                android:layout_width="wrap_content"
                android:layout_height="32dp"
                android:text="Accept"
                android:textSize="11sp"
                app:backgroundTint="@color/colorCallGreen"
                android:layout_marginEnd="4dp"/>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnRejectRequest"
                android:layout_width="wrap_content"
                android:layout_height="32dp"
                android:text="Decline"
                android:textSize="11sp"
                app:backgroundTint="@color/colorCallRed"/>

        </LinearLayout>

    </LinearLayout>

    <View
        android:layout_width="0dp"
        android:layout_height="0.5dp"
        android:background="@color/colorDivider"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ─── LAYOUT: ITEM_MESSAGE ─────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/layout/item_message.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:paddingTop="2dp"
    android:paddingBottom="2dp">

    <!-- OUTGOING MESSAGE (right) -->
    <LinearLayout
        android:id="@+id/outgoingLayout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="end"
        android:orientation="vertical"
        android:background="@drawable/msg_out_bg"
        android:maxWidth="280dp"
        android:layout_marginStart="64dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvMsgOut"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/colorMsgOutText"
            android:textSize="@dimen/message_text_size"/>

        <TextView
            android:id="@+id/tvTimeOut"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:textColor="@color/colorTimestamp"
            android:textSize="@dimen/timestamp_text_size"
            android:layout_marginTop="2dp"/>
    </LinearLayout>

    <!-- INCOMING MESSAGE (left) -->
    <LinearLayout
        android:id="@+id/incomingLayout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="start"
        android:orientation="vertical"
        android:background="@drawable/msg_in_bg"
        android:maxWidth="280dp"
        android:layout_marginEnd="64dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvMsgIn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/colorMsgInText"
            android:textSize="@dimen/message_text_size"/>

        <TextView
            android:id="@+id/tvTimeIn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:textColor="@color/colorTimestamp"
            android:textSize="@dimen/timestamp_text_size"
            android:layout_marginTop="2dp"/>
    </LinearLayout>

</FrameLayout>
EOF

# ─── LAYOUT: DIALOG_INPUT ────────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/layout/dialog_input.xml"
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp">

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">

        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="text"
            android:maxLines="1"/>

    </com.google.android.material.textfield.TextInputLayout>

    <TextView
        android:id="@+id/tvDialogMessage"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textSize="14sp"
        android:textColor="#F44336"
        android:layout_marginTop="4dp"
        android:visibility="gone"/>

</LinearLayout>
EOF

# ─── XML: FILE PROVIDER PATHS ────────────────────────────────────────────────
cat <<'EOF' > "$RES_DIR/xml/file_paths.xml"
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
</paths>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# ─── JAVA FILES ───────────────────────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════════════════════

# ─── CallActionReceiver.java ──────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/CallActionReceiver.java"
package com.example.callingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class CallActionReceiver extends BroadcastReceiver {
    public static final String ACTION_ACCEPT = "com.example.callingapp.ACTION_ACCEPT";
    public static final String ACTION_REJECT = "com.example.callingapp.ACTION_REJECT";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) return;
        String action = intent.getAction();
        if (action == null) return;

        Intent mainIntent = new Intent(context, MainActivity.class);
        mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        mainIntent.setAction(action);
        mainIntent.putExtra("callerId", intent.getStringExtra("callerId"));
        mainIntent.putExtra("callerName", intent.getStringExtra("callerName"));
        mainIntent.putExtra("callerEmoji", intent.getStringExtra("callerEmoji"));
        mainIntent.putExtra("isVideo", intent.getBooleanExtra("isVideo", false));
        context.startActivity(mainIntent);
    }
}
EOF

# ─── FirebaseConfig.java ──────────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/FirebaseConfig.java"
package com.example.callingapp;

public class FirebaseConfig {
    public static final String API_KEY = "AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM";
    public static final String AUTH_DOMAIN = "videocallpro-f5f1b.firebaseapp.com";
    public static final String DATABASE_URL = "https://videocallpro-f5f1b-default-rtdb.firebaseio.com";
    public static final String PROJECT_ID = "videocallpro-f5f1b";
    public static final String STORAGE_BUCKET = "videocallpro-f5f1b.firebasestorage.app";
    public static final String MESSAGING_SENDER_ID = "1044955332082";
    public static final String APP_ID = "1:1044955332082:android:2c6e7458b191b9d96eff6b";
}
EOF

# ─── Models ──────────────────────────────────────────────────────────────────
mkdir -p "$APP_PACKAGE_DIR/model"

cat <<'EOF' > "$APP_PACKAGE_DIR/model/User.java"
package com.example.callingapp.model;

public class User {
    public String uid;
    public String name;
    public String emoji;
    public String friendId;
    public boolean online;
    public long lastSeen;

    public User() {}

    public User(String uid, String name, String emoji, String friendId) {
        this.uid = uid;
        this.name = name;
        this.emoji = emoji;
        this.friendId = friendId;
        this.online = false;
        this.lastSeen = System.currentTimeMillis();
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/ChatMessage.java"
package com.example.callingapp.model;

public class ChatMessage {
    public String id;
    public String senderId;
    public String text;
    public long timestamp;
    public boolean isOutgoing;

    public ChatMessage() {}

    public ChatMessage(String senderId, String text, long timestamp) {
        this.senderId = senderId;
        this.text = text;
        this.timestamp = timestamp;
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/FriendRequest.java"
package com.example.callingapp.model;

public class FriendRequest {
    public String fromUid;
    public String fromName;
    public String fromEmoji;
    public String fromFriendId;
    public long timestamp;
    public String status; // "pending", "accepted", "rejected"

    public FriendRequest() {}

    public FriendRequest(String fromUid, String fromName, String fromEmoji, String fromFriendId) {
        this.fromUid = fromUid;
        this.fromName = fromName;
        this.fromEmoji = fromEmoji;
        this.fromFriendId = fromFriendId;
        this.timestamp = System.currentTimeMillis();
        this.status = "pending";
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/CallRecord.java"
package com.example.callingapp.model;

public class CallRecord {
    public String partnerId;
    public String partnerName;
    public String partnerEmoji;
    public String type; // "voice" or "video"
    public String direction; // "incoming" or "outgoing"
    public long timestamp;
    public long duration; // seconds

    public CallRecord() {}

    public CallRecord(String partnerId, String partnerName, String partnerEmoji,
                      String type, String direction, long timestamp, long duration) {
        this.partnerId = partnerId;
        this.partnerName = partnerName;
        this.partnerEmoji = partnerEmoji;
        this.type = type;
        this.direction = direction;
        this.timestamp = timestamp;
        this.duration = duration;
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/Contact.java"
package com.example.callingapp.model;

public class Contact {
    public String uid;
    public String name;
    public String emoji;
    public String friendId;
    public boolean online;
    public String lastMessage;
    public long lastMessageTime;
    public int unreadCount;

    public Contact() {}
}
EOF

# ─── GenericAdapter.java ─────────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/GenericAdapter.java"
package com.example.callingapp;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class GenericAdapter<T> extends RecyclerView.Adapter<GenericAdapter.ViewHolder> {

    public interface BindCallback<T> {
        void bind(View itemView, T item, int position);
    }

    private final int layoutRes;
    private final BindCallback<T> callback;
    private List<T> items = new ArrayList<>();

    public GenericAdapter(int layoutRes, BindCallback<T> callback) {
        this.layoutRes = layoutRes;
        this.callback = callback;
    }

    public void setItems(List<T> newItems) {
        items = new ArrayList<>(newItems);
        notifyDataSetChanged();
    }

    public List<T> getItems() {
        return items;
    }

    public void addItem(T item) {
        items.add(item);
        notifyItemInserted(items.size() - 1);
    }

    public void clear() {
        items.clear();
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(layoutRes, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        callback.bind(holder.itemView, items.get(position), position);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }
}
EOF

# ─── WebRTCManager.java ───────────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/WebRTCManager.java"
package com.example.callingapp;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import org.webrtc.AudioSource;
import org.webrtc.AudioTrack;
import org.webrtc.Camera2Enumerator;
import org.webrtc.CameraEnumerator;
import org.webrtc.DataChannel;
import org.webrtc.DefaultVideoDecoderFactory;
import org.webrtc.DefaultVideoEncoderFactory;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpTransceiver;
import org.webrtc.SdpObserver;
import org.webrtc.SessionDescription;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

public class WebRTCManager {

    private static final String TAG = "WebRTCManager";

    public interface CallStateListener {
        void onCallConnected();
        void onCallEnded();
        void onRemoteVideoTrack(VideoTrack track);
    }

    private final Context context;
    private final EglBase eglBase;
    private PeerConnectionFactory peerConnectionFactory;
    private PeerConnection peerConnection;
    private VideoTrack localVideoTrack;
    private AudioTrack localAudioTrack;
    private VideoCapturer videoCapturer;
    private SurfaceTextureHelper surfaceTextureHelper;
    private SurfaceViewRenderer localView;
    private SurfaceViewRenderer remoteView;
    private AudioManager audioManager;
    private int savedAudioMode;
    private boolean savedSpeakerphoneOn;

    private final DatabaseReference db;
    private String myUid;
    private String partnerUid;
    private boolean isCaller;
    private boolean isVideo;
    private boolean remoteDescSet = false;
    private final List<IceCandidate> pendingCandidates = new ArrayList<>();
    private CallStateListener stateListener;
    private long callStartTime;
    private ValueEventListener answerListener;
    private ValueEventListener candidateListener;

    public WebRTCManager(Context context, EglBase eglBase) {
        this.context = context.getApplicationContext();
        this.eglBase = eglBase;
        this.db = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL).getReference();
        this.audioManager = (AudioManager) this.context.getSystemService(Context.AUDIO_SERVICE);
    }

    public void setStateListener(CallStateListener listener) {
        this.stateListener = listener;
    }

    public void initFactory() {
        PeerConnectionFactory.InitializationOptions initOptions =
                PeerConnectionFactory.InitializationOptions.builder(context)
                        .setEnableInternalTracer(false)
                        .createInitializationOptions();
        PeerConnectionFactory.initialize(initOptions);

        PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
        DefaultVideoEncoderFactory encoderFactory =
                new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true);
        DefaultVideoDecoderFactory decoderFactory =
                new DefaultVideoDecoderFactory(eglBase.getEglBaseContext());

        peerConnectionFactory = PeerConnectionFactory.builder()
                .setOptions(options)
                .setVideoEncoderFactory(encoderFactory)
                .setVideoDecoderFactory(decoderFactory)
                .createPeerConnectionFactory();
    }

    public void initViews(SurfaceViewRenderer localView, SurfaceViewRenderer remoteView) {
        this.localView = localView;
        this.remoteView = remoteView;
        localView.init(eglBase.getEglBaseContext(), null);
        localView.setMirror(true);
        localView.setZOrderMediaOverlay(true);
        remoteView.init(eglBase.getEglBaseContext(), null);
    }

    public void startCall(String myUid, String partnerUid, boolean isCaller, boolean isVideo) {
        this.myUid = myUid;
        this.partnerUid = partnerUid;
        this.isCaller = isCaller;
        this.isVideo = isVideo;

        configureAudio();
        createMediaTracks();
        createPeerConnection();

        if (isCaller) {
            createAndSendOffer();
        }
    }

    public void receiveCall(String myUid, String partnerUid, boolean isVideo) {
        this.myUid = myUid;
        this.partnerUid = partnerUid;
        this.isCaller = false;
        this.isVideo = isVideo;

        configureAudio();
        createMediaTracks();
        createPeerConnection();
        listenForOffer();
    }

    d configureAudio() {
        savedAudioMode = audioManager.getMode();
        savedSpeakerphoneOn = audioManager.isSpeakerphoneOn();
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        audioManager.setSpeakerphoneOn(isVideo);
    }

    private void createMediaTracks() {
        AudioSource audioSource = peerConnectionFactory.createAudioSource(new MediaConstraints());
        localAudioTrack = peerConnectionFactory.createAudioTrack("audio0", audioSource);
        localAudioTrack.setEnabled(true);

        if (isVideo) {
            videoCapturer = createVideoCapturer();
            if (videoCapturer != null) {
                surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
                VideoSource videoSource = peerConnectionFactory.createVideoSource(false);
                videoCapturer.initialize(surfaceTextureHelper, context, videoSource.getCapturerObserver());
                videoCapturer.startCapture(640, 480, 30);
                localVideoTrack = peerConnectionFactory.createVideoTrack("video0", videoSource);
                localVideoTrack.setEnabled(true);
                if (localView != null) {
                    localVideoTrack.addSink(localView);
                }
            }
        }
    }

    private VideoCapturer createVideoCapturer() {
        Camera2Enumerator enumerator = new Camera2Enumerator(context);
        String[] deviceNames = enumerator.getDeviceNames();
        // Prefer front camera
        for (String name : deviceNames) {
            if (enumerator.isFrontFacing(name)) {
                VideoCapturer capturer = enumerator.createCapturer(name, null);
                if (capturer != null) return capturer;
            }
        }
        // Fallback to any camera
        for (String name : deviceNames) {
            VideoCapturer capturer = enumerator.createCapturer(name, null);
            if (capturer != null) return capturer;
        }
        return null;
    }

    private void createPeerConnection() {
        List<PeerConnection.IceServer> iceServers = new ArrayList<>();
        iceServers.add(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer());
        iceServers.add(PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer());
        iceServers.add(PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer());

        PeerConnection.RTCConfiguration rtcConfig = new PeerConnection.RTCConfiguration(iceServers);
        rtcConfig.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN;
        rtcConfig.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY;

        peerConnection = peerConnectionFactory.createPeerConnection(rtcConfig, new PeerConnection.Observer() {
            @Override
            public void onSignalingChange(PeerConnection.SignalingState state) {}

            @Override
            public void onIceConnectionChange(PeerConnection.IceConnectionState state) {
                Log.d(TAG, "ICE state: " + state);
                if (state == PeerConnection.IceConnectionState.CONNECTED) {
                    callStartTime = System.currentTimeMillis();
                    if (stateListener != null) stateListener.onCallConnected();
                } else if (state == PeerConnection.IceConnectionState.DISCONNECTED ||
                        state == PeerConnection.IceConnectionState.FAILED ||
                        state == PeerConnection.IceConnectionState.CLOSED) {
                    if (stateListener != null) stateListener.onCallEnded();
                }
            }

            @Override
            public void onIceConnectionReceivingChange(boolean b) {}

            @Override
            public void onIceGatheringChange(PeerConnection.IceGatheringState state) {}

            @Override
            public void onIceCandidate(IceCandidate candidate) {
                sendIceCandidate(candidate);
            }

            @Override
            public void onIceCandidatesRemoved(IceCandidate[] candidates) {}

            @Override
            public void onAddStream(MediaStream stream) {}

            @Override
            public void onRemoveStream(MediaStream stream) {}

            @Override
            public void onDataChannel(DataChannel dataChannel) {}

            @Override
            public void onRenegotiationNeeded() {}

            @Override
            public void onAddTrack(RtpReceiver receiver, MediaStream[] streams) {
                if (receiver.track() instanceof VideoTrack) {
                    VideoTrack remoteVideo = (VideoTrack) receiver.track();
                    remoteVideo.setEnabled(true);
                    if (remoteView != null) remoteVideo.addSink(remoteView);
                    if (stateListener != null) stateListener.onRemoteVideoTrack(remoteVideo);
                }
            }

            @Override
            public void onTrack(RtpTransceiver transceiver) {}
        });

        if (peerConnection != null) {
            peerConnection.addTrack(localAudioTrack);
            if (isVideo && localVideoTrack != null) {
                peerConnection.addTrack(localVideoTrack);
            }
        }
    }

    private void createAndSendOffer() {
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        if (isVideo) {
            constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
        }

        peerConnection.createOffer(new SdpObserver() {
            @Override
            public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetSuccess() {
                        Map<String, Object> callData = new HashMap<>();
                        callData.put("callerId", myUid);
                        callData.put("calleeId", partnerUid);
                        callData.put("offer", sdp.description);
                        callData.put("offerType", sdp.type.canonicalForm());
                        callData.put("isVideo", isVideo);
                        callData.put("timestamp", System.currentTimeMillis());
                        db.child("calls").child(partnerUid).setValue(callData);
                        listenForAnswer();
                        listenForCandidates("receiver");
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) { Log.e(TAG, "setLocalDesc fail: " + s); }
                }, sdp);
            }
            @Override public void onSetSuccess() {}
            @Override public void onCreateFailure(String s) { Log.e(TAG, "createOffer fail: " + s); }
            @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void listenForOffer() {
        db.child("calls").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snap) {
                if (!snap.exists()) return;
                String offer = snap.child("offer").getValue(String.class);
                String offerType = snap.child("offerType").getValue(String.class);
                if (offer == null || offerType == null) return;

                SessionDescription.Type type = SessionDescription.Type.fromCanonicalForm(offerType);
                SessionDescription sdp = new SessionDescription(type, offer);

                peerConnection.setRemoteDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetSuccess() {
                        remoteDescSet = true;
                        for (IceCandidate c : pendingCandidates) {
                            peerConnection.addIceCandidate(c);
                        }
                        pendingCandidates.clear();
                        createAndSendAnswer();
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) { Log.e(TAG, "setRemoteDesc fail: " + s); }
                }, sdp);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
        listenForCandidates("caller");
    }

    private void createAndSendAnswer() {
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        if (isVideo) {
            constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
        }

        peerConnection.createAnswer(new SdpObserver() {
            @Override
            public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetSuccess() {
                        Map<String, Object> updates = new HashMap<>();
                        updates.put("answer", sdp.description);
                        updates.put("answerType", sdp.type.canonicalForm());
                        updates.put("accepted", true);
                        db.child("calls").child(myUid).updateChildren(updates);
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) { Log.e(TAG, "setLocalDesc(ans) fail: " + s); }
                }, sdp);
            }
            @Override public void onSetSuccess() {}
            @Override public void onCreateFailure(String s) { Log.e(TAG, "createAnswer fail: " + s); }
            @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void listenForAnswer() {
        answerListener = db.child("calls").child(partnerUid).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snap) {
                if (!snap.exists()) return;
                Boolean accepted = snap.child("accepted").getValue(Boolean.class);
                if (accepted == null || !accepted) return;

                String answer = snap.child("answer").getValue(String.class);
                String answerType = snap.child("answerType").getValue(String.class);
                if (answer == null || answerType == null) return;

                SessionDescription.Type type = SessionDescription.Type.fromCanonicalForm(answerType);
                SessionDescription sdp = new SessionDescription(type, answer);

                peerConnection.setRemoteDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetSuccess() {
                        remoteDescSet = true;
                        for (IceCandidate c : pendingCandidates) {
                            peerConnection.addIceCandidate(c);
                        }
                        pendingCandidates.clear();
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) { Log.e(TAG, "setRemoteDesc(ans) fail: " + s); }
                }, sdp);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void sendIceCandidate(IceCandidate candidate) {
        String side = isCaller ? "caller" : "receiver";
        String targetUid = isCaller ? partnerUid : myUid;

        Map<String, Object> candidateMap = new HashMap<>();
        candidateMap.put("sdp", candidate.sdp);
        candidateMap.put("sdpMid", candidate.sdpMid);
        candidateMap.put("sdpMLineIndex", candidate.sdpMLineIndex);
        db.child("calls").child(targetUid).child("candidates").child(side)
                .push().setValue(candidateMap);
    }

    private void listenForCandidates(String side) {
        String targetUid = isCaller ? partnerUid : myUid;
        candidateListener = db.child("calls").child(targetUid)
                .child("candidates").child(side)
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        for (DataSnapshot child : snap.getChildren()) {
                            String sdp = child.child("sdp").getValue(String.class);
                            String sdpMid = child.child("sdpMid").getValue(String.class);
                            Integer sdpMLineIndex = child.child("sdpMLineIndex").getValue(Integer.class);
                            if (sdp == null || sdpMid == null || sdpMLineIndex == null) continue;

                            IceCandidate candidate = new IceCandidate(sdpMid, sdpMLineIndex, sdp);
                            if (remoteDescSet && peerConnection != null) {
                                peerConnection.addIceCandidate(candidate);
                            } else {
                                pendingCandidates.add(candidate);
                            }
                        }
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    public long getCallDurationSeconds() {
        if (callStartTime == 0) return 0;
        return (System.currentTimeMillis() - callStartTime) / 1000;
    }

    public void endCall() {
        try {
            if (answerListener != null && partnerUid != null) {
                db.child("calls").child(partnerUid).removeEventListener(answerListener);
            }
            if (candidateListener != null) {
                String targetUid = isCaller ? partnerUid : myUid;
                if (targetUid != null) {
                    String side = isCaller ? "receiver" : "caller";
                    db.child("calls").child(targetUid).child("candidates").child(side)
                            .removeEventListener(candidateListener);
                }
            }
            if (myUid != null) {
                db.child("calls").child(myUid).removeValue();
            }
            if (partnerUid != null) {
                db.child("calls").child(partnerUid).removeValue();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error cleaning Firebase: " + e.getMessage());
        }

        try {
            if (videoCapturer != null) {
                videoCapturer.stopCapture();
                videoCapturer.dispose();
                videoCapturer = null;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error stopping capturer: " + e.getMessage());
        }

        try {
            if (surfaceTextureHelper != null) {
                surfaceTextureHelper.dispose();
                surfaceTextureHelper = null;
            }
            if (localVideoTrack != null) {
                localVideoTrack.dispose();
                localVideoTrack = null;
            }
            if (localAudioTrack != null) {
                localAudioTrack.dispose();
                localAudioTrack = null;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error disposing tracks: " + e.getMessage());
        }

        try {
            if (peerConnection != null) {
                peerConnection.close();
                peerConnection = null;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error closing peer connection: " + e.getMessage());
        }

        try {
            if (localView != null) localView.release();
            if (remoteView != null) remoteView.release();
        } catch (Exception e) {
            Log.e(TAG, "Error releasing views: " + e.getMessage());
        }

        try {
            audioManager.setMode(savedAudioMode);
            audioManager.setSpeakerphoneOn(savedSpeakerphoneOn);
        } catch (Exception e) {
            Log.e(TAG, "Error restoring audio: " + e.getMessage());
        }

        remoteDescSet = false;
        pendingCandidates.clear();
    }

    public void dispose() {
        endCall();
        try {
            if (peerConnectionFactory != null) {
                peerConnectionFactory.dispose();
                peerConnectionFactory = null;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error disposing factory: " + e.getMessage());
        }
    }
}
EOF

# ─── BackgroundService.java ───────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/BackgroundService.java"
package com.example.callingapp;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;
import java.util.Map;

public class BackgroundService extends Service {

    private static final String TAG = "BackgroundService";
    public static final String CHANNEL_PERSISTENT = "ch_persistent";
    public static final String CHANNEL_MESSAGES = "ch_messages";
    public static final String CHANNEL_CALLS = "ch_calls";
    private static final int NOTIF_PERSISTENT = 1001;
    private static final int NOTIF_MESSAGE_BASE = 2000;
    private static final int NOTIF_CALL = 3001;

    private DatabaseReference db;
    private String myUid;
    private final Map<String, ValueEventListener> listeners = new HashMap<>();
    private ValueEventListener callListener;
    private ValueEventListener unreadListener;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannels();
        startForeground(NOTIF_PERSISTENT, buildPersistentNotification());

        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user != null) {
            myUid = user.getUid();
            db = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL).getReference();
            startListeners();
        }
    }

    private void createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = getSystemService(NotificationManager.class);

            NotificationChannel persistent = new NotificationChannel(
                    CHANNEL_PERSISTENT, "Background Service",
                    NotificationManager.IMPORTANCE_MIN);
            persistent.setDescription("Keeps Java Goat active");
            persistent.setShowBadge(false);

            NotificationChannel messages = new NotificationChannel(
                    CHANNEL_MESSAGES, "Messages",
                    NotificationManager.IMPORTANCE_HIGH);
            messages.setDescription("New message notifications");

            NotificationChannel calls = new NotificationChannel(
                    CHANNEL_CALLS, "Calls",
                    NotificationManager.IMPORTANCE_HIGH);
            calls.setDescription("Incoming call notifications");
            calls.enableVibration(true);
            calls.setVibrationPattern(new long[]{0, 500, 500, 500});

            nm.createNotificationChannel(persistent);
            nm.createNotificationChannel(messages);
            nm.createNotificationChannel(calls);
        }
    }

    private Notification buildPersistentNotification() {
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

        return new NotificationCompat.Builder(this, CHANNEL_PERSISTENT)
                .setContentTitle("Java Goat")
                .setContentText("Listening for messages and calls…")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pi)
                .setPriority(NotificationCompat.PRIORITY_MIN)
                .setOngoing(true)
                .build();
    }

    private void startListeners() {
        // Listen for unread messages across all contacts
        unreadListener = db.child("users").child(myUid).child("contacts")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        if (MainActivity.isAppInForeground) return;
                        for (DataSnapshot contact : snap.getChildren()) {
                            Long unread = contact.child("unread").getValue(Long.class);
                            if (unread != null && unread > 0) {
                                String name = contact.child("name").getValue(String.class);
                                String emoji = contact.child("emoji").getValue(String.class);
                                if (name == null) name = "Someone";
                                if (emoji == null) emoji = "👤";
                                showMessageNotification(contact.getKey(), emoji + " " + name,
                                        unread + " new message" + (unread > 1 ? "s" : ""));
                            }
                        }
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });

        // Listen for incoming calls
        callListener = db.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snap) {
                if (!snap.exists()) {
                    cancelCallNotification();
                    return;
                }
                String callerId = snap.child("callerId").getValue(String.class);
                if (callerId == null || callerId.equals(myUid)) return;

                Boolean accepted = snap.child("accepted").getValue(Boolean.class);
                if (accepted != null && accepted) return;

                // Fetch caller info
                db.child("users").child(callerId).addListenerForSingleValueEvent(
                        new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot userSnap) {
                                String name = userSnap.child("name").getValue(String.class);
                                String emoji = userSnap.child("emoji").getValue(String.class);
                                Boolean isVideo = snap.child("isVideo").getValue(Boolean.class);
                                if (name == null) name = "Unknown";
                                if (emoji == null) emoji = "👤";
                                showCallNotification(callerId, name, emoji,
                                        isVideo != null && isVideo);
                            }
                            @Override public void onCancelled(@NonNull DatabaseError e) {}
                        });
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void showMessageNotification(String contactUid, String title, String text) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("openChatUid", contactUid);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pi = PendingIntent.getActivity(this, contactUid.hashCode(), intent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

        Notification notif = new NotificationCompat.Builder(this, CHANNEL_MESSAGES)
                .setContentTitle(title)
                .setContentText(text)
                .setSmallIcon(android.R.drawable.ic_dialog_email)
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .build();

        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm != null) nm.notify(NOTIF_MESSAGE_BASE + contactUid.hashCode(), notif);
    }

    private void showCallNotification(String callerId, String name, String emoji, boolean isVideo) {
        Intent fullScreenIntent = new Intent(this, MainActivity.class);
        fullScreenIntent.putExtra("incomingCallUid", callerId);
        fullScreenIntent.putExtra("callerName", name);
        fullScreenIntent.putExtra("callerEmoji", emoji);
        fullScreenIntent.putExtra("isVideo", isVideo);
        fullScreenIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        PendingIntent fullScreenPi = PendingIntent.getActivity(this, NOTIF_CALL, fullScreenIntent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

        Intent acceptIntent = new Intent(this, CallActionReceiver.class);
        acceptIntent.setAction(CallActionReceiver.ACTION_ACCEPT);
        acceptIntent.putExtra("callerId", callerId);
        acceptIntent.putExtra("callerName", name);
        acceptIntent.putExtra("callerEmoji", emoji);
        acceptIntent.putExtra("isVideo", isVideo);
        PendingIntent acceptPi = PendingIntent.getBroadcast(this, 1, acceptIntent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

        Intent rejectIntent = new Intent(this, CallActionReceiver.class);
        rejectIntent.setAction(CallActionReceiver.ACTION_REJECT);
        rejectIntent.putExtra("callerId", callerId);
        PendingIntent rejectPi = PendingIntent.getBroadcast(this, 2, rejectIntent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

        String callType = isVideo ? "📹 Video Call" : "📞 Voice Call";
        Notification notif = new NotificationCompat.Builder(this, CHANNEL_CALLS)
                .setContentTitle(emoji + " " + name + " is calling")
                .setContentText(callType + " • Incoming call")
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setFullScreenIntent(fullScreenPi, true)
                .addAction(android.R.drawable.ic_menu_call, "Accept", acceptPi)
                .addAction(android.R.drawable.ic_delete, "Decline", rejectPi)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setAutoCancel(false)
                .setOngoing(true)
                .setVibrate(new long[]{0, 500, 500, 500})
                .build();

        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm != null) nm.notify(NOTIF_CALL, notif);
    }

    private void cancelCallNotification() {
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm != null) nm.cancel(NOTIF_CALL);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (db != null && myUid != null) {
            if (unreadListener != null) {
                db.child("users").child(myUid).child("contacts").removeEventListener(unreadListener);
            }
            if (callListener != null) {
                db.child("calls").child(myUid).removeEventListener(callListener);
            }
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
EOF

# ─── MainActivity.java ────────────────────────────────────────────────────────
cat <<'EOF' > "$APP_PACKAGE_DIR/MainActivity.java"
package com.example.callingapp;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.callingapp.model.CallRecord;
import com.example.callingapp.model.ChatMessage;
import com.example.callingapp.model.Contact;
import com.example.callingapp.model.FriendRequest;
import com.example.callingapp.model.User;
import com.google.android.material.badge.BadgeDrawable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.ValueEventListener;

import org.webrtc.EglBase;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoTrack;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    private static final int PERM_REQUEST = 100;
    public static boolean isAppInForeground = false;

    // Firebase
    private FirebaseAuth auth;
    private DatabaseReference db;
    private FirebaseUser currentUser;
    private String myUid;
    private User myProfile;

    // Views - Auth
    private View authView;
    private TextInputEditText etEmail, etPassword;
    private TextView tvAuthError;

    // Views - Main
    private View mainView;
    private RecyclerView mainRecyclerView;
    private BottomNavigationView bottomNav;
    private int currentTab = 0; // 0=chats, 1=updates, 2=calls

    // Views - Chat
    private View chatView;
    private TextView tvChatName, tvChatEmoji, tvChatStatus;
    private RecyclerView chatRecyclerView;
    private TextInputEditText etMessage;
    private String chatPartnerUid;
    private Contact chatPartner;
    private ValueEventListener messagesListener;
    private ValueEventListener partnerStatusListener;

    // Views - Call
    private View callView;
    private SurfaceViewRenderer localVideoView, remoteVideoView;
    private TextView tvCallerName, tvCallerEmoji, tvCallStatus;
    private LinearLayout btnAcceptLayout, btnEndLayout;
    private boolean isIncomingCall = false;
    private boolean isCallActive = false;
    private String callPartnerUid;
    private String callPartnerName;
    private String callPartnerEmoji;
    private boolean callIsVideo = false;

    // WebRTC
    private EglBase eglBase;
    private WebRTCManager webRTCManager;

    // Adapters
    private GenericAdapter<Contact> chatsAdapter;
    private GenericAdapter<FriendRequest> updatesAdapter;
    private GenericAdapter<CallRecord> callsAdapter;

    // Firebase listeners
    private ValueEventListener contactsListener;
    private ValueEventListener requestsListener;
    private ValueEventListener callHistoryListener;
    private ValueEventListener incomingCallListener;

    // Data
    private final List<Contact> contactsList = new ArrayList<>();
    private final List<FriendRequest> requestsList = new ArrayList<>();
    private final List<CallRecord> callsList = new ArrayList<>();

    private final Handler handler = new Handler(Looper.getMainLooper());

    // Emojis for avatar selection
    private static final String[] EMOJIS = {
            "😀", "😎", "🤖", "👻", "🦊", "🐸", "🦁", "🐯", "🦋", "🌸",
            "🍕", "🚀", "⚡", "🔥", "💎", "🎸", "🎮", "🏆", "🌈", "🦄"
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initFirebase();
        initViews();
        initWebRTC();
        requestPermissions();

        handleIntent(getIntent());
    }

    private void initFirebase() {
    auth = FirebaseAuth.getInstance();
    
    // Enable disk persistence - data will survive app restart
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL);
    firebaseDatabase.setPersistenceEnabled(true);
    
    db = firebaseDatabase.getReference();
    currentUser = auth.getCurrentUser();
    if (currentUser != null) {
        myUid = currentUser.getUid();
    }
}

    private void initViews() {
        authView = findViewById(R.id.authView);
        mainView = findViewById(R.id.mainView);
        chatView = findViewById(R.id.chatView);
        callView = findViewById(R.id.callView);

        // Auth
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        tvAuthError = findViewById(R.id.tvAuthError);
        findViewById(R.id.btnLogin).setOnClickListener(v -> doLogin());
        findViewById(R.id.btnSignup).setOnClickListener(v -> doSignup());

        // Main toolbar
        Toolbar toolbar = findViewById(R.id.toolbar);
        toolbar.inflateMenu(R.menu.bottom_nav_menu); // reuse icons
        toolbar.setOnMenuItemClickListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats) {
                showAddFriendDialog();
                return true;
            }
            return false;
        });
        // Add action buttons manually
        View addFriendBtn = toolbar.getChildAt(0);

        // Bottom nav
        bottomNav = findViewById(R.id.bottomNav);
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats) { currentTab = 0; refreshMainList(); return true; }
            if (id == R.id.nav_updates) { currentTab = 1; refreshMainList(); return true; }
            if (id == R.id.nav_calls) { currentTab = 2; refreshMainList(); return true; }
            return false;
        });

        // Add toolbar menu items
        Toolbar mainToolbar = findViewById(R.id.toolbar);
        mainToolbar.setOnClickListener(v -> showProfileDialog());

        // Chat views
        tvChatName = findViewById(R.id.tvChatName);
        tvChatEmoji = findViewById(R.id.tvChatEmoji);
        tvChatStatus = findViewById(R.id.tvChatStatus);
        chatRecyclerView = findViewById(R.id.chatRecyclerView);
        etMessage = findViewById(R.id.etMessage);
        FloatingActionButton btnSend = findViewById(R.id.btnSend);
        btnSend.setOnClickListener(v -> sendMessage());
        ImageButton btnChatBack = findViewById(R.id.btnChatBack);
        btnChatBack.setOnClickListener(v -> showMainView());
        ImageButton btnVoiceCall = findViewById(R.id.btnVoiceCall);
        btnVoiceCall.setOnClickListener(v -> startCall(false));
        ImageButton btnVideoCall = findViewById(R.id.btnVideoCall);
        btnVideoCall.setOnClickListener(v -> startCall(true));

        // Main RecyclerView
        mainRecyclerView = findViewById(R.id.mainRecyclerView);
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));

        // Call views
        localVideoView = findViewById(R.id.localVideoView);
        remoteVideoView = findViewById(R.id.remoteVideoView);
        tvCallerName = findViewById(R.id.tvCallerName);
        tvCallerEmoji = findViewById(R.id.tvCallerEmoji);
        tvCallStatus = findViewById(R.id.tvCallStatus);
        btnAcceptLayout = findViewById(R.id.btnAcceptLayout);
        btnEndLayout = findViewById(R.id.btnEndLayout);
        btnAcceptLayout.setOnClickListener(v -> acceptIncomingCall());
        btnEndLayout.setOnClickListener(v -> endCurrentCall());

        if (currentUser != null) {
            showMainView();
        } else {
            showAuthView();
        }
    }

    private void initWebRTC() {
        eglBase = EglBase.create();
    }

    // ── AUTH FLOW ─────────────────────────────────────────────────────────────

    private void doLogin() {
        String email = getText(etEmail);
        String pass = getText(etPassword);
        if (email.isEmpty() || pass.isEmpty()) {
            showAuthError("Please enter email and password");
            return;
        }
        auth.signInWithEmailAndPassword(email, pass)
                .addOnSuccessListener(result -> {
                    currentUser = result.getUser();
                    if (currentUser != null) {
                        myUid = currentUser.getUid();
                        onAuthSuccess();
                    }
                })
                .addOnFailureListener(e -> showAuthError(e.getMessage()));
    }

    private void doSignup() {
        String email = getText(etEmail);
        String pass = getText(etPassword);
        if (email.isEmpty() || pass.isEmpty()) {
            showAuthError("Please enter email and password");
            return;
        }
        if (pass.length() < 6) {
            showAuthError("Password must be at least 6 characters");
            return;
        }
        auth.createUserWithEmailAndPassword(email, pass)
                .addOnSuccessListener(result -> {
                    currentUser = result.getUser();
                    if (currentUser != null) {
                        myUid = currentUser.getUid();
                        showSetupProfileDialog();
                    }
                })
                .addOnFailureListener(e -> showAuthError(e.getMessage()));
    }

    private void showSetupProfileDialog() {
        // Name dialog
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        TextInputEditText nameEt = dialogView.findViewById(R.id.etInput);
        com.google.android.material.textfield.TextInputLayout til = dialogView.findViewById(R.id.tilInput);
        til.setHint("Your name");

        new AlertDialog.Builder(this)
                .setTitle("Set Your Name")
                .setView(dialogView)
                .setCancelable(false)
                .setPositiveButton("Next", (d, w) -> {
                    String name = nameEt.getText() != null ? nameEt.getText().toString().trim() : "";
                    if (name.isEmpty()) name = "User";
                    showEmojiSelectionDialog(name);
                })
                .show();
    }

    private void showEmojiSelectionDialog(String name) {
        final String[] selectedEmoji = {EMOJIS[0]};
        new AlertDialog.Builder(this)
                .setTitle("Choose Your Emoji Avatar")
                .setItems(EMOJIS, (d, which) -> {
                    selectedEmoji[0] = EMOJIS[which];
                    createUserProfile(name, selectedEmoji[0]);
                })
                .setCancelable(false)
                .show();
    }

    private void createUserProfile(String name, String emoji) {
        String friendId = generateFriendId();
        User user = new User(myUid, name, emoji, friendId);
        myProfile = user;

        Map<String, Object> userMap = new HashMap<>();
        userMap.put("uid", myUid);
        userMap.put("name", name);
        userMap.put("emoji", emoji);
        userMap.put("friendId", friendId);
        userMap.put("online", true);
        userMap.put("lastSeen", ServerValue.TIMESTAMP);

        db.child("users").child(myUid).setValue(userMap)
                .addOnSuccessListener(v -> {
                    // Index by friendId for lookup
                    db.child("friendIds").child(friendId).setValue(myUid);
                    onAuthSuccess();
                })
                .addOnFailureListener(e -> showAuthError("Failed to save profile: " + e.getMessage()));
    }

    private String generateFriendId() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder("jg-");
        Random rnd = new Random();
        for (int i = 0; i < 4; i++) sb.append(chars.charAt(rnd.nextInt(chars.length())));
        return sb.toString();
    }

    private void onAuthSuccess() {
        loadMyProfile(() -> {
            setOnlineStatus(true);
            showMainView();
            startBackgroundService();
            setupContactsListener();
            setupRequestsListener();
            setupCallHistoryListener();
            setupIncomingCallListener();
        });
    }

    private void loadMyProfile(Runnable onDone) {
        db.child("users").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snap) {
                myProfile = new User();
                myProfile.uid = myUid;
                myProfile.name = snap.child("name").getValue(String.class);
                myProfile.emoji = snap.child("emoji").getValue(String.class);
                myProfile.friendId = snap.child("friendId").getValue(String.class);
                if (myProfile.name == null) myProfile.name = "User";
                if (myProfile.emoji == null) myProfile.emoji = "👤";
                if (myProfile.friendId == null) myProfile.friendId = "jg-0000";
                if (onDone != null) onDone.run();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {
                if (onDone != null) onDone.run();
            }
        });
    }

    private void setOnlineStatus(boolean online) {
        if (myUid == null) return;
        db.child("users").child(myUid).child("online").setValue(online);
        if (online) {
            db.child("users").child(myUid).child("online").onDisconnect().setValue(false);
        }
    }

    // ── VIEWS ─────────────────────────────────────────────────────────────────

    private void showAuthView() {
        authView.setVisibility(View.VISIBLE);
        mainView.setVisibility(View.GONE);
        chatView.setVisibility(View.GONE);
        callView.setVisibility(View.GONE);
    }

    private void showMainView() {
        authView.setVisibility(View.GONE);
        mainView.setVisibility(View.VISIBLE);
        chatView.setVisibility(View.GONE);
        if (!isCallActive) callView.setVisibility(View.GONE);
        refreshMainList();
    }

    private void showChatView(Contact contact) {
        chatPartnerUid = contact.uid;
        chatPartner = contact;
        tvChatName.setText(contact.name);
        tvChatEmoji.setText(contact.emoji);
        tvChatStatus.setText(contact.online ? "online" : "offline");

        authView.setVisibility(View.GONE);
        mainView.setVisibility(View.GONE);
        chatView.setVisibility(View.VISIBLE);
        if (!isCallActive) callView.setVisibility(View.GONE);

        loadMessages();
        listenPartnerStatus();
        clearUnreadCount(contact.uid);
    }

    private void showCallView(String partnerUid, String partnerName, String partnerEmoji,
                              boolean incoming, boolean isVideo) {
        callPartnerUid = partnerUid;
        callPartnerName = partnerName;
        callPartnerEmoji = partnerEmoji;
        isIncomingCall = incoming;
        callIsVideo = isVideo;

        tvCallerName.setText(partnerName);
        tvCallerEmoji.setText(partnerEmoji);
        tvCallStatus.setText(incoming ? "Incoming call…" : "Calling…");

        btnAcceptLayout.setVisibility(incoming ? View.VISIBLE : View.GONE);

        localVideoView.setVisibility(isVideo ? View.VISIBLE : View.GONE);
        remoteVideoView.setVisibility(isVideo ? View.VISIBLE : View.GONE);

        callView.setVisibility(View.VISIBLE);
        callView.bringToFront();
        isCallActive = true;
    }

    // ── MAIN LIST ─────────────────────────────────────────────────────────────

    private void refreshMainList() {
        switch (currentTab) {
            case 0: showChatsList(); break;
            case 1: showUpdatesList(); break;
            case 2: showCallsList(); break;
        }
    }

    private void showChatsList() {
        chatsAdapter = new GenericAdapter<>(R.layout.item_list, (view, contact, pos) -> {
            TextView tvEmoji = view.findViewById(R.id.tvEmoji);
            TextView tvName = view.findViewById(R.id.tvName);
            TextView tvSubtitle = view.findViewById(R.id.tvSubtitle);
            TextView tvTime = view.findViewById(R.id.tvTime);
            TextView tvBadge = view.findViewById(R.id.tvBadge);
            View onlineDot = view.findViewById(R.id.onlineDot);
            View requestButtons = view.findViewById(R.id.requestButtons);

            tvEmoji.setText(contact.emoji != null ? contact.emoji : "👤");
            tvName.setText(contact.name != null ? contact.name : "Unknown");
            tvSubtitle.setText(contact.lastMessage != null ? contact.lastMessage : "Tap to chat");

            if (contact.lastMessageTime > 0) {
                tvTime.setText(formatTime(contact.lastMessageTime));
            } else {
                tvTime.setText("");
            }

            onlineDot.setVisibility(View.VISIBLE);
            onlineDot.setBackgroundResource(contact.online ? R.drawable.online_dot : R.drawable.offline_dot);

            if (contact.unreadCount > 0) {
                tvBadge.setVisibility(View.VISIBLE);
                tvBadge.setText(String.valueOf(contact.unreadCount));
            } else {
                tvBadge.setVisibility(View.GONE);
            }

            requestButtons.setVisibility(View.GONE);
            view.setOnClickListener(v -> showChatView(contact));
        });
        chatsAdapter.setItems(contactsList);
        mainRecyclerView.setAdapter(chatsAdapter);
    }

    private void showUpdatesList() {
        updatesAdapter = new GenericAdapter<>(R.layout.item_list, (view, request, pos) -> {
            TextView tvEmoji = view.findViewById(R.id.tvEmoji);
            TextView tvName = view.findViewById(R.id.tvName);
            TextView tvSubtitle = view.findViewById(R.id.tvSubtitle);
            TextView tvTime = view.findViewById(R.id.tvTime);
            TextView tvBadge = view.findViewById(R.id.tvBadge);
            View onlineDot = view.findViewById(R.id.onlineDot);
            View requestButtons = view.findViewById(R.id.requestButtons);

            tvEmoji.setText(request.fromEmoji != null ? request.fromEmoji : "👤");
            tvName.setText(request.fromName != null ? request.fromName : "Unknown");
            tvSubtitle.setText("Friend request • " + request.fromFriendId);
            tvTime.setText(formatTime(request.timestamp));
            tvBadge.setVisibility(View.GONE);
            onlineDot.setVisibility(View.GONE);

            requestButtons.setVisibility(View.VISIBLE);
            view.findViewById(R.id.btnAcceptRequest).setOnClickListener(v ->
                    acceptFriendRequest(request));
            view.findViewById(R.id.btnRejectRequest).setOnClickListener(v ->
                    rejectFriendRequest(request));
        });
        updatesAdapter.setItems(requestsList);
        mainRecyclerView.setAdapter(updatesAdapter);
    }

    private void showCallsList() {
        callsAdapter = new GenericAdapter<>(R.layout.item_list, (view, record, pos) -> {
            TextView tvEmoji = view.findViewById(R.id.tvEmoji);
            TextView tvName = view.findViewById(R.id.tvName);
            TextView tvSubtitle = view.findViewById(R.id.tvSubtitle);
            TextView tvTime = view.findViewById(R.id.tvTime);
            TextView tvBadge = view.findViewById(R.id.tvBadge);
            View onlineDot = view.findViewById(R.id.onlineDot);
            View requestButtons = view.findViewById(R.id.requestButtons);

            tvEmoji.setText(record.partnerEmoji != null ? record.partnerEmoji : "👤");
            tvName.setText(record.partnerName != null ? record.partnerName : "Unknown");
            String icon = "video".equals(record.type) ? "📹" : "📞";
            String dir = "incoming".equals(record.direction) ? "↙" : "↗";
            tvSubtitle.setText(dir + " " + icon + " " + formatDuration(record.duration));
            tvTime.setText(formatTime(record.timestamp));
            tvBadge.setVisibility(View.GONE);
            onlineDot.setVisibility(View.GONE);
            requestButtons.setVisibility(View.GONE);
        });
        callsAdapter.setItems(callsList);
        mainRecyclerView.setAdapter(callsAdapter);
    }

    // ── FIREBASE LISTENERS ────────────────────────────────────────────────────

    private void setupContactsListener() {
        if (myUid == null) return;
        contactsListener = db.child("users").child(myUid).child("contacts")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        contactsList.clear();
                        for (DataSnapshot child : snap.getChildren()) {
                            Contact c = new Contact();
                            c.uid = child.getKey();
                            c.name = child.child("name").getValue(String.class);
                            c.emoji = child.child("emoji").getValue(String.class);
                            c.friendId = child.child("friendId").getValue(String.class);
                            Long unread = child.child("unread").getValue(Long.class);
                            c.unreadCount = unread != null ? unread.intValue() : 0;
                            c.lastMessage = child.child("lastMessage").getValue(String.class);
                            Long lmt = child.child("lastMessageTime").getValue(Long.class);
                            c.lastMessageTime = lmt != null ? lmt : 0;
                            // Fetch online status
                            fetchOnlineStatus(c);
                            contactsList.add(c);
                        }
                        if (currentTab == 0) refreshMainList();
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void fetchOnlineStatus(Contact c) {
        db.child("users").child(c.uid).child("online")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        Boolean online = snap.getValue(Boolean.class);
                        c.online = online != null && online;
                        if (currentTab == 0 && chatsAdapter != null) {
                            chatsAdapter.notifyDataSetChanged();
                        }
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void setupRequestsListener() {
        if (myUid == null) return;
        requestsListener = db.child("users").child(myUid).child("requests")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        requestsList.clear();
                        for (DataSnapshot child : snap.getChildren()) {
                            FriendRequest req = new FriendRequest();
                            req.fromUid = child.child("fromUid").getValue(String.class);
                            req.fromName = child.child("fromName").getValue(String.class);
                            req.fromEmoji = child.child("fromEmoji").getValue(String.class);
                            req.fromFriendId = child.child("fromFriendId").getValue(String.class);
                            Long ts = child.child("timestamp").getValue(Long.class);
                            req.timestamp = ts != null ? ts : 0;
                            req.status = child.child("status").getValue(String.class);
                            if ("pending".equals(req.status)) {
                                requestsList.add(req);
                            }
                        }

                        // Update badge
                        int count = requestsList.size();
                        BadgeDrawable badge = bottomNav.getOrCreateBadge(R.id.nav_updates);
                        if (count > 0) {
                            badge.setVisible(true);
                            badge.setNumber(count);
                        } else {
                            badge.setVisible(false);
                        }

                        if (currentTab == 1) refreshMainList();
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void setupCallHistoryListener() {
        if (myUid == null) return;
        callHistoryListener = db.child("users").child(myUid).child("call_history")
                .orderByChild("timestamp").limitToLast(50)
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        callsList.clear();
                        for (DataSnapshot child : snap.getChildren()) {
                            CallRecord r = new CallRecord();
                            r.partnerId = child.child("partnerId").getValue(String.class);
                            r.partnerName = child.child("partnerName").getValue(String.class);
                            r.partnerEmoji = child.child("partnerEmoji").getValue(String.class);
                            r.type = child.child("type").getValue(String.class);
                            r.direction = child.child("direction").getValue(String.class);
                            Long ts = child.child("timestamp").getValue(Long.class);
                            r.timestamp = ts != null ? ts : 0;
                            Long dur = child.child("duration").getValue(Long.class);
                            r.duration = dur != null ? dur : 0;
                            callsList.add(0, r);
                        }
                        if (currentTab == 2) refreshMainList();
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void setupIncomingCallListener() {
        if (myUid == null) return;
        incomingCallListener = db.child("calls").child(myUid)
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        if (!snap.exists()) return;
                        String callerId = snap.child("callerId").getValue(String.class);
                        if (callerId == null || callerId.equals(myUid)) return;
                        Boolean accepted = snap.child("accepted").getValue(Boolean.class);
                        if (accepted != null && accepted) return;
                        if (isCallActive) return;

                        Boolean isVideo = snap.child("isVideo").getValue(Boolean.class);
                        boolean video = isVideo != null && isVideo;

                        db.child("users").child(callerId).addListenerForSingleValueEvent(
                                new ValueEventListener() {
                                    @Override
                                    public void onDataChange(@NonNull DataSnapshot userSnap) {
                                        String name = userSnap.child("name").getValue(String.class);
                                        String emoji = userSnap.child("emoji").getValue(String.class);
                                        if (name == null) name = "Unknown";
                                        if (emoji == null) emoji = "👤";
                                        final String fn = name, fe = emoji;
                                        handler.post(() ->
                                                showCallView(callerId, fn, fe, true, video));
                                    }
                                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                                });
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    // ── CHAT ──────────────────────────────────────────────────────────────────

    private void loadMessages() {
        if (chatPartnerUid == null || myUid == null) return;

        String chatId = getChatId(myUid, chatPartnerUid);
        LinearLayoutManager llm = new LinearLayoutManager(this);
        llm.setStackFromEnd(true);
        chatRecyclerView.setLayoutManager(llm);

        GenericAdapter<ChatMessage> msgAdapter = new GenericAdapter<>(R.layout.item_message,
                (view, msg, pos) -> {
                    View outgoing = view.findViewById(R.id.outgoingLayout);
                    View incoming = view.findViewById(R.id.incomingLayout);
                    TextView tvOut = view.findViewById(R.id.tvMsgOut);
                    TextView tvTOut = view.findViewById(R.id.tvTimeOut);
                    TextView tvIn = view.findViewById(R.id.tvMsgIn);
                    TextView tvTIn = view.findViewById(R.id.tvTimeIn);

                    if (msg.isOutgoing) {
                        outgoing.setVisibility(View.VISIBLE);
                        incoming.setVisibility(View.GONE);
                        tvOut.setText(msg.text);
                        tvTOut.setText(formatTime(msg.timestamp));
                    } else {
                        outgoing.setVisibility(View.GONE);
                        incoming.setVisibility(View.VISIBLE);
                        tvIn.setText(msg.text);
                        tvTIn.setText(formatTime(msg.timestamp));
                    }
                });

        chatRecyclerView.setAdapter(msgAdapter);

        Query q = db.child("messages").child(chatId).orderByChild("timestamp").limitToLast(50);
        if (messagesListener != null) {
            db.child("messages").child(chatId).removeEventListener(messagesListener);
        }
        messagesListener = q.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snap) {
                List<ChatMessage> msgs = new ArrayList<>();
                for (DataSnapshot child : snap.getChildren()) {
                    ChatMessage m = new ChatMessage();
                    m.id = child.getKey();
                    m.senderId = child.child("senderId").getValue(String.class);
                    m.text = child.child("text").getValue(String.class);
                    Long ts = child.child("timestamp").getValue(Long.class);
                    m.timestamp = ts != null ? ts : 0;
                    m.isOutgoing = myUid.equals(m.senderId);
                    if (m.text != null) msgs.add(m);
                }
                msgAdapter.setItems(msgs);
                if (!msgs.isEmpty()) {
                    chatRecyclerView.scrollToPosition(msgs.size() - 1);
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }

    private void listenPartnerStatus() {
        if (chatPartnerUid == null) return;
        if (partnerStatusListener != null) {
            db.child("users").child(chatPartnerUid).child("online")
                    .removeEventListener(partnerStatusListener);
        }
        partnerStatusListener = db.child("users").child(chatPartnerUid).child("online")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        Boolean online = snap.getValue(Boolean.class);
                        if (tvChatStatus != null) {
                            tvChatStatus.setText(online != null && online ? "online" : "offline");
                        }
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void sendMessage() {
        if (chatPartnerUid == null || myUid == null) return;
        String text = etMessage.getText() != null ? etMessage.getText().toString().trim() : "";
        if (text.isEmpty()) return;

        etMessage.setText("");
        String chatId = getChatId(myUid, chatPartnerUid);

        Map<String, Object> msg = new HashMap<>();
        msg.put("senderId", myUid);
        msg.put("text", text);
        msg.put("timestamp", ServerValue.TIMESTAMP);

        db.child("messages").child(chatId).push().setValue(msg);

        // Update last message on sender's contact
        Map<String, Object> senderContact = new HashMap<>();
        senderContact.put("lastMessage", text);
        senderContact.put("lastMessageTime", ServerValue.TIMESTAMP);
        db.child("users").child(myUid).child("contacts").child(chatPartnerUid)
                .updateChildren(senderContact);

        // Increment unread count on receiver's contact
        db.child("users").child(chatPartnerUid).child("contacts").child(myUid)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        Long current = snap.child("unread").getValue(Long.class);
                        long newCount = (current != null ? current : 0) + 1;
                        Map<String, Object> updates = new HashMap<>();
                        updates.put("unread", newCount);
                        updates.put("lastMessage", text);
                        updates.put("lastMessageTime", ServerValue.TIMESTAMP);
                        // Make sure sender info is there
                        if (myProfile != null) {
                            updates.put("name", myProfile.name);
                            updates.put("emoji", myProfile.emoji);
                            updates.put("friendId", myProfile.friendId);
                        }
                        db.child("users").child(chatPartnerUid).child("contacts")
                                .child(myUid).updateChildren(updates);
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void clearUnreadCount(String partnerUid) {
        if (myUid == null) return;
        db.child("users").child(myUid).child("contacts").child(partnerUid)
                .child("unread").setValue(0);
    }

    private String getChatId(String uid1, String uid2) {
        return uid1.compareTo(uid2) < 0 ? uid1 + "_" + uid2 : uid2 + "_" + uid1;
    }

    // ── CALLS ─────────────────────────────────────────────────────────────────

    private void startCall(boolean isVideo) {
        if (chatPartnerUid == null || myProfile == null) return;
        callIsVideo = isVideo;

        if (!hasCallPermissions(isVideo)) {
            requestCallPermissions(isVideo);
            return;
        }

        String pName = chatPartner != null ? chatPartner.name : "Unknown";
        String pEmoji = chatPartner != null ? chatPartner.emoji : "👤";

        showCallView(chatPartnerUid, pName, pEmoji, false, isVideo);

        // Write call invitation to Firebase
        Map<String, Object> callData = new HashMap<>();
        callData.put("callerId", myUid);
        callData.put("callerName", myProfile.name);
        callData.put("callerEmoji", myProfile.emoji);
        callData.put("calleeId", chatPartnerUid);
        callData.put("isVideo", isVideo);
        callData.put("timestamp", ServerValue.TIMESTAMP);
        db.child("calls").child(chatPartnerUid).setValue(callData);

        initWebRTCAndCall(chatPartnerUid, true, isVideo);
    }

    private void acceptIncomingCall() {
        if (callPartnerUid == null) return;
        if (!hasCallPermissions(callIsVideo)) {
            requestCallPermissions(callIsVideo);
            return;
        }
        btnAcceptLayout.setVisibility(View.GONE);
        tvCallStatus.setText("Connecting…");
        initWebRTCAndReceive(callPartnerUid, callIsVideo);
    }

    private void initWebRTCAndCall(String partnerUid, boolean isCaller, boolean isVideo) {
        if (webRTCManager != null) {
            webRTCManager.dispose();
        }
        webRTCManager = new WebRTCManager(this, eglBase);
        webRTCManager.initFactory();
        webRTCManager.setStateListener(new WebRTCManager.CallStateListener() {
            @Override
            public void onCallConnected() {
                handler.post(() -> tvCallStatus.setText("Connected"));
            }
            @Override
            public void onCallEnded() {
                handler.post(() -> endCurrentCall());
            }
            @Override
            public void onRemoteVideoTrack(VideoTrack track) {}
        });
        if (isVideo) {
            webRTCManager.initViews(localVideoView, remoteVideoView);
        }
        webRTCManager.startCall(myUid, partnerUid, isCaller, isVideo);
    }

    private void initWebRTCAndReceive(String partnerUid, boolean isVideo) {
        if (webRTCManager != null) {
            webRTCManager.dispose();
        }
        webRTCManager = new WebRTCManager(this, eglBase);
        webRTCManager.initFactory();
        webRTCManager.setStateListener(new WebRTCManager.CallStateListener() {
            @Override
            public void onCallConnected() {
                handler.post(() -> tvCallStatus.setText("Connected"));
            }
            @Override
            public void onCallEnded() {
                handler.post(() -> endCurrentCall());
            }
            @Override
            public void onRemoteVideoTrack(VideoTrack track) {}
        });
        if (isVideo) {
            webRTCManager.initViews(localVideoView, remoteVideoView);
        }
        webRTCManager.receiveCall(myUid, partnerUid, isVideo);
    }

    private void endCurrentCall() {
        if (!isCallActive) return;
        isCallActive = false;

        long duration = webRTCManager != null ? webRTCManager.getCallDurationSeconds() : 0;

        if (webRTCManager != null) {
            webRTCManager.endCall();
        }

        // Save call record
        if (callPartnerUid != null && myUid != null) {
            saveCallRecord(callPartnerUid, callPartnerName, callPartnerEmoji,
                    callIsVideo ? "video" : "voice",
                    isIncomingCall ? "incoming" : "outgoing", duration);
        }

        callView.setVisibility(View.GONE);

        // Remove call from Firebase
        if (myUid != null) {
            db.child("calls").child(myUid).removeValue();
        }
        if (callPartnerUid != null) {
            db.child("calls").child(callPartnerUid).removeValue();
        }

        callPartnerUid = null;
        callPartnerName = null;
        callPartnerEmoji = null;

        // Return to appropriate view
        if (chatView.getVisibility() == View.VISIBLE) {
            // stay in chat
        } else {
            showMainView();
        }
    }

    private void saveCallRecord(String partnerUid, String partnerName, String partnerEmoji,
                                String type, String direction, long duration) {
        Map<String, Object> record = new HashMap<>();
        record.put("partnerId", partnerUid);
        record.put("partnerName", partnerName != null ? partnerName : "Unknown");
        record.put("partnerEmoji", partnerEmoji != null ? partnerEmoji : "👤");
        record.put("type", type);
        record.put("direction", direction);
        record.put("timestamp", ServerValue.TIMESTAMP);
        record.put("duration", duration);

        db.child("users").child(myUid).child("call_history").push().setValue(record);
    }

    // ── FRIEND REQUESTS ───────────────────────────────────────────────────────

    private void showAddFriendDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        TextInputEditText inputEt = dialogView.findViewById(R.id.etInput);
        com.google.android.material.textfield.TextInputLayout til = dialogView.findViewById(R.id.tilInput);
        til.setHint("Enter jg-XXXX ID");

        AlertDialog dialog = new AlertDialog.Builder(this)
                .setTitle("Add Friend")
                .setView(dialogView)
                .setPositiveButton("Send Request", null)
                .setNegativeButton("Cancel", null)
                .create();

        dialog.setOnShowListener(d -> {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
                String friendId = inputEt.getText() != null ?
                        inputEt.getText().toString().trim().toUpperCase() : "";
                if (friendId.isEmpty()) return;
                if (!friendId.startsWith("JG-")) friendId = "JG-" + friendId;
                // Normalize
                friendId = "jg-" + friendId.substring(3);
                sendFriendRequest(friendId, dialog,
                        (TextView) dialogView.findViewById(R.id.tvDialogMessage));
            });
        });
        dialog.show();
    }

    private void sendFriendRequest(String friendId, AlertDialog dialog, TextView errorView) {
        if (myProfile == null) return;
        if (friendId.equals(myProfile.friendId)) {
            if (errorView != null) {
                errorView.setVisibility(View.VISIBLE);
                errorView.setText("That's your own ID!");
            }
            return;
        }

        String finalFriendId = friendId;
        db.child("friendIds").child(friendId).addListenerForSingleValueEvent(
                new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snap) {
                        String targetUid = snap.getValue(String.class);
                        if (targetUid == null) {
                            if (errorView != null) {
                                errorView.setVisibility(View.VISIBLE);
                                errorView.setText("User not found");
                            }
                            return;
                        }

                        Map<String, Object> request = new HashMap<>();
                        request.put("fromUid", myUid);
                        request.put("fromName", myProfile.name);
                        request.put("fromEmoji", myProfile.emoji);
                        request.put("fromFriendId", myProfile.friendId);
                        request.put("timestamp", ServerValue.TIMESTAMP);
                        request.put("status", "pending");

                        db.child("users").child(targetUid).child("requests")
                                .child(myUid).setValue(request)
                                .addOnSuccessListener(v -> {
                                    Toast.makeText(MainActivity.this,
                                            "Friend request sent!", Toast.LENGTH_SHORT).show();
                                    if (dialog != null) dialog.dismiss();
                                })
                                .addOnFailureListener(e -> {
                                    if (errorView != null) {
                                        errorView.setVisibility(View.VISIBLE);
                                        errorView.setText("Failed: " + e.getMessage());
                                    }
                                });
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
    }

    private void acceptFriendRequest(FriendRequest request) {
        if (myUid == null || myProfile == null || request.fromUid == null) return;

        // Add to my contacts
        Map<String, Object> myContact = new HashMap<>();
        myContact.put("name", request.fromName);
        myContact.put("emoji", request.fromEmoji);
        myContact.put("friendId", request.fromFriendId);
        myContact.put("unread", 0);
        myContact.put("lastMessage", "");
        myContact.put("lastMessageTime", 0);
        db.child("users").child(myUid).child("contacts")
                .child(request.fromUid).setValue(myContact);

        // Add me to their contacts
        Map<String, Object> theirContact = new HashMap<>();
        theirContact.put("name", myProfile.name);
        theirContact.put("emoji", myProfile.emoji);
        theirContact.put("friendId", myProfile.friendId);
        theirContact.put("unread", 0);
        theirContact.put("lastMessage", "");
        theirContact.put("lastMessageTime", 0);
        db.child("users").child(request.fromUid).child("contacts")
                .child(myUid).setValue(theirContact);

        // Remove request
        db.child("users").child(myUid).child("requests")
                .child(request.fromUid).removeValue();

        Toast.makeText(this, "Friend added!", Toast.LENGTH_SHORT).show();
    }

    private void rejectFriendRequest(FriendRequest request) {
        if (myUid == null || request.fromUid == null) return;
        db.child("users").child(myUid).child("requests")
                .child(request.fromUid).removeValue();
    }

    // ── PROFILE ───────────────────────────────────────────────────────────────

    private void showProfileDialog() {
        if (myProfile == null) return;
        String msg = myProfile.emoji + " " + myProfile.name + "\nID: " + myProfile.friendId;
        new AlertDialog.Builder(this)
                .setTitle("Your Profile")
                .setMessage(msg)
                .setPositiveButton("Close", null)
                .setNegativeButton("Logout", (d, w) -> logout())
                .show();
    }

    private void logout() {
        setOnlineStatus(false);
        cleanup();
        auth.signOut();
        currentUser = null;
        myUid = null;
        myProfile = null;
        contactsList.clear();
        requestsList.clear();
        callsList.clear();
        showAuthView();
        stopService(new Intent(this, BackgroundService.class));
    }

    private void cleanup() {
        if (myUid != null && db != null) {
            if (contactsListener != null)
                db.child("users").child(myUid).child("contacts").removeEventListener(contactsListener);
            if (requestsListener != null)
                db.child("users").child(myUid).child("requests").removeEventListener(requestsListener);
            if (callHistoryListener != null)
                db.child("users").child(myUid).child("call_history").removeEventListener(callHistoryListener);
            if (incomingCallListener != null)
                db.child("calls").child(myUid).removeEventListener(incomingCallListener);
        }
        if (chatPartnerUid != null && db != null) {
            if (messagesListener != null) {
                String chatId = getChatId(myUid != null ? myUid : "", chatPartnerUid);
                db.child("messages").child(chatId).removeEventListener(messagesListener);
            }
            if (partnerStatusListener != null) {
                db.child("users").child(chatPartnerUid).child("online")
                        .removeEventListener(partnerStatusListener);
            }
        }
    }

    // ── PERMISSIONS ───────────────────────────────────────────────────────────

    private void requestPermissions() {
        List<String> perms = new ArrayList<>();
        perms.add(Manifest.permission.RECORD_AUDIO);
        perms.add(Manifest.permission.CAMERA);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            perms.add(Manifest.permission.POST_NOTIFICATIONS);
        }

        List<String> needed = new ArrayList<>();
        for (String p : perms) {
            if (ContextCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED) {
                needed.add(p);
            }
        }
        if (!needed.isEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toArray(new String[0]), PERM_REQUEST);
        }
    }

    private boolean hasCallPermissions(boolean isVideo) {
        boolean audio = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED;
        if (!isVideo) return audio;
        boolean camera = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED;
        return audio && camera;
    }

    private void requestCallPermissions(boolean isVideo) {
        List<String> perms = new ArrayList<>();
        perms.add(Manifest.permission.RECORD_AUDIO);
        if (isVideo) perms.add(Manifest.permission.CAMERA);
        ActivityCompat.requestPermissions(this, perms.toArray(new String[0]), PERM_REQUEST);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    // ── LIFECYCLE ─────────────────────────────────────────────────────────────

    @Override
    protected void onResume() {
        super.onResume();
        isAppInForeground = true;
        if (myUid != null) setOnlineStatus(true);
    }

    @Override
    protected void onPause() {
        super.onPause();
        isAppInForeground = false;
        if (myUid != null) setOnlineStatus(false);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent == null) return;
        String action = intent.getAction();

        if (CallActionReceiver.ACTION_ACCEPT.equals(action)) {
            String callerId = intent.getStringExtra("callerId");
            String callerName = intent.getStringExtra("callerName");
            String callerEmoji = intent.getStringExtra("callerEmoji");
            boolean isVideo = intent.getBooleanExtra("isVideo", false);
            if (callerId != null && !isCallActive) {
                callPartnerUid = callerId;
                callPartnerName = callerName;
                callPartnerEmoji = callerEmoji;
                callIsVideo = isVideo;
                showCallView(callerId, callerName != null ? callerName : "Unknown",
                        callerEmoji != null ? callerEmoji : "👤", true, isVideo);
                acceptIncomingCall();
            }
        } else if (CallActionReceiver.ACTION_REJECT.equals(action)) {
            String callerId = intent.getStringExtra("callerId");
            if (callerId != null && myUid != null) {
                db.child("calls").child(myUid).removeValue();
                db.child("calls").child(callerId).removeValue();
            }
        } else if (intent.hasExtra("incomingCallUid")) {
            String callerUid = intent.getStringExtra("incomingCallUid");
            String callerName = intent.getStringExtra("callerName");
            String callerEmoji = intent.getStringExtra("callerEmoji");
            boolean isVideo = intent.getBooleanExtra("isVideo", false);
            if (callerUid != null && !isCallActive) {
                showCallView(callerUid,
                        callerName != null ? callerName : "Unknown",
                        callerEmoji != null ? callerEmoji : "👤",
                        true, isVideo);
            }
        } else if (intent.hasExtra("openChatUid")) {
            String uid = intent.getStringExtra("openChatUid");
            if (uid != null && currentUser != null) {
                for (Contact c : contactsList) {
                    if (uid.equals(c.uid)) {
                        showChatView(c);
                        return;
                    }
                }
                // Build minimal contact
                Contact c = new Contact();
                c.uid = uid;
                c.name = "Contact";
                c.emoji = "👤";
                showChatView(c);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cleanup();
        if (webRTCManager != null) webRTCManager.dispose();
        if (eglBase != null) eglBase.release();
    }

    @Override
    public void onBackPressed() {
        if (callView.getVisibility() == View.VISIBLE) {
            // Don't allow back during call
            return;
        }
        if (chatView.getVisibility() == View.VISIBLE) {
            showMainView();
            return;
        }
        super.onBackPressed();
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────

    private void startBackgroundService() {
        Intent serviceIntent = new Intent(this, BackgroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }
    }

    private String getText(TextInputEditText et) {
        return et.getText() != null ? et.getText().toString().trim() : "";
    }

    private void showAuthError(String msg) {
        tvAuthError.setVisibility(View.VISIBLE);
        tvAuthError.setText(msg);
    }

    private String formatTime(long timestamp) {
        if (timestamp == 0) return "";
        Date d = new Date(timestamp);
        long now = System.currentTimeMillis();
        long diff = now - timestamp;
        if (diff < 24 * 60 * 60 * 1000) {
            return new SimpleDateFormat("HH:mm", Locale.getDefault()).format(d);
        } else if (diff < 7 * 24 * 60 * 60 * 1000L) {
            return new SimpleDateFormat("EEE", Locale.getDefault()).format(d);
        } else {
            return new SimpleDateFormat("dd/MM", Locale.getDefault()).format(d);
        }
    }

    private String formatDuration(long seconds) {
        if (seconds < 60) return seconds + "s";
        long m = seconds / 60;
        long s = seconds % 60;
        return m + "m " + s + "s";
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# ─── BUILD ────────────────────────────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════════════════════

echo "=== Building Java Goat ==="
cd "$PROJECT_ROOT"

export ANDROID_SDK_ROOT="$HOME/android-sdk"
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$JAVA_HOME/bin:$PATH"

# Accept licenses again just in case
yes | sdkmanager --licenses > /dev/null 2>&1 || true

# Final build
./gradlew clean assembleRelease --stacktrace --no-daemon 2>&1 | tail -50

echo ""
echo "=== BUILD COMPLETE ==="
echo "APK location: $PROJECT_ROOT/app/build/outputs/apk/release/app-release.apk"
ls -lh "$PROJECT_ROOT/app/build/outputs/apk/release/" 2>/dev/null || echo "Check build output above"