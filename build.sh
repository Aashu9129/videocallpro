#!/usr/bin/env bash
set -e

export PROJECT_ROOT="$HOME/videocallpro"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

# Create directory structure
mkdir -p app/src/main/java/com/example/callingapp
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/menu
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p app/src/main/res/mipmap-hdpi
mkdir -p app/src/main/res/mipmap-mdpi
mkdir -p app/src/main/res/mipmap-xhdpi
mkdir -p app/src/main/res/mipmap-xxhdpi
mkdir -p app/src/main/res/mipmap-xxxhdpi
mkdir -p app/src/main/res/xml
mkdir -p gradle/wrapper

# ─── google-services.json ───────────────────────────────────────────────────
cat <<'EOF' > app/google-services.json
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

# ─── settings.gradle ────────────────────────────────────────────────────────
cat <<'EOF' > settings.gradle
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

# ─── gradle.properties ──────────────────────────────────────────────────────
cat <<'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
EOF

# ─── root build.gradle ──────────────────────────────────────────────────────
cat <<'EOF' > build.gradle
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

# ─── Generate keystore ──────────────────────────────────────────────────────
keytool -genkeypair -v \
  -keystore app/javagoat-release.jks \
  -alias javagoat \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass javagoat123 \
  -keypass javagoat123 \
  -dname "CN=JavaGoat,OU=Dev,O=JavaGoat,L=City,S=State,C=US" 2>/dev/null || true

# ─── app/build.gradle ───────────────────────────────────────────────────────
cat <<'EOF' > app/build.gradle
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
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'

    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'

    // WebRTC
    implementation 'io.getstream:stream-webrtc-android:1.1.1'

    // Glide
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    annotationProcessor 'com.github.bumptech.glide:compiler:4.16.0'
}
EOF

# ─── proguard-rules.pro ─────────────────────────────────────────────────────
cat <<'EOF' > app/proguard-rules.pro
-keep class com.example.callingapp.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
EOF

# ─── gradle/wrapper/gradle-wrapper.properties ───────────────────────────────
cat <<'EOF' > gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# ─── AndroidManifest.xml ────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>

    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.front" android:required="false"/>

    <application
        android:name=".MyApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="Java Goat"
        android:supportsRtl="true"
        android:theme="@style/AppTheme"
        android:usesCleartextTraffic="true"
        tools:targetApi="34">

        <activity
            android:name=".MainActivity"
            android:exported="true"
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
            android:name=".BootReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>

    </application>
</manifest>
EOF

# ─── colors.xml ─────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Primary WhatsApp-inspired dark teal -->
    <color name="colorPrimary">#075E54</color>
    <color name="colorPrimaryDark">#054D44</color>
    <color name="colorAccent">#25D366</color>

    <!-- Backgrounds -->
    <color name="bg_main">#ECE5DD</color>
    <color name="bg_card">#FFFFFF</color>
    <color name="bg_dark">#1A1A2E</color>
    <color name="bg_surface">#F0F2F5</color>

    <!-- Neumorphism -->
    <color name="neuro_bg">#E8EDF2</color>
    <color name="neuro_shadow_dark">#B8C0CC</color>
    <color name="neuro_shadow_light">#FFFFFF</color>

    <!-- Text -->
    <color name="text_primary">#1A1A1A</color>
    <color name="text_secondary">#667781</color>
    <color name="text_hint">#999999</color>
    <color name="text_white">#FFFFFF</color>
    <color name="text_orange">#FF6B35</color>
    <color name="text_blue">#0077FF</color>

    <!-- Message bubbles -->
    <color name="msg_out_bg">#DCF8C6</color>
    <color name="msg_in_bg">#FFFFFF</color>
    <color name="msg_out_text">#1A1A1A</color>
    <color name="msg_in_text">#1A1A1A</color>
    <color name="msg_time_color">#888888</color>

    <!-- Call buttons -->
    <color name="call_accept">#25D366</color>
    <color name="call_decline">#FF3B30</color>
    <color name="call_mute">#FF9500</color>
    <color name="call_video">#007AFF</color>
    <color name="call_bg">#1C1C1E</color>

    <!-- Status -->
    <color name="online_color">#25D366</color>
    <color name="offline_color">#999999</color>
    <color name="unread_badge">#25D366</color>

    <!-- Navigation -->
    <color name="nav_selected">#25D366</color>
    <color name="nav_unselected">#90CAF9</color>
    <color name="toolbar_bg">#075E54</color>

    <!-- Friend request -->
    <color name="accept_color">#25D366</color>
    <color name="reject_color">#FF3B30</color>

    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="transparent">#00000000</color>
    <color name="divider">#E0E0E0</color>
    <color name="ripple">#1F000000</color>
</resources>
EOF

# ─── styles.xml ─────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/styles.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
        <item name="colorPrimary">@color/colorPrimary</item>
        <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
        <item name="colorAccent">@color/colorAccent</item>
        <item name="android:windowBackground">@color/bg_surface</item>
        <item name="android:statusBarColor">@color/colorPrimaryDark</item>
    </style>

    <style name="NeumorphCard" parent="Widget.MaterialComponents.CardView">
        <item name="cardElevation">0dp</item>
        <item name="cardBackgroundColor">@color/neuro_bg</item>
        <item name="cardCornerRadius">16dp</item>
    </style>

    <style name="CallButton">
        <item name="android:layout_width">64dp</item>
        <item name="android:layout_height">64dp</item>
        <item name="android:gravity">center</item>
    </style>
</resources>
EOF

# ─── strings.xml ────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Java Goat</string>
    <string name="login">Login</string>
    <string name="register">Register</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="name">Name</string>
    <string name="bio">Bio</string>
    <string name="send">Send</string>
    <string name="chats">Chats</string>
    <string name="updates">Updates</string>
    <string name="calls">Calls</string>
    <string name="search">Search</string>
    <string name="profile">Profile</string>
    <string name="logout">Logout</string>
    <string name="accept">Accept</string>
    <string name="reject">Reject</string>
    <string name="typing">typing…</string>
    <string name="online">online</string>
    <string name="channel_messages">Messages</string>
    <string name="channel_calls">Calls</string>
    <string name="channel_service">Background Service</string>
</resources>
EOF

# ─── dimens.xml ─────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/dimens.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="toolbar_height">56dp</dimen>
    <dimen name="avatar_size">48dp</dimen>
    <dimen name="avatar_size_large">80dp</dimen>
    <dimen name="msg_bubble_radius">12dp</dimen>
    <dimen name="card_radius">16dp</dimen>
    <dimen name="padding_small">8dp</dimen>
    <dimen name="padding_medium">16dp</dimen>
    <dimen name="padding_large">24dp</dimen>
    <dimen name="local_video_width">120dp</dimen>
    <dimen name="local_video_height">160dp</dimen>
    <dimen name="call_btn_size">64dp</dimen>
    <dimen name="neuro_elevation">8dp</dimen>
</resources>
EOF

# ─── msg_out_bg.xml ─────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/msg_out_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_out_bg"/>
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

# ─── msg_in_bg.xml ──────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/msg_in_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_in_bg"/>
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
    <stroke
        android:width="0.5dp"
        android:color="@color/divider"/>
</shape>
EOF

# ─── emoji_bg.xml ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/emoji_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorPrimary"/>
    <size android:width="48dp" android:height="48dp"/>
</shape>
EOF

# ─── bg_neuro.xml ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_neuro.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/neuro_bg"/>
    <corners android:radius="16dp"/>
</shape>
EOF

# ─── bg_circle_green.xml ────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_circle_green.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/call_accept"/>
    <size android:width="64dp" android:height="64dp"/>
</shape>
EOF

# ─── bg_circle_red.xml ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_circle_red.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/call_decline"/>
    <size android:width="64dp" android:height="64dp"/>
</shape>
EOF

# ─── bg_circle_gray.xml ─────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_circle_gray.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#444444"/>
    <size android:width="52dp" android:height="52dp"/>
</shape>
EOF

# ─── bg_input.xml ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_input.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/white"/>
    <corners android:radius="24dp"/>
    <stroke android:width="1dp" android:color="@color/divider"/>
</shape>
EOF

# ─── bg_badge.xml ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/bg_badge.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/unread_badge"/>
    <size android:width="20dp" android:height="20dp"/>
</shape>
EOF

# ─── ic_launcher_background.xml ─────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_background.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#075E54"/>
</shape>
EOF

# ─── ic_launcher_foreground.xml ─────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_foreground.xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <text
            android:fontFamily="sans-serif-black"
            android:text="🐐"
            android:textSize="48sp"/>
    </item>
</layer-list>
EOF

# ─── mipmap adaptive icons ──────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

# Simple PNG placeholders for non-anydpi mipmaps (1x1 green pixel encoded as base64)
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    mkdir -p app/src/main/res/mipmap-$density
    # Write a minimal valid PNG (1x1 green pixel)
    python3 -c "
import base64, os
png = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==')
with open('app/src/main/res/mipmap-$density/ic_launcher.png','wb') as f: f.write(png)
with open('app/src/main/res/mipmap-$density/ic_launcher_round.png','wb') as f: f.write(png)
" 2>/dev/null || true
done

# ─── bottom_nav_menu.xml ────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/menu/bottom_nav_menu.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/nav_chats"
        android:icon="@android:drawable/ic_dialog_email"
        android:title="Chats"/>
    <item
        android:id="@+id/nav_updates"
        android:icon="@android:drawable/ic_menu_recent_history"
        android:title="Updates"/>
    <item
        android:id="@+id/nav_calls"
        android:icon="@android:drawable/ic_menu_call"
        android:title="Calls"/>
</menu>
EOF

