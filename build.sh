#!/usr/bin/env bash
set -e

PROJECT_ROOT="/workspaces/videocallpro/JavaGoat"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

# ─── Directory Structure ───────────────────────────────────────────────────────
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

# ─── Android SDK Setup ────────────────────────────────────────────────────────
export ANDROID_SDK_ROOT="$HOME/android-sdk"
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

if [ ! -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "Downloading Android command-line tools..."
  wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O /tmp/cmdline-tools.zip
  unzip -q -o /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extracted
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  cp -r /tmp/cmdline-tools-extracted/cmdline-tools/* "$ANDROID_SDK_ROOT/cmdline-tools/latest/"
fi

export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools" > /dev/null 2>&1

# ─── Keystore Generation ──────────────────────────────────────────────────────
if [ ! -f "$PROJECT_ROOT/javagoat-release.jks" ]; then
  keytool -genkeypair \
    -alias javagoat \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -keystore "$PROJECT_ROOT/javagoat-release.jks" \
    -storepass javagoat123 \
    -keypass javagoat123 \
    -dname "CN=JavaGoat,OU=Dev,O=JavaGoat,L=City,ST=State,C=US" \
    -noprompt
fi

# ─── settings.gradle ──────────────────────────────────────────────────────────
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
        maven { url = uri("https://jitpack.io") }
    }
}
rootProject.name = "JavaGoat"
include ':app'
EOF

# ─── gradle.properties ────────────────────────────────────────────────────────
cat <<'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
org.gradle.daemon=true
org.gradle.parallel=true
EOF

# ─── Root build.gradle ────────────────────────────────────────────────────────
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

# ─── app/build.gradle ─────────────────────────────────────────────────────────
cat <<EOF > app/build.gradle
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
            storeFile file("${PROJECT_ROOT}/javagoat-release.jks")
            storePassword "javagoat123"
            keyAlias "javagoat"
            keyPassword "javagoat123"
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

    buildFeatures {
        viewBinding false
    }

    packaging {
        resources {
            excludes += ['/META-INF/{AL2.0,LGPL2.1}', 'META-INF/INDEX.LIST', 'META-INF/io.netty.versions.properties']
        }
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
}
EOF

# ─── google-services.json (placeholder — user must replace) ──────────────────
cat <<'EOF' > app/google-services.json
{
  "project_info": {
    "project_number": "123456789012",
    "project_id": "javagoat-demo",
    "storage_bucket": "javagoat-demo.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef1234567890",
        "android_client_info": {
          "package_name": "com.example.callingapp"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyDEMO_REPLACE_WITH_REAL_KEY"
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

# ─── proguard-rules.pro ───────────────────────────────────────────────────────
cat <<'EOF' > app/proguard-rules.pro
-keep class com.example.callingapp.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
EOF

# ─── Gradle Wrapper ───────────────────────────────────────────────────────────
cat <<'EOF' > gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

wget -q "https://services.gradle.org/distributions/gradle-8.2-bin.zip" -O /tmp/gradle-8.2-bin.zip
sudo mkdir -p /opt/gradle
sudo unzip -q -o /tmp/gradle-8.2-bin.zip -d /opt/gradle
/opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2 --project-dir "$PROJECT_ROOT" || true
chmod +x gradlew 2>/dev/null || true

# ─── AndroidManifest.xml ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.front" android:required="false" />
    <uses-feature android:name="android.hardware.microphone" android:required="false" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="Java Goat"
        android:supportsRtl="true"
        android:theme="@style/Theme.JavaGoat"
        tools:targetApi="34">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:windowSoftInputMode="adjustResize"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".BackgroundService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

    </application>
</manifest>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# RESOURCE FILES
# ═══════════════════════════════════════════════════════════════════════════════

# ─── colors.xml ───────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- WhatsApp-style palette -->
    <color name="header_teal">#075E54</color>
    <color name="header_teal_dark">#054C43</color>
    <color name="accent_green">#25D366</color>
    <color name="accent_teal_light">#128C7E</color>
    <color name="msg_out_bg">#DCF8C6</color>
    <color name="msg_in_bg">#FFFFFF</color>
    <color name="background_chat">#ECE5DD</color>
    <color name="background_main">#F0F0F0</color>
    <color name="text_primary">#111B21</color>
    <color name="text_secondary">#667781</color>
    <color name="text_white">#FFFFFF</color>
    <color name="call_accept">#25D366</color>
    <color name="call_reject">#FF3B30</color>
    <color name="call_end">#FF3B30</color>
    <color name="unread_badge">#25D366</color>
    <color name="online_dot">#25D366</color>
    <color name="orange_brand">#FF6B00</color>
    <color name="blue_brand">#1A73E8</color>
    <color name="divider">#E0E0E0</color>
    <color name="toolbar_teal">#075E54</color>
    <color name="status_bar_teal">#054C43</color>
    <color name="black_overlay">#CC000000</color>
    <color name="card_bg">#FFFFFF</color>
    <color name="bottom_nav_selected">#075E54</color>
    <color name="bottom_nav_unselected">#8A9BA8</color>
</resources>
EOF

# ─── strings.xml ──────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Java Goat</string>
    <string name="login">Login</string>
    <string name="signup">Sign Up</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="chats">Chats</string>
    <string name="updates">Updates</string>
    <string name="calls">Calls</string>
    <string name="send">Send</string>
    <string name="type_message">Type a message…</string>
    <string name="accept">Accept</string>
    <string name="reject">Reject</string>
    <string name="end_call">End</string>
    <string name="connecting">Connecting…</string>
    <string name="incoming_call">Incoming Call</string>
    <string name="outgoing_call">Calling…</string>
    <string name="add_friend">Add Friend</string>
    <string name="profile">Profile</string>
    <string name="logout">Logout</string>
    <string name="friend_id_hint">Enter jg-XXXX ID</string>
    <string name="name_hint">Your name</string>
    <string name="emoji_hint">Pick an emoji avatar</string>
    <string name="no_chats">No chats yet. Add a friend!</string>
    <string name="no_calls">No call history.</string>
    <string name="no_updates">No updates.</string>
</resources>
EOF

# ─── styles.xml ───────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/values/styles.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.JavaGoat" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/header_teal</item>
        <item name="colorPrimaryDark">@color/header_teal_dark</item>
        <item name="colorAccent">@color/accent_green</item>
        <item name="android:statusBarColor">@color/status_bar_teal</item>
        <item name="android:navigationBarColor">@color/header_teal</item>
        <item name="android:windowBackground">@color/background_main</item>
    </style>

    <style name="BrandTitle.Orange" parent="TextAppearance.MaterialComponents.Headline6">
        <item name="android:textColor">@color/orange_brand</item>
        <item name="android:textStyle">bold</item>
        <item name="android:textSize">20sp</item>
    </style>

    <style name="BrandTitle.Blue" parent="TextAppearance.MaterialComponents.Headline6">
        <item name="android:textColor">@color/blue_brand</item>
        <item name="android:textStyle">bold</item>
        <item name="android:textSize">20sp</item>
    </style>

    <style name="CallButton">
        <item name="android:layout_width">64dp</item>
        <item name="android:layout_height">64dp</item>
        <item name="android:elevation">4dp</item>
    </style>
</resources>
EOF

# ─── msg_out_bg.xml ───────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/msg_out_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/msg_out_bg" />
    <corners
        android:topLeftRadius="12dp"
        android:topRightRadius="12dp"
        android:bottomLeftRadius="12dp"
        android:bottomRightRadius="2dp" />
    <stroke android:width="0.5dp" android:color="#C8E6C9" />
</shape>
EOF

# ─── msg_in_bg.xml ────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/msg_in_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/msg_in_bg" />
    <corners
        android:topLeftRadius="2dp"
        android:topRightRadius="12dp"
        android:bottomLeftRadius="12dp"
        android:bottomRightRadius="12dp" />
    <stroke android:width="0.5dp" android:color="#E0E0E0" />
</shape>
EOF

# ─── emoji_bg.xml ─────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/emoji_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/accent_teal_light" />
</shape>
EOF

# ─── rounded_btn.xml ──────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/rounded_btn.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/header_teal" />
    <corners android:radius="8dp" />
</shape>
EOF

# ─── rounded_input.xml ────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/rounded_input.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/msg_in_bg" />
    <corners android:radius="24dp" />
    <stroke android:width="1dp" android:color="@color/divider" />
</shape>
EOF

# ─── call_btn_accept.xml ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/call_btn_accept.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/call_accept" />
</shape>
EOF

# ─── call_btn_reject.xml ──────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/call_btn_reject.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/call_reject" />
</shape>
EOF

# ─── ic_launcher_background.xml ───────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_background.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/header_teal" />
</shape>
EOF

# ─── ic_launcher_foreground.xml ───────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_foreground.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M54,20 C35.2,20 20,33.4 20,50 C20,58.8 24.2,66.6 31,72 L28,88 L44,80 C47.2,81.2 50.6,82 54,82 C72.8,82 88,68.6 88,52 C88,35.4 72.8,20 54,20 Z M54,26 C69.4,26 82,38 82,52 C82,66 69.4,76 54,76 C50.8,76 47.8,75.4 44.8,74.4 L43.2,73.8 L36,77.4 L37.8,70.4 L37,69.4 C32,65 26,58.8 26,50 C26,37.2 38.8,26 54,26 Z" />
</vector>
EOF

# ─── ic_launcher.xml (mipmap-anydpi-v26) ──────────────────────────────────────
cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

# ─── Bottom Navigation Menu ────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/menu/bottom_nav_menu.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/nav_chats"
        android:icon="@android:drawable/ic_menu_send"
        android:title="Chats" />
    <item
        android:id="@+id/nav_updates"
        android:icon="@android:drawable/ic_menu_info_details"
        android:title="Updates" />
    <item
        android:id="@+id/nav_calls"
        android:icon="@android:drawable/ic_menu_call"
        android:title="Calls" />
</menu>
EOF

# ─── Main Menu ────────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/menu/main_menu.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/action_add_friend"
        android:title="Add Friend"
        android:icon="@android:drawable/ic_input_add"
        app:showAsAction="ifRoom" />
    <item
        android:id="@+id/action_profile"
        android:title="Profile"
        app:showAsAction="never" />
    <item
        android:id="@+id/action_logout"
        android:title="Logout"
        app:showAsAction="never" />
</menu>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# LAYOUTS
# ═══════════════════════════════════════════════════════════════════════════════

# ─── activity_main.xml ────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/rootFrame"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background_main">

    <!-- ════ AUTH VIEW ════ -->
    <LinearLayout
        android:id="@+id/authView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:gravity="center"
        android:padding="32dp"
        android:background="@color/header_teal"
        android:visibility="visible">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="🐐 Java Goat"
            android:textSize="36sp"
            android:textStyle="bold"
            android:textColor="@color/text_white"
            android:layout_marginBottom="8dp" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Simple. Fast. Reliable."
            android:textSize="14sp"
            android:textColor="#B2DFDB"
            android:layout_marginBottom="48dp" />

        <com.google.android.material.textfield.TextInputLayout
            style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="Email"
            android:layout_marginBottom="16dp">
            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/etEmail"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="textEmailAddress"
                android:textColor="@color/text_white"
                android:textColorHint="#B2DFDB" />
        </com.google.android.material.textfield.TextInputLayout>

        <com.google.android.material.textfield.TextInputLayout
            style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="Password"
            app:passwordToggleEnabled="true"
            android:layout_marginBottom="24dp">
            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/etPassword"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="textPassword"
                android:textColor="@color/text_white"
                android:textColorHint="#B2DFDB" />
        </com.google.android.material.textfield.TextInputLayout>

        <Button
            android:id="@+id/btnLogin"
            android:layout_width="match_parent"
            android:layout_height="48dp"
            android:text="Login"
            android:textColor="@color/header_teal"
            android:backgroundTint="@color/text_white"
            android:layout_marginBottom="12dp" />

        <Button
            android:id="@+id/btnSignup"
            style="@style/Widget.MaterialComponents.Button.OutlinedButton"
            android:layout_width="match_parent"
            android:layout_height="48dp"
            android:text="Sign Up"
            android:textColor="@color/text_white"
            app:strokeColor="@color/text_white" />
    </LinearLayout>

    <!-- ════ MAIN VIEW ════ -->
    <LinearLayout
        android:id="@+id/mainView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:visibility="gone">

        <androidx.appcompat.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@color/header_teal"
            android:elevation="4dp">

            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Java "
                    android:textSize="20sp"
                    android:textStyle="bold"
                    android:textColor="@color/orange_brand" />

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Goat"
                    android:textSize="20sp"
                    android:textStyle="bold"
                    android:textColor="@color/blue_brand" />
            </LinearLayout>

        </androidx.appcompat.widget.Toolbar>

        <FrameLayout
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1">

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/mainRecycler"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:clipToPadding="false"
                android:padding="0dp" />

            <TextView
                android:id="@+id/tvEmpty"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="center"
                android:text="No chats yet. Add a friend!"
                android:textColor="@color/text_secondary"
                android:textSize="16sp"
                android:visibility="gone" />
        </FrameLayout>

        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottomNav"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@color/card_bg"
            app:menu="@menu/bottom_nav_menu"
            app:itemIconTint="@color/bottom_nav_unselected"
            app:itemTextColor="@color/bottom_nav_unselected"
            app:labelVisibilityMode="labeled" />
    </LinearLayout>

    <!-- ════ CHAT VIEW ════ -->
    <LinearLayout
        android:id="@+id/chatView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:visibility="gone">

        <!-- Chat Toolbar -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@color/header_teal"
            android:orientation="horizontal"
            android:gravity="center_vertical"
            android:padding="8dp"
            android:elevation="4dp">

            <ImageButton
                android:id="@+id/btnChatBack"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_media_previous"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:tint="@color/text_white" />

            <TextView
                android:id="@+id/tvChatEmoji"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:gravity="center"
                android:textSize="24sp"
                android:background="@drawable/emoji_bg"
                android:layout_marginStart="4dp" />

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
                    android:textColor="@color/text_white"
                    android:textSize="16sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/tvChatStatus"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textColor="#B2DFDB"
                    android:textSize="12sp"
                    android:text="online" />
            </LinearLayout>

            <ImageButton
                android:id="@+id/btnVoiceCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_call"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:tint="@color/text_white" />

            <ImageButton
                android:id="@+id/btnVideoCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_camera"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:tint="@color/text_white"
                android:layout_marginStart="4dp" />
        </LinearLayout>

        <!-- Messages -->
        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/chatRecycler"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"
            android:background="@color/background_chat"
            android:clipToPadding="false"
            android:paddingTop="8dp"
            android:paddingBottom="8dp" />

        <!-- Input Bar -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@color/card_bg"
            android:orientation="horizontal"
            android:padding="8dp"
            android:gravity="center_vertical">

            <EditText
                android:id="@+id/etMessage"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:hint="Type a message…"
                android:background="@drawable/rounded_input"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                android:paddingTop="10dp"
                android:paddingBottom="10dp"
                android:maxLines="4"
                android:inputType="textMultiLine"
                android:textSize="15sp" />

            <ImageButton
                android:id="@+id/btnSend"
                android:layout_width="48dp"
                android:layout_height="48dp"
                android:src="@android:drawable/ic_menu_send"
                android:background="@drawable/emoji_bg"
                android:tint="@color/text_white"
                android:layout_marginStart="8dp" />
        </LinearLayout>
    </LinearLayout>

    <!-- ════ CALL VIEW ════ -->
    <FrameLayout
        android:id="@+id/callView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/black_overlay"
        android:visibility="gone">

        <!-- Remote Video (full screen) -->
        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/remoteVideoView"
            android:layout_width="match_parent"
            android:layout_height="match_parent" />

        <!-- Dark overlay for UI -->
        <View
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:background="#80000000" />

        <!-- Local Video (corner) -->
        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/localVideoView"
            android:layout_width="120dp"
            android:layout_height="160dp"
            android:layout_gravity="top|end"
            android:layout_margin="16dp"
            android:background="@color/header_teal_dark" />

        <!-- Caller Info -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="top|center_horizontal"
            android:orientation="vertical"
            android:gravity="center_horizontal"
            android:paddingTop="80dp">

            <TextView
                android:id="@+id/tvCallEmoji"
                android:layout_width="80dp"
                android:layout_height="80dp"
                android:gravity="center"
                android:textSize="40sp"
                android:background="@drawable/emoji_bg" />

            <TextView
                android:id="@+id/tvCallName"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/text_white"
                android:textSize="28sp"
                android:textStyle="bold"
                android:layout_marginTop="16dp" />

            <TextView
                android:id="@+id/tvCallStatus"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="#B2DFDB"
                android:textSize="16sp"
                android:layout_marginTop="8dp"
                android:text="Connecting…" />
        </LinearLayout>

        <!-- Call Buttons -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="bottom|center_horizontal"
            android:orientation="horizontal"
            android:gravity="center"
            android:paddingBottom="60dp"
            android:spacing="32dp">

            <ImageButton
                android:id="@+id/btnAcceptCall"
                android:layout_width="72dp"
                android:layout_height="72dp"
                android:src="@android:drawable/ic_menu_call"
                android:background="@drawable/call_btn_accept"
                android:tint="@color/text_white"
                android:layout_marginEnd="40dp"
                android:visibility="gone" />

            <ImageButton
                android:id="@+id/btnEndCall"
                android:layout_width="72dp"
                android:layout_height="72dp"
                android:src="@android:drawable/ic_menu_close_clear_cancel"
                android:background="@drawable/call_btn_reject"
                android:tint="@color/text_white" />
        </LinearLayout>
    </FrameLayout>

</FrameLayout>
EOF

# ─── item_list.xml ────────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/item_list.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginHorizontal="0dp"
    android:layout_marginVertical="0dp"
    app:cardElevation="0dp"
    app:cardCornerRadius="0dp"
    app:cardBackgroundColor="@color/card_bg">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="72dp"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:paddingHorizontal="16dp">

        <!-- Avatar / Emoji -->
        <FrameLayout
            android:layout_width="52dp"
            android:layout_height="52dp">

            <TextView
                android:id="@+id/tvItemEmoji"
                android:layout_width="52dp"
                android:layout_height="52dp"
                android:gravity="center"
                android:textSize="26sp"
                android:background="@drawable/emoji_bg" />

            <View
                android:id="@+id/onlineDot"
                android:layout_width="12dp"
                android:layout_height="12dp"
                android:layout_gravity="bottom|end"
                android:background="@drawable/call_btn_accept"
                android:visibility="gone" />
        </FrameLayout>

        <!-- Text -->
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:layout_marginStart="12dp">

            <TextView
                android:id="@+id/tvItemName"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textColor="@color/text_primary"
                android:textSize="16sp"
                android:textStyle="bold"
                android:maxLines="1"
                android:ellipsize="end" />

            <TextView
                android:id="@+id/tvItemSub"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textColor="@color/text_secondary"
                android:textSize="13sp"
                android:maxLines="1"
                android:ellipsize="end" />
        </LinearLayout>

        <!-- Right side: time + badge OR action buttons -->
        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:gravity="end|center_vertical">

            <TextView
                android:id="@+id/tvItemTime"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/text_secondary"
                android:textSize="11sp" />

            <TextView
                android:id="@+id/tvUnreadBadge"
                android:layout_width="22dp"
                android:layout_height="22dp"
                android:gravity="center"
                android:textSize="11sp"
                android:textColor="@color/text_white"
                android:textStyle="bold"
                android:background="@drawable/call_btn_accept"
                android:visibility="gone"
                android:layout_marginTop="4dp" />
        </LinearLayout>

        <!-- Accept/Reject buttons (for friend requests) -->
        <LinearLayout
            android:id="@+id/actionButtons"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:visibility="gone">

            <Button
                android:id="@+id/btnAccept"
                style="@style/Widget.MaterialComponents.Button"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="Accept"
                android:textSize="12sp"
                android:paddingHorizontal="12dp"
                android:backgroundTint="@color/call_accept" />

            <Button
                android:id="@+id/btnReject"
                style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="Reject"
                android:textSize="12sp"
                android:paddingHorizontal="12dp"
                android:layout_marginStart="8dp"
                app:strokeColor="@color/call_reject"
                android:textColor="@color/call_reject" />
        </LinearLayout>
    </LinearLayout>

    <!-- Divider -->
    <View
        android:layout_width="match_parent"
        android:layout_height="1dp"
        android:layout_gravity="bottom"
        android:layout_marginStart="80dp"
        android:background="@color/divider" />

</androidx.cardview.widget.CardView>
EOF

# ─── item_message.xml ─────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/item_message.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:paddingHorizontal="8dp"
    android:paddingVertical="2dp">

    <!-- Outgoing message (right) -->
    <LinearLayout
        android:id="@+id/outgoingBubble"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="end"
        android:orientation="vertical"
        android:background="@drawable/msg_out_bg"
        android:paddingHorizontal="12dp"
        android:paddingVertical="6dp"
        android:maxWidth="280dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvOutText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/text_primary"
            android:textSize="15sp"
            android:lineSpacingExtra="2dp" />

        <TextView
            android:id="@+id/tvOutTime"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:textColor="@color/text_secondary"
            android:textSize="10sp"
            android:layout_marginTop="2dp" />
    </LinearLayout>

    <!-- Incoming message (left) -->
    <LinearLayout
        android:id="@+id/incomingBubble"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="start"
        android:orientation="vertical"
        android:background="@drawable/msg_in_bg"
        android:paddingHorizontal="12dp"
        android:paddingVertical="6dp"
        android:maxWidth="280dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvInText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/text_primary"
            android:textSize="15sp"
            android:lineSpacingExtra="2dp" />

        <TextView
            android:id="@+id/tvInTime"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/text_secondary"
            android:textSize="10sp"
            android:layout_marginTop="2dp" />
    </LinearLayout>

</FrameLayout>
EOF

# ─── dialog_input.xml ─────────────────────────────────────────────────────────
cat <<'EOF' > app/src/main/res/layout/dialog_input.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="24dp">

    <TextView
        android:id="@+id/tvDialogTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Enter Details"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="@color/text_primary"
        android:layout_marginBottom="16dp" />

    <EditText
        android:id="@+id/etDialogInput1"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Name"
        android:inputType="textPersonName"
        android:background="@drawable/rounded_input"
        android:paddingHorizontal="16dp"
        android:paddingVertical="12dp"
        android:layout_marginBottom="12dp" />

    <EditText
        android:id="@+id/etDialogInput2"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Emoji avatar (e.g. 🐐)"
        android:background="@drawable/rounded_input"
        android:paddingHorizontal="16dp"
        android:paddingVertical="12dp"
        android:layout_marginBottom="8dp" />

    <TextView
        android:id="@+id/tvDialogInfo"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/text_secondary"
        android:textSize="13sp"
        android:layout_marginBottom="8dp" />

</LinearLayout>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# JAVA SOURCE FILES
# ═══════════════════════════════════════════════════════════════════════════════

SRC="app/src/main/java/com/example/callingapp"

# ─── BackgroundService.java ───────────────────────────────────────────────────
cat <<'EOF' > "$SRC/BackgroundService.java"
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

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class BackgroundService extends Service {

    private static final String TAG = "BackgroundService";
    private static final String CHANNEL_PERSISTENT = "jg_persistent";
    private static final String CHANNEL_MESSAGES   = "jg_messages";
    private static final String CHANNEL_CALLS      = "jg_calls";
    private static final int    NOTIF_PERSISTENT   = 1001;
    private static final int    NOTIF_MESSAGE_BASE = 2000;
    private static final int    NOTIF_CALL         = 3001;

    private DatabaseReference dbRef;
    private ValueEventListener msgListener;
    private ValueEventListener callListener;
    private String myUid;

    @Override
    public void onCreate() {
        super.onCreate();
        createChannels();
        startForeground(NOTIF_PERSISTENT, buildPersistentNotification());

        FirebaseAuth auth = FirebaseAuth.getInstance();
        if (auth.getCurrentUser() == null) return;
        myUid = auth.getCurrentUser().getUid();
        dbRef = FirebaseDatabase.getInstance().getReference();
        startListeners();
    }

    private void startListeners() {
        // Unread message count listener
        msgListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                if (MainActivity.isAppInForeground) return;
                for (DataSnapshot contact : snapshot.getChildren()) {
                    Object unreadObj = contact.child("unread").getValue();
                    if (unreadObj == null) continue;
                    long unread = 0;
                    if (unreadObj instanceof Long)   unread = (Long) unreadObj;
                    if (unreadObj instanceof Integer) unread = ((Integer) unreadObj).longValue();
                    if (unread > 0) {
                        String name = contact.child("name").getValue(String.class);
                        if (name == null) name = "Someone";
                        String emoji = contact.child("emoji").getValue(String.class);
                        if (emoji == null) emoji = "💬";
                        fireMessageNotification(name, emoji, unread);
                    }
                }
            }
            @Override
            public void onCancelled(DatabaseError error) {
                Log.e(TAG, "msgListener cancelled: " + error.getMessage());
            }
        };
        dbRef.child("users").child(myUid).child("contacts")
             .addValueEventListener(msgListener);

        // Incoming call listener
        callListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                if (!snapshot.exists()) return;
                String callerUid = snapshot.child("callerUid").getValue(String.class);
                if (callerUid == null || callerUid.equals(myUid)) return;
                Boolean accepted = snapshot.child("accepted").getValue(Boolean.class);
                if (accepted != null && accepted) return;

                String callerName  = snapshot.child("callerName").getValue(String.class);
                String callerEmoji = snapshot.child("callerEmoji").getValue(String.class);
                boolean isVideo    = Boolean.TRUE.equals(snapshot.child("isVideo").getValue(Boolean.class));
                if (callerName == null) callerName = "Unknown";
                if (callerEmoji == null) callerEmoji = "📞";
                fireCallNotification(callerName, callerEmoji, isVideo);
            }
            @Override
            public void onCancelled(DatabaseError error) {
                Log.e(TAG, "callListener cancelled: " + error.getMessage());
            }
        };
        dbRef.child("calls").child(myUid).addValueEventListener(callListener);
    }

    private void fireMessageNotification(String name, String emoji, long unread) {
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Notification n = new NotificationCompat.Builder(this, CHANNEL_MESSAGES)
                .setSmallIcon(android.R.drawable.ic_dialog_email)
                .setContentTitle(emoji + " " + name)
                .setContentText(unread + " new message" + (unread > 1 ? "s" : ""))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pi)
                .build();
        nm.notify(NOTIF_MESSAGE_BASE, n);
    }

    private void fireCallNotification(String name, String emoji, boolean isVideo) {
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        Intent fullIntent = new Intent(this, MainActivity.class);
        fullIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        fullIntent.putExtra("incoming_call", true);

        int flags = PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE;
        PendingIntent fullScreenPi = PendingIntent.getActivity(this, 1, fullIntent, flags);

        String type = isVideo ? "Video Call" : "Voice Call";
        Notification n = new NotificationCompat.Builder(this, CHANNEL_CALLS)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Incoming " + type)
                .setContentText(emoji + " " + name + " is calling")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setFullScreenIntent(fullScreenPi, true)
                .setAutoCancel(false)
                .setOngoing(true)
                .setTimeoutAfter(60000)
                .build();
        nm.notify(NOTIF_CALL, n);
    }

    private Notification buildPersistentNotification() {
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_IMMUTABLE);
        return new NotificationCompat.Builder(this, CHANNEL_PERSISTENT)
                .setSmallIcon(android.R.drawable.ic_dialog_email)
                .setContentTitle("Java Goat")
                .setContentText("Running in background")
                .setPriority(NotificationCompat.PRIORITY_MIN)
                .setContentIntent(pi)
                .setOngoing(true)
                .build();
    }

    private void createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return;
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        NotificationChannel persistent = new NotificationChannel(
                CHANNEL_PERSISTENT, "Service", NotificationManager.IMPORTANCE_MIN);
        persistent.setShowBadge(false);

        NotificationChannel messages = new NotificationChannel(
                CHANNEL_MESSAGES, "Messages", NotificationManager.IMPORTANCE_HIGH);
        messages.setShowBadge(true);

        NotificationChannel calls = new NotificationChannel(
                CHANNEL_CALLS, "Calls", NotificationManager.IMPORTANCE_HIGH);
        calls.setShowBadge(true);

        nm.createNotificationChannel(persistent);
        nm.createNotificationChannel(messages);
        nm.createNotificationChannel(calls);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (dbRef != null && myUid != null) {
            if (msgListener != null)
                dbRef.child("users").child(myUid).child("contacts").removeEventListener(msgListener);
            if (callListener != null)
                dbRef.child("calls").child(myUid).removeEventListener(callListener);
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) { return null; }
}
EOF

# ─── GenericAdapter.java ──────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/GenericAdapter.java"
package com.example.callingapp;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class GenericAdapter extends RecyclerView.Adapter<GenericAdapter.VH> {

    public interface ItemClickListener { void onClick(int position); }
    public interface ActionListener {
        void onAccept(int position);
        void onReject(int position);
    }

    private List<ListItem> items;
    private ItemClickListener clickListener;
    private ActionListener actionListener;

    public GenericAdapter(List<ListItem> items,
                          ItemClickListener clickListener,
                          ActionListener actionListener) {
        this.items = items;
        this.clickListener = clickListener;
        this.actionListener = actionListener;
    }

    public void setItems(List<ListItem> newItems) {
        this.items = newItems;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_list, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH h, int pos) {
        ListItem item = items.get(pos);
        h.tvEmoji.setText(item.emoji);
        h.tvName.setText(item.name);
        h.tvSub.setText(item.subtitle);
        h.tvTime.setText(item.time);

        // Online dot
        h.onlineDot.setVisibility(item.isOnline ? View.VISIBLE : View.GONE);

        // Unread badge
        if (item.unreadCount > 0) {
            h.tvBadge.setVisibility(View.VISIBLE);
            h.tvBadge.setText(String.valueOf(item.unreadCount));
        } else {
            h.tvBadge.setVisibility(View.GONE);
        }

        // Action buttons (friend requests)
        if (item.showActions) {
            h.actionButtons.setVisibility(View.VISIBLE);
            h.tvTime.setVisibility(View.GONE);
            h.tvBadge.setVisibility(View.GONE);
            h.btnAccept.setOnClickListener(v -> {
                if (actionListener != null) actionListener.onAccept(h.getAdapterPosition());
            });
            h.btnReject.setOnClickListener(v -> {
                if (actionListener != null) actionListener.onReject(h.getAdapterPosition());
            });
        } else {
            h.actionButtons.setVisibility(View.GONE);
            h.tvTime.setVisibility(View.VISIBLE);
        }

        h.itemView.setOnClickListener(v -> {
            if (clickListener != null && !item.showActions)
                clickListener.onClick(h.getAdapterPosition());
        });
    }

    @Override
    public int getItemCount() { return items == null ? 0 : items.size(); }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvEmoji, tvName, tvSub, tvTime, tvBadge;
        View onlineDot, actionButtons;
        Button btnAccept, btnReject;

        VH(View v) {
            super(v);
            tvEmoji     = v.findViewById(R.id.tvItemEmoji);
            tvName      = v.findViewById(R.id.tvItemName);
            tvSub       = v.findViewById(R.id.tvItemSub);
            tvTime      = v.findViewById(R.id.tvItemTime);
            tvBadge     = v.findViewById(R.id.tvUnreadBadge);
            onlineDot   = v.findViewById(R.id.onlineDot);
            actionButtons = v.findViewById(R.id.actionButtons);
            btnAccept   = v.findViewById(R.id.btnAccept);
            btnReject   = v.findViewById(R.id.btnReject);
        }
    }
}
EOF

# ─── ListItem.java ────────────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/ListItem.java"
package com.example.callingapp;

public class ListItem {
    public String id;
    public String emoji;
    public String name;
    public String subtitle;
    public String time;
    public int unreadCount;
    public boolean isOnline;
    public boolean showActions;
    public String type; // "chat", "update", "call"

    public ListItem() {}

    public ListItem(String id, String emoji, String name, String subtitle,
                    String time, int unreadCount, boolean isOnline,
                    boolean showActions, String type) {
        this.id = id;
        this.emoji = emoji;
        this.name = name;
        this.subtitle = subtitle;
        this.time = time;
        this.unreadCount = unreadCount;
        this.isOnline = isOnline;
        this.showActions = showActions;
        this.type = type;
    }
}
EOF

# ─── MessageItem.java ─────────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/MessageItem.java"
package com.example.callingapp;

public class MessageItem {
    public String id;
    public String senderId;
    public String text;
    public long timestamp;

    public MessageItem() {}

    public MessageItem(String id, String senderId, String text, long timestamp) {
        this.id = id;
        this.senderId = senderId;
        this.text = text;
        this.timestamp = timestamp;
    }
}
EOF

# ─── MessageAdapter.java ──────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/MessageAdapter.java"
package com.example.callingapp;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.VH> {

    private List<MessageItem> messages;
    private String myUid;
    private static final SimpleDateFormat SDF =
            new SimpleDateFormat("h:mm a", Locale.getDefault());

    public MessageAdapter(List<MessageItem> messages, String myUid) {
        this.messages = messages;
        this.myUid = myUid;
    }

    public void setMessages(List<MessageItem> newMessages) {
        this.messages = newMessages;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_message, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH h, int pos) {
        MessageItem msg = messages.get(pos);
        boolean isMe = myUid.equals(msg.senderId);
        String timeStr = SDF.format(new Date(msg.timestamp));

        if (isMe) {
            h.outBubble.setVisibility(View.VISIBLE);
            h.inBubble.setVisibility(View.GONE);
            h.tvOutText.setText(msg.text);
            h.tvOutTime.setText(timeStr);
        } else {
            h.inBubble.setVisibility(View.VISIBLE);
            h.outBubble.setVisibility(View.GONE);
            h.tvInText.setText(msg.text);
            h.tvInTime.setText(timeStr);
        }
    }

    @Override
    public int getItemCount() { return messages == null ? 0 : messages.size(); }

    static class VH extends RecyclerView.ViewHolder {
        LinearLayout outBubble, inBubble;
        TextView tvOutText, tvOutTime, tvInText, tvInTime;

        VH(View v) {
            super(v);
            outBubble  = v.findViewById(R.id.outgoingBubble);
            inBubble   = v.findViewById(R.id.incomingBubble);
            tvOutText  = v.findViewById(R.id.tvOutText);
            tvOutTime  = v.findViewById(R.id.tvOutTime);
            tvInText   = v.findViewById(R.id.tvInText);
            tvInTime   = v.findViewById(R.id.tvInTime);
        }
    }
}
EOF

# ─── WebRTCManager.java ───────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/WebRTCManager.java"
package com.example.callingapp;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import org.webrtc.AudioSource;
import org.webrtc.AudioTrack;
import org.webrtc.Camera2Enumerator;
import org.webrtc.CameraEnumerator;
import org.webrtc.CameraVideoCapturer;
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
import org.webrtc.SdpObserver;
import org.webrtc.SessionDescription;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WebRTCManager {

    private static final String TAG = "WebRTCManager";

    public interface CallEventListener {
        void onCallConnected();
        void onCallEnded();
        void onError(String error);
    }

    private final Context context;
    private final EglBase eglBase;
    private PeerConnectionFactory factory;
    private PeerConnection peerConnection;
    private AudioTrack localAudioTrack;
    private VideoTrack localVideoTrack;
    private CameraVideoCapturer videoCapturer;
    private SurfaceViewRenderer localView, remoteView;
    private AudioManager audioManager;
    private int savedAudioMode;
    private boolean isCaller;
    private boolean isVideo;
    private String myUid;
    private String partnerUid;
    private final List<IceCandidate> pendingCandidates = new ArrayList<>();
    private boolean remoteDescSet = false;
    private DatabaseReference dbRef;
    private ValueEventListener answerListener;
    private ValueEventListener candidateListener;
    private long callStartTime;
    private CallEventListener eventListener;

    // STUN servers
    private static final List<PeerConnection.IceServer> ICE_SERVERS = new ArrayList<>();

    static {
        ICE_SERVERS.add(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer());
        ICE_SERVERS.add(PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer());
        ICE_SERVERS.add(PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer());
    }

    public WebRTCManager(Context context, EglBase eglBase,
                         SurfaceViewRenderer localView, SurfaceViewRenderer remoteView,
                         String myUid, String partnerUid,
                         boolean isCaller, boolean isVideo,
                         CallEventListener listener) {
        this.context = context.getApplicationContext();
        this.eglBase = eglBase;
        this.localView = localView;
        this.remoteView = remoteView;
        this.myUid = myUid;
        this.partnerUid = partnerUid;
        this.isCaller = isCaller;
        this.isVideo = isVideo;
        this.eventListener = listener;
        this.dbRef = FirebaseDatabase.getInstance().getReference();
    }

    public void init() {
        // Init audio manager
        audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        savedAudioMode = audioManager.getMode();
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        audioManager.setSpeakerphoneOn(isVideo);

        // Init video renderers
        localView.init(eglBase.getEglBaseContext(), null);
        localView.setMirror(true);
        remoteView.init(eglBase.getEglBaseContext(), null);
        remoteView.setMirror(false);

        // Init PeerConnectionFactory
        PeerConnectionFactory.InitializationOptions initOptions =
                PeerConnectionFactory.InitializationOptions.builder(context)
                        .setEnableInternalTracer(false)
                        .createInitializationOptions();
        PeerConnectionFactory.initialize(initOptions);

        PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
        factory = PeerConnectionFactory.builder()
                .setOptions(options)
                .setVideoEncoderFactory(new DefaultVideoEncoderFactory(
                        eglBase.getEglBaseContext(), true, true))
                .setVideoDecoderFactory(new DefaultVideoDecoderFactory(
                        eglBase.getEglBaseContext()))
                .createPeerConnectionFactory();

        // Create media tracks
        createMediaTracks();

        // Create peer connection
        createPeerConnection();

        if (isCaller) {
            createOffer();
        }
    }

    private void createMediaTracks() {
        // Audio
        MediaConstraints audioConstraints = new MediaConstraints();
        audioConstraints.mandatory.add(new MediaConstraints.KeyValuePair("googEchoCancellation", "true"));
        audioConstraints.mandatory.add(new MediaConstraints.KeyValuePair("googNoiseSuppression", "true"));
        AudioSource audioSource = factory.createAudioSource(audioConstraints);
        localAudioTrack = factory.createAudioTrack("ARDAMSa0", audioSource);
        localAudioTrack.setEnabled(true);

        if (isVideo) {
            // Video
            videoCapturer = createCameraCapturer();
            if (videoCapturer != null) {
                SurfaceTextureHelper surfaceHelper =
                        SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
                VideoSource videoSource = factory.createVideoSource(videoCapturer.isScreencast());
                videoCapturer.initialize(surfaceHelper, context, videoSource.getCapturerObserver());
                videoCapturer.startCapture(1280, 720, 30);
                localVideoTrack = factory.createVideoTrack("ARDAMSv0", videoSource);
                localVideoTrack.setEnabled(true);
                localVideoTrack.addSink(localView);
            }
        }
    }

    private CameraVideoCapturer createCameraCapturer() {
        Camera2Enumerator enumerator = new Camera2Enumerator(context);
        String[] names = enumerator.getDeviceNames();
        // Prefer front camera
        for (String name : names) {
            if (enumerator.isFrontFacing(name)) {
                return enumerator.createCapturer(name, null);
            }
        }
        for (String name : names) {
            if (!enumerator.isFrontFacing(name)) {
                return enumerator.createCapturer(name, null);
            }
        }
        return null;
    }

    private void createPeerConnection() {
        PeerConnection.RTCConfiguration rtcConfig =
                new PeerConnection.RTCConfiguration(ICE_SERVERS);
        rtcConfig.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN;

        peerConnection = factory.createPeerConnection(rtcConfig, new PeerConnection.Observer() {
            @Override
            public void onSignalingChange(PeerConnection.SignalingState state) {}

            @Override
            public void onIceConnectionChange(PeerConnection.IceConnectionState state) {
                Log.d(TAG, "ICE: " + state);
                if (state == PeerConnection.IceConnectionState.CONNECTED ||
                    state == PeerConnection.IceConnectionState.COMPLETED) {
                    callStartTime = System.currentTimeMillis();
                    if (eventListener != null) eventListener.onCallConnected();
                } else if (state == PeerConnection.IceConnectionState.DISCONNECTED ||
                           state == PeerConnection.IceConnectionState.FAILED ||
                           state == PeerConnection.IceConnectionState.CLOSED) {
                    if (eventListener != null) eventListener.onCallEnded();
                }
            }

            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}

            @Override
            public void onIceCandidate(IceCandidate candidate) {
                sendIceCandidate(candidate);
            }

            @Override public void onIceCandidatesRemoved(IceCandidate[] c) {}
            @Override public void onAddStream(MediaStream stream) {}
            @Override public void onRemoveStream(MediaStream stream) {}
            @Override public void onDataChannel(DataChannel dc) {}
            @Override public void onRenegotiationNeeded() {}

            @Override
            public void onAddTrack(RtpReceiver receiver, MediaStream[] streams) {
                if (receiver.track() instanceof VideoTrack) {
                    VideoTrack remoteVideo = (VideoTrack) receiver.track();
                    remoteVideo.addSink(remoteView);
                }
            }
        });

        if (peerConnection == null) {
            if (eventListener != null) eventListener.onError("Failed to create PeerConnection");
            return;
        }

        // Add local tracks
        if (localAudioTrack != null) {
            peerConnection.addTrack(localAudioTrack, List.of("ARDAMS"));
        }
        if (localVideoTrack != null && isVideo) {
            peerConnection.addTrack(localVideoTrack, List.of("ARDAMS"));
        }

        // Listen for remote ICE candidates
        listenForRemoteCandidates();
    }

    private void createOffer() {
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo",
                isVideo ? "true" : "false"));

        peerConnection.createOffer(new SdpObserver() {
            @Override
            public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription s) {}
                    @Override public void onSetSuccess() {
                        // Write offer to Firebase
                        Map<String, Object> callData = new HashMap<>();
                        callData.put("callerUid", myUid);
                        callData.put("sdpOffer", sdp.description);
                        callData.put("isVideo", isVideo);
                        callData.put("accepted", false);
                        dbRef.child("calls").child(partnerUid).setValue(callData);
                        listenForAnswer();
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) {
                        if (eventListener != null) eventListener.onError("Set local desc failed: " + s);
                    }
                }, sdp);
            }
            @Override public void onSetSuccess() {}
            @Override public void onCreateFailure(String s) {
                if (eventListener != null) eventListener.onError("Create offer failed: " + s);
            }
            @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void listenForAnswer() {
        answerListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                String sdpAnswer = snapshot.child("sdpAnswer").getValue(String.class);
                Boolean accepted = snapshot.child("accepted").getValue(Boolean.class);
                if (sdpAnswer != null && Boolean.TRUE.equals(accepted)) {
                    SessionDescription answer = new SessionDescription(
                            SessionDescription.Type.ANSWER, sdpAnswer);
                    peerConnection.setRemoteDescription(new SdpObserver() {
                        @Override public void onCreateSuccess(SessionDescription s) {}
                        @Override public void onSetSuccess() {
                            remoteDescSet = true;
                            drainPendingCandidates();
                        }
                        @Override public void onCreateFailure(String s) {}
                        @Override public void onSetFailure(String s) {
                            if (eventListener != null) eventListener.onError("Set remote answer failed: " + s);
                        }
                    }, answer);
                    dbRef.child("calls").child(partnerUid).removeEventListener(this);
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        dbRef.child("calls").child(partnerUid).addValueEventListener(answerListener);
    }

    public void handleOffer(String sdpOffer) {
        SessionDescription offer = new SessionDescription(SessionDescription.Type.OFFER, sdpOffer);
        peerConnection.setRemoteDescription(new SdpObserver() {
            @Override public void onCreateSuccess(SessionDescription s) {}
            @Override
            public void onSetSuccess() {
                remoteDescSet = true;
                drainPendingCandidates();
                createAnswer();
            }
            @Override public void onCreateFailure(String s) {}
            @Override public void onSetFailure(String s) {
                if (eventListener != null) eventListener.onError("Set remote offer failed: " + s);
            }
        }, offer);
    }

    private void createAnswer() {
        MediaConstraints constraints = new MediaConstraints();
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo",
                isVideo ? "true" : "false"));

        peerConnection.createAnswer(new SdpObserver() {
            @Override
            public void onCreateSuccess(SessionDescription sdp) {
                peerConnection.setLocalDescription(new SdpObserver() {
                    @Override public void onCreateSuccess(SessionDescription s) {}
                    @Override
                    public void onSetSuccess() {
                        // Write answer + accepted=true
                        Map<String, Object> update = new HashMap<>();
                        update.put("sdpAnswer", sdp.description);
                        update.put("accepted", true);
                        dbRef.child("calls").child(myUid).updateChildren(update);
                    }
                    @Override public void onCreateFailure(String s) {}
                    @Override public void onSetFailure(String s) {
                        if (eventListener != null) eventListener.onError("Set local answer failed: " + s);
                    }
                }, sdp);
            }
            @Override public void onSetSuccess() {}
            @Override public void onCreateFailure(String s) {
                if (eventListener != null) eventListener.onError("Create answer failed: " + s);
            }
            @Override public void onSetFailure(String s) {}
        }, constraints);
    }

    private void sendIceCandidate(IceCandidate candidate) {
        String role = isCaller ? "caller" : "receiver";
        String targetUid = isCaller ? partnerUid : myUid;
        String key = dbRef.child("calls").child(targetUid)
                .child("candidates").child(role).push().getKey();
        if (key == null) return;
        Map<String, Object> candidateMap = new HashMap<>();
        candidateMap.put("sdpMid", candidate.sdpMid);
        candidateMap.put("sdpMLineIndex", candidate.sdpMLineIndex);
        candidateMap.put("candidate", candidate.sdp);
        dbRef.child("calls").child(targetUid)
             .child("candidates").child(role).child(key)
             .setValue(candidateMap);
    }

    private void listenForRemoteCandidates() {
        String remoteRole = isCaller ? "receiver" : "caller";
        String listenUid = isCaller ? partnerUid : myUid;
        candidateListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                for (DataSnapshot snap : snapshot.getChildren()) {
                    String sdpMid = snap.child("sdpMid").getValue(String.class);
                    Integer sdpMLineIndex = snap.child("sdpMLineIndex").getValue(Integer.class);
                    String candidateSdp = snap.child("candidate").getValue(String.class);
                    if (sdpMid == null || sdpMLineIndex == null || candidateSdp == null) continue;
                    IceCandidate ic = new IceCandidate(sdpMid, sdpMLineIndex, candidateSdp);
                    if (remoteDescSet) {
                        peerConnection.addIceCandidate(ic);
                    } else {
                        pendingCandidates.add(ic);
                    }
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        dbRef.child("calls").child(listenUid)
             .child("candidates").child(remoteRole)
             .addValueEventListener(candidateListener);
    }

    private void drainPendingCandidates() {
        for (IceCandidate ic : pendingCandidates) {
            if (peerConnection != null) peerConnection.addIceCandidate(ic);
        }
        pendingCandidates.clear();
    }

    public long endCall(String myUid, String partnerUid, boolean isCaller) {
        long duration = 0;
        if (callStartTime > 0) {
            duration = (System.currentTimeMillis() - callStartTime) / 1000;
        }

        // Save call history
        String callUidTarget = isCaller ? partnerUid : myUid;
        Map<String, Object> history = new HashMap<>();
        history.put("partnerUid", isCaller ? partnerUid : myUid);
        history.put("duration", duration);
        history.put("timestamp", System.currentTimeMillis());
        history.put("isVideo", isVideo);
        history.put("isCaller", isCaller);
        dbRef.child("users").child(myUid).child("call_history").push().setValue(history);

        // Remove call node
        if (isCaller) {
            dbRef.child("calls").child(partnerUid).removeValue();
        } else {
            dbRef.child("calls").child(myUid).removeValue();
        }

        // Remove listeners
        if (answerListener != null) {
            dbRef.child("calls").child(partnerUid).removeEventListener(answerListener);
        }
        if (candidateListener != null) {
            String listenUid = isCaller ? partnerUid : myUid;
            String remoteRole = isCaller ? "receiver" : "caller";
            dbRef.child("calls").child(listenUid).child("candidates")
                 .child(remoteRole).removeEventListener(candidateListener);
        }

        dispose();
        return duration;
    }

    private void dispose() {
        try {
            if (videoCapturer != null) {
                videoCapturer.stopCapture();
                videoCapturer.dispose();
                videoCapturer = null;
            }
        } catch (Exception e) { Log.e(TAG, "capturer stop error", e); }

        if (localVideoTrack != null) { localVideoTrack.dispose(); localVideoTrack = null; }
        if (localAudioTrack != null) { localAudioTrack.dispose(); localAudioTrack = null; }
        if (peerConnection != null)  { peerConnection.close(); peerConnection = null; }
        if (factory != null)         { factory.dispose(); factory = null; }

        try { localView.release(); } catch (Exception ignored) {}
        try { remoteView.release(); } catch (Exception ignored) {}

        if (audioManager != null) {
            audioManager.setMode(savedAudioMode);
            audioManager.setSpeakerphoneOn(false);
        }
    }
}
EOF

# ─── MainActivity.java ────────────────────────────────────────────────────────
cat <<'EOF' > "$SRC/MainActivity.java"
package com.example.callingapp;

import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
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

import com.google.android.material.badge.BadgeDrawable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import org.webrtc.EglBase;
import org.webrtc.SurfaceViewRenderer;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;

import android.Manifest;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    private static final int PERM_REQ = 100;
    public static volatile boolean isAppInForeground = false;

    // Firebase
    private FirebaseAuth auth;
    private DatabaseReference dbRef;
    private String myUid;
    private String myName;
    private String myEmoji;
    private String myFriendId;

    // Views - Auth
    private LinearLayout authView;
    private EditText etEmail, etPassword;
    private Button btnLogin, btnSignup;

    // Views - Main
    private LinearLayout mainView;
    private Toolbar toolbar;
    private RecyclerView mainRecycler;
    private TextView tvEmpty;
    private BottomNavigationView bottomNav;

    // Views - Chat
    private LinearLayout chatView;
    private ImageButton btnChatBack, btnVoiceCall, btnVideoCall, btnSend;
    private TextView tvChatEmoji, tvChatName, tvChatStatus;
    private RecyclerView chatRecycler;
    private EditText etMessage;

    // Views - Call
    private FrameLayout callView;
    private SurfaceViewRenderer localVideoView, remoteVideoView;
    private TextView tvCallEmoji, tvCallName, tvCallStatus;
    private ImageButton btnAcceptCall, btnEndCall;

    // Adapters
    private GenericAdapter mainAdapter;
    private MessageAdapter messageAdapter;

    // State
    private int currentTab = 0; // 0=chats, 1=updates, 2=calls
    private String chatPartnerUid;
    private String chatPartnerName;
    private String chatPartnerEmoji;
    private List<ListItem> chatItems   = new ArrayList<>();
    private List<ListItem> updateItems = new ArrayList<>();
    private List<ListItem> callItems   = new ArrayList<>();
    private List<MessageItem> messageList = new ArrayList<>();

    // Listeners
    private ValueEventListener contactsListener;
    private ValueEventListener friendRequestListener;
    private ValueEventListener callHistoryListener;
    private ValueEventListener messagesListener;
    private ValueEventListener incomingCallListener;
    private DatabaseReference contactsRef;
    private DatabaseReference friendReqRef;
    private DatabaseReference callHistRef;
    private DatabaseReference messagesRef;
    private DatabaseReference callNodeRef;

    // WebRTC
    private EglBase eglBase;
    private WebRTCManager webRTCManager;
    private boolean inCall = false;
    private boolean isCallerRole = false;
    private boolean isVideoCall = false;
    private String callPartnerUid;
    private String callPartnerName;
    private String callPartnerEmoji;

    private static final SimpleDateFormat TIME_FMT =
            new SimpleDateFormat("h:mm a", Locale.getDefault());
    private static final SimpleDateFormat DATE_FMT =
            new SimpleDateFormat("MMM d", Locale.getDefault());

    // ─── Lifecycle ─────────────────────────────────────────────────────────────

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        auth  = FirebaseAuth.getInstance();
        dbRef = FirebaseDatabase.getInstance().getReference();
        eglBase = EglBase.create();

        bindViews();
        setupAuthButtons();

        if (auth.getCurrentUser() != null) {
            myUid = auth.getCurrentUser().getUid();
            loadMyProfile(() -> showMainView());
        } else {
            showAuthView();
        }
        requestPermissions();
    }

    @Override
    protected void onResume() {
        super.onResume();
        isAppInForeground = true;
        if (myUid != null) {
            dbRef.child("users").child(myUid).child("online").setValue(true);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isAppInForeground = false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeAllListeners();
        if (myUid != null) {
            dbRef.child("users").child(myUid).child("online").setValue(false);
        }
    }

    @Override
    public void onBackPressed() {
        if (chatView.getVisibility() == View.VISIBLE) {
            exitChat();
        } else if (callView.getVisibility() == View.VISIBLE) {
            // Don't allow back during call
        } else {
            super.onBackPressed();
        }
    }

    // ─── View Binding ──────────────────────────────────────────────────────────

    private void bindViews() {
        // Auth
        authView   = findViewById(R.id.authView);
        etEmail    = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        btnLogin   = findViewById(R.id.btnLogin);
        btnSignup  = findViewById(R.id.btnSignup);

        // Main
        mainView     = findViewById(R.id.mainView);
        toolbar      = findViewById(R.id.toolbar);
        mainRecycler = findViewById(R.id.mainRecycler);
        tvEmpty      = findViewById(R.id.tvEmpty);
        bottomNav    = findViewById(R.id.bottomNav);

        // Chat
        chatView     = findViewById(R.id.chatView);
        btnChatBack  = findViewById(R.id.btnChatBack);
        btnVoiceCall = findViewById(R.id.btnVoiceCall);
        btnVideoCall = findViewById(R.id.btnVideoCall);
        tvChatEmoji  = findViewById(R.id.tvChatEmoji);
        tvChatName   = findViewById(R.id.tvChatName);
        tvChatStatus = findViewById(R.id.tvChatStatus);
        chatRecycler = findViewById(R.id.chatRecycler);
        etMessage    = findViewById(R.id.etMessage);
        btnSend      = findViewById(R.id.btnSend);

        // Call
        callView       = findViewById(R.id.callView);
        localVideoView  = findViewById(R.id.localVideoView);
        remoteVideoView = findViewById(R.id.remoteVideoView);
        tvCallEmoji    = findViewById(R.id.tvCallEmoji);
        tvCallName     = findViewById(R.id.tvCallName);
        tvCallStatus   = findViewById(R.id.tvCallStatus);
        btnAcceptCall  = findViewById(R.id.btnAcceptCall);
        btnEndCall     = findViewById(R.id.btnEndCall);
    }

    // ─── Auth ──────────────────────────────────────────────────────────────────

    private void setupAuthButtons() {
        btnLogin.setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();
            String pass  = etPassword.getText().toString().trim();
            if (TextUtils.isEmpty(email) || TextUtils.isEmpty(pass)) {
                toast("Enter email and password"); return;
            }
            auth.signInWithEmailAndPassword(email, pass)
                .addOnSuccessListener(res -> {
                    myUid = res.getUser().getUid();
                    loadMyProfile(() -> showMainView());
                })
                .addOnFailureListener(e -> toast("Login failed: " + e.getMessage()));
        });

        btnSignup.setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();
            String pass  = etPassword.getText().toString().trim();
            if (TextUtils.isEmpty(email) || TextUtils.isEmpty(pass)) {
                toast("Enter email and password"); return;
            }
            auth.createUserWithEmailAndPassword(email, pass)
                .addOnSuccessListener(res -> {
                    myUid = res.getUser().getUid();
                    showProfileSetupDialog();
                })
                .addOnFailureListener(e -> toast("Signup failed: " + e.getMessage()));
        });
    }

    private void showProfileSetupDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        TextView tvTitle    = dialogView.findViewById(R.id.tvDialogTitle);
        EditText etName     = dialogView.findViewById(R.id.etDialogInput1);
        EditText etEmoji    = dialogView.findViewById(R.id.etDialogInput2);
        TextView tvInfo     = dialogView.findViewById(R.id.tvDialogInfo);

        String friendId = "jg-" + String.format("%04d", new Random().nextInt(10000));
        tvTitle.setText("Set up your profile");
        etName.setHint("Your name");
        etEmoji.setHint("Emoji avatar (e.g. 🐐)");
        tvInfo.setText("Your friend ID: " + friendId);

        new AlertDialog.Builder(this)
            .setView(dialogView)
            .setCancelable(false)
            .setPositiveButton("Save", (dialog, which) -> {
                String name  = etName.getText().toString().trim();
                String emoji = etEmoji.getText().toString().trim();
                if (TextUtils.isEmpty(name)) name = "User";
                if (TextUtils.isEmpty(emoji)) emoji = "🐐";

                Map<String, Object> userData = new HashMap<>();
                userData.put("name", name);
                userData.put("emoji", emoji);
                userData.put("friendId", friendId);
                userData.put("online", true);
                userData.put("email", auth.getCurrentUser().getEmail());

                dbRef.child("users").child(myUid).setValue(userData)
                     .addOnSuccessListener(u -> {
                         // Index by friendId
                         dbRef.child("friendIds").child(friendId).setValue(myUid);
                         loadMyProfile(() -> showMainView());
                     });
            })
            .show();
    }

    private void loadMyProfile(Runnable onDone) {
        dbRef.child("users").child(myUid).get().addOnSuccessListener(snap -> {
            myName     = snap.child("name").getValue(String.class);
            myEmoji    = snap.child("emoji").getValue(String.class);
            myFriendId = snap.child("friendId").getValue(String.class);
            if (myName  == null) myName  = "Me";
            if (myEmoji == null) myEmoji = "🐐";
            onDone.run();
        });
    }

    // ─── Main View ─────────────────────────────────────────────────────────────

    private void showMainView() {
        authView.setVisibility(View.GONE);
        chatView.setVisibility(View.GONE);
        callView.setVisibility(View.GONE);
        mainView.setVisibility(View.VISIBLE);

        setSupportActionBar(toolbar);
        toolbar.inflateMenu(R.menu.main_menu);
        toolbar.setOnMenuItemClickListener(item -> {
            int id = item.getItemId();
            if (id == R.id.action_add_friend) { showAddFriendDialog(); return true; }
            if (id == R.id.action_profile)    { showProfileDialog(); return true; }
            if (id == R.id.action_logout)     { logout(); return true; }
            return false;
        });

        setupMainRecycler();
        setupBottomNav();
        startBackgroundService();
        setOnlineStatus();
        startIncomingCallListener();
        loadChats();
    }

    private void setOnlineStatus() {
        DatabaseReference presenceRef = dbRef.child("users").child(myUid).child("online");
        presenceRef.setValue(true);
        presenceRef.onDisconnect().setValue(false);
    }

    private void setupMainRecycler() {
        mainAdapter = new GenericAdapter(chatItems,
            pos -> {
                ListItem item = getCurrentList().get(pos);
                if ("chat".equals(item.type)) openChat(item);
            },
            new GenericAdapter.ActionListener() {
                @Override public void onAccept(int pos) {
                    ListItem item = getCurrentList().get(pos);
                    acceptFriendRequest(item);
                }
                @Override public void onReject(int pos) {
                    ListItem item = getCurrentList().get(pos);
                    rejectFriendRequest(item);
                }
            }
        );
        mainRecycler.setLayoutManager(new LinearLayoutManager(this));
        mainRecycler.setAdapter(mainAdapter);
    }

    private List<ListItem> getCurrentList() {
        switch (currentTab) {
            case 1: return updateItems;
            case 2: return callItems;
            default: return chatItems;
        }
    }

    private void setupBottomNav() {
        bottomNav.setSelectedItemId(R.id.nav_chats);
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats)   { currentTab = 0; refreshMainList(); return true; }
            if (id == R.id.nav_updates) { currentTab = 1; refreshMainList(); return true; }
            if (id == R.id.nav_calls)   { currentTab = 2; refreshMainList(); return true; }
            return false;
        });
    }

    private void refreshMainList() {
        List<ListItem> list = getCurrentList();
        mainAdapter.setItems(list);
        tvEmpty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
        switch (currentTab) {
            case 0: tvEmpty.setText("No chats yet. Add a friend!"); break;
            case 1: tvEmpty.setText("No updates."); break;
            case 2: tvEmpty.setText("No call history."); break;
        }
    }

    // ─── Load Chats ────────────────────────────────────────────────────────────

    private void loadChats() {
        contactsRef = dbRef.child("users").child(myUid).child("contacts");
        contactsListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                chatItems.clear();
                for (DataSnapshot snap : snapshot.getChildren()) {
                    String uid     = snap.getKey();
                    String name    = snap.child("name").getValue(String.class);
                    String emoji   = snap.child("emoji").getValue(String.class);
                    String lastMsg = snap.child("lastMessage").getValue(String.class);
                    Long ts        = snap.child("lastTimestamp").getValue(Long.class);
                    Object unreadObj = snap.child("unread").getValue();
                    int unread = 0;
                    if (unreadObj instanceof Long)    unread = ((Long)unreadObj).intValue();
                    if (unreadObj instanceof Integer) unread = (Integer)unreadObj;

                    // Check online status
                    dbRef.child("users").child(uid).child("online").get()
                         .addOnSuccessListener(onlineSnap -> {
                             boolean online = Boolean.TRUE.equals(onlineSnap.getValue(Boolean.class));
                             String timeStr = ts != null ? formatTime(ts) : "";
                             ListItem li = new ListItem(uid, emoji != null ? emoji : "👤",
                                     name != null ? name : "User",
                                     lastMsg != null ? lastMsg : "Tap to chat",
                                     timeStr, unread, online, false, "chat");
                             chatItems.removeIf(i -> i.id.equals(uid));
                             chatItems.add(0, li);
                             if (currentTab == 0) refreshMainList();
                         });
                }
                if (currentTab == 0) refreshMainList();
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        contactsRef.addValueEventListener(contactsListener);
        loadFriendRequests();
        loadCallHistory();
    }

    private void loadFriendRequests() {
        friendReqRef = dbRef.child("users").child(myUid).child("friendRequests");
        friendRequestListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                updateItems.clear();
                for (DataSnapshot snap : snapshot.getChildren()) {
                    String fromUid  = snap.getKey();
                    String fromName = snap.child("name").getValue(String.class);
                    String fromEmoji= snap.child("emoji").getValue(String.class);
                    String fId      = snap.child("friendId").getValue(String.class);
                    ListItem li = new ListItem(fromUid,
                            fromEmoji != null ? fromEmoji : "👤",
                            fromName  != null ? fromName  : "User",
                            "Friend request • " + (fId != null ? fId : ""),
                            "", 0, false, true, "update");
                    updateItems.add(li);
                }
                // Update badge
                updateBadge(updateItems.size());
                if (currentTab == 1) refreshMainList();
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        friendReqRef.addValueEventListener(friendRequestListener);
    }

    private void loadCallHistory() {
        callHistRef = dbRef.child("users").child(myUid).child("call_history");
        callHistoryListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                callItems.clear();
                List<DataSnapshot> snaps = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) snaps.add(s);
                // Show last 50, newest first
                int start = Math.max(0, snaps.size() - 50);
                for (int i = snaps.size() - 1; i >= start; i--) {
                    DataSnapshot s   = snaps.get(i);
                    String partnerU  = s.child("partnerUid").getValue(String.class);
                    Long duration    = s.child("duration").getValue(Long.class);
                    Long ts          = s.child("timestamp").getValue(Long.class);
                    Boolean vid      = s.child("isVideo").getValue(Boolean.class);
                    Boolean caller   = s.child("isCaller").getValue(Boolean.class);

                    String type = Boolean.TRUE.equals(vid) ? "📹" : "📞";
                    String dir  = Boolean.TRUE.equals(caller) ? "↑ " : "↓ ";
                    String dur  = duration != null ? formatDuration(duration) : "0s";
                    String time = ts != null ? formatTime(ts) : "";

                    // Fetch partner info
                    if (partnerU != null) {
                        final String pUid = partnerU;
                        dbRef.child("users").child(pUid).get().addOnSuccessListener(pSnap -> {
                            String pName  = pSnap.child("name").getValue(String.class);
                            String pEmoji = pSnap.child("emoji").getValue(String.class);
                            ListItem li = new ListItem(pUid,
                                    pEmoji != null ? pEmoji : "👤",
                                    pName  != null ? pName  : "User",
                                    dir + type + " • " + dur,
                                    time, 0, false, false, "call");
                            callItems.add(li);
                            if (currentTab == 2) refreshMainList();
                        });
                    }
                }
                if (currentTab == 2) refreshMainList();
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        callHistRef.addValueEventListener(callHistoryListener);
    }

    private void updateBadge(int count) {
        runOnUiThread(() -> {
            try {
                BadgeDrawable badge = bottomNav.getOrCreateBadge(R.id.nav_updates);
                if (count > 0) {
                    badge.setVisible(true);
                    badge.setNumber(count);
                } else {
                    badge.setVisible(false);
                }
            } catch (Exception e) {
                Log.e(TAG, "Badge error", e);
            }
        });
    }

    // ─── Friend Requests ───────────────────────────────────────────────────────

    private void showAddFriendDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        TextView tvTitle = dialogView.findViewById(R.id.tvDialogTitle);
        EditText etInput = dialogView.findViewById(R.id.etDialogInput1);
        dialogView.findViewById(R.id.etDialogInput2).setVisibility(View.GONE);
        dialogView.findViewById(R.id.tvDialogInfo).setVisibility(View.GONE);

        tvTitle.setText("Add Friend");
        etInput.setHint("Enter jg-XXXX ID");

        new AlertDialog.Builder(this)
            .setView(dialogView)
            .setPositiveButton("Send Request", (d, w) -> {
                String friendId = etInput.getText().toString().trim();
                if (TextUtils.isEmpty(friendId)) return;
                lookupAndSendRequest(friendId);
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void lookupAndSendRequest(String friendId) {
        dbRef.child("friendIds").child(friendId).get().addOnSuccessListener(snap -> {
            if (!snap.exists()) { toast("User not found"); return; }
            String targetUid = snap.getValue(String.class);
            if (targetUid == null || targetUid.equals(myUid)) {
                toast("Invalid user"); return;
            }
            Map<String, Object> req = new HashMap<>();
            req.put("name", myName);
            req.put("emoji", myEmoji);
            req.put("friendId", myFriendId);
            dbRef.child("users").child(targetUid)
                 .child("friendRequests").child(myUid)
                 .setValue(req)
                 .addOnSuccessListener(u -> toast("Friend request sent!"));
        }).addOnFailureListener(e -> toast("Error: " + e.getMessage()));
    }

    private void acceptFriendRequest(ListItem item) {
        String fromUid = item.id;
        // Add to both contacts
        Map<String, Object> myContact = new HashMap<>();
        myContact.put("name", item.name);
        myContact.put("emoji", item.emoji);
        myContact.put("unread", 0);
        dbRef.child("users").child(myUid).child("contacts").child(fromUid).setValue(myContact);

        Map<String, Object> theirContact = new HashMap<>();
        theirContact.put("name", myName);
        theirContact.put("emoji", myEmoji);
        theirContact.put("unread", 0);
        dbRef.child("users").child(fromUid).child("contacts").child(myUid).setValue(theirContact);

        // Remove request
        dbRef.child("users").child(myUid).child("friendRequests").child(fromUid).removeValue();
        toast("Friend added!");
    }

    private void rejectFriendRequest(ListItem item) {
        dbRef.child("users").child(myUid).child("friendRequests").child(item.id).removeValue();
        toast("Request rejected");
    }

    // ─── Chat ──────────────────────────────────────────────────────────────────

    private void openChat(ListItem item) {
        chatPartnerUid   = item.id;
        chatPartnerName  = item.name;
        chatPartnerEmoji = item.emoji;

        tvChatName.setText(chatPartnerName);
        tvChatEmoji.setText(chatPartnerEmoji);

        mainView.setVisibility(View.GONE);
        chatView.setVisibility(View.VISIBLE);

        // Clear unread
        dbRef.child("users").child(myUid).child("contacts")
             .child(chatPartnerUid).child("unread").setValue(0);

        // Check online status
        dbRef.child("users").child(chatPartnerUid).child("online").get()
             .addOnSuccessListener(snap -> {
                 boolean online = Boolean.TRUE.equals(snap.getValue(Boolean.class));
                 tvChatStatus.setText(online ? "online" : "offline");
             });

        // Setup message adapter
        messageList.clear();
        messageAdapter = new MessageAdapter(messageList, myUid);
        chatRecycler.setLayoutManager(new LinearLayoutManager(this));
        chatRecycler.setAdapter(messageAdapter);

        loadMessages();

        btnChatBack.setOnClickListener(v -> exitChat());
        btnSend.setOnClickListener(v -> sendMessage());
        btnVoiceCall.setOnClickListener(v -> startCall(false));
        btnVideoCall.setOnClickListener(v -> startCall(true));
    }

    private String getChatKey() {
        if (myUid.compareTo(chatPartnerUid) < 0)
            return myUid + "_" + chatPartnerUid;
        return chatPartnerUid + "_" + myUid;
    }

    private void loadMessages() {
        String chatKey = getChatKey();
        messagesRef = dbRef.child("messages").child(chatKey);
        if (messagesListener != null) messagesRef.removeEventListener(messagesListener);

        messagesListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                messageList.clear();
                List<DataSnapshot> snaps = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) snaps.add(s);
                // Last 50
                int start = Math.max(0, snaps.size() - 50);
                for (int i = start; i < snaps.size(); i++) {
                    DataSnapshot s = snaps.get(i);
                    String id       = s.getKey();
                    String sender   = s.child("senderId").getValue(String.class);
                    String text     = s.child("text").getValue(String.class);
                    Long ts         = s.child("timestamp").getValue(Long.class);
                    if (sender != null && text != null && ts != null) {
                        messageList.add(new MessageItem(id, sender, text, ts));
                    }
                }
                messageAdapter.setMessages(new ArrayList<>(messageList));
                chatRecycler.scrollToPosition(messageList.size() - 1);
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        messagesRef.addValueEventListener(messagesListener);
    }

    private void sendMessage() {
        String text = etMessage.getText().toString().trim();
        if (TextUtils.isEmpty(text)) return;
        etMessage.setText("");

        String chatKey = getChatKey();
        String key = dbRef.child("messages").child(chatKey).push().getKey();
        if (key == null) return;

        long ts = System.currentTimeMillis();
        Map<String, Object> msg = new HashMap<>();
        msg.put("senderId", myUid);
        msg.put("text", text);
        msg.put("timestamp", ts);
        dbRef.child("messages").child(chatKey).child(key).setValue(msg);

        // Update my contact entry
        Map<String, Object> myContactUpdate = new HashMap<>();
        myContactUpdate.put("lastMessage", text);
        myContactUpdate.put("lastTimestamp", ts);
        dbRef.child("users").child(myUid).child("contacts").child(chatPartnerUid)
             .updateChildren(myContactUpdate);

        // Increment partner unread
        dbRef.child("users").child(chatPartnerUid).child("contacts").child(myUid)
             .get().addOnSuccessListener(snap -> {
                 Object unreadObj = snap.child("unread").getValue();
                 int unread = 0;
                 if (unreadObj instanceof Long)    unread = ((Long)unreadObj).intValue();
                 if (unreadObj instanceof Integer) unread = (Integer)unreadObj;

                 Map<String, Object> partnerUpdate = new HashMap<>();
                 partnerUpdate.put("lastMessage", text);
                 partnerUpdate.put("lastTimestamp", ts);
                 partnerUpdate.put("unread", unread + 1);
                 partnerUpdate.put("name", myName);
                 partnerUpdate.put("emoji", myEmoji);
                 dbRef.child("users").child(chatPartnerUid).child("contacts").child(myUid)
                      .updateChildren(partnerUpdate);
             });
    }

    private void exitChat() {
        if (messagesListener != null && messagesRef != null) {
            messagesRef.removeEventListener(messagesListener);
            messagesListener = null;
        }
        chatView.setVisibility(View.GONE);
        mainView.setVisibility(View.VISIBLE);
        chatPartnerUid = null;
    }

    // ─── Calls ─────────────────────────────────────────────────────────────────

    private void startCall(boolean isVideo) {
        if (inCall) return;
        if (chatPartnerUid == null) return;

        isVideoCall  = isVideo;
        isCallerRole = true;
        callPartnerUid   = chatPartnerUid;
        callPartnerName  = chatPartnerName;
        callPartnerEmoji = chatPartnerEmoji;

        // Write call info to Firebase for receiver
        Map<String, Object> callData = new HashMap<>();
        callData.put("callerUid", myUid);
        callData.put("callerName", myName);
        callData.put("callerEmoji", myEmoji);
        callData.put("isVideo", isVideo);
        callData.put("accepted", false);
        dbRef.child("calls").child(callPartnerUid).setValue(callData);

        showCallUI(callPartnerName, callPartnerEmoji, false, isVideo);
        initWebRTC(true);
    }

    private void startIncomingCallListener() {
        callNodeRef = dbRef.child("calls").child(myUid);
        incomingCallListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                if (!snapshot.exists()) {
                    if (inCall && !isCallerRole) hideCallUI();
                    return;
                }
                String callerUid = snapshot.child("callerUid").getValue(String.class);
                if (callerUid == null || callerUid.equals(myUid)) return;
                Boolean accepted = snapshot.child("accepted").getValue(Boolean.class);
                if (Boolean.TRUE.equals(accepted)) return;
                if (inCall) return;

                callPartnerUid   = callerUid;
                callPartnerName  = snapshot.child("callerName").getValue(String.class);
                callPartnerEmoji = snapshot.child("callerEmoji").getValue(String.class);
                isVideoCall      = Boolean.TRUE.equals(snapshot.child("isVideo").getValue(Boolean.class));
                isCallerRole     = false;
                if (callPartnerName  == null) callPartnerName  = "Unknown";
                if (callPartnerEmoji == null) callPartnerEmoji = "📞";

                runOnUiThread(() -> showCallUI(callPartnerName, callPartnerEmoji, true, isVideoCall));
            }
            @Override public void onCancelled(DatabaseError e) {}
        };
        callNodeRef.addValueEventListener(incomingCallListener);
    }

    private void showCallUI(String name, String emoji, boolean showAccept, boolean isVideo) {
        runOnUiThread(() -> {
            tvCallName.setText(name);
            tvCallEmoji.setText(emoji);
            tvCallStatus.setText(showAccept ? "Incoming call…" : "Calling…");
            btnAcceptCall.setVisibility(showAccept ? View.VISIBLE : View.GONE);
            localVideoView.setVisibility(isVideo ? View.VISIBLE : View.GONE);

            mainView.setVisibility(View.GONE);
            chatView.setVisibility(View.GONE);
            callView.setVisibility(View.VISIBLE);
            inCall = true;

            btnAcceptCall.setOnClickListener(v -> acceptIncomingCall());
            btnEndCall.setOnClickListener(v -> endCurrentCall());
        });
    }

    private void hideCallUI() {
        runOnUiThread(() -> {
            callView.setVisibility(View.GONE);
            mainView.setVisibility(View.VISIBLE);
            inCall = false;
        });
    }

    private void acceptIncomingCall() {
        btnAcceptCall.setVisibility(View.GONE);
        tvCallStatus.setText("Connecting…");
        initWebRTC(false);

        // Fetch offer
        dbRef.child("calls").child(myUid).child("sdpOffer").get()
             .addOnSuccessListener(snap -> {
                 String offer = snap.getValue(String.class);
                 if (offer != null && webRTCManager != null) {
                     webRTCManager.handleOffer(offer);
                 }
             });
    }

    private void initWebRTC(boolean isCaller) {
        webRTCManager = new WebRTCManager(
                this, eglBase, localVideoView, remoteVideoView,
                myUid, callPartnerUid, isCaller, isVideoCall,
                new WebRTCManager.CallEventListener() {
                    @Override public void onCallConnected() {
                        runOnUiThread(() -> tvCallStatus.setText("Connected"));
                    }
                    @Override public void onCallEnded() { endCurrentCall(); }
                    @Override public void onError(String error) {
                        runOnUiThread(() -> { toast("Call error: " + error); endCurrentCall(); });
                    }
                }
        );
        webRTCManager.init();
    }

    private void endCurrentCall() {
        if (!inCall) return;
        inCall = false;
        if (webRTCManager != null) {
            webRTCManager.endCall(myUid, callPartnerUid, isCallerRole);
            webRTCManager = null;
        } else {
            // Caller hung up before answer
            if (isCallerRole) {
                dbRef.child("calls").child(callPartnerUid).removeValue();
            }
        }
        hideCallUI();
    }

    // ─── Profile Dialog ────────────────────────────────────────────────────────

    private void showProfileDialog() {
        new AlertDialog.Builder(this)
            .setTitle(myEmoji + " " + myName)
            .setMessage("Friend ID: " + myFriendId + "\n\nEmail: " +
                    (auth.getCurrentUser() != null ? auth.getCurrentUser().getEmail() : ""))
            .setPositiveButton("Close", null)
            .setNegativeButton("Logout", (d, w) -> logout())
            .show();
    }

    private void logout() {
        if (myUid != null) {
            dbRef.child("users").child(myUid).child("online").setValue(false);
        }
        removeAllListeners();
        auth.signOut();
        myUid = null;
        chatItems.clear(); updateItems.clear(); callItems.clear();
        showAuthView();
    }

    private void showAuthView() {
        mainView.setVisibility(View.GONE);
        chatView.setVisibility(View.GONE);
        callView.setVisibility(View.GONE);
        authView.setVisibility(View.VISIBLE);
    }

    // ─── Background Service ────────────────────────────────────────────────────

    private void startBackgroundService() {
        Intent intent = new Intent(this, BackgroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);
        } else {
            startService(intent);
        }
    }

    // ─── Listeners Cleanup ─────────────────────────────────────────────────────

    private void removeAllListeners() {
        if (contactsRef != null && contactsListener != null) {
            contactsRef.removeEventListener(contactsListener);
        }
        if (friendReqRef != null && friendRequestListener != null) {
            friendReqRef.removeEventListener(friendRequestListener);
        }
        if (callHistRef != null && callHistoryListener != null) {
            callHistRef.removeEventListener(callHistoryListener);
        }
        if (messagesRef != null && messagesListener != null) {
            messagesRef.removeEventListener(messagesListener);
        }
        if (callNodeRef != null && incomingCallListener != null) {
            callNodeRef.removeEventListener(incomingCallListener);
        }
    }

    // ─── Permissions ───────────────────────────────────────────────────────────

    private void requestPermissions() {
        List<String> perms = new ArrayList<>();
        perms.add(Manifest.permission.CAMERA);
        perms.add(Manifest.permission.RECORD_AUDIO);
        perms.add(Manifest.permission.MODIFY_AUDIO_SETTINGS);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            perms.add(Manifest.permission.POST_NOTIFICATIONS);
        }
        List<String> toRequest = new ArrayList<>();
        for (String p : perms) {
            if (ContextCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED) {
                toRequest.add(p);
            }
        }
        if (!toRequest.isEmpty()) {
            ActivityCompat.requestPermissions(this, toRequest.toArray(new String[0]), PERM_REQ);
        }
    }

    @Override
    public void onRequestPermissionsResult(int req, @NonNull String[] perms, @NonNull int[] results) {
        super.onRequestPermissionsResult(req, perms, results);
    }

    // ─── Helpers ───────────────────────────────────────────────────────────────

    private String formatTime(long ts) {
        long now = System.currentTimeMillis();
        long diff = now - ts;
        if (diff < 24 * 60 * 60 * 1000) return TIME_FMT.format(new Date(ts));
        return DATE_FMT.format(new Date(ts));
    }

    private String formatDuration(long seconds) {
        if (seconds < 60) return seconds + "s";
        return (seconds / 60) + "m " + (seconds % 60) + "s";
    }

    private void toast(String msg) {
        runOnUiThread(() -> Toast.makeText(this, msg, Toast.LENGTH_SHORT).show());
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         Java Goat — Building Release APK                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  IMPORTANT: Replace app/google-services.json with your real"
echo "    Firebase project config before running a production build."
echo ""

# Download and install Gradle wrapper
if [ ! -f "gradlew" ]; then
  echo "Setting up Gradle wrapper..."
  if [ -f "/opt/gradle/gradle-8.2/bin/gradle" ]; then
    /opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2 --project-dir "$PROJECT_ROOT" || {
      # Manual wrapper setup as fallback
      cat <<'WEOF' > gradlew
#!/bin/sh
exec java -jar gradle/wrapper/gradle-wrapper.jar "$@"
WEOF
      chmod +x gradlew
    }
  fi
fi

chmod +x gradlew 2>/dev/null || true

echo "Building..."
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))"

./gradlew clean assembleRelease --stacktrace 2>&1 | tail -50

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Build complete!                                         ║"
echo "║  APK: app/build/outputs/apk/release/app-release.apk     ║"
echo "║                                                          ║"
echo "║  Next steps:                                             ║"
echo "║  1. Create Firebase project at console.firebase.google.com║"
echo "║  2. Enable Auth (Email/Password) + Realtime Database      ║"
echo "║  3. Download google-services.json → replace app/          ║"
echo "║  4. Set DB rules to allow read/write for auth users       ║"
echo "║  5. Rebuild: ./gradlew assembleRelease                    ║"
echo "╚══════════════════════════════════════════════════════════╝"