# ─── activity_main.xml ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg_surface">

    <!-- AUTH VIEW -->
    <LinearLayout
        android:id="@+id/authContainer"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:gravity="center"
        android:padding="32dp"
        android:background="@color/bg_surface"
        android:visibility="visible">

        <TextView
            android:id="@+id/tvAppTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="🐐 Java Goat"
            android:textSize="32sp"
            android:textStyle="bold"
            android:textColor="@color/colorPrimary"
            android:layout_marginBottom="8dp"/>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Connect. Chat. Call."
            android:textSize="14sp"
            android:textColor="@color/text_secondary"
            android:layout_marginBottom="40dp"/>

        <!-- Login Form -->
        <LinearLayout
            android:id="@+id/loginForm"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:visibility="visible">

            <com.google.android.material.textfield.TextInputLayout
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Email"
                android:layout_marginBottom="12dp">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/loginEmail"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textEmailAddress"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Password"
                android:passwordToggleEnabled="true"
                android:layout_marginBottom="20dp">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/loginPassword"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textPassword"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnLogin"
                android:layout_width="match_parent"
                android:layout_height="56dp"
                android:text="LOGIN"
                android:textSize="16sp"
                android:backgroundTint="@color/colorPrimary"
                android:layout_marginBottom="12dp"/>

            <TextView
                android:id="@+id/tvSwitchToRegister"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Don't have an account? Register"
                android:textColor="@color/colorPrimary"
                android:textSize="14sp"
                android:layout_gravity="center"
                android:padding="8dp"/>
        </LinearLayout>

        <!-- Register Form -->
        <LinearLayout
            android:id="@+id/registerForm"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:visibility="gone">

            <com.google.android.material.textfield.TextInputLayout
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Email"
                android:layout_marginBottom="12dp">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/regEmail"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textEmailAddress"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Password"
                android:passwordToggleEnabled="true"
                android:layout_marginBottom="20dp">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/regPassword"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textPassword"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnRegister"
                android:layout_width="match_parent"
                android:layout_height="56dp"
                android:text="CREATE ACCOUNT"
                android:textSize="16sp"
                android:backgroundTint="@color/colorAccent"
                android:layout_marginBottom="12dp"/>

            <TextView
                android:id="@+id/tvSwitchToLogin"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Already have an account? Login"
                android:textColor="@color/colorPrimary"
                android:textSize="14sp"
                android:layout_gravity="center"
                android:padding="8dp"/>
        </LinearLayout>

    </LinearLayout>

    <!-- MAIN VIEW -->
    <LinearLayout
        android:id="@+id/mainContainer"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:visibility="gone">

        <!-- Toolbar -->
        <androidx.appcompat.widget.Toolbar
            android:id="@+id/mainToolbar"
            android:layout_width="match_parent"
            android:layout_height="56dp"
            android:background="@color/colorPrimary"
            android:elevation="4dp">

            <TextView
                android:id="@+id/tvToolbarTitle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Java Goat"
                android:textSize="20sp"
                android:textStyle="bold"
                android:textColor="@color/white"/>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="end"
                android:layout_marginEnd="8dp">

                <ImageButton
                    android:id="@+id/btnAddFriend"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_input_add"
                    android:tint="@color/white"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="Add Friend"/>

                <ImageButton
                    android:id="@+id/btnMenu"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_menu_more"
                    android:tint="@color/white"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="Menu"/>
            </LinearLayout>
        </androidx.appcompat.widget.Toolbar>

        <FrameLayout
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1">

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/mainRecyclerView"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:padding="0dp"
                android:clipToPadding="false"/>
        </FrameLayout>

        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottomNav"
            android:layout_width="match_parent"
            android:layout_height="56dp"
            android:background="@color/white"
            app:menu="@menu/bottom_nav_menu"
            xmlns:app="http://schemas.android.com/apk/res-auto"/>
    </LinearLayout>

    <!-- CHAT VIEW -->
    <LinearLayout
        android:id="@+id/chatContainer"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:background="@color/bg_main"
        android:visibility="gone">

        <!-- Chat Toolbar -->
        <LinearLayout
            android:id="@+id/chatToolbar"
            android:layout_width="match_parent"
            android:layout_height="60dp"
            android:orientation="horizontal"
            android:background="@color/colorPrimary"
            android:gravity="center_vertical"
            android:padding="8dp"
            android:elevation="4dp">

            <ImageButton
                android:id="@+id/btnChatBack"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_media_previous"
                android:tint="@color/white"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Back"/>

            <TextView
                android:id="@+id/tvChatEmoji"
                android:layout_width="36dp"
                android:layout_height="36dp"
                android:gravity="center"
                android:textSize="22sp"
                android:background="@drawable/emoji_bg"
                android:text="👤"
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
                    android:text="Contact"
                    android:textSize="16sp"
                    android:textStyle="bold"
                    android:textColor="@color/white"/>

                <TextView
                    android:id="@+id/tvChatStatus"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="online"
                    android:textSize="12sp"
                    android:textColor="#CCFFFFFF"/>
            </LinearLayout>

            <ImageButton
                android:id="@+id/btnVoiceCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_call"
                android:tint="@color/white"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Voice Call"/>

            <ImageButton
                android:id="@+id/btnVideoCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_camera"
                android:tint="@color/white"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Video Call"/>
        </LinearLayout>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/chatRecyclerView"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"
            android:padding="8dp"
            android:clipToPadding="false"/>

        <TextView
            android:id="@+id/tvTypingIndicator"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="typing…"
            android:textSize="12sp"
            android:textColor="@color/text_secondary"
            android:paddingStart="16dp"
            android:paddingBottom="2dp"
            android:visibility="gone"/>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:background="@color/white"
            android:padding="8dp"
            android:gravity="center_vertical">

            <EditText
                android:id="@+id/etMessage"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:hint="Type a message…"
                android:background="@drawable/bg_input"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                android:paddingTop="10dp"
                android:paddingBottom="10dp"
                android:maxLines="4"
                android:inputType="textMultiLine"/>

            <ImageButton
                android:id="@+id/btnSend"
                android:layout_width="48dp"
                android:layout_height="48dp"
                android:src="@android:drawable/ic_menu_send"
                android:background="@drawable/bg_circle_green"
                android:tint="@color/white"
                android:layout_marginStart="8dp"
                android:contentDescription="Send"/>
        </LinearLayout>
    </LinearLayout>

    <!-- CALL VIEW -->
    <FrameLayout
        android:id="@+id/callContainer"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/call_bg"
        android:visibility="gone">

        <!-- Remote video full screen -->
        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/remoteVideoView"
            android:layout_width="match_parent"
            android:layout_height="match_parent"/>

        <!-- Caller info overlay -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:gravity="center_horizontal"
            android:layout_gravity="top"
            android:paddingTop="60dp"
            android:paddingBottom="20dp"
            android:background="#99000000">

            <TextView
                android:id="@+id/tvCallEmoji"
                android:layout_width="96dp"
                android:layout_height="96dp"
                android:gravity="center"
                android:textSize="48sp"
                android:text="👤"
                android:background="@drawable/emoji_bg"/>

            <TextView
                android:id="@+id/tvCallName"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Calling…"
                android:textSize="24sp"
                android:textStyle="bold"
                android:textColor="@color/white"
                android:layout_marginTop="12dp"/>

            <TextView
                android:id="@+id/tvCallStatus"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Ringing…"
                android:textSize="16sp"
                android:textColor="#CCFFFFFF"
                android:layout_marginTop="6dp"/>

            <TextView
                android:id="@+id/tvCallDuration"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="00:00"
                android:textSize="18sp"
                android:textColor="@color/white"
                android:layout_marginTop="4dp"
                android:visibility="gone"/>
        </LinearLayout>

        <!-- Local video pip -->
        <FrameLayout
            android:layout_width="120dp"
            android:layout_height="160dp"
            android:layout_gravity="top|end"
            android:layout_margin="16dp"
            android:layout_marginTop="80dp">

            <org.webrtc.SurfaceViewRenderer
                android:id="@+id/localVideoView"
                android:layout_width="match_parent"
                android:layout_height="match_parent"/>
        </FrameLayout>

        <!-- Controls -->
        <LinearLayout
            android:id="@+id/callControlsLayout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:gravity="center"
            android:layout_gravity="bottom"
            android:paddingBottom="60dp"
            android:paddingTop="20dp"
            android:background="#99000000">

            <!-- Toggle controls row -->
            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center"
                android:layout_marginBottom="24dp">

                <LinearLayout
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center"
                    android:layout_marginEnd="20dp">
                    <ImageButton
                        android:id="@+id/btnMute"
                        android:layout_width="52dp"
                        android:layout_height="52dp"
                        android:src="@android:drawable/ic_lock_silent_mode"
                        android:background="@drawable/bg_circle_gray"
                        android:tint="@color/white"
                        android:contentDescription="Mute"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Mute"
                        android:textColor="@color/white"
                        android:textSize="11sp"
                        android:layout_marginTop="4dp"/>
                </LinearLayout>

                <LinearLayout
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center"
                    android:layout_marginEnd="20dp">
                    <ImageButton
                        android:id="@+id/btnCameraToggle"
                        android:layout_width="52dp"
                        android:layout_height="52dp"
                        android:src="@android:drawable/ic_menu_camera"
                        android:background="@drawable/bg_circle_gray"
                        android:tint="@color/white"
                        android:contentDescription="Camera"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Camera"
                        android:textColor="@color/white"
                        android:textSize="11sp"
                        android:layout_marginTop="4dp"/>
                </LinearLayout>

                <LinearLayout
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center"
                    android:layout_marginEnd="20dp">
                    <ImageButton
                        android:id="@+id/btnFlipCamera"
                        android:layout_width="52dp"
                        android:layout_height="52dp"
                        android:src="@android:drawable/ic_menu_rotate"
                        android:background="@drawable/bg_circle_gray"
                        android:tint="@color/white"
                        android:contentDescription="Flip Camera"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Flip"
                        android:textColor="@color/white"
                        android:textSize="11sp"
                        android:layout_marginTop="4dp"/>
                </LinearLayout>

                <LinearLayout
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center">
                    <ImageButton
                        android:id="@+id/btnSpeaker"
                        android:layout_width="52dp"
                        android:layout_height="52dp"
                        android:src="@android:drawable/ic_lock_silent_mode_off"
                        android:background="@drawable/bg_circle_gray"
                        android:tint="@color/white"
                        android:contentDescription="Speaker"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Speaker"
                        android:textColor="@color/white"
                        android:textSize="11sp"
                        android:layout_marginTop="4dp"/>
                </LinearLayout>
            </LinearLayout>

            <!-- Accept / End row -->
            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center">

                <LinearLayout
                    android:id="@+id/btnAcceptCall"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center"
                    android:layout_marginEnd="60dp"
                    android:visibility="gone">
                    <ImageButton
                        android:layout_width="68dp"
                        android:layout_height="68dp"
                        android:src="@android:drawable/ic_menu_call"
                        android:background="@drawable/bg_circle_green"
                        android:tint="@color/white"
                        android:contentDescription="Accept"
                        android:clickable="false"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Accept"
                        android:textColor="@color/white"
                        android:textSize="12sp"
                        android:layout_marginTop="6dp"/>
                </LinearLayout>

                <LinearLayout
                    android:id="@+id/btnEndCall"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:gravity="center">
                    <ImageButton
                        android:layout_width="68dp"
                        android:layout_height="68dp"
                        android:src="@android:drawable/ic_delete"
                        android:background="@drawable/bg_circle_red"
                        android:tint="@color/white"
                        android:contentDescription="End"
                        android:clickable="false"/>
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="End"
                        android:textColor="@color/white"
                        android:textSize="12sp"
                        android:layout_marginTop="6dp"/>
                </LinearLayout>
            </LinearLayout>
        </LinearLayout>
    </FrameLayout>

    <!-- PROFILE VIEW -->
    <ScrollView
        android:id="@+id/profileContainer"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/bg_surface"
        android:visibility="gone">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="56dp"
                android:orientation="horizontal"
                android:background="@color/colorPrimary"
                android:gravity="center_vertical"
                android:padding="8dp">

                <ImageButton
                    android:id="@+id/btnProfileBack"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_media_previous"
                    android:tint="@color/white"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="Back"/>

                <TextView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Profile"
                    android:textSize="18sp"
                    android:textStyle="bold"
                    android:textColor="@color/white"
                    android:layout_marginStart="8dp"/>

                <ImageButton
                    android:id="@+id/btnEditProfile"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:src="@android:drawable/ic_menu_edit"
                    android:tint="@color/white"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="Edit"/>
            </LinearLayout>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:gravity="center_horizontal"
                android:padding="24dp"
                android:background="@color/colorPrimary">

                <FrameLayout
                    android:layout_width="96dp"
                    android:layout_height="96dp">

                    <TextView
                        android:id="@+id/tvProfileEmoji"
                        android:layout_width="96dp"
                        android:layout_height="96dp"
                        android:gravity="center"
                        android:textSize="48sp"
                        android:text="👤"
                        android:background="@drawable/emoji_bg"/>

                    <ImageView
                        android:id="@+id/ivProfileImage"
                        android:layout_width="96dp"
                        android:layout_height="96dp"
                        android:scaleType="centerCrop"
                        android:visibility="gone"/>
                </FrameLayout>

                <TextView
                    android:id="@+id/tvProfileName"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Your Name"
                    android:textSize="22sp"
                    android:textStyle="bold"
                    android:textColor="@color/white"
                    android:layout_marginTop="12dp"/>

                <TextView
                    android:id="@+id/tvProfileBio"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Bio here"
                    android:textSize="14sp"
                    android:textColor="#CCFFFFFF"
                    android:layout_marginTop="4dp"/>
            </LinearLayout>

            <androidx.cardview.widget.CardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_margin="16dp"
                app:cardCornerRadius="12dp"
                app:cardElevation="2dp"
                xmlns:app="http://schemas.android.com/apk/res-auto">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:padding="16dp">

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Your UID"
                        android:textSize="12sp"
                        android:textColor="@color/text_secondary"/>

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:orientation="horizontal"
                        android:gravity="center_vertical"
                        android:layout_marginTop="4dp">

                        <TextView
                            android:id="@+id/tvProfileUid"
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:text="00000"
                            android:textSize="28sp"
                            android:textStyle="bold"
                            android:textColor="@color/colorPrimary"
                            android:letterSpacing="0.2"/>

                        <com.google.android.material.button.MaterialButton
                            android:id="@+id/btnCopyUid"
                            style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Copy"
                            android:textSize="12sp"/>
                    </LinearLayout>

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Share this UID with friends so they can find you"
                        android:textSize="11sp"
                        android:textColor="@color/text_hint"
                        android:layout_marginTop="4dp"/>
                </LinearLayout>
            </androidx.cardview.widget.CardView>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnChangePhoto"
                android:layout_width="match_parent"
                android:layout_height="48dp"
                android:layout_marginStart="16dp"
                android:layout_marginEnd="16dp"
                android:layout_marginBottom="8dp"
                android:text="Change Profile Photo"
                style="@style/Widget.MaterialComponents.Button.OutlinedButton"/>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnLogout"
                android:layout_width="match_parent"
                android:layout_height="48dp"
                android:layout_marginStart="16dp"
                android:layout_marginEnd="16dp"
                android:layout_marginBottom="16dp"
                android:text="Logout"
                android:backgroundTint="@color/call_decline"
                android:textColor="@color/white"/>
        </LinearLayout>
    </ScrollView>

</FrameLayout>
EOF

# ─── item_list.xml ──────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/item_list.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginStart="8dp"
    android:layout_marginEnd="8dp"
    android:layout_marginTop="4dp"
    app:cardCornerRadius="12dp"
    app:cardElevation="2dp"
    app:cardBackgroundColor="@color/white">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="12dp"
        android:gravity="center_vertical">

        <FrameLayout
            android:layout_width="52dp"
            android:layout_height="52dp">

            <TextView
                android:id="@+id/tvItemEmoji"
                android:layout_width="52dp"
                android:layout_height="52dp"
                android:gravity="center"
                android:textSize="26sp"
                android:text="👤"
                android:background="@drawable/emoji_bg"/>

            <View
                android:id="@+id/vOnlineIndicator"
                android:layout_width="12dp"
                android:layout_height="12dp"
                android:background="@drawable/bg_circle_green"
                android:layout_gravity="bottom|end"
                android:visibility="gone"/>
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:layout_marginStart="12dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical">

                <TextView
                    android:id="@+id/tvItemName"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Contact Name"
                    android:textSize="16sp"
                    android:textStyle="bold"
                    android:textColor="@color/text_primary"
                    android:ellipsize="end"
                    android:maxLines="1"/>

                <TextView
                    android:id="@+id/tvItemTime"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="12:00"
                    android:textSize="11sp"
                    android:textColor="@color/text_secondary"/>
            </LinearLayout>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical"
                android:layout_marginTop="2dp">

                <TextView
                    android:id="@+id/tvItemPreview"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Last message…"
                    android:textSize="13sp"
                    android:textColor="@color/text_secondary"
                    android:ellipsize="end"
                    android:maxLines="1"/>

                <TextView
                    android:id="@+id/tvUnreadCount"
                    android:layout_width="20dp"
                    android:layout_height="20dp"
                    android:gravity="center"
                    android:text="1"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/bg_badge"
                    android:visibility="gone"/>
            </LinearLayout>
        </LinearLayout>
    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

# ─── item_message.xml ───────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/item_message.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:padding="2dp">

    <!-- Incoming message (left) -->
    <LinearLayout
        android:id="@+id/layoutMsgIn"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:layout_gravity="start"
        android:maxWidth="280dp"
        android:visibility="gone">

        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:background="@drawable/msg_in_bg">

            <TextView
                android:id="@+id/tvReplyIn"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text=""
                android:textSize="11sp"
                android:textColor="@color/colorPrimary"
                android:background="#22075E54"
                android:padding="4dp"
                android:visibility="gone"/>

            <TextView
                android:id="@+id/tvMsgTextIn"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Hello!"
                android:textSize="15sp"
                android:textColor="@color/msg_in_text"/>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="end">

                <TextView
                    android:id="@+id/tvMsgTimeIn"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="12:00"
                    android:textSize="10sp"
                    android:textColor="@color/msg_time_color"/>
            </LinearLayout>
        </LinearLayout>

        <TextView
            android:id="@+id/tvReactionIn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text=""
            android:textSize="16sp"
            android:background="@color/transparent"
            android:visibility="gone"/>
    </LinearLayout>

    <!-- Outgoing message (right) -->
    <LinearLayout
        android:id="@+id/layoutMsgOut"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:layout_gravity="end"
        android:maxWidth="280dp"
        android:visibility="gone">

        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:background="@drawable/msg_out_bg">

            <TextView
                android:id="@+id/tvReplyOut"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text=""
                android:textSize="11sp"
                android:textColor="@color/colorPrimary"
                android:background="#22075E54"
                android:padding="4dp"
                android:visibility="gone"/>

            <TextView
                android:id="@+id/tvMsgTextOut"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Hello!"
                android:textSize="15sp"
                android:textColor="@color/msg_out_text"/>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="end">

                <TextView
                    android:id="@+id/tvMsgTimeOut"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="12:00"
                    android:textSize="10sp"
                    android:textColor="@color/msg_time_color"
                    android:layout_marginEnd="4dp"/>

                <TextView
                    android:id="@+id/tvMsgStatus"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="✓"
                    android:textSize="11sp"
                    android:textColor="@color/msg_time_color"/>
            </LinearLayout>
        </LinearLayout>

        <TextView
            android:id="@+id/tvReactionOut"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text=""
            android:textSize="16sp"
            android:background="@color/transparent"
            android:layout_gravity="end"
            android:visibility="gone"/>
    </LinearLayout>
</FrameLayout>
EOF

# ─── dialog_input.xml ───────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/dialog_input.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="24dp">

    <TextView
        android:id="@+id/tvDialogTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Enter details"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="@color/text_primary"
        android:layout_marginBottom="16dp"/>

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilInput1"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Name"
        android:layout_marginBottom="12dp">
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput1"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="textPersonName"/>
    </com.google.android.material.textfield.TextInputLayout>

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilInput2"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Bio"
        android:layout_marginBottom="12dp">
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput2"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="textMultiLine"
            android:maxLines="3"/>
    </com.google.android.material.textfield.TextInputLayout>

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilInput3"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Emoji (paste one emoji)"
        android:layout_marginBottom="8dp">
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput3"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="text"
            android:maxLength="4"/>
    </com.google.android.material.textfield.TextInputLayout>

</LinearLayout>
EOF

# ─── MyApplication.java ─────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/MyApplication.java
package com.example.callingapp;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.database.FirebaseDatabase;

public class MyApplication extends Application {

    public static final String CHANNEL_MESSAGES = "ch_messages";
    public static final String CHANNEL_CALLS    = "ch_calls";
    public static final String CHANNEL_SERVICE  = "ch_service";

    @Override
    public void onCreate() {
        super.onCreate();
        initFirebase();
        createNotificationChannels();
        FirebaseDatabase.getInstance().setPersistenceEnabled(true);
    }

    private void initFirebase() {
        if (FirebaseApp.getApps(this).isEmpty()) {
            FirebaseOptions opts = new FirebaseOptions.Builder()
                .setApiKey("AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM")
                .setApplicationId("1:1044955332082:android:2c6e7458b191b9d96eff6b")
                .setDatabaseUrl("https://videocallpro-f5f1b-default-rtdb.firebaseio.com")
                .setProjectId("videocallpro-f5f1b")
                .setStorageBucket("videocallpro-f5f1b.firebasestorage.app")
                .setGcmSenderId("1044955332082")
                .build();
            FirebaseApp.initializeApp(this, opts);
        }
    }

    private void createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = getSystemService(NotificationManager.class);

            NotificationChannel msgs = new NotificationChannel(
                CHANNEL_MESSAGES, "Messages", NotificationManager.IMPORTANCE_HIGH);
            msgs.setDescription("New message notifications");
            nm.createNotificationChannel(msgs);

            NotificationChannel calls = new NotificationChannel(
                CHANNEL_CALLS, "Calls", NotificationManager.IMPORTANCE_HIGH);
            calls.setDescription("Incoming call notifications");
            calls.setLockscreenVisibility(1);
            nm.createNotificationChannel(calls);

            NotificationChannel svc = new NotificationChannel(
                CHANNEL_SERVICE, "Background Service", NotificationManager.IMPORTANCE_LOW);
            svc.setDescription("Keeps app alive for notifications");
            nm.createNotificationChannel(svc);
        }
    }
}
EOF

# ─── BootReceiver.java ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/BootReceiver.java
package com.example.callingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context ctx, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            com.google.firebase.auth.FirebaseAuth auth =
                com.google.firebase.auth.FirebaseAuth.getInstance();
            if (auth.getCurrentUser() != null) {
                Intent svc = new Intent(ctx, BackgroundService.class);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(svc);
                } else {
                    ctx.startService(svc);
                }
            }
        }
    }
}
EOF

# ─── BackgroundService.java ─────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/BackgroundService.java
package com.example.callingapp;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.HashMap;
import java.util.Map;

public class BackgroundService extends Service {

    private static final String TAG = "BgService";
    private static final int NOTIF_ID_SERVICE = 1;
    private static final int NOTIF_ID_MSG     = 2;
    private static final int NOTIF_ID_CALL    = 3;

    private DatabaseReference dbRef;
    private String myUid;
    private ValueEventListener callListener;
    private ValueEventListener friendsListener;
    private boolean isRunning = false;

    @Override
    public void onCreate() {
        super.onCreate();
        dbRef = FirebaseDatabase.getInstance().getReference();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForeground(NOTIF_ID_SERVICE, buildServiceNotification());
        isRunning = true;

        FirebaseAuth auth = FirebaseAuth.getInstance();
        if (auth.getCurrentUser() == null) {
            stopSelf();
            return START_NOT_STICKY;
        }

        dbRef.child("users").orderByChild("firebaseUid")
            .equalTo(auth.getCurrentUser().getUid())
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    for (DataSnapshot child : snap.getChildren()) {
                        myUid = child.getKey();
                        startListeners();
                        break;
                    }
                }
                @Override public void onCancelled(DatabaseError e) {}
            });

        return START_STICKY;
    }

    private void startListeners() {
        if (myUid == null) return;
        listenForIncomingCalls();
        listenForMessages();
    }

    private void listenForIncomingCalls() {
        callListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                if (!snap.exists()) return;
                String status = snap.child("status").getValue(String.class);
                if ("ringing".equals(status) && !MainActivity.isAppInForeground) {
                    String callerName = snap.child("callerName").getValue(String.class);
                    if (callerName == null) callerName = "Unknown";
                    showCallNotification(callerName);
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        dbRef.child("calls").child(myUid).addValueEventListener(callListener);
    }

    private void listenForMessages() {
        friendsListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                if (MainActivity.isAppInForeground) return;
                int totalUnread = 0;
                for (DataSnapshot friend : snap.getChildren()) {
                    Long unread = friend.child("unreadCount").getValue(Long.class);
                    if (unread != null) totalUnread += unread.intValue();
                }
                if (totalUnread > 0) showMessageNotification(totalUnread);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        dbRef.child("chats").child(myUid).addValueEventListener(friendsListener);
    }

    private void showCallNotification(String callerName) {
        Intent fullScreenIntent = new Intent(this, MainActivity.class);
        fullScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        fullScreenIntent.putExtra("action", "incoming_call");
        PendingIntent pi = PendingIntent.getActivity(this, 0, fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Notification n = new NotificationCompat.Builder(this, MyApplication.CHANNEL_CALLS)
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setContentTitle("Incoming Call")
            .setContentText(callerName + " is calling you")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setFullScreenIntent(pi, true)
            .setAutoCancel(true)
            .build();

        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTIF_ID_CALL, n);
    }

    private void showMessageNotification(int count) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Notification n = new NotificationCompat.Builder(this, MyApplication.CHANNEL_MESSAGES)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle("Java Goat")
            .setContentText(count + " unread message" + (count > 1 ? "s" : ""))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pi)
            .setAutoCancel(true)
            .build();

        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTIF_ID_MSG, n);
    }

    private Notification buildServiceNotification() {
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE);
        return new NotificationCompat.Builder(this, MyApplication.CHANNEL_SERVICE)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Java Goat")
            .setContentText("Running in background")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setContentIntent(pi)
            .setOngoing(true)
            .build();
    }

    @Override
    public void onDestroy() {
        isRunning = false;
        if (callListener != null && myUid != null)
            dbRef.child("calls").child(myUid).removeEventListener(callListener);
        if (friendsListener != null && myUid != null)
            dbRef.child("chats").child(myUid).removeEventListener(friendsListener);
        super.onDestroy();
    }

    @Nullable @Override
    public IBinder onBind(Intent intent) { return null; }
}
EOF

# ─── Message.java ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/Message.java
package com.example.callingapp;

public class Message {
    public String id;
    public String senderId;
    public String text;
    public long timestamp;
    public String status; // sent, delivered, seen
    public String reaction;
    public boolean deleted;
    public String replyTo;
    public String replyText;

    public Message() {}

    public Message(String senderId, String text, long timestamp) {
        this.senderId  = senderId;
        this.text      = text;
        this.timestamp = timestamp;
        this.status    = "sent";
        this.deleted   = false;
    }
}
EOF

# ─── User.java ──────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/User.java
package com.example.callingapp;

public class User {
    public String uid;
    public String firebaseUid;
    public String name;
    public String bio;
    public String emoji;
    public String email;
    public String profileImageBase64;
    public boolean online;
    public long lastSeen;
    public long createdAt;

    public User() {}
}
EOF

# ─── ChatMeta.java ──────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/ChatMeta.java
package com.example.callingapp;

public class ChatMeta {
    public String uid;
    public String name;
    public String emoji;
    public String lastMessage;
    public long lastTimestamp;
    public int unreadCount;
    public boolean online;
    public long lastSeen;
    public boolean muted;
    public boolean blocked;
    public String profileImageBase64;

    public ChatMeta() {}
}
EOF

# ─── CallRecord.java ────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/CallRecord.java
package com.example.callingapp;

public class CallRecord {
    public String callId;
    public String callerId;
    public String callerName;
    public String callerEmoji;
    public String receiverId;
    public String type; // voice, video
    public String status; // ringing, accepted, ended, missed
    public long startTime;
    public long endTime;
    public long duration;
    public String offer;
    public String answer;

    public CallRecord() {}
}
EOF

# ─── GenericAdapter.java ────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/GenericAdapter.java
package com.example.callingapp;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class GenericAdapter<T> extends RecyclerView.Adapter<GenericAdapter.VH> {

    public interface Binder<T> {
        void bind(View v, T item, int pos);
    }

    public interface ClickListener<T> {
        void onClick(T item, int pos);
    }

    public interface LongClickListener<T> {
        boolean onLongClick(T item, int pos);
    }

    private final int layoutRes;
    private List<T> items = new ArrayList<>();
    private Binder<T> binder;
    private ClickListener<T> clickListener;
    private LongClickListener<T> longClickListener;

    public GenericAdapter(int layoutRes) {
        this.layoutRes = layoutRes;
    }

    public void setBinder(Binder<T> b)                           { this.binder = b; }
    public void setClickListener(ClickListener<T> l)             { this.clickListener = l; }
    public void setLongClickListener(LongClickListener<T> l)     { this.longClickListener = l; }

    public void setItems(List<T> newItems) {
        items.clear();
        if (newItems != null) items.addAll(newItems);
        notifyDataSetChanged();
    }

    public List<T> getItems() { return items; }

    public void addItem(T item) {
        items.add(item);
        notifyItemInserted(items.size() - 1);
    }

    public void updateItem(int pos, T item) {
        items.set(pos, item);
        notifyItemChanged(pos);
    }

    public void removeItem(int pos) {
        items.remove(pos);
        notifyItemRemoved(pos);
    }

    @NonNull @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(layoutRes, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        T item = items.get(position);
        if (binder != null) binder.bind(holder.itemView, item, position);
        if (clickListener != null)
            holder.itemView.setOnClickListener(v -> clickListener.onClick(item, position));
        if (longClickListener != null)
            holder.itemView.setOnLongClickListener(v -> longClickListener.onLongClick(item, position));
    }

    @Override
    public int getItemCount() { return items.size(); }

    static class VH extends RecyclerView.ViewHolder {
        VH(View v) { super(v); }
    }
}
EOF

# ─── WebRTCManager.java ─────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/java/com/example/callingapp/WebRTCManager.java
package com.example.callingapp;

import android.content.Context;
import android.util.Log;
import org.webrtc.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class WebRTCManager {

    private static final String TAG = "WebRTCManager";

    public interface Callback {
        void onLocalSdpReady(SessionDescription sdp);
        void onIceCandidateReady(IceCandidate candidate);
        void onRemoteVideoTrack(VideoTrack track);
        void onConnectionStateChange(String state);
        void onError(String error);
    }

    private final Context context;
    private final Callback callback;
    private EglBase eglBase;
    private PeerConnectionFactory factory;
    private PeerConnection peerConnection;
    private VideoSource videoSource;
    private VideoTrack localVideoTrack;
    private AudioSource audioSource;
    private AudioTrack localAudioTrack;
    private VideoCapturer videoCapturer;
    private boolean isMuted   = false;
    private boolean isCameraOn = true;
    private boolean isVideoCall;
    private SurfaceViewRenderer localView;
    private SurfaceViewRenderer remoteView;

    public WebRTCManager(Context ctx, Callback cb) {
        this.context  = ctx.getApplicationContext();
        this.callback = cb;
    }

    public void init(boolean videoCall, SurfaceViewRenderer local, SurfaceViewRenderer remote) {
        this.isVideoCall = videoCall;
        this.localView   = local;
        this.remoteView  = remote;

        PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(false)
                .createInitializationOptions());

        eglBase = EglBase.create();

        if (local != null)  { local.init(eglBase.getEglBaseContext(), null);  local.setMirror(true); }
        if (remote != null) { remote.init(eglBase.getEglBaseContext(), null); remote.setMirror(false); }

        DefaultVideoEncoderFactory encoderFactory =
            new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true);
        DefaultVideoDecoderFactory decoderFactory =
            new DefaultVideoDecoderFactory(eglBase.getEglBaseContext());

        PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
        factory = PeerConnectionFactory.builder()
            .setOptions(options)
            .setVideoEncoderFactory(encoderFactory)
            .setVideoDecoderFactory(decoderFactory)
            .createPeerConnectionFactory();

        createPeerConnection();
        createLocalTracks();
    }

    private void createPeerConnection() {
        List<PeerConnection.IceServer> iceServers = Arrays.asList(
            PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer(),
            PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer(),
            PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer()
        );

        PeerConnection.RTCConfiguration config = new PeerConnection.RTCConfiguration(iceServers);
        config.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN;
        config.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY;

        peerConnection = factory.createPeerConnection(config, new PeerConnection.Observer() {
            @Override public void onIceCandidate(IceCandidate candidate) {
                callback.onIceCandidateReady(candidate);
            }
            @Override public void onAddTrack(RtpReceiver receiver, MediaStream[] streams) {
                for (RtpReceiver r : new RtpReceiver[]{receiver}) {
                    MediaStreamTrack track = r.track();
                    if (track instanceof VideoTrack) {
                        VideoTrack vt = (VideoTrack) track;
                        vt.setEnabled(true);
                        callback.onRemoteVideoTrack(vt);
                    }
                }
            }
            @Override public void onConnectionChange(PeerConnection.PeerConnectionState state) {
                callback.onConnectionStateChange(state.toString());
            }
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {}
            @Override public void onIceConnectionChange(PeerConnection.IceConnectionState s) {}
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}
            @Override public void onIceCandidatesRemoved(IceCandidate[] c) {}
            @Override public void onAddStream(MediaStream s) {}
            @Override public void onRemoveStream(MediaStream s) {}
            @Override public void onDataChannel(DataChannel d) {}
            @Override public void onRenegotiationNeeded() {}
        });
    }

    private void createLocalTracks() {
        // Audio
        audioSource    = factory.createAudioSource(new MediaConstraints());
        localAudioTrack = factory.createAudioTrack("audio0", audioSource);
        localAudioTrack.setEnabled(true);
        peerConnection.addTrack(localAudioTrack);

        if (isVideoCall) {
            videoCapturer = createVideoCapturer();
            if (videoCapturer != null) {
                SurfaceTextureHelper helper =
                    SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
                videoSource = factory.createVideoSource(videoCapturer.isScreencast());
                videoCapturer.initialize(helper, context, videoSource.getCapturerObserver());
                videoCapturer.startCapture(1280, 720, 30);
                localVideoTrack = factory.createVideoTrack("video0", videoSource);
                localVideoTrack.setEnabled(true);
                if (localView != null) localVideoTrack.addSink(localView);
                peerConnection.addTrack(localVideoTrack);
            }
        }
    }

    private VideoCapturer createVideoCapturer() {
        Camera2Enumerator enumerator = new Camera2Enumerator(context);
        String[] deviceNames = enumerator.getDeviceNames();
        // Prefer front camera
        for (String name : deviceNames) {
            if (enumerator.isFrontFacing(name)) {
                VideoCapturer cap = enumerator.createCapturer(name, null);
                if (cap != null) return cap;
            }
        }
        for (String name : deviceNames) {
            VideoCapturer cap = enumerator.createCapturer(name, null);
            if (cap != null) return cap;
        }
        return null;
    }

    public void createOffer() {
        if (peerConnection == null) return;
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", isVideoCall ? "true" : "false"));

        peerConnection.createOffer(new SimpleSdpObserver() {
            @Override public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SimpleSdpObserver(), sdp);
                callback.onLocalSdpReady(sdp);
            }
            @Override public void onCreateFailure(String error) { callback.onError(error); }
        }, constraints);
    }

    public void createAnswer() {
        if (peerConnection == null) return;
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", isVideoCall ? "true" : "false"));

        peerConnection.createAnswer(new SimpleSdpObserver() {
            @Override public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SimpleSdpObserver(), sdp);
                callback.onLocalSdpReady(sdp);
            }
            @Override public void onCreateFailure(String error) { callback.onError(error); }
        }, constraints);
    }

    public void setRemoteDescription(SessionDescription sdp) {
        if (peerConnection != null)
            peerConnection.setRemoteDescription(new SimpleSdpObserver(), sdp);
    }

    public void addIceCandidate(IceCandidate candidate) {
        if (peerConnection != null)
            peerConnection.addIceCandidate(candidate);
    }

    public void toggleMute() {
        isMuted = !isMuted;
        if (localAudioTrack != null) localAudioTrack.setEnabled(!isMuted);
    }

    public void toggleCamera() {
        isCameraOn = !isCameraOn;
        if (localVideoTrack != null) localVideoTrack.setEnabled(isCameraOn);
        if (videoCapturer != null) {
            try {
                if (isCameraOn) videoCapturer.startCapture(1280, 720, 30);
                else            videoCapturer.stopCapture();
            } catch (Exception e) { Log.e(TAG, "Camera toggle error", e); }
        }
    }

    public void flipCamera() {
        if (videoCapturer instanceof Camera2Capturer) {
            ((Camera2Capturer) videoCapturer).switchCamera(null);
        }
    }

    public boolean isMuted()   { return isMuted; }
    public boolean isCameraOn(){ return isCameraOn; }

    public void release() {
        try {
            if (videoCapturer != null) { videoCapturer.stopCapture(); videoCapturer.dispose(); }
        } catch (Exception e) { Log.e(TAG, "Capturer stop error", e); }
        if (videoSource    != null) videoSource.dispose();
        if (localView      != null) localView.release();
        if (remoteView     != null) remoteView.release();
        if (peerConnection != null) { peerConnection.close(); peerConnection.dispose(); }
        if (factory        != null) factory.dispose();
        if (eglBase        != null) eglBase.release();
    }

    // Simple no-op SDP observer base
    static class SimpleSdpObserver implements SdpObserver {
        @Override public void onCreateSuccess(SessionDescription s) {}
        @Override public void onSetSuccess() {}
        @Override public void onCreateFailure(String e) { Log.e("SdpObs", "Create fail: " + e); }
        @Override public void onSetFailure(String e)    { Log.e("SdpObs", "Set fail: " + e); }
    }
}
EOF

# ─── MainActivity.java ──────────────────────────────────────────────────────
cat <<'JAVAEOF' > app/src/main/java/com/example/callingapp/MainActivity.java
package com.example.callingapp;

import android.Manifest;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.snackbar.Snackbar;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.*;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    private static final int REQ_PERMS  = 100;
    private static final int REQ_IMAGE  = 200;
    private static final int MAX_MSGS   = 50;

    public static boolean isAppInForeground = false;

    // ── Firebase ──────────────────────────────────────────────
    private FirebaseAuth mAuth;
    private DatabaseReference db;
    private String myFirebaseUid;
    private String myUid;      // 5-digit numeric
    private String myName;
    private String myEmoji;
    private String myBio;
    private String myProfileBase64;

    // ── Views ─────────────────────────────────────────────────
    private View authContainer, mainContainer, chatContainer, callContainer, profileContainer;
    private View loginForm, registerForm;
    private EditText loginEmail, loginPassword, regEmail, regPassword;
    private RecyclerView mainRecyclerView, chatRecyclerView;
    private BottomNavigationView bottomNav;
    private EditText etMessage;
    private TextView tvTypingIndicator, tvChatName, tvChatStatus, tvChatEmoji;
    private TextView tvCallName, tvCallStatus, tvCallDuration, tvCallEmoji;
    private TextView tvProfileName, tvProfileBio, tvProfileEmoji, tvProfileUid;
    private ImageView ivProfileImage;
    private View btnAcceptCall, btnEndCall;
    private SurfaceViewRenderer localVideoView, remoteVideoView;
    private LinearLayout callControlsLayout;

    // ── Adapters ──────────────────────────────────────────────
    private GenericAdapter<ChatMeta>   chatAdapter;
    private GenericAdapter<ChatMeta>   updatesAdapter;
    private GenericAdapter<CallRecord> callLogAdapter;
    private GenericAdapter<Message>    messageAdapter;

    // ── Current chat ──────────────────────────────────────────
    private String currentChatUid;
    private String currentChatName;
    private String currentChatEmoji;
    private boolean isMutedChat = false;
    private boolean isBlocked   = false;
    private Message replyToMessage = null;

    // ── Listeners ─────────────────────────────────────────────
    private ValueEventListener msgListener;
    private ValueEventListener typingListener;
    private ValueEventListener callListener;
    private ValueEventListener chatListListener;
    private ValueEventListener friendRequestListener;
    private ValueEventListener callLogDbListener;

    // ── WebRTC ────────────────────────────────────────────────
    private WebRTCManager webRTC;
    private String currentCallId;
    private boolean isCallActive   = false;
    private boolean isCaller       = false;
    private boolean isVideoCallActive = false;

    // ── Call timer ────────────────────────────────────────────
    private Handler callTimerHandler = new Handler(Looper.getMainLooper());
    private long callStartTime;
    private Runnable timerRunnable;

    // ── Typing debounce ───────────────────────────────────────
    private Handler typingHandler = new Handler(Looper.getMainLooper());
    private Runnable stopTypingRunnable;

    // ── Ringtone ──────────────────────────────────────────────
    private MediaPlayer ringtone;

    // ── Tab state ─────────────────────────────────────────────
    private int currentTab = 0; // 0=chats, 1=updates, 2=calls

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mAuth = FirebaseAuth.getInstance();
        db    = FirebaseDatabase.getInstance().getReference();

        bindViews();
        setupAdapters();
        checkAutoLogin();
        requestPermissions();

        handleIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent != null && "incoming_call".equals(intent.getStringExtra("action"))) {
            if (myUid != null) listenForIncomingCall();
        }
    }

    // ════════════════════════════════════════════════════════════
    // BIND VIEWS
    // ════════════════════════════════════════════════════════════
    private void bindViews() {
        authContainer    = findViewById(R.id.authContainer);
        mainContainer    = findViewById(R.id.mainContainer);
        chatContainer    = findViewById(R.id.chatContainer);
        callContainer    = findViewById(R.id.callContainer);
        profileContainer = findViewById(R.id.profileContainer);

        loginForm    = findViewById(R.id.loginForm);
        registerForm = findViewById(R.id.registerForm);

        loginEmail    = findViewById(R.id.loginEmail);
        loginPassword = findViewById(R.id.loginPassword);
        regEmail      = findViewById(R.id.regEmail);
        regPassword   = findViewById(R.id.regPassword);

        mainRecyclerView = findViewById(R.id.mainRecyclerView);
        chatRecyclerView = findViewById(R.id.chatRecyclerView);
        bottomNav        = findViewById(R.id.bottomNav);

        etMessage        = findViewById(R.id.etMessage);
        tvTypingIndicator= findViewById(R.id.tvTypingIndicator);
        tvChatName       = findViewById(R.id.tvChatName);
        tvChatStatus     = findViewById(R.id.tvChatStatus);
        tvChatEmoji      = findViewById(R.id.tvChatEmoji);

        tvCallName     = findViewById(R.id.tvCallName);
        tvCallStatus   = findViewById(R.id.tvCallStatus);
        tvCallDuration = findViewById(R.id.tvCallDuration);
        tvCallEmoji    = findViewById(R.id.tvCallEmoji);

        tvProfileName  = findViewById(R.id.tvProfileName);
        tvProfileBio   = findViewById(R.id.tvProfileBio);
        tvProfileEmoji = findViewById(R.id.tvProfileEmoji);
        tvProfileUid   = findViewById(R.id.tvProfileUid);
        ivProfileImage = findViewById(R.id.ivProfileImage);

        btnAcceptCall    = findViewById(R.id.btnAcceptCall);
        btnEndCall       = findViewById(R.id.btnEndCall);
        callControlsLayout = findViewById(R.id.callControlsLayout);

        localVideoView  = findViewById(R.id.localVideoView);
        remoteVideoView = findViewById(R.id.remoteVideoView);

        // Auth button listeners
        findViewById(R.id.btnLogin).setOnClickListener(v -> doLogin());
        findViewById(R.id.btnRegister).setOnClickListener(v -> doRegister());
        findViewById(R.id.tvSwitchToRegister).setOnClickListener(v -> showRegisterForm());
        findViewById(R.id.tvSwitchToLogin).setOnClickListener(v -> showLoginForm());

        // Main toolbar
        findViewById(R.id.btnAddFriend).setOnClickListener(v -> showAddFriendDialog());
        findViewById(R.id.btnMenu).setOnClickListener(v -> showMainMenu(v));

        // Chat toolbar
        findViewById(R.id.btnChatBack).setOnClickListener(v -> closeChatView());
        findViewById(R.id.btnVoiceCall).setOnClickListener(v -> startCall(false));
        findViewById(R.id.btnVideoCall).setOnClickListener(v -> startCall(true));
        findViewById(R.id.btnSend).setOnClickListener(v -> sendMessage());

        // Call buttons
        btnAcceptCall.setOnClickListener(v -> acceptCall());
        btnEndCall.setOnClickListener(v -> endCall());
        findViewById(R.id.btnMute).setOnClickListener(v -> toggleMute());
        findViewById(R.id.btnCameraToggle).setOnClickListener(v -> toggleCamera());
        findViewById(R.id.btnFlipCamera).setOnClickListener(v -> flipCamera());
        findViewById(R.id.btnSpeaker).setOnClickListener(v -> toggleSpeaker());

        // Profile
        findViewById(R.id.btnProfileBack).setOnClickListener(v -> showMainView());
        findViewById(R.id.btnEditProfile).setOnClickListener(v -> editProfile());
        findViewById(R.id.btnCopyUid).setOnClickListener(v -> copyUid());
        findViewById(R.id.btnChangePhoto).setOnClickListener(v -> pickImage());
        findViewById(R.id.btnLogout).setOnClickListener(v -> logout());

        // Bottom nav
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats)   { currentTab = 0; loadChatTab();   return true; }
            if (id == R.id.nav_updates) { currentTab = 1; loadUpdatesTab();return true; }
            if (id == R.id.nav_calls)   { currentTab = 2; loadCallsTab();  return true; }
            return false;
        });

        // Typing
        etMessage.addTextChangedListener(new android.text.TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void afterTextChanged(android.text.Editable s) {}
            @Override public void onTextChanged(CharSequence s, int a, int b, int c) {
                sendTypingIndicator(s.length() > 0);
            }
        });
    }

    // ════════════════════════════════════════════════════════════
    // ADAPTERS
    // ════════════════════════════════════════════════════════════
    private void setupAdapters() {
        chatAdapter = new GenericAdapter<>(R.layout.item_list);
        chatAdapter.setBinder((v, item, pos) -> bindChatItem(v, item));
        chatAdapter.setClickListener((item, pos) -> openChat(item));

        updatesAdapter = new GenericAdapter<>(R.layout.item_list);
        updatesAdapter.setBinder((v, item, pos) -> bindFriendRequestItem(v, item));

        callLogAdapter = new GenericAdapter<>(R.layout.item_list);
        callLogAdapter.setBinder((v, item, pos) -> bindCallLogItem(v, item));
        callLogAdapter.setClickListener((item, pos) -> {
            // Redial
        });

        messageAdapter = new GenericAdapter<>(R.layout.item_message);
        messageAdapter.setBinder((v, item, pos) -> bindMessageItem(v, item));
        messageAdapter.setLongClickListener((item, pos) -> { showMsgMenu(item, pos); return true; });
    }

    // ════════════════════════════════════════════════════════════
    // AUTH
    // ════════════════════════════════════════════════════════════
    private void checkAutoLogin() {
        FirebaseUser user = mAuth.getCurrentUser();
        if (user != null) {
            myFirebaseUid = user.getUid();
            loadMyProfile();
        } else {
            showAuthView();
        }
    }

    private void showAuthView() {
        authContainer.setVisibility(View.VISIBLE);
        mainContainer.setVisibility(View.GONE);
        chatContainer.setVisibility(View.GONE);
        callContainer.setVisibility(View.GONE);
        profileContainer.setVisibility(View.GONE);
    }

    private void showLoginForm() {
        loginForm.setVisibility(View.VISIBLE);
        registerForm.setVisibility(View.GONE);
    }

    private void showRegisterForm() {
        loginForm.setVisibility(View.GONE);
        registerForm.setVisibility(View.VISIBLE);
    }

    private void doLogin() {
        String email = loginEmail.getText().toString().trim();
        String pass  = loginPassword.getText().toString().trim();
        if (email.isEmpty() || pass.isEmpty()) { toast("Fill all fields"); return; }

        mAuth.signInWithEmailAndPassword(email, pass)
            .addOnSuccessListener(r -> {
                myFirebaseUid = r.getUser().getUid();
                loadMyProfile();
            })
            .addOnFailureListener(e -> toast("Login failed: " + e.getMessage()));
    }

    private void doRegister() {
        String email = regEmail.getText().toString().trim();
        String pass  = regPassword.getText().toString().trim();
        if (email.isEmpty() || pass.isEmpty()) { toast("Fill all fields"); return; }
        if (pass.length() < 6) { toast("Password must be 6+ chars"); return; }

        mAuth.createUserWithEmailAndPassword(email, pass)
            .addOnSuccessListener(r -> {
                myFirebaseUid = r.getUser().getUid();
                showProfileSetupDialog(email);
            })
            .addOnFailureListener(e -> toast("Registration failed: " + e.getMessage()));
    }

    private void showProfileSetupDialog(String email) {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        TextView title = dialogView.findViewById(R.id.tvDialogTitle);
        title.setText("Set up your profile");
        EditText etName  = dialogView.findViewById(R.id.etInput1);
        EditText etBio   = dialogView.findViewById(R.id.etInput2);
        EditText etEmoji = dialogView.findViewById(R.id.etInput3);
        etEmoji.setText("🐐");

        new MaterialAlertDialogBuilder(this)
            .setView(dialogView)
            .setCancelable(false)
            .setPositiveButton("Save", (d, w) -> {
                String name  = etName.getText().toString().trim();
                String bio   = etBio.getText().toString().trim();
                String emoji = etEmoji.getText().toString().trim();
                if (name.isEmpty()) name = "User";
                if (emoji.isEmpty()) emoji = "🐐";
                createUserProfile(email, name, bio, emoji);
            })
            .show();
    }

    private void createUserProfile(String email, String name, String bio, String emoji) {
        String uid = generateUniqueUid();
        User user  = new User();
        user.uid         = uid;
        user.firebaseUid = myFirebaseUid;
        user.name        = name;
        user.bio         = bio;
        user.emoji       = emoji;
        user.email       = email;
        user.online      = true;
        user.lastSeen    = System.currentTimeMillis();
        user.createdAt   = System.currentTimeMillis();

        db.child("users").child(uid).setValue(user)
            .addOnSuccessListener(v -> {
                myUid  = uid;
                myName = name;
                myEmoji= emoji;
                myBio  = bio;
                afterLogin();
            })
            .addOnFailureListener(e -> toast("Profile save failed"));
    }

    private String generateUniqueUid() {
        Random rnd = new Random();
        return String.format("%05d", rnd.nextInt(100000));
    }

    private void loadMyProfile() {
        db.child("users").orderByChild("firebaseUid").equalTo(myFirebaseUid)
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    if (snap.exists()) {
                        for (DataSnapshot child : snap.getChildren()) {
                            User u = child.getValue(User.class);
                            if (u != null) {
                                myUid           = child.getKey();
                                myName          = u.name;
                                myEmoji         = u.emoji;
                                myBio           = u.bio;
                                myProfileBase64 = u.profileImageBase64;
                                afterLogin();
                                return;
                            }
                        }
                    }
                    // Profile not found – show setup
                    showProfileSetupDialog(mAuth.getCurrentUser() != null ?
                        mAuth.getCurrentUser().getEmail() : "");
                }
                @Override public void onCancelled(DatabaseError e) { showAuthView(); }
            });
    }

    private void afterLogin() {
        setOnlineStatus(true);
        startBackgroundService();
        listenForIncomingCall();
        showMainView();
        loadChatTab();
        loadChatList();
    }

    // ════════════════════════════════════════════════════════════
    // VIEWS NAVIGATION
    // ════════════════════════════════════════════════════════════
    private void showMainView() {
        authContainer.setVisibility(View.GONE);
        mainContainer.setVisibility(View.VISIBLE);
        chatContainer.setVisibility(View.GONE);
        callContainer.setVisibility(View.GONE);
        profileContainer.setVisibility(View.GONE);
    }

    private void showChatView() {
        authContainer.setVisibility(View.GONE);
        mainContainer.setVisibility(View.GONE);
        chatContainer.setVisibility(View.VISIBLE);
        callContainer.setVisibility(View.GONE);
        profileContainer.setVisibility(View.GONE);
    }

    private void showCallView() {
        authContainer.setVisibility(View.GONE);
        mainContainer.setVisibility(View.GONE);
        chatContainer.setVisibility(View.GONE);
        callContainer.setVisibility(View.VISIBLE);
        profileContainer.setVisibility(View.GONE);
    }

    private void showProfileView() {
        authContainer.setVisibility(View.GONE);
        mainContainer.setVisibility(View.GONE);
        chatContainer.setVisibility(View.GONE);
        callContainer.setVisibility(View.GONE);
        profileContainer.setVisibility(View.VISIBLE);
        refreshProfileView();
    }

    private void closeChatView() {
        detachChatListeners();
        currentChatUid  = null;
        replyToMessage  = null;
        showMainView();
    }

    // ════════════════════════════════════════════════════════════
    // TABS
    // ════════════════════════════════════════════════════════════
    private void loadChatTab() {
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mainRecyclerView.setAdapter(chatAdapter);
    }

    private void loadUpdatesTab() {
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mainRecyclerView.setAdapter(updatesAdapter);
        loadFriendRequests();
    }

    private void loadCallsTab() {
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mainRecyclerView.setAdapter(callLogAdapter);
        loadCallLog();
    }

    // ════════════════════════════════════════════════════════════
    // CHAT LIST
    // ════════════════════════════════════════════════════════════
    private void loadChatList() {
        if (myUid == null) return;
        if (chatListListener != null)
            db.child("chats").child(myUid).removeEventListener(chatListListener);

        chatListListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                List<ChatMeta> list = new ArrayList<>();
                for (DataSnapshot child : snap.getChildren()) {
                    ChatMeta cm = child.getValue(ChatMeta.class);
                    if (cm != null) { cm.uid = child.getKey(); list.add(cm); }
                }
                list.sort((a, b) -> Long.compare(b.lastTimestamp, a.lastTimestamp));
                chatAdapter.setItems(list);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("chats").child(myUid).addValueEventListener(chatListListener);
    }

    // ════════════════════════════════════════════════════════════
    // FRIEND REQUESTS
    // ════════════════════════════════════════════════════════════
    private void showAddFriendDialog() {
        View v = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        TextView title = v.findViewById(R.id.tvDialogTitle);
        title.setText("Add Friend by UID");
        v.findViewById(R.id.tilInput2).setVisibility(View.GONE);
        v.findViewById(R.id.tilInput3).setVisibility(View.GONE);
        EditText et = v.findViewById(R.id.etInput1);
        et.setHint("5-digit UID");
        et.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);

        new MaterialAlertDialogBuilder(this)
            .setTitle("Add Friend")
            .setView(v)
            .setPositiveButton("Send Request", (d, w) -> {
                String uid = et.getText().toString().trim();
                if (uid.length() == 5) sendFriendRequest(uid);
                else toast("Enter a valid 5-digit UID");
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void sendFriendRequest(String targetUid) {
        if (targetUid.equals(myUid)) { toast("Can't add yourself"); return; }
        db.child("users").child(targetUid)
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    if (!snap.exists()) { toast("User not found"); return; }
                    Map<String, Object> req = new HashMap<>();
                    req.put("fromUid",   myUid);
                    req.put("fromName",  myName);
                    req.put("fromEmoji", myEmoji);
                    req.put("status",    "pending");
                    req.put("timestamp", System.currentTimeMillis());
                    db.child("friendRequests").child(targetUid).child(myUid).setValue(req)
                        .addOnSuccessListener(v2 -> toast("Friend request sent!"))
                        .addOnFailureListener(e -> toast("Failed to send request"));
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
    }

    private void loadFriendRequests() {
        if (myUid == null) return;
        if (friendRequestListener != null)
            db.child("friendRequests").child(myUid).removeEventListener(friendRequestListener);

        friendRequestListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                List<ChatMeta> list = new ArrayList<>();
                for (DataSnapshot child : snap.getChildren()) {
                    String status = child.child("status").getValue(String.class);
                    if (!"pending".equals(status)) continue;
                    ChatMeta cm = new ChatMeta();
                    cm.uid  = child.getKey();
                    cm.name = child.child("fromName").getValue(String.class);
                    cm.emoji= child.child("fromEmoji").getValue(String.class);
                    cm.lastMessage = "Friend request";
                    list.add(cm);
                }
                updatesAdapter.setItems(list);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("friendRequests").child(myUid).addValueEventListener(friendRequestListener);
    }

    private void acceptFriendRequest(ChatMeta cm) {
        db.child("friendRequests").child(myUid).child(cm.uid).child("status").setValue("accepted");

        // Add to both chat lists
        ChatMeta myEntry = new ChatMeta();
        myEntry.uid  = cm.uid;
        myEntry.name = cm.name;
        myEntry.emoji= cm.emoji != null ? cm.emoji : "👤";
        myEntry.lastMessage   = "Say hi!";
        myEntry.lastTimestamp = System.currentTimeMillis();
        db.child("chats").child(myUid).child(cm.uid).setValue(myEntry);

        // Find their profile and add me to their chats
        db.child("users").child(cm.uid)
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    ChatMeta theirEntry = new ChatMeta();
                    theirEntry.uid  = myUid;
                    theirEntry.name = myName;
                    theirEntry.emoji= myEmoji != null ? myEmoji : "🐐";
                    theirEntry.lastMessage   = "Say hi!";
                    theirEntry.lastTimestamp = System.currentTimeMillis();
                    db.child("chats").child(cm.uid).child(myUid).setValue(theirEntry);
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
        toast("Friend added!");
    }

    private void rejectFriendRequest(ChatMeta cm) {
        db.child("friendRequests").child(myUid).child(cm.uid).child("status").setValue("rejected");
        toast("Request rejected");
    }

    // ════════════════════════════════════════════════════════════
    // OPEN CHAT
    // ════════════════════════════════════════════════════════════
    private void openChat(ChatMeta cm) {
        currentChatUid  = cm.uid;
        currentChatName = cm.name;
        currentChatEmoji= cm.emoji != null ? cm.emoji : "👤";
        replyToMessage  = null;

        tvChatName.setText(currentChatName);
        tvChatEmoji.setText(currentChatEmoji);

        showChatView();
        setupMessageRecycler();
        clearUnreadCount();
        loadMessages();
        listenTyping();
        listenPartnerOnline();
    }

    private void setupMessageRecycler() {
        LinearLayoutManager lm = new LinearLayoutManager(this);
        lm.setStackFromEnd(true);
        chatRecyclerView.setLayoutManager(lm);
        chatRecyclerView.setAdapter(messageAdapter);
        messageAdapter.setItems(new ArrayList<>());
    }

    private void loadMessages() {
        if (myUid == null || currentChatUid == null) return;
        String chatId = chatRoomId(myUid, currentChatUid);

        if (msgListener != null)
            db.child("messages").child(chatId).removeEventListener(msgListener);

        msgListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                List<Message> msgs = new ArrayList<>();
                for (DataSnapshot child : snap.getChildren()) {
                    Message m = child.getValue(Message.class);
                    if (m != null) { m.id = child.getKey(); msgs.add(m); }
                }
                messageAdapter.setItems(msgs);
                chatRecyclerView.scrollToPosition(msgs.size() - 1);
                markMessagesAsSeen(msgs);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("messages").child(chatId)
            .limitToLast(MAX_MSGS)
            .addValueEventListener(msgListener);
    }

    private void markMessagesAsSeen(List<Message> msgs) {
        String chatId = chatRoomId(myUid, currentChatUid);
        for (Message m : msgs) {
            if (!myUid.equals(m.senderId) && !"seen".equals(m.status)) {
                db.child("messages").child(chatId).child(m.id).child("status").setValue("seen");
            }
        }
    }

    private void clearUnreadCount() {
        if (myUid == null || currentChatUid == null) return;
        db.child("chats").child(myUid).child(currentChatUid).child("unreadCount").setValue(0);
    }

    private void listenTyping() {
        if (currentChatUid == null) return;
        if (typingListener != null)
            db.child("typing").child(currentChatUid).child(myUid)
              .removeEventListener(typingListener);

        typingListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                Boolean typing = snap.getValue(Boolean.class);
                tvTypingIndicator.setVisibility(Boolean.TRUE.equals(typing) ? View.VISIBLE : View.GONE);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("typing").child(currentChatUid).child(myUid)
          .addValueEventListener(typingListener);
    }

    private void listenPartnerOnline() {
        if (currentChatUid == null) return;
        db.child("users").child(currentChatUid)
          .addValueEventListener(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  Boolean online = snap.child("online").getValue(Boolean.class);
                  Long lastSeen  = snap.child("lastSeen").getValue(Long.class);
                  if (Boolean.TRUE.equals(online)) {
                      tvChatStatus.setText("online");
                  } else if (lastSeen != null) {
                      tvChatStatus.setText("last seen " + formatTime(lastSeen));
                  } else {
                      tvChatStatus.setText("offline");
                  }
              }
              @Override public void onCancelled(DatabaseError e) {}
          });
    }

    private void sendTypingIndicator(boolean typing) {
        if (myUid == null || currentChatUid == null) return;
        db.child("typing").child(myUid).child(currentChatUid).setValue(typing);
        if (stopTypingRunnable != null) typingHandler.removeCallbacks(stopTypingRunnable);
        if (typing) {
            stopTypingRunnable = () ->
                db.child("typing").child(myUid).child(currentChatUid).setValue(false);
            typingHandler.postDelayed(stopTypingRunnable, 3000);
        }
    }

    private void sendMessage() {
        if (currentChatUid == null || isBlocked) return;
        String text = etMessage.getText().toString().trim();
        if (text.isEmpty()) return;

        String chatId = chatRoomId(myUid, currentChatUid);
        String msgId  = db.child("messages").child(chatId).push().getKey();
        if (msgId == null) return;

        Message msg = new Message(myUid, text, System.currentTimeMillis());
        if (replyToMessage != null) {
            msg.replyTo   = replyToMessage.id;
            msg.replyText = replyToMessage.text;
            replyToMessage = null;
        }

        db.child("messages").child(chatId).child(msgId).setValue(msg);

        // Update chat meta
        ChatMeta myCm = new ChatMeta();
        myCm.uid  = currentChatUid;
        myCm.name = currentChatName;
        myCm.emoji= currentChatEmoji;
        myCm.lastMessage   = text;
        myCm.lastTimestamp = msg.timestamp;
        db.child("chats").child(myUid).child(currentChatUid).setValue(myCm);

        // Increment partner unread
        db.child("chats").child(currentChatUid).child(myUid)
          .addListenerForSingleValueEvent(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  ChatMeta cm = snap.getValue(ChatMeta.class);
                  int unread = (cm != null && cm.unreadCount > 0) ? cm.unreadCount + 1 : 1;
                  db.child("chats").child(currentChatUid).child(myUid).child("unreadCount").setValue(unread);
                  db.child("chats").child(currentChatUid).child(myUid).child("lastMessage").setValue(text);
                  db.child("chats").child(currentChatUid).child(myUid).child("lastTimestamp").setValue(msg.timestamp);
              }
              @Override public void onCancelled(DatabaseError e) {}
          });

        etMessage.setText("");
        sendTypingIndicator(false);
    }

    // ════════════════════════════════════════════════════════════
    // MESSAGE BINDING
    // ════════════════════════════════════════════════════════════
    private void bindMessageItem(View v, Message msg) {
        View layoutIn  = v.findViewById(R.id.layoutMsgIn);
        View layoutOut = v.findViewById(R.id.layoutMsgOut);
        boolean isMine = myUid != null && myUid.equals(msg.senderId);

        layoutIn.setVisibility(isMine ? View.GONE : View.VISIBLE);
        layoutOut.setVisibility(isMine ? View.VISIBLE : View.GONE);

        String displayText = msg.deleted ? "🚫 This message was deleted" : msg.text;

        if (isMine) {
            TextView tvText  = v.findViewById(R.id.tvMsgTextOut);
            TextView tvTime  = v.findViewById(R.id.tvMsgTimeOut);
            TextView tvStatus= v.findViewById(R.id.tvMsgStatus);
            TextView tvReact = v.findViewById(R.id.tvReactionOut);
            TextView tvReply = v.findViewById(R.id.tvReplyOut);

            tvText.setText(displayText);
            tvTime.setText(formatTime(msg.timestamp));
            tvStatus.setText("seen".equals(msg.status) ? "✓✓" :
                             "delivered".equals(msg.status) ? "✓✓" : "✓");
            tvStatus.setTextColor("seen".equals(msg.status) ?
                getResources().getColor(R.color.colorAccent, null) :
                getResources().getColor(R.color.msg_time_color, null));

            if (msg.reaction != null && !msg.reaction.isEmpty()) {
                tvReact.setText(msg.reaction); tvReact.setVisibility(View.VISIBLE);
            } else { tvReact.setVisibility(View.GONE); }

            if (msg.replyText != null && !msg.replyText.isEmpty()) {
                tvReply.setText("↩ " + msg.replyText); tvReply.setVisibility(View.VISIBLE);
            } else { tvReply.setVisibility(View.GONE); }
        } else {
            TextView tvText = v.findViewById(R.id.tvMsgTextIn);
            TextView tvTime = v.findViewById(R.id.tvMsgTimeIn);
            TextView tvReact= v.findViewById(R.id.tvReactionIn);
            TextView tvReply= v.findViewById(R.id.tvReplyIn);

            tvText.setText(displayText);
            tvTime.setText(formatTime(msg.timestamp));

            if (msg.reaction != null && !msg.reaction.isEmpty()) {
                tvReact.setText(msg.reaction); tvReact.setVisibility(View.VISIBLE);
            } else { tvReact.setVisibility(View.GONE); }

            if (msg.replyText != null && !msg.replyText.isEmpty()) {
                tvReply.setText("↩ " + msg.replyText); tvReply.setVisibility(View.VISIBLE);
            } else { tvReply.setVisibility(View.GONE); }
        }
    }

    // ════════════════════════════════════════════════════════════
    // MESSAGE LONG PRESS MENU
    // ════════════════════════════════════════════════════════════
    private void showMsgMenu(Message msg, int pos) {
        List<String> options = new ArrayList<>();
        options.add("Reply");
        options.add("Copy");
        options.add("React 👍");
        options.add("React ❤️");
        options.add("React 😂");
        if (myUid != null && myUid.equals(msg.senderId) && !msg.deleted) {
            long diff = System.currentTimeMillis() - msg.timestamp;
            if (diff < 5 * 60 * 1000) options.add("Delete for Everyone");
        }

        new MaterialAlertDialogBuilder(this)
            .setItems(options.toArray(new String[0]), (d, which) -> {
                String opt = options.get(which);
                switch (opt) {
                    case "Reply": replyToMessage = msg; toast("Swipe or tap to reply to: " + msg.text); break;
                    case "Copy":
                        ClipboardManager cm2 = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
                        cm2.setPrimaryClip(ClipData.newPlainText("msg", msg.text));
                        toast("Copied"); break;
                    case "React 👍": reactToMessage(msg, "👍"); break;
                    case "React ❤️": reactToMessage(msg, "❤️"); break;
                    case "React 😂": reactToMessage(msg, "😂"); break;
                    case "Delete for Everyone": deleteForEveryone(msg, pos); break;
                }
            })
            .show();
    }

    private void reactToMessage(Message msg, String emoji) {
        if (msg.id == null) return;
        String chatId = chatRoomId(myUid, currentChatUid);
        db.child("messages").child(chatId).child(msg.id).child("reaction").setValue(emoji);
    }

    private void deleteForEveryone(Message msg, int pos) {
        String chatId = chatRoomId(myUid, currentChatUid);
        db.child("messages").child(chatId).child(msg.id).child("deleted").setValue(true);
        db.child("messages").child(chatId).child(msg.id).child("text").setValue("deleted");
    }

    // ════════════════════════════════════════════════════════════
    // CHAT ITEM BINDING
    // ════════════════════════════════════════════════════════════
    private void bindChatItem(View v, ChatMeta cm) {
        TextView tvEmoji   = v.findViewById(R.id.tvItemEmoji);
        TextView tvName    = v.findViewById(R.id.tvItemName);
        TextView tvPreview = v.findViewById(R.id.tvItemPreview);
        TextView tvTime    = v.findViewById(R.id.tvItemTime);
        TextView tvUnread  = v.findViewById(R.id.tvUnreadCount);
        View vOnline       = v.findViewById(R.id.vOnlineIndicator);

        tvEmoji.setText(cm.emoji != null ? cm.emoji : "👤");
        tvName.setText(cm.name != null ? cm.name : "Unknown");
        tvPreview.setText(cm.lastMessage != null ? cm.lastMessage : "");
        tvTime.setText(cm.lastTimestamp > 0 ? formatTime(cm.lastTimestamp) : "");
        vOnline.setVisibility(cm.online ? View.VISIBLE : View.GONE);

        if (cm.unreadCount > 0) {
            tvUnread.setText(String.valueOf(cm.unreadCount));
            tvUnread.setVisibility(View.VISIBLE);
        } else {
            tvUnread.setVisibility(View.GONE);
        }
    }

    private void bindFriendRequestItem(View v, ChatMeta cm) {
        TextView tvEmoji   = v.findViewById(R.id.tvItemEmoji);
        TextView tvName    = v.findViewById(R.id.tvItemName);
        TextView tvPreview = v.findViewById(R.id.tvItemPreview);
        TextView tvTime    = v.findViewById(R.id.tvItemTime);

        tvEmoji.setText(cm.emoji != null ? cm.emoji : "👤");
        tvName.setText(cm.name != null ? cm.name : "Unknown");
        tvPreview.setText("Wants to be your friend");
        tvTime.setText("");

        v.setOnClickListener(null);
        new Handler(Looper.getMainLooper()).post(() -> {
            v.setOnClickListener(null);
        });

        // Show accept/reject using a popup
        v.setOnClickListener(view -> {
            new MaterialAlertDialogBuilder(this)
                .setTitle("Friend Request")
                .setMessage(cm.name + " wants to be your friend")
                .setPositiveButton("Accept", (d, w) -> acceptFriendRequest(cm))
                .setNegativeButton("Reject",  (d, w) -> rejectFriendRequest(cm))
                .show();
        });
    }

    private void bindCallLogItem(View v, CallRecord cr) {
        TextView tvEmoji   = v.findViewById(R.id.tvItemEmoji);
        TextView tvName    = v.findViewById(R.id.tvItemName);
        TextView tvPreview = v.findViewById(R.id.tvItemPreview);
        TextView tvTime    = v.findViewById(R.id.tvItemTime);

        tvEmoji.setText(cr.callerEmoji != null ? cr.callerEmoji : "📞");
        tvName.setText(cr.callerName != null ? cr.callerName : "Unknown");
        tvPreview.setText(("video".equals(cr.type) ? "📹 " : "📞 ") + cr.status);
        tvTime.setText(formatTime(cr.startTime));
    }

    // ════════════════════════════════════════════════════════════
    // CALL LOG
    // ════════════════════════════════════════════════════════════
    private void loadCallLog() {
        if (myUid == null) return;
        if (callLogDbListener != null)
            db.child("callLogs").child(myUid).removeEventListener(callLogDbListener);

        callLogDbListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                List<CallRecord> list = new ArrayList<>();
                for (DataSnapshot child : snap.getChildren()) {
                    CallRecord cr = child.getValue(CallRecord.class);
                    if (cr != null) list.add(cr);
                }
                list.sort((a, b) -> Long.compare(b.startTime, a.startTime));
                callLogAdapter.setItems(list);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("callLogs").child(myUid)
          .limitToLast(50)
          .addValueEventListener(callLogDbListener);
    }

    // ════════════════════════════════════════════════════════════
    // PROFILE
    // ════════════════════════════════════════════════════════════
    private void refreshProfileView() {
        tvProfileName.setText(myName != null ? myName : "");
        tvProfileBio.setText(myBio  != null ? myBio  : "");
        tvProfileEmoji.setText(myEmoji != null ? myEmoji : "🐐");
        tvProfileUid.setText(myUid  != null ? myUid  : "");

        if (myProfileBase64 != null && !myProfileBase64.isEmpty()) {
            try {
                byte[] bytes = Base64.decode(myProfileBase64, Base64.DEFAULT);
                Bitmap bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                ivProfileImage.setImageBitmap(bmp);
                ivProfileImage.setVisibility(View.VISIBLE);
            } catch (Exception ignored) {}
        }
    }

    private void editProfile() {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        EditText etName  = dialogView.findViewById(R.id.etInput1);
        EditText etBio   = dialogView.findViewById(R.id.etInput2);
        EditText etEmoji = dialogView.findViewById(R.id.etInput3);

        etName.setText(myName);
        etBio.setText(myBio);
        etEmoji.setText(myEmoji);

        new MaterialAlertDialogBuilder(this)
            .setTitle("Edit Profile")
            .setView(dialogView)
            .setPositiveButton("Save", (d, w) -> {
                String name  = etName.getText().toString().trim();
                String bio   = etBio.getText().toString().trim();
                String emoji = etEmoji.getText().toString().trim();
                if (name.isEmpty()) return;
                myName  = name;
                myBio   = bio;
                myEmoji = emoji.isEmpty() ? "🐐" : emoji;
                Map<String, Object> upd = new HashMap<>();
                upd.put("name",  myName);
                upd.put("bio",   myBio);
                upd.put("emoji", myEmoji);
                db.child("users").child(myUid).updateChildren(upd)
                  .addOnSuccessListener(v2 -> { refreshProfileView(); toast("Profile updated"); });
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void copyUid() {
        ClipboardManager cm2 = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        cm2.setPrimaryClip(ClipData.newPlainText("UID", myUid));
        toast("UID copied: " + myUid);
    }

    private void pickImage() {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        startActivityForResult(intent, REQ_IMAGE);
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (req == REQ_IMAGE && res == RESULT_OK && data != null && data.getData() != null) {
            try {
                Uri uri = data.getData();
                InputStream is = getContentResolver().openInputStream(uri);
                Bitmap bmp = BitmapFactory.decodeStream(is);
                // Resize
                Bitmap scaled = Bitmap.createScaledBitmap(bmp, 256, 256, true);
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                scaled.compress(Bitmap.CompressFormat.JPEG, 70, baos);
                String base64 = Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT);
                myProfileBase64 = base64;
                db.child("users").child(myUid).child("profileImageBase64").setValue(base64)
                  .addOnSuccessListener(v2 -> { refreshProfileView(); toast("Photo updated"); });
            } catch (Exception e) { toast("Image error: " + e.getMessage()); }
        }
    }

    // ════════════════════════════════════════════════════════════
    // CALLS
    // ════════════════════════════════════════════════════════════
    private void startCall(boolean videoCall) {
        if (currentChatUid == null) return;
        if (isCallActive) { toast("Already in a call"); return; }

        isVideoCallActive = videoCall;
        isCaller          = true;
        currentCallId     = db.child("calls").push().getKey();

        // Fetch callee info
        db.child("users").child(currentChatUid)
          .addListenerForSingleValueEvent(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  String calleeName  = snap.child("name").getValue(String.class);
                  String calleeEmoji = snap.child("emoji").getValue(String.class);
                  prepareCallUI(calleeName, calleeEmoji, true, videoCall);
                  initWebRTC(videoCall);

                  CallRecord rec = new CallRecord();
                  rec.callId     = currentCallId;
                  rec.callerId   = myUid;
                  rec.callerName = myName;
                  rec.callerEmoji= myEmoji;
                  rec.receiverId = currentChatUid;
                  rec.type       = videoCall ? "video" : "voice";
                  rec.status     = "ringing";
                  rec.startTime  = System.currentTimeMillis();

                  db.child("calls").child(currentChatUid).setValue(rec);
                  db.child("calls").child(currentChatUid).child("offer"); // placeholder

                  // Create offer after WebRTC is ready
                  new Handler(Looper.getMainLooper()).postDelayed(() -> {
                      if (webRTC != null) webRTC.createOffer();
                  }, 1000);

                  listenForCallAnswer();
              }
              @Override public void onCancelled(DatabaseError e) {}
          });
    }

    private void listenForIncomingCall() {
        if (myUid == null) return;
        if (callListener != null)
            db.child("calls").child(myUid).removeEventListener(callListener);

        callListener = new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                if (!snap.exists() || isCallActive) return;
                String status = snap.child("status").getValue(String.class);
                if (!"ringing".equals(status)) return;

                String callerName  = snap.child("callerName").getValue(String.class);
                String callerEmoji = snap.child("callerEmoji").getValue(String.class);
                String callType    = snap.child("type").getValue(String.class);
                String callerId    = snap.child("callerId").getValue(String.class);

                currentCallId     = snap.child("callId").getValue(String.class);
                currentChatUid    = callerId;
                isVideoCallActive = "video".equals(callType);
                isCaller          = false;

                runOnUiThread(() -> {
                    prepareCallUI(callerName, callerEmoji, false, isVideoCallActive);
                    playRingtone();
                });
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        db.child("calls").child(myUid).addValueEventListener(callListener);
    }

    private void listenForCallAnswer() {
        if (currentChatUid == null) return;
        db.child("calls").child(currentChatUid)
          .addValueEventListener(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  Boolean accepted = snap.child("accepted").getValue(Boolean.class);
                  if (Boolean.TRUE.equals(accepted)) {
                      String answerSdp  = snap.child("answer").getValue(String.class);
                      String answerType = snap.child("answerType").getValue(String.class);
                      if (answerSdp != null && webRTC != null) {
                          SessionDescription sdp = new SessionDescription(
                              SessionDescription.Type.fromCanonicalForm(
                                  answerType != null ? answerType : "answer"), answerSdp);
                          webRTC.setRemoteDescription(sdp);
                          onCallConnected();
                      }
                      db.child("calls").child(currentChatUid).removeEventListener(this);
                  }
              }
              @Override public void onCancelled(DatabaseError e) {}
          });

        // ICE candidates for caller
        listenIceCandidates(currentChatUid + "_to_" + myUid);
    }

    private void acceptCall() {
        if (isCallActive) return;
        stopRingtone();
        initWebRTC(isVideoCallActive);

        // Read offer from Firebase
        db.child("calls").child(myUid)
          .addListenerForSingleValueEvent(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  String offerSdp  = snap.child("offer").getValue(String.class);
                  String offerType = snap.child("offerType").getValue(String.class);
                  if (offerSdp != null && webRTC != null) {
                      SessionDescription sdp = new SessionDescription(
                          SessionDescription.Type.fromCanonicalForm(
                              offerType != null ? offerType : "offer"), offerSdp);
                      webRTC.setRemoteDescription(sdp);
                      new Handler(Looper.getMainLooper()).postDelayed(() -> {
                          if (webRTC != null) webRTC.createAnswer();
                      }, 500);
                  }
                  listenIceCandidates(currentChatUid + "_to_" + myUid);
              }
              @Override public void onCancelled(DatabaseError e) {}
          });
    }

    private void listenIceCandidates(String path) {
        db.child("iceCandidates").child(path)
          .addChildEventListener(new ChildEventListener() {
              @Override public void onChildAdded(DataSnapshot snap, String prev) {
                  try {
                      String sdpMid        = snap.child("sdpMid").getValue(String.class);
                      Long sdpMLineIndex   = snap.child("sdpMLineIndex").getValue(Long.class);
                      String candidate     = snap.child("candidate").getValue(String.class);
                      if (candidate != null && webRTC != null) {
                          IceCandidate ic = new IceCandidate(
                              sdpMid, sdpMLineIndex != null ? sdpMLineIndex.intValue() : 0, candidate);
                          webRTC.addIceCandidate(ic);
                      }
                  } catch (Exception e) { Log.e(TAG, "ICE err", e); }
              }
              @Override public void onChildChanged(DataSnapshot s, String p) {}
              @Override public void onChildRemoved(DataSnapshot s) {}
              @Override public void onChildMoved(DataSnapshot s, String p) {}
              @Override public void onCancelled(DatabaseError e) {}
          });
    }

    private void initWebRTC(boolean videoCall) {
        webRTC = new WebRTCManager(this, new WebRTCManager.Callback() {
            @Override public void onLocalSdpReady(SessionDescription sdp) {
                runOnUiThread(() -> {
                    if (isCaller) {
                        // Write offer to Firebase
                        db.child("calls").child(currentChatUid).child("offer").setValue(sdp.description);
                        db.child("calls").child(currentChatUid).child("offerType").setValue(sdp.type.canonicalForm());
                    } else {
                        // Write answer to Firebase
                        db.child("calls").child(myUid).child("answer").setValue(sdp.description);
                        db.child("calls").child(myUid).child("answerType").setValue(sdp.type.canonicalForm());
                        db.child("calls").child(myUid).child("accepted").setValue(true);
                        onCallConnected();
                    }
                });
            }
            @Override public void onIceCandidateReady(IceCandidate candidate) {
                String path = isCaller ?
                    (myUid + "_to_" + currentChatUid) :
                    (myUid + "_to_" + currentChatUid);
                Map<String, Object> cm2 = new HashMap<>();
                cm2.put("sdpMid",       candidate.sdpMid);
                cm2.put("sdpMLineIndex", candidate.sdpMLineIndex);
                cm2.put("candidate",    candidate.sdp);
                db.child("iceCandidates").child(path).push().setValue(cm2);
            }
            @Override public void onRemoteVideoTrack(VideoTrack track) {
                runOnUiThread(() -> {
                    if (remoteVideoView != null) track.addSink(remoteVideoView);
                });
            }
            @Override public void onConnectionStateChange(String state) {
                runOnUiThread(() -> {
                    if (tvCallStatus != null) tvCallStatus.setText(state);
                    if ("CONNECTED".equals(state)) onCallConnected();
                    if ("DISCONNECTED".equals(state) || "FAILED".equals(state)) endCall();
                });
            }
            @Override public void onError(String error) {
                runOnUiThread(() -> toast("Call error: " + error));
            }
        });

        webRTC.init(videoCall, localVideoView, remoteVideoView);
        isCallActive = true;
    }

    private void prepareCallUI(String name, String emoji, boolean isCalling, boolean videoCall) {
        showCallView();
        tvCallName.setText(name != null ? name : "Unknown");
        tvCallEmoji.setText(emoji != null ? emoji : "👤");
        tvCallStatus.setText(isCalling ? "Calling…" : "Incoming call…");
        tvCallDuration.setVisibility(View.GONE);

        btnAcceptCall.setVisibility(isCalling ? View.GONE : View.VISIBLE);
        localVideoView.setVisibility(videoCall ? View.VISIBLE : View.GONE);
        remoteVideoView.setVisibility(videoCall ? View.VISIBLE : View.GONE);
    }

    private void onCallConnected() {
        runOnUiThread(() -> {
            tvCallStatus.setText("Connected");
            tvCallDuration.setVisibility(View.VISIBLE);
            btnAcceptCall.setVisibility(View.GONE);
            stopRingtone();
            startCallTimer();
        });
    }

    private void startCallTimer() {
        callStartTime = System.currentTimeMillis();
        timerRunnable = new Runnable() {
            @Override public void run() {
                long elapsed = System.currentTimeMillis() - callStartTime;
                long secs  = (elapsed / 1000) % 60;
                long mins  = (elapsed / 60000) % 60;
                if (tvCallDuration != null)
                    tvCallDuration.setText(String.format(Locale.US, "%02d:%02d", mins, secs));
                callTimerHandler.postDelayed(this, 1000);
            }
        };
        callTimerHandler.post(timerRunnable);
    }

    private void endCall() {
        if (timerRunnable != null) callTimerHandler.removeCallbacks(timerRunnable);
        stopRingtone();

        long duration = isCallActive ? (System.currentTimeMillis() - callStartTime) / 1000 : 0;
        if (webRTC != null) { webRTC.release(); webRTC = null; }
        isCallActive = false;

        // Clean Firebase
        if (currentChatUid != null) {
            db.child("calls").child(currentChatUid).removeValue();
            db.child("calls").child(myUid).removeValue();
            String icePath1 = myUid + "_to_" + currentChatUid;
            String icePath2 = currentChatUid + "_to_" + myUid;
            db.child("iceCandidates").child(icePath1).removeValue();
            db.child("iceCandidates").child(icePath2).removeValue();
        }

        // Save call log
        if (currentChatUid != null && myUid != null) {
            CallRecord log = new CallRecord();
            log.callId     = currentCallId;
            log.callerId   = isCaller ? myUid : currentChatUid;
            log.callerName = isCaller ? myName : currentChatName;
            log.callerEmoji= isCaller ? myEmoji : currentChatEmoji;
            log.receiverId = isCaller ? currentChatUid : myUid;
            log.type       = isVideoCallActive ? "video" : "voice";
            log.status     = "ended";
            log.startTime  = callStartTime;
            log.endTime    = System.currentTimeMillis();
            log.duration   = duration;
            db.child("callLogs").child(myUid).push().setValue(log);
        }

        runOnUiThread(() -> {
            if (currentChatUid != null) {
                ChatMeta cm = new ChatMeta();
                cm.uid  = currentChatUid;
                cm.name = currentChatName;
                cm.emoji= currentChatEmoji;
                openChat(cm);
            } else {
                showMainView();
            }
        });
    }

    private void toggleMute() {
        if (webRTC == null) return;
        webRTC.toggleMute();
        toast(webRTC.isMuted() ? "Muted" : "Unmuted");
    }

    private void toggleCamera() {
        if (webRTC == null) return;
        webRTC.toggleCamera();
    }

    private void flipCamera() {
        if (webRTC == null) return;
        webRTC.flipCamera();
    }

    private void toggleSpeaker() {
        AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);
        am.setSpeakerphoneOn(!am.isSpeakerphoneOn());
        toast(am.isSpeakerphoneOn() ? "Speaker On" : "Speaker Off");
    }

    private void playRingtone() {
        try {
            ringtone = MediaPlayer.create(this, android.provider.Settings.System.DEFAULT_RINGTONE_URI);
            if (ringtone != null) { ringtone.setLooping(true); ringtone.start(); }
        } catch (Exception e) { Log.e(TAG, "Ringtone err", e); }
    }

    private void stopRingtone() {
        if (ringtone != null) {
            ringtone.stop(); ringtone.release(); ringtone = null;
        }
    }

    // ════════════════════════════════════════════════════════════
    // MAIN MENU
    // ════════════════════════════════════════════════════════════
    private void showMainMenu(View anchor) {
        android.widget.PopupMenu popup = new android.widget.PopupMenu(this, anchor);
        popup.getMenu().add(0, 1, 0, "My Profile");
        popup.getMenu().add(0, 2, 0, "Search User");
        popup.getMenu().add(0, 3, 0, "Mute Chat");
        popup.getMenu().add(0, 4, 0, "Block User");
        popup.getMenu().add(0, 5, 0, "Logout");
        popup.setOnMenuItemClickListener(item -> {
            switch (item.getItemId()) {
                case 1: showProfileView(); return true;
                case 2: showSearchDialog(); return true;
                case 3: muteCurrentChat(); return true;
                case 4: blockCurrentUser(); return true;
                case 5: logout(); return true;
            }
            return false;
        });
        popup.show();
    }

    private void showSearchDialog() {
        View v = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        TextView title = v.findViewById(R.id.tvDialogTitle);
        title.setText("Search User by UID");
        v.findViewById(R.id.tilInput2).setVisibility(View.GONE);
        v.findViewById(R.id.tilInput3).setVisibility(View.GONE);
        EditText et = v.findViewById(R.id.etInput1);
        et.setHint("5-digit UID");
        et.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);

        new MaterialAlertDialogBuilder(this)
            .setTitle("Search")
            .setView(v)
            .setPositiveButton("Search", (d, w) -> {
                String uid = et.getText().toString().trim();
                if (uid.length() == 5) searchUser(uid);
                else toast("Enter a valid 5-digit UID");
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void searchUser(String uid) {
        db.child("users").child(uid)
          .addListenerForSingleValueEvent(new ValueEventListener() {
              @Override public void onDataChange(DataSnapshot snap) {
                  if (!snap.exists()) { toast("User not found"); return; }
                  User u = snap.getValue(User.class);
                  if (u == null) return;
                  new MaterialAlertDialogBuilder(MainActivity.this)
                      .setTitle(u.emoji + " " + u.name)
                      .setMessage("UID: " + uid + "\n" + (u.bio != null ? u.bio : ""))
                      .setPositiveButton("Send Friend Request", (d, w) -> sendFriendRequest(uid))
                      .setNegativeButton("Close", null)
                      .show();
              }
              @Override public void onCancelled(DatabaseError e) {}
          });
    }

    private void muteCurrentChat() {
        if (currentChatUid == null) { toast("Open a chat first"); return; }
        isMutedChat = !isMutedChat;
        db.child("chats").child(myUid).child(currentChatUid).child("muted").setValue(isMutedChat);
        toast(isMutedChat ? "Chat muted" : "Chat unmuted");
    }

    private void blockCurrentUser() {
        if (currentChatUid == null) { toast("Open a chat first"); return; }
        isBlocked = !isBlocked;
        db.child("chats").child(myUid).child(currentChatUid).child("blocked").setValue(isBlocked);
        toast(isBlocked ? "User blocked" : "User unblocked");
    }

    // ════════════════════════════════════════════════════════════
    // HELPERS
    // ════════════════════════════════════════════════════════════
    private void detachChatListeners() {
        if (msgListener != null && currentChatUid != null)
            db.child("messages").child(chatRoomId(myUid, currentChatUid))
              .removeEventListener(msgListener);
        if (typingListener != null && currentChatUid != null)
            db.child("typing").child(currentChatUid).child(myUid)
              .removeEventListener(typingListener);
        sendTypingIndicator(false);
    }

    private String chatRoomId(String a, String b) {
        return a.compareTo(b) < 0 ? a + "_" + b : b + "_" + a;
    }

    private String formatTime(long ts) {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.US);
        return sdf.format(new Date(ts));
    }

    private void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    private void setOnlineStatus(boolean online) {
        if (myUid == null) return;
        Map<String, Object> upd = new HashMap<>();
        upd.put("online",   online);
        upd.put("lastSeen", System.currentTimeMillis());
        db.child("users").child(myUid).updateChildren(upd);
    }

    private void startBackgroundService() {
        Intent svc = new Intent(this, BackgroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            startForegroundService(svc);
        else
            startService(svc);
    }

    private void logout() {
        setOnlineStatus(false);
        mAuth.signOut();
        if (webRTC != null) { webRTC.release(); webRTC = null; }
        stopRingtone();
        myUid = null; myName = null; myEmoji = null; myBio = null;
        showAuthView();
        showLoginForm();
    }

    private void requestPermissions() {
        List<String> perms = new ArrayList<>();
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED)
            perms.add(Manifest.permission.CAMERA);
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED)
            perms.add(Manifest.permission.RECORD_AUDIO);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED)
            perms.add(Manifest.permission.POST_NOTIFICATIONS);
        if (!perms.isEmpty())
            ActivityCompat.requestPermissions(this, perms.toArray(new String[0]), REQ_PERMS);
    }

    // ════════════════════════════════════════════════════════════
    // LIFECYCLE
    // ════════════════════════════════════════════════════════════
    @Override protected void onResume() {
        super.onResume();
        isAppInForeground = true;
        if (myUid != null) setOnlineStatus(true);
    }

    @Override protected void onPause() {
        super.onPause();
        isAppInForeground = false;
        if (myUid != null) setOnlineStatus(false);
    }

    @Override protected void onDestroy() {
        if (webRTC != null) { webRTC.release(); webRTC = null; }
        stopRingtone();
        if (chatListListener != null && myUid != null)
            db.child("chats").child(myUid).removeEventListener(chatListListener);
        if (callListener != null && myUid != null)
            db.child("calls").child(myUid).removeEventListener(callListener);
        if (callLogDbListener != null && myUid != null)
            db.child("callLogs").child(myUid).removeEventListener(callLogDbListener);
        if (friendRequestListener != null && myUid != null)
            db.child("friendRequests").child(myUid).removeEventListener(friendRequestListener);
        super.onDestroy();
    }

    @Override public void onBackPressed() {
        if (callContainer.getVisibility() == View.VISIBLE) {
            // Do nothing while in call
        } else if (chatContainer.getVisibility() == View.VISIBLE) {
            closeChatView();
        } else if (profileContainer.getVisibility() == View.VISIBLE) {
            showMainView();
        } else {
            super.onBackPressed();
        }
    }
}
JAVAEOF

# ─── Gradle wrapper jar (download) ──────────────────────────────────────────
# We'll let the gradle wrapper download task handle this
mkdir -p gradle/wrapper

# Download gradle wrapper jar
echo "Downloading gradle-wrapper.jar..."
curl -sL -o gradle/wrapper/gradle-wrapper.jar \
  "https://raw.githubusercontent.com/nicoulaj/idea-byteman/master/gradle/wrapper/gradle-wrapper.jar" \
  2>/dev/null || true

# If above fails, try alternative
if [ ! -s gradle/wrapper/gradle-wrapper.jar ]; then
    curl -sL -o gradle/wrapper/gradle-wrapper.jar \
      "https://github.com/gradle/gradle/raw/v8.2.0/gradle/wrapper/gradle-wrapper.jar" \
      2>/dev/null || true
fi

# ─── gradlew script ─────────────────────────────────────────────────────────
cat <<'EOF' > gradlew
#!/bin/sh
##############################################################################
# Gradle start up script for UN*X
##############################################################################
APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'
CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

# Determine the Java command to use
if [ -n "$JAVA_HOME" ] ; then
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD="java"
fi

APP_HOME=`dirname "$0"`
APP_HOME=`cd "$APP_HOME" && pwd`

exec "$JAVACMD" $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS \
  -classpath "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" \
  org.gradle.wrapper.GradleWrapperMain "$@"
EOF
chmod +x gradlew

# ─── Setup Android SDK ───────────────────────────────────────────────────────
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "Downloading Android Command Line Tools..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    wget -q -O /tmp/cmdline-tools.zip \
      "https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip"
    unzip -q -o /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extract
    mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
    cp -r /tmp/cmdline-tools-extract/cmdline-tools/. "$ANDROID_HOME/cmdline-tools/latest/"
fi

echo "Accepting licenses..."
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true

echo "Installing Android SDK packages..."
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    2>/dev/null || true

# ─── local.properties ────────────────────────────────────────────────────────
cat > local.properties <<LOCALEOF
sdk.dir=$ANDROID_HOME
LOCALEOF

# ─── Download Gradle 8.2 and set up wrapper ──────────────────────────────────
if [ ! -d "/opt/gradle/gradle-8.2" ]; then
    echo "Downloading Gradle 8.2..."
    wget -q -O /tmp/gradle-8.2-bin.zip \
        "https://services.gradle.org/distributions/gradle-8.2-bin.zip"
    sudo mkdir -p /opt/gradle
    sudo unzip -q -o -d /opt/gradle /tmp/gradle-8.2-bin.zip
fi

export PATH="/opt/gradle/gradle-8.2/bin:$PATH"

echo "Generating Gradle wrapper..."
/opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2 2>/dev/null || true
chmod +x gradlew

# Download the actual wrapper jar using gradle itself
if [ ! -s gradle/wrapper/gradle-wrapper.jar ]; then
    /opt/gradle/gradle-8.2/bin/gradle wrapper 2>/dev/null || true
fi

echo ""
echo "════════════════════════════════════════════════"
echo "  Building Java Goat APK..."
echo "════════════════════════════════════════════════"

export JAVA_OPTS="-Xmx4g"
export GRADLE_OPTS="-Xmx4g -Dfile.encoding=UTF-8"

./gradlew clean assembleRelease \
    --no-daemon \
    --stacktrace \
    -Pandroid.sdk.path="$ANDROID_HOME" \
    2>&1 | tail -50

echo ""
if [ -f "app/build/outputs/apk/release/app-release.apk" ]; then
    echo "✅ BUILD SUCCESS!"
    echo "APK: $PROJECT_ROOT/app/build/outputs/apk/release/app-release.apk"
    ls -lh app/build/outputs/apk/release/app-release.apk
else
    echo "Build output:"
    find app/build/outputs -name "*.apk" 2>/dev/null || echo "No APK found"
    echo ""
    echo "Check build logs above for errors."
fi