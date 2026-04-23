#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
PROJECT_NAME="videocallpro"
APP_NAME="Java Goat"
PACKAGE_NAME="com.example.callingapp"
PACKAGE_PATH="com/example/callingapp"
ANDROID_HOME_DIR="$PWD/android_sdk"
KEYSTORE_PASS="android"
KEY_ALIAS="androiddebugkey"
KEY_PASS="android"
DNAME="CN=Android Debug, O=Android, C=US"

# --- 1. Environment Setup ---
echo "--- Setting up Android SDK ---"
mkdir -p "$ANDROID_HOME_DIR"
export ANDROID_HOME="$ANDROID_HOME_DIR"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Download and unzip command line tools
if [ ! -d "$ANDROID_HOME/cmdline-tools" ]; then
    echo "Downloading Android command-line tools..."
    # As of late 2023, Google's links can be unstable. This is a common one.
    wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdline-tools.zip
    mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
    unzip -q cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools/temp"
    mv "$ANDROID_HOME/cmdline-tools/temp/cmdline-tools/"* "$ANDROID_HOME/cmdline-tools/latest/"
    rm -rf "$ANDROID_HOME/cmdline-tools/temp" cmdline-tools.zip
fi

# Install required SDK packages and accept licenses
echo "Installing SDK platforms, build-tools, and platform-tools..."
yes | sdkmanager --licenses > /dev/null || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# --- 2. Project Structure ---
echo "--- Creating project directory structure for '$PROJECT_NAME' ---"
rm -rf "$PROJECT_NAME"
mkdir -p "$PROJECT_NAME/app/src/main/java/$PACKAGE_PATH"
mkdir -p "$PROJECT_NAME/app/src/main/res/drawable"
mkdir -p "$PROJECT_NAME/app/src/main/res/layout"
mkdir -p "$PROJECT_NAME/app/src/main/res/values"
mkdir -p "$PROJECT_NAME/app/src/main/res/menu"
mkdir -p "$PROJECT_NAME/app/src/main/res/mipmap-anydpi-v26"
mkdir -p "$PROJECT_NAME/app/src/main/res/raw"
cd "$PROJECT_NAME"

# --- 3. Firebase Configuration (Auto-generated) ---
echo "--- Generating google-services.json ---"
cat <<EOF > app/google-services.json
{
  "project_info": {
    "project_number": "1044955332082",
    "firebase_url": "https://videocallpro-f5f1b-default-rtdb.firebaseio.com",
    "project_id": "videocallpro-f5f1b",
    "storage_bucket": "videocallpro-f5f1b.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1044955332082:android:693d22b2b1ff95a36eff6b",
        "android_client_info": {
          "package_name": "${PACKAGE_NAME}"
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

# --- 4. Keystore Generation ---
echo "--- Generating release keystore ---"
keytool -genkey -v -keystore app/release.jks \
-alias "$KEY_ALIAS" \
-keyalg RSA -keysize 2048 \
-validity 10000 \
-storepass "$KEYSTORE_PASS" \
-keypass "$KEY_PASS" \
-dname "$DNAME"

# --- 5. Gradle Configuration ---
echo "--- Creating Gradle build files ---"

# /settings.gradle
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
    }
}
rootProject.name = "JavaGoat"
include ':app'
EOF

# /gradle.properties
cat <<'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
EOF

# /build.gradle (Root)
cat <<'EOF' > build.gradle
plugins {
    id 'com.android.application' version '8.2.0' apply false
    id 'com.google.gms.google-services' version '4.4.1' apply false
}
EOF

# /app/build.gradle
cat <<EOF > app/build.gradle
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
}

android {
    namespace '${PACKAGE_NAME}'
    compileSdk 34

    defaultConfig {
        applicationId "${PACKAGE_NAME}"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        release {
            storeFile file('release.jks')
            storePassword '${KEYSTORE_PASS}'
            keyAlias '${KEY_ALIAS}'
            keyPassword '${KEY_PASS}'
        }
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
        debug {
            applicationIdSuffix ".debug"
            debuggable true
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'

    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.4')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'

    // WebRTC (Stream)
    implementation 'io.getstream:stream-webrtc-android:1.1.1'

    // Glide for image loading (decoding Base64)
    implementation 'com.github.bumptech.glide:glide:4.16.0'

    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

# /app/proguard-rules.pro
cat <<'EOF' > app/proguard-rules.pro
-keep class org.webrtc.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.firebase.database.** { *; }
-keep class com.example.callingapp.models.** { *; }
EOF

# --- 6. AndroidManifest.xml ---
echo "--- Creating AndroidManifest.xml ---"
cat <<EOF > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="${PACKAGE_NAME}">

    <!-- Core Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <!-- Calling Permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.BLUETOOTH" />

    <!-- Notification Permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

    <!-- Foreground Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
    
    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="${APP_NAME}"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.JavaGoat"
        android:name=".MainApplication"
        tools:targetApi="34">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize"
            android:screenOrientation="portrait"
            tools:ignore="LockedOrientationActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".BackgroundService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync"/>
            
    </application>
</manifest>
EOF

# --- 7. Resource Files ---
echo "--- Creating resource files ---"

# values/colors.xml
cat <<'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Neumorphism Palette -->
    <color name="neumorph_background">#E0E5EC</color>
    <color name="neumorph_shadow_light">#FFFFFFFF</color>
    <color name="neumorph_shadow_dark">#A3B1C6</color>
    <color name="neumorph_text_color">#5C6B83</color>

    <!-- WhatsApp-Inspired Accents -->
    <color name="brand_teal_dark">#075E54</color>
    <color name="brand_teal_light">#128C7E</color>
    <color name="brand_accent_blue">#34B7F1</color>
    <color name="brand_aashu_orange">#FF9800</color>
    
    <!-- Status & Buttons -->
    <color name="status_online">#4CAF50</color>
    <color name="call_green">#4CAF50</color>
    <color name="call_red">#F44336</color>
    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="light_gray">#D3D3D3</color>
</resources>
EOF

# values/strings.xml
cat <<EOF > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">${APP_NAME}</string>
    <string name="chats">Chats</string>
    <string name="updates">Updates</string>
    <string name="calls">Calls</string>
    <string name="notification_channel_id">messages_channel</string>
    <string name="notification_channel_name">Messages</string>
    <string name="call_notification_channel_id">calls_channel</string>
    <string name="call_notification_channel_name">Incoming Calls</string>
    <string name="persistent_channel_id">background_service</string>
    <string name="persistent_channel_name">Background Service</string>
</resources>
EOF

# values/themes.xml
cat <<'EOF' > app/src/main/res/values/themes.xml
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.JavaGoat" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/brand_teal_dark</item>
        <item name="colorPrimaryVariant">@color/brand_teal_light</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="android:statusBarColor">?attr/colorPrimary</item>
        <item name="android:windowBackground">@color/neumorph_background</item>
    </style>
</resources>
EOF

# drawable/msg_out_bg.xml (Neumorphic)
cat <<'EOF' > app/src/main/res/drawable/msg_out_bg.xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Shadow Layer -->
    <item>
        <shape>
            <solid android:color="@color/neumorph_shadow_dark" />
            <corners android:topLeftRadius="16dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="4dp"/>
        </shape>
    </item>
    <!-- Highlight Layer -->
    <item android:bottom="2dp" android:right="2dp">
        <shape>
            <solid android:color="@color/neumorph_shadow_light" />
            <corners android:topLeftRadius="16dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="4dp"/>
        </shape>
    </item>
    <!-- Content Layer -->
    <item android:bottom="3dp" android:right="3dp" android:left="1dp" android:top="1dp">
        <shape>
            <solid android:color="@color/brand_accent_blue" />
            <corners android:topLeftRadius="16dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="4dp"/>
        </shape>
    </item>
</layer-list>
EOF

# drawable/msg_in_bg.xml (Neumorphic)
cat <<'EOF' > app/src/main/res/drawable/msg_in_bg.xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Shadow Layer -->
    <item>
        <shape>
            <solid android:color="@color/neumorph_shadow_dark" />
            <corners android:topLeftRadius="4dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="16dp"/>
        </shape>
    </item>
    <!-- Highlight Layer -->
    <item android:bottom="2dp" android:right="2dp">
        <shape>
            <solid android:color="@color/neumorph_shadow_light" />
             <corners android:topLeftRadius="4dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="16dp"/>
        </shape>
    </item>
    <!-- Content Layer -->
    <item android:bottom="3dp" android:right="3dp" android:left="1dp" android:top="1dp">
        <shape>
            <solid android:color="@color/white" />
            <corners android:topLeftRadius="4dp" android:bottomLeftRadius="16dp" android:topRightRadius="16dp" android:bottomRightRadius="16dp"/>
        </shape>
    </item>
</layer-list>
EOF

# drawable/emoji_bg.xml
cat <<'EOF' > app/src/main/res/drawable/emoji_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/light_gray" />
</shape>
EOF

# drawable/neumorph_button_bg.xml
cat <<'EOF' > app/src/main/res/drawable/neumorph_button_bg.xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Shadow -->
    <item>
        <shape android:shape="rectangle">
            <solid android:color="@color/neumorph_shadow_dark"/>
            <corners android:radius="12dp"/>
        </shape>
    </item>
    <!-- Highlight -->
    <item android:bottom="2dp" android:right="2dp">
        <shape android:shape="rectangle">
            <solid android:color="@color/neumorph_shadow_light"/>
            <corners android:radius="12dp"/>
        </shape>
    </item>
    <!-- Background -->
    <item android:top="1dp" android:left="1dp" android:right="3dp" android:bottom="3dp">
        <shape android:shape="rectangle">
            <solid android:color="@color/neumorph_background"/>
            <corners android:radius="12dp"/>
        </shape>
    </item>
</layer-list>
EOF

# drawable/neumorph_button_pressed_bg.xml
cat <<'EOF' > app/src/main/res/drawable/neumorph_button_pressed_bg.xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Inset Shadow -->
    <item>
        <shape android:shape="rectangle">
            <gradient
                android:angle="225"
                android:endColor="@color/neumorph_shadow_dark"
                android:startColor="@android:color/transparent"
                android:type="linear" />
            <corners android:radius="12dp"/>
        </shape>
    </item>
    <item>
        <shape android:shape="rectangle">
            <gradient
                android:angle="45"
                android:endColor="@color/neumorph_shadow_light"
                android:startColor="@android:color/transparent"
                android:type="linear" />
            <corners android:radius="12dp"/>
        </shape>
    </item>
    <!-- Background -->
    <item android:top="2dp" android:left="2dp" android:right="2dp" android:bottom="2dp">
        <shape android:shape="rectangle">
            <solid android:color="@color/neumorph_background"/>
            <corners android:radius="10dp"/>
        </shape>
    </item>
</layer-list>
EOF

# drawable/neumorph_button_selector.xml
cat <<'EOF' > app/src/main/res/drawable/neumorph_button_selector.xml
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_pressed="true" android:drawable="@drawable/neumorph_button_pressed_bg" />
    <item android:drawable="@drawable/neumorph_button_bg" />
</selector>
EOF

# menu/bottom_nav_menu.xml
cat <<'EOF' > app/src/main/res/menu/bottom_nav_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/navigation_chats"
        android:icon="@drawable/ic_baseline_chat_24"
        android:title="@string/chats" />
    <item
        android:id="@+id/navigation_updates"
        android:icon="@drawable/ic_baseline_notifications_24"
        android:title="@string/updates" />
    <item
        android:id="@+id/navigation_calls"
        android:icon="@drawable/ic_baseline_call_24"
        android:title="@string/calls" />
</menu>
EOF

# drawable/ic_baseline_chat_24.xml
cat <<'EOF' > app/src/main/res/drawable/ic_baseline_chat_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M20,2L4,2c-1.1,0 -1.99,0.9 -1.99,2L2,22l4,-4h14c1.1,0 2,-0.9 2,-2L22,4c0,-1.1 -0.9,-2 -2,-2zM6,9h12v2L6,11L6,9zM14,14L6,14v-2h8v2zM18,8L6,8L6,6h12v2z"/>
</vector>
EOF

# drawable/ic_baseline_notifications_24.xml
cat <<'EOF' > app/src/main/res/drawable/ic_baseline_notifications_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.9,2 2,2zM18,16v-5c0,-3.07 -1.63,-5.64 -4.5,-6.32L13.5,4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.64,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
EOF

# drawable/ic_baseline_call_24.xml
cat <<'EOF' > app/src/main/res/drawable/ic_baseline_call_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M6.62,10.79c1.44,2.83 3.76,5.14 6.59,6.59l2.2,-2.2c0.27,-0.27 0.67,-0.36 1.02,-0.24 1.12,0.37 2.33,0.57 3.58,0.57 0.55,0 1,0.45 1,1L21,18c0,0.55 -0.45,1 -1,1 -9.39,0 -17,-7.61 -17,-17 0,-0.55 0.45,-1 1,-1l3.5,0c0.55,0 1,0.45 1,1 0,1.25 0.2,2.45 0.57,3.58 0.11,0.35 0.03,0.74 -0.25,1.02l-2.2,2.2z"/>
</vector>
EOF

# mipmap-anydpi-v26/ic_launcher.xml
cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

# mipmap-anydpi-v26/ic_launcher_round.xml
cat <<'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

# drawable/ic_launcher_background.xml
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_background.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/brand_teal_dark"/>
</shape>
EOF

# drawable/ic_launcher_foreground.xml
cat <<'EOF' > app/src/main/res/drawable/ic_launcher_foreground.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
  <path
      android:fillColor="#FFFFFF"
      android:pathData="M54,54m-26,0a26,26 0,1 1,52 0a26,26 0,1 1,-52 0"
      android:strokeColor="#FFF"
      android:strokeWidth="2"/>
  <path
      android:fillColor="#FFFFFF"
      android:pathData="M38,44h32v4H38z M38,52h32v4H38z M38,60h20v4H38z"/>
</vector>
EOF

# layout/activity_main.xml
cat <<'EOF' > app/src/main/res/layout/activity_main.xml
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <!-- Auth View -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/auth_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/neumorph_background"
        android:padding="32dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/auth_title"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Java Goat"
            android:textSize="34sp"
            android:textStyle="bold"
            android:textColor="@color/brand_teal_dark"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintBottom_toTopOf="@id/email_input"/>

        <EditText
            android:id="@+id/email_input"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:hint="Email"
            android:inputType="textEmailAddress"
            android:background="@drawable/neumorph_button_pressed_bg"
            android:padding="16dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintVertical_bias="0.4"/>

        <EditText
            android:id="@+id/password_input"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:hint="Password"
            android:inputType="textPassword"
            android:background="@drawable/neumorph_button_pressed_bg"
            android:padding="16dp"
            app:layout_constraintTop_toBottomOf="@id/email_input"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <Button
            android:id="@+id/login_button"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginTop="24dp"
            android:text="Login"
            android:background="@drawable/neumorph_button_selector"
            android:textColor="@color/neumorph_text_color"
            app:layout_constraintTop_toBottomOf="@id/password_input"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <Button
            android:id="@+id/signup_button"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="Sign Up"
            android:background="@drawable/neumorph_button_selector"
            android:textColor="@color/neumorph_text_color"
            app:layout_constraintTop_toBottomOf="@id/login_button"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- Main Content View -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/main_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:visibility="gone">

        <com.google.android.material.appbar.AppBarLayout
            android:id="@+id/app_bar_layout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            app:layout_constraintTop_toTopOf="parent">

            <androidx.appcompat.widget.Toolbar
                android:id="@+id/toolbar"
                android:layout_width="match_parent"
                android:layout_height="?attr/actionBarSize"
                android:background="?attr/colorPrimary"
                app:titleTextColor="@color/white" />
        </com.google.android.material.appbar.AppBarLayout>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/main_recycler_view"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            app:layout_constraintTop_toBottomOf="@id/app_bar_layout"
            app:layout_constraintBottom_toTopOf="@id/bottom_navigation"
            tools:listitem="@layout/item_list_contact" />
            
        <com.google.android.material.floatingactionbutton.FloatingActionButton
            android:id="@+id/fab_add_friend"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_margin="16dp"
            android:src="@drawable/ic_baseline_person_add_24"
            app:backgroundTint="@color/brand_accent_blue"
            app:tint="@color/white"
            app:layout_constraintBottom_toTopOf="@id/bottom_navigation"
            app:layout_constraintEnd_toEndOf="parent"/>

        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottom_navigation"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="?attr/colorPrimary"
            app:itemIconTint="@color/white"
            app:itemTextColor="@color/white"
            app:layout_constraintBottom_toBottomOf="parent"
            app:menu="@menu/bottom_nav_menu" />
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- Chat View -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/chat_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/neumorph_background"
        android:visibility="gone">

        <com.google.android.material.appbar.AppBarLayout
            android:id="@+id/chat_app_bar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            app:layout_constraintTop_toTopOf="parent">
            <androidx.appcompat.widget.Toolbar
                android:id="@+id/chat_toolbar"
                android:layout_width="match_parent"
                android:layout_height="?attr/actionBarSize"
                android:background="?attr/colorPrimary" />
        </com.google.android.material.appbar.AppBarLayout>
        
        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/chat_recycler_view"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:padding="8dp"
            app:layout_constraintTop_toBottomOf="@id/chat_app_bar"
            app:layout_constraintBottom_toTopOf="@id/reply_layout" />

        <LinearLayout
            android:id="@+id/reply_layout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="8dp"
            android:paddingEnd="8dp"
            android:paddingTop="4dp"
            android:background="#DDDDDD"
            android:visibility="gone"
            app:layout_constraintBottom_toTopOf="@id/message_input_layout">
            <TextView
                android:id="@+id/replying_to_name"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textStyle="bold"
                android:textColor="@color/brand_teal_dark"/>
            <TextView
                android:id="@+id/replying_to_text"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:maxLines="1"
                android:ellipsize="end"/>
        </LinearLayout>

        <LinearLayout
            android:id="@+id/message_input_layout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:padding="8dp"
            android:gravity="center_vertical"
            app:layout_constraintBottom_toBottomOf="parent">

            <EditText
                android:id="@+id/message_input"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:hint="Type a message"
                android:background="@drawable/neumorph_button_pressed_bg"
                android:padding="12dp"
                android:maxLines="5"/>

            <com.google.android.material.floatingactionbutton.FloatingActionButton
                android:id="@+id/send_button"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:src="@drawable/ic_baseline_send_24"
                app:fabSize="mini"
                app:backgroundTint="@color/brand_teal_light"
                app:tint="@color/white"/>
        </LinearLayout>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- Call View -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/call_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="#2C3E50"
        android:visibility="gone">

        <org.webrtc.SurfaceViewRenderer
            android:id="@+id/remote_video_view"
            android:layout_width="match_parent"
            android:layout_height="match_parent" />
        
        <androidx.cardview.widget.CardView
            android:layout_width="120dp"
            android:layout_height="160dp"
            app:cardCornerRadius="8dp"
            android:layout_margin="16dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintEnd_toEndOf="parent">
            <org.webrtc.SurfaceViewRenderer
                android:id="@+id/local_video_view"
                android:layout_width="match_parent"
                android:layout_height="match_parent" />
        </androidx.cardview.widget.CardView>
        
        <TextView
            android:id="@+id/caller_name"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/white"
            android:textSize="28sp"
            android:textStyle="bold"
            tools:text="Partner Name"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            android:layout_marginTop="64dp"/>

        <TextView
            android:id="@+id/call_status"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/light_gray"
            android:textSize="18sp"
            tools:text="Ringing..."
            app:layout_constraintTop_toBottomOf="@id/caller_name"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            android:layout_marginTop="8dp"/>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center"
            android:layout_marginBottom="64dp"
            app:layout_constraintBottom_toBottomOf="parent">

            <com.google.android.material.floatingactionbutton.FloatingActionButton
                android:id="@+id/accept_call_button"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:src="@drawable/ic_baseline_call_24"
                app:backgroundTint="@color/call_green"
                app:tint="@color/white"
                android:layout_marginEnd="40dp"
                android:visibility="gone"/>

            <com.google.android.material.floatingactionbutton.FloatingActionButton
                android:id="@+id/end_call_button"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:src="@drawable/ic_baseline_call_end_24"
                app:backgroundTint="@color/call_red"
                app:tint="@color/white"
                android:layout_marginStart="40dp"/>
        </LinearLayout>
    </androidx.constraintlayout.widget.ConstraintLayout>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# layout/item_list_contact.xml
cat <<'EOF' > app/src/main/res/layout/item_list_contact.xml
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:padding="12dp">

    <ImageView
        android:id="@+id/item_avatar"
        android:layout_width="50dp"
        android:layout_height="50dp"
        android:background="@drawable/emoji_bg"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent" />

    <View
        android:id="@+id/online_indicator"
        android:layout_width="12dp"
        android:layout_height="12dp"
        android:background="@drawable/online_indicator_shape"
        app:layout_constraintCircle="@id/item_avatar"
        app:layout_constraintCircleRadius="25dp"
        app:layout_constraintCircleAngle="135"
        android:visibility="gone"
        tools:visibility="visible"
        android:layout_margin="2dp"
        />

    <TextView
        android:id="@+id/item_name"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:textColor="@color/neumorph_text_color"
        android:textSize="18sp"
        android:textStyle="bold"
        app:layout_constraintStart_toEndOf="@id/item_avatar"
        app:layout_constraintEnd_toStartOf="@id/item_timestamp"
        app:layout_constraintTop_toTopOf="@id/item_avatar"
        tools:text="Contact Name" />

    <TextView
        android:id="@+id/item_last_message"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:maxLines="1"
        android:ellipsize="end"
        android:textColor="@color/neumorph_text_color"
        app:layout_constraintStart_toEndOf="@id/item_avatar"
        app:layout_constraintEnd_toStartOf="@id/item_unread_badge"
        app:layout_constraintTop_toBottomOf="@id/item_name"
        tools:text="This is the last message sent..." />
        
    <TextView
        android:id="@+id/item_timestamp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/neumorph_text_color"
        android:textSize="12sp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="@id/item_name"
        tools:text="10:45 AM" />

    <TextView
        android:id="@+id/item_unread_badge"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:minWidth="20dp"
        android:minHeight="20dp"
        android:background="@drawable/unread_badge_shape"
        android:textColor="@color/white"
        android:gravity="center"
        android:textSize="10sp"
        android:padding="3dp"
        android:visibility="gone"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toBottomOf="@id/item_timestamp"
        app:layout_constraintBottom_toBottomOf="parent"
        tools:text="3"
        tools:visibility="visible"/>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# layout/item_list_update.xml
cat <<'EOF' > app/src/main/res/layout/item_list_update.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="12dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical">
        <ImageView
            android:id="@+id/item_avatar"
            android:layout_width="50dp"
            android:layout_height="50dp"
            android:background="@drawable/emoji_bg"/>
        <TextView
            android:id="@+id/item_message"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:textColor="@color/neumorph_text_color"
            android:text="Friend request from Name"/>
    </LinearLayout>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="end"
        android:layout_marginTop="8dp">

        <Button
            android:id="@+id/reject_button"
            android:layout_width="wrap_content"
            android:layout_height="40dp"
            android:text="Reject"
            android:background="@drawable/neumorph_button_selector"
            android:textColor="@color/call_red"
            android:layout_marginEnd="8dp"/>

        <Button
            android:id="@+id/accept_button"
            android:layout_width="wrap_content"
            android:layout_height="40dp"
            android:text="Accept"
            android:background="@drawable/neumorph_button_selector"
            android:textColor="@color/call_green"/>
    </LinearLayout>
</LinearLayout>
EOF

# layout/item_list_call.xml
cat <<'EOF' > app/src/main/res/layout/item_list_call.xml
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:padding="12dp">

    <ImageView
        android:id="@+id/item_avatar"
        android:layout_width="50dp"
        android:layout_height="50dp"
        android:background="@drawable/emoji_bg"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent" />
        
    <TextView
        android:id="@+id/item_name"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:textColor="@color/neumorph_text_color"
        android:textSize="18sp"
        android:textStyle="bold"
        app:layout_constraintStart_toEndOf="@id/item_avatar"
        app:layout_constraintEnd_toStartOf="@id/item_call_type_icon"
        app:layout_constraintTop_toTopOf="@id/item_avatar"
        tools:text="Contact Name" />
        
    <ImageView
        android:id="@+id/item_call_direction_icon"
        android:layout_width="16dp"
        android:layout_height="16dp"
        android:layout_marginStart="16dp"
        tools:src="@drawable/ic_call_received_24"
        app:layout_constraintStart_toEndOf="@id/item_avatar"
        app:layout_constraintTop_toBottomOf="@id/item_name"/>

    <TextView
        android:id="@+id/item_timestamp"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="4dp"
        android:maxLines="1"
        android:ellipsize="end"
        android:textColor="@color/neumorph_text_color"
        app:layout_constraintStart_toEndOf="@id/item_call_direction_icon"
        app:layout_constraintTop_toBottomOf="@id/item_name"
        tools:text="Yesterday, 10:45 PM" />

    <ImageButton
        android:id="@+id/item_call_type_icon"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="?selectableItemBackgroundBorderless"
        tools:src="@drawable/ic_baseline_videocam_24"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:tint="@color/brand_teal_light"/>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# layout/item_message.xml
cat <<'EOF' > app/src/main/res/layout/item_message.xml
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:padding="4dp">

    <androidx.cardview.widget.CardView
        android:id="@+id/message_card"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:cardElevation="0dp"
        app:cardBackgroundColor="@android:color/transparent"
        app:layout_constrainedWidth="true"
        app:layout_constraintHorizontal_bias="0.0"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent">

        <LinearLayout
            android:id="@+id/message_bubble"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="12dp"
            android:paddingTop="8dp"
            android:paddingEnd="12dp"
            android:paddingBottom="8dp"
            tools:background="@drawable/msg_in_bg">

            <LinearLayout
                android:id="@+id/reply_preview_layout"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:background="@drawable/reply_preview_bg"
                android:padding="8dp"
                android:layout_marginBottom="4dp"
                android:visibility="gone"
                tools:visibility="visible">

                <TextView
                    android:id="@+id/replied_to_name"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textStyle="bold"
                    android:textColor="@color/brand_teal_dark"
                    tools:text="You"/>

                <TextView
                    android:id="@+id/replied_to_message"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:maxLines="2"
                    android:ellipsize="end"
                    android:textColor="@color/neumorph_text_color"
                    tools:text="This is the message being replied to, it can be a bit long."/>
            </LinearLayout>

            <TextView
                android:id="@+id/message_text"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/black"
                android:textSize="16sp"
                tools:text="This is a sample message content." />

            <TextView
                android:id="@+id/message_timestamp"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="end"
                android:layout_marginTop="4dp"
                android:textColor="@color/neumorph_text_color"
                android:textSize="10sp"
                tools:text="10:30 PM" />
        </LinearLayout>
    </androidx.cardview.widget.CardView>

    <TextView
        android:id="@+id/reactions_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="8dp"
        android:layout_marginEnd="8dp"
        android:paddingStart="6dp"
        android:paddingEnd="6dp"
        android:paddingTop="2dp"
        android:paddingBottom="2dp"
        android:background="@drawable/emoji_bg"
        android:elevation="1dp"
        android:visibility="gone"
        tools:text="👍 2 ❤️ 1"
        tools:visibility="visible"
        app:layout_constraintTop_toBottomOf="@id/message_card"
        app:layout_constraintEnd_toEndOf="@id/message_card"/>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF


# layout/dialog_input.xml
cat <<'EOF' > app/src/main/res/layout/dialog_input.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="24dp">

    <TextView
        android:id="@+id/dialog_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Title"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="@color/black"/>

    <EditText
        android:id="@+id/dialog_input"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp" />
</LinearLayout>
EOF

# layout/dialog_profile_setup.xml
cat <<'EOF' > app/src/main/res/layout/dialog_profile_setup.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:gravity="center_horizontal"
    android:padding="24dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Set up your Profile"
        android:textSize="20sp"
        android:textStyle="bold"
        android:textColor="@color/black"
        android:layout_marginBottom="24dp"/>

    <androidx.cardview.widget.CardView
        android:layout_width="100dp"
        android:layout_height="100dp"
        app:cardCornerRadius="50dp">
        <ImageView
            android:id="@+id/profile_image_picker"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:src="@drawable/ic_baseline_add_a_photo_24"
            android:scaleType="centerCrop"
            android:background="@color/light_gray"
            android:clickable="true"
            android:focusable="true"/>
    </androidx.cardview.widget.CardView>
    
    <EditText
        android:id="@+id/name_input"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Your Name"
        android:layout_marginTop="24dp"/>

</LinearLayout>
EOF

# Other drawables
cat <<'EOF' > app/src/main/res/drawable/ic_baseline_person_add_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M15,12c2.21,0 4,-1.79 4,-4s-1.79,-4 -4,-4 -4,1.79 -4,4 1.79,4 4,4zM6,10V7H4v3H1v2h3v3h2v-3h3v-2H6zM15,14c-2.67,0 -8,1.34 -8,4v2h16v-2c0,-2.66 -5.33,-4 -8,-4z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_baseline_send_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_baseline_videocam_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M17,10.5V7c0,-0.55 -0.45,-1 -1,-1H4c-0.55,0 -1,0.45 -1,1v10c0,0.55 0.45,1 1,1h12c0.55,0 1,-0.45 1,-1v-3.5l4,4v-11l-4,4z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_baseline_call_end_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,9c-1.6,0 -3.15,0.25 -4.6,0.72v3.1c0,0 0,0.01 0,0.01 1.4,-0.42 2.9,-0.63 4.45,-0.63 1.55,0 3.05,0.21 4.45,0.63 0,0 0,-0.01 0,-0.01v-3.1C15.15,9.25 13.6,9 12,9zM3.95,7.95C5.8,6.81 8.83,6 12,6s6.2,0.81 8.05,1.95v7.21c-0.16,0.02 -0.32,0.04 -0.48,0.07 -0.25,0.03 -0.5,0.08 -0.76,0.13 -0.73,0.15 -1.5,0.27 -2.29,0.37C15.1,15.89 13.58,16 12,16s-3.1,-0.11 -4.52,-0.27c-0.79,-0.09 -1.56,-0.22 -2.29,-0.37 -0.26,-0.05 -0.51,-0.09 -0.76,-0.13 -0.16,-0.03 -0.32,-0.05 -0.48,-0.07V7.95zM19.95,5.13c-2.31,-1.4 -5.58,-2.13 -9.95,-2.13S2.36,3.73 0.05,5.13L0,17.21c0.31,0.06 0.62,0.12 0.93,0.19 0.35,0.08 0.7,0.16 1.06,0.25 0.9,0.22 1.85,0.41 2.82,0.56C6.27,18.7 8.96,19 12,19s5.73,-0.3 7.18,-0.79c0.97,-0.15 1.92,-0.34 2.82,-0.56 0.36,-0.09 0.71,-0.17 1.06,-0.25 0.31,-0.07 0.62,-0.13 0.93,-0.19L24,5.13l-4.05,0z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/online_indicator_shape.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/status_online"/>
    <stroke android:width="2dp" android:color="@color/neumorph_background"/>
</shape>
EOF

cat <<'EOF' > app/src/main/res/drawable/unread_badge_shape.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/brand_accent_blue"/>
</shape>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_call_received_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="@color/call_green">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M20,5.41L18.59,4 7,15.59V9H5v10h10v-2H8.41z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_call_made_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="@color/call_red">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M9,5v2h6.59L4,18.59 5.41,20 17,8.41V15h2V5z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_baseline_more_vert_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,8c1.1,0 2,-0.9 2,-2s-0.9,-2 -2,-2 -2,0.9 -2,2 0.9,2 2,2zM12,10c-1.1,0 -2,0.9 -2,2s0.9,2 2,2 2,-0.9 2,-2 -0.9,-2 -2,-2zM12,16c-1.1,0 -2,0.9 -2,2s0.9,2 2,2 2,-0.9 2,-2 -0.9,-2 -2,-2z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/ic_baseline_add_a_photo_24.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:height="24dp" android:tint="#6F6F6F" android:viewportHeight="24" android:viewportWidth="24" android:width="24dp">
    <path android:fillColor="@android:color/white" android:pathData="M3,4V1h2v3h3v2H5v3H3V6H0V4H3zM6,10V7h3V4h7l1.83,2H21c1.1,0 2,0.9 2,2v12c0,1.1 -0.9,2 -2,2H5c-1.1,0 -2,-0.9 -2,-2V10H6zM13,19c2.76,0 5,-2.24 5,-5s-2.24,-5 -5,-5 -5,2.24 -5,5 2.24,5 5,5zM13,11.5c1.93,0 3.5,1.57 3.5,3.5s-1.57,3.5 -3.5,3.5 -3.5,-1.57 -3.5,-3.5 1.57,-3.5 3.5,-3.5z"/>
</vector>
EOF

cat <<'EOF' > app/src/main/res/drawable/reply_preview_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#E0E0E0"/>
    <corners android:radius="8dp"/>
    <padding android:left="8dp" android:right="8dp" android:top="4dp" android:bottom="4dp"/>
</shape>
EOF

# --- 8. Java Source Code ---
echo "--- Creating Java source files ---"

# /app/src/main/java/com/example/callingapp/MainApplication.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/MainApplication.java
package ${PACKAGE_NAME};

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannels();
    }

    private void createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Channel for incoming calls (high importance)
            NotificationChannel callChannel = new NotificationChannel(
                    getString(R.string.call_notification_channel_id),
                    getString(R.string.call_notification_channel_name),
                    NotificationManager.IMPORTANCE_HIGH
            );
            callChannel.setDescription("Channel for incoming call notifications");

            // Channel for messages (default importance)
            NotificationChannel messageChannel = new NotificationChannel(
                    getString(R.string.notification_channel_id),
                    getString(R.string.notification_channel_name),
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            messageChannel.setDescription("Channel for new message notifications");

            // Channel for persistent background service notification (low importance)
            NotificationChannel persistentChannel = new NotificationChannel(
                    getString(R.string.persistent_channel_id),
                    getString(R.string.persistent_channel_name),
                    NotificationManager.IMPORTANCE_LOW
            );
            persistentChannel.setDescription("Notification to keep the service running");

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(callChannel);
                manager.createNotificationChannel(messageChannel);
                manager.createNotificationChannel(persistentChannel);
            }
        }
    }
}
EOF


# /app/src/main/java/com/example/callingapp/MainActivity.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/MainActivity.java
package ${PACKAGE_NAME};

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.media.AudioManager;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.media.ToneGenerator;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.example.callingapp.models.CallHistory;
import com.example.callingapp.models.ChatContact;
import com.example.callingapp.models.Message;
import com.example.callingapp.models.User;
import com.google.android.material.badge.BadgeDrawable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import org.webrtc.AudioSource;
import org.webrtc.AudioTrack;
import org.webrtc.Camera2Enumerator;
import org.webrtc.CameraEnumerator;
import org.webrtc.DefaultVideoDecoderFactory;
import org.webrtc.DefaultVideoEncoderFactory;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.SessionDescription;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    private static final int PERMISSION_REQUEST_CODE = 1001;
    public static boolean isAppInForeground = false;

    // Firebase
    private FirebaseAuth mAuth;
    private DatabaseReference mUsersRef, mCallsRef, mFriendRequestsRef, mFriendshipsRef, mChatsRef, mTypingRef;
    private ValueEventListener incomingCallListener;
    private ValueEventListener friendRequestListener;

    // UI Components
    private ConstraintLayout authView, mainView, chatView, callView;
    private BottomNavigationView bottomNavigationView;
    private RecyclerView mainRecyclerView, chatRecyclerView;
    private MainAdapter mainAdapter;
    private ChatAdapter chatAdapter;
    private Toolbar mainToolbar, chatToolbar;
    private FloatingActionButton fabAddFriend;

    // Chat UI
    private TextView chatPartnerName;
    private ImageView chatPartnerAvatar;
    private EditText messageInput;
    private ImageButton sendButton;
    private LinearLayout replyLayout;
    private TextView replyingToName, replyingToText;

    // User Data
    private User currentUser;
    private User chatPartner;
    private String currentChatId;
    private Message messageToReplyTo;

    // WebRTC
    private PeerConnectionFactory peerConnectionFactory;
    private PeerConnection peerConnection;
    private EglBase eglBase;
    private SurfaceViewRenderer localVideoView, remoteVideoView;
    private VideoTrack localVideoTrack;
    private AudioTrack localAudioTrack;
    private VideoCapturer videoCapturer;
    private SurfaceTextureHelper surfaceTextureHelper;
    private List<PeerConnection.IceServer> iceServers = new ArrayList<>();
    private String currentCallId = null;
    private boolean isCallInitiator = false;

    // Call UI
    private TextView callerName, callStatus;
    private FloatingActionButton acceptCallButton, endCallButton;
    private long callStartTime;
    private Ringtone ringtone;
    private ToneGenerator toneGenerator;

    // Handlers & Executors
    private final Handler typingHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    
    // Image Picking
    private String profileImageBase64;
    private ImageView profileImagePicker;
    private final ActivityResultLauncher<Intent> imagePickerLauncher = registerForActivityResult(
        new ActivityResultContracts.StartActivityForResult(),
        result -> {
            if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                Uri imageUri = result.getData().getData();
                try {
                    Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), imageUri);
                    Bitmap scaledBitmap = scaleBitmap(bitmap, 400); // Scale down to reasonable size
                    profileImagePicker.setImageBitmap(scaledBitmap);
                    profileImageBase64 = bitmapToBase64(scaledBitmap);
                } catch (IOException e) {
                    Log.e(TAG, "Image picking failed", e);
                }
            }
        });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        checkPermissions();
        initializeUI();
        initializeFirebase();
        initializeWebRTC();

        handleAuthState();
    }

    private void checkPermissions() {
        String[] permissions = {
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.POST_NOTIFICATIONS,
                Manifest.permission.BLUETOOTH
        };
        
        List<String> permissionsToRequest = new ArrayList<>();
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(permission);
            }
        }

        if (!permissionsToRequest.isEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toArray(new String[0]), PERMISSION_REQUEST_CODE);
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }
            if (!allGranted) {
                Toast.makeText(this, "Some permissions were denied. App functionality may be limited.", Toast.LENGTH_LONG).show();
            }
        }
    }


    private void initializeUI() {
        // Views
        authView = findViewById(R.id.auth_view);
        mainView = findViewById(R.id.main_view);
        chatView = findViewById(R.id.chat_view);
        callView = findViewById(R.id.call_view);

        // Main Toolbar
        mainToolbar = findViewById(R.id.toolbar);
        setSupportActionBar(mainToolbar);
        setToolbarTitle("Aashu g");

        // Auth
        findViewById(R.id.login_button).setOnClickListener(v -> handleLogin());
        findViewById(R.id.signup_button).setOnClickListener(v -> handleSignup());

        // Main View
        bottomNavigationView = findViewById(R.id.bottom_navigation);
        mainRecyclerView = findViewById(R.id.main_recycler_view);
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mainAdapter = new MainAdapter(this);
        mainRecyclerView.setAdapter(mainAdapter);
        fabAddFriend = findViewById(R.id.fab_add_friend);
        fabAddFriend.setOnClickListener(v -> showAddFriendDialog());
        
        bottomNavigationView.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.navigation_chats) {
                mainAdapter.setMode(MainAdapter.Mode.CHATS);
                fabAddFriend.hide();
                return true;
            } else if (itemId == R.id.navigation_updates) {
                mainAdapter.setMode(MainAdapter.Mode.UPDATES);
                fabAddFriend.hide();
                return true;
            } else if (itemId == R.id.navigation_calls) {
                mainAdapter.setMode(MainAdapter.Mode.CALLS);
                fabAddFriend.show();
                return true;
            }
            return false;
        });

        // Chat View
        chatToolbar = findViewById(R.id.chat_toolbar);
        chatRecyclerView = findViewById(R.id.chat_recycler_view);
        LinearLayoutManager chatLayoutManager = new LinearLayoutManager(this);
        chatLayoutManager.setStackFromEnd(true);
        chatRecyclerView.setLayoutManager(chatLayoutManager);
        messageInput = findViewById(R.id.message_input);
        sendButton = findViewById(R.id.send_button);
        replyLayout = findViewById(R.id.reply_layout);
        replyingToName = findViewById(R.id.replying_to_name);
        replyingToText = findViewById(R.id.replying_to_text);
        findViewById(R.id.reply_layout).setOnClickListener(v -> clearReply());
        
        sendButton.setOnClickListener(v -> sendMessage());
        setupMessageInputListener();
        setupSwipeToReply();

        // Call View
        localVideoView = findViewById(R.id.local_video_view);
        remoteVideoView = findViewById(R.id.remote_video_view);
        callerName = findViewById(R.id.caller_name);
        callStatus = findViewById(R.id.call_status);
        acceptCallButton = findViewById(R.id.accept_call_button);
        endCallButton = findViewById(R.id.end_call_button);

        acceptCallButton.setOnClickListener(v -> acceptCall());
        endCallButton.setOnClickListener(v -> endCall());
    }

    private void setToolbarTitle(String title) {
        if (getSupportActionBar() != null) {
            SpannableString spannableString = new SpannableString(title);
            spannableString.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.brand_aashu_orange)), 0, 5, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            spannableString.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.brand_accent_blue)), 5, title.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            getSupportActionBar().setTitle(spannableString);
        }
    }

    private void initializeFirebase() {
        mAuth = FirebaseAuth.getInstance();
        FirebaseDatabase database = FirebaseDatabase.getInstance();
        mUsersRef = database.getReference("users");
        mCallsRef = database.getReference("calls");
        mFriendRequestsRef = database.getReference("friend_requests");
        mFriendshipsRef = database.getReference("friendships");
        mChatsRef = database.getReference("chats");
        mTypingRef = database.getReference("typing_indicators");
    }

    private void initializeWebRTC() {
        executor.execute(() -> {
            eglBase = EglBase.create();
            PeerConnectionFactory.initialize(
                PeerConnectionFactory.InitializationOptions.builder(this)
                    .setEnableInternalTracer(true)
                    .createInitializationOptions()
            );

            PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
            DefaultVideoEncoderFactory defaultVideoEncoderFactory = new DefaultVideoEncoderFactory(
                eglBase.getEglBaseContext(), true, true);
            DefaultVideoDecoderFactory defaultVideoDecoderFactory = new DefaultVideoDecoderFactory(
                eglBase.getEglBaseContext());

            peerConnectionFactory = PeerConnectionFactory.builder()
                .setOptions(options)
                .setVideoEncoderFactory(defaultVideoEncoderFactory)
                .setVideoDecoderFactory(defaultVideoDecoderFactory)
                .createPeerConnectionFactory();

            iceServers.add(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer());
            iceServers.add(PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer());
            iceServers.add(PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer());
            
            mainHandler.post(() -> {
                localVideoView.init(eglBase.getEglBaseContext(), null);
                remoteVideoView.init(eglBase.getEglBaseContext(), null);
                localVideoView.setMirror(true);
                remoteVideoView.setMirror(false);
            });
        });
    }

    private void handleAuthState() {
        mAuth.addAuthStateListener(firebaseAuth -> {
            FirebaseUser user = firebaseAuth.getCurrentUser();
            if (user != null) {
                // User is signed in
                loadUserProfile(user.getUid());
                switchView(mainView);
            } else {
                // User is signed out
                switchView(authView);
                cleanupAfterLogout();
            }
        });
    }

    private void loadUserProfile(String uid) {
        mUsersRef.child(uid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    currentUser = snapshot.getValue(User.class);
                    if (currentUser != null) {
                        currentUser.setUid(uid);
                        onUserLoggedIn();
                    }
                } else {
                    // This is a new user, show profile setup
                    showProfileSetupDialog(uid);
                }
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.e(TAG, "Failed to load user profile: " + error.getMessage());
                Toast.makeText(MainActivity.this, "Failed to load profile.", Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void showProfileSetupDialog(String uid) {
        MaterialAlertDialogBuilder builder = new MaterialAlertDialogBuilder(this);
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_profile_setup, null);
        EditText nameInput = view.findViewById(R.id.name_input);
        profileImagePicker = view.findViewById(R.id.profile_image_picker);
        
        profileImagePicker.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            imagePickerLauncher.launch(intent);
        });

        builder.setView(view);
        builder.setTitle("Create Profile");
        builder.setCancelable(false);
        builder.setPositiveButton("Save", (dialog, which) -> {
            String name = nameInput.getText().toString().trim();
            if (name.isEmpty()) {
                Toast.makeText(this, "Name cannot be empty", Toast.LENGTH_SHORT).show();
                showProfileSetupDialog(uid); // Re-show dialog
                return;
            }
            
            String friendId = String.format(Locale.US, "%04d", new Random().nextInt(10000));
            User newUser = new User(uid, name, friendId, profileImageBase64, true);

            mUsersRef.child(uid).setValue(newUser).addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    currentUser = newUser;
                    onUserLoggedIn();
                } else {
                    Toast.makeText(MainActivity.this, "Profile creation failed.", Toast.LENGTH_SHORT).show();
                }
            });
        });
        builder.show();
    }

    private void onUserLoggedIn() {
        Toast.makeText(this, "Welcome, " + currentUser.getName(), Toast.LENGTH_SHORT).show();
        switchView(mainView);
        startBackgroundService();
        setupOnlineStatus();
        listenForIncomingCalls();
        listenForFriendRequests();
        loadMainListData();
    }
    
    private void cleanupAfterLogout() {
        stopBackgroundService();
        if (currentUser != null && mUsersRef != null) {
            mUsersRef.child(currentUser.getUid()).child("online").setValue(false);
        }
        if (incomingCallListener != null && mCallsRef != null && currentUser != null) {
            mCallsRef.child(currentUser.getUid()).removeEventListener(incomingCallListener);
        }
        if (friendRequestListener != null && mFriendRequestsRef != null && currentUser != null) {
            mFriendRequestsRef.child(currentUser.getUid()).removeEventListener(friendRequestListener);
        }
        
        currentUser = null;
        if(mainAdapter != null) mainAdapter.clearData();
        if(chatAdapter != null) chatAdapter.clearData();
        
        BadgeDrawable badge = bottomNavigationView.getOrCreateBadge(R.id.navigation_updates);
        badge.setVisible(false);
    }
    
    private void handleLogin() {
        String email = ((EditText) findViewById(R.id.email_input)).getText().toString();
        String password = ((EditText) findViewById(R.id.password_input)).getText().toString();

        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Fields cannot be empty", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, task -> {
                    if (!task.isSuccessful()) {
                        Toast.makeText(MainActivity.this, "Authentication failed.", Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void handleSignup() {
        String email = ((EditText) findViewById(R.id.email_input)).getText().toString();
        String password = ((EditText) findViewById(R.id.password_input)).getText().toString();

        if (email.isEmpty() || password.isEmpty() || password.length() < 6) {
            Toast.makeText(this, "Enter valid email and password (min 6 chars)", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, task -> {
                    if (task.isSuccessful()) {
                        String uid = mAuth.getCurrentUser().getUid();
                        showProfileSetupDialog(uid);
                    } else {
                        if (task.getException() instanceof FirebaseAuthUserCollisionException) {
                            Toast.makeText(MainActivity.this, "Email is already registered.", Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(MainActivity.this, "Sign up failed.", Toast.LENGTH_SHORT).show();
                            Log.e(TAG, "Signup failed", task.getException());
                        }
                    }
                });
    }

    private void setupOnlineStatus() {
        if (currentUser == null) return;
        DatabaseReference onlineRef = mUsersRef.child(currentUser.getUid()).child("online");
        DatabaseReference lastSeenRef = mUsersRef.child(currentUser.getUid()).child("lastSeen");
        
        onlineRef.setValue(true);
        onlineRef.onDisconnect().setValue(false);
        lastSeenRef.onDisconnect().setValue(System.currentTimeMillis());
    }
    
    private void startBackgroundService() {
        Intent serviceIntent = new Intent(this, BackgroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }
    }

    private void stopBackgroundService() {
        Intent serviceIntent = new Intent(this, BackgroundService.class);
        stopService(serviceIntent);
    }

    private void switchView(View viewToShow) {
        authView.setVisibility(View.GONE);
        mainView.setVisibility(View.GONE);
        chatView.setVisibility(View.GONE);
        callView.setVisibility(View.GONE);
        viewToShow.setVisibility(View.VISIBLE);
    }
    
    @Override
    public void onBackPressed() {
        if (callView.getVisibility() == View.VISIBLE) {
            endCall();
        } else if (chatView.getVisibility() == View.VISIBLE) {
            closeChat();
        } else if (mainView.getVisibility() == View.VISIBLE) {
             super.onBackPressed();
        } else {
            super.onBackPressed();
        }
    }
    
    // =====================================================================================
    // Main Screen Logic (Friends, Updates, Calls)
    // =====================================================================================

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.menu_profile) {
            showProfileDialog();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
    
    private void showProfileDialog() {
        if (currentUser == null) return;
        String profileInfo = "Name: " + currentUser.getName() + "\n"
                           + "Friend ID: " + currentUser.getFriendId() + "\n"
                           + "UID: " + currentUser.getUid();

        new MaterialAlertDialogBuilder(this)
                .setTitle("Your Profile")
                .setMessage(profileInfo)
                .setPositiveButton("OK", null)
                .setNeutralButton("Logout", (dialog, which) -> {
                    mAuth.signOut();
                })
                .show();
    }
    
    private void showAddFriendDialog() {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        TextView title = dialogView.findViewById(R.id.dialog_title);
        EditText input = dialogView.findViewById(R.id.dialog_input);
        title.setText("Add Friend by ID");
        input.setHint("Enter 4-digit Friend ID");

        new MaterialAlertDialogBuilder(this)
                .setView(dialogView)
                .setPositiveButton("Send Request", (dialog, which) -> {
                    String friendId = input.getText().toString().trim();
                    if (!friendId.isEmpty()) {
                        sendFriendRequest(friendId);
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void sendFriendRequest(String friendId) {
        mUsersRef.orderByChild("friendId").equalTo(friendId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    for (DataSnapshot userSnapshot : snapshot.getChildren()) {
                        User targetUser = userSnapshot.getValue(User.class);
                        if (targetUser != null && !targetUser.getUid().equals(currentUser.getUid())) {
                            // Found user, send request
                            mFriendRequestsRef.child(targetUser.getUid()).child(currentUser.getUid())
                                .setValue(new ChatContact(currentUser.getName(), currentUser.getAvatar(), "pending"))
                                .addOnSuccessListener(aVoid -> Toast.makeText(MainActivity.this, "Friend request sent!", Toast.LENGTH_SHORT).show())
                                .addOnFailureListener(e -> Toast.makeText(MainActivity.this, "Failed to send request.", Toast.LENGTH_SHORT).show());
                            return;
                        }
                    }
                }
                Toast.makeText(MainActivity.this, "User not found.", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(MainActivity.this, "Database error.", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void listenForFriendRequests() {
        if (currentUser == null) return;
        if (friendRequestListener != null) {
            mFriendRequestsRef.child(currentUser.getUid()).removeEventListener(friendRequestListener);
        }
        friendRequestListener = mFriendRequestsRef.child(currentUser.getUid()).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<ChatContact> requests = new ArrayList<>();
                boolean hasPendingRequests = false;
                for (DataSnapshot requestSnapshot : snapshot.getChildren()) {
                    ChatContact contact = requestSnapshot.getValue(ChatContact.class);
                    if (contact != null) {
                        contact.setUid(requestSnapshot.getKey());
                        requests.add(contact);
                        hasPendingRequests = true;
                    }
                }
                mainAdapter.setUpdatesData(requests);
                updateUpdatesBadge(hasPendingRequests);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {}
        });
    }

    private void updateUpdatesBadge(boolean visible) {
        BadgeDrawable badge = bottomNavigationView.getOrCreateBadge(R.id.navigation_updates);
        badge.setVisible(visible);
    }
    
    public void acceptFriendRequest(ChatContact request) {
        if (currentUser == null) return;
        String friendUid = request.getUid();
        
        // Add to each other's friend lists
        Map<String, Object> friendUpdates = new HashMap<>();
        friendUpdates.put("/friendships/" + currentUser.getUid() + "/" + friendUid, true);
        friendUpdates.put("/friendships/" + friendUid + "/" + currentUser.getUid(), true);
        
        FirebaseDatabase.getInstance().getReference().updateChildren(friendUpdates)
                .addOnSuccessListener(aVoid -> {
                    // Remove the request
                    mFriendRequestsRef.child(currentUser.getUid()).child(friendUid).removeValue();
                    Toast.makeText(this, "You are now friends with " + request.getName(), Toast.LENGTH_SHORT).show();
                });
    }

    public void rejectFriendRequest(ChatContact request) {
        if (currentUser == null) return;
        mFriendRequestsRef.child(currentUser.getUid()).child(request.getUid()).removeValue();
    }
    
    private void loadMainListData() {
        if (currentUser == null) return;

        // Load Chats
        mFriendshipsRef.child(currentUser.getUid()).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<String> friendUids = new ArrayList<>();
                for (DataSnapshot friendSnapshot : snapshot.getChildren()) {
                    friendUids.add(friendSnapshot.getKey());
                }
                fetchFriendDetails(friendUids);
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {}
        });
        
        // Load Call History
        DatabaseReference callHistoryRef = FirebaseDatabase.getInstance().getReference("call_history").child(currentUser.getUid());
        callHistoryRef.orderByChild("timestamp").limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<CallHistory> calls = new ArrayList<>();
                for (DataSnapshot callSnapshot : snapshot.getChildren()) {
                    CallHistory call = callSnapshot.getValue(CallHistory.class);
                    if (call != null) {
                        calls.add(call);
                    }
                }
                Collections.reverse(calls); // Show newest first
                mainAdapter.setCallsData(calls);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {}
        });
    }

    private void fetchFriendDetails(List<String> uids) {
        List<ChatContact> contacts = new ArrayList<>();
        if (uids.isEmpty()) {
            mainAdapter.setChatsData(contacts);
            return;
        }
        
        for (String uid : uids) {
            mUsersRef.child(uid).addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    User friend = snapshot.getValue(User.class);
                    if (friend != null) {
                        friend.setUid(uid);
                        // Check if contact already exists and update, or add new
                        boolean updated = false;
                        for(int i=0; i<contacts.size(); i++) {
                            if(contacts.get(i).getUid().equals(uid)) {
                                contacts.set(i, new ChatContact(friend.getName(), friend.getAvatar(), friend.getUid(), friend.isOnline()));
                                updated = true;
                                break;
                            }
                        }
                        if(!updated) {
                            contacts.add(new ChatContact(friend.getName(), friend.getAvatar(), friend.getUid(), friend.isOnline()));
                        }
                        mainAdapter.setChatsData(new ArrayList<>(contacts));
                    }
                }
                @Override
                public void onCancelled(@NonNull DatabaseError error) {}
            });
        }
    }


    // =====================================================================================
    // Chat Screen Logic
    // =====================================================================================

    public void openChat(User partner) {
        this.chatPartner = partner;
        this.currentChatId = getChatId(currentUser.getUid(), partner.getUid());
        
        chatAdapter = new ChatAdapter(this, currentUser.getUid());
        chatRecyclerView.setAdapter(chatAdapter);
        
        setupChatToolbar();
        loadMessages();
        listenForTypingStatus();
        switchView(chatView);
    }
    
    private void closeChat() {
        if(chatAdapter != null) chatAdapter.cleanup();
        if(mTypingRef != null && currentChatId != null && currentUser != null) {
            mTypingRef.child(currentChatId).child(currentUser.getUid()).removeValue();
        }
        this.chatPartner = null;
        this.currentChatId = null;
        switchView(mainView);
    }

    private void setupChatToolbar() {
        chatToolbar.setNavigationIcon(androidx.appcompat.R.drawable.abc_ic_ab_back_material);
        chatToolbar.setNavigationOnClickListener(v -> closeChat());
        chatToolbar.setTitle(""); // Clear default title to use custom layout
        chatToolbar.getMenu().clear();
        chatToolbar.inflateMenu(R.menu.chat_menu);

        // Find or inflate custom views
        View customView = chatToolbar.findViewById(R.id.chat_toolbar_custom_view);
        if (customView == null) {
            customView = LayoutInflater.from(this).inflate(R.layout.chat_toolbar_layout, chatToolbar, false);
            chatToolbar.addView(customView);
        }
        
        chatPartnerName = customView.findViewById(R.id.toolbar_title);
        TextView chatPartnerStatus = customView.findViewById(R.id.toolbar_subtitle);
        chatPartnerAvatar = customView.findViewById(R.id.toolbar_avatar);

        chatPartnerName.setText(chatPartner.getName());
        loadAvatar(chatPartner.getAvatar(), chatPartnerAvatar);
        
        mUsersRef.child(chatPartner.getUid()).child("online").addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                Boolean isOnline = snapshot.getValue(Boolean.class);
                if (Boolean.TRUE.equals(isOnline)) {
                    chatPartnerStatus.setText("online");
                } else {
                    listenForTypingStatus();
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });

        chatToolbar.setOnMenuItemClickListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.menu_voice_call) {
                initiateCall(chatPartner, "voice");
                return true;
            } else if (itemId == R.id.menu_video_call) {
                initiateCall(chatPartner, "video");
                return true;
            } else if (itemId == R.id.menu_block_user) {
                blockUser(chatPartner.getUid());
                return true;
            }
            return false;
        });
    }

    private void blockUser(String uidToBlock) {
        if (currentUser == null) return;
        mUsersRef.child(currentUser.getUid()).child("blocked_users").child(uidToBlock).setValue(true)
            .addOnSuccessListener(aVoid -> {
                Toast.makeText(this, chatPartner.getName() + " has been blocked.", Toast.LENGTH_SHORT).show();
                closeChat();
            });
    }
    
    private void listenForTypingStatus() {
         TextView chatPartnerStatus = chatToolbar.findViewById(R.id.toolbar_subtitle);
         if (chatPartnerStatus == null) return;
         
         mTypingRef.child(currentChatId).child(chatPartner.getUid()).addValueEventListener(new ValueEventListener() {
             @Override
             public void onDataChange(@NonNull DataSnapshot snapshot) {
                 Boolean isTyping = snapshot.getValue(Boolean.class);
                 if (Boolean.TRUE.equals(isTyping)) {
                     chatPartnerStatus.setText("typing...");
                 } else {
                     chatPartnerStatus.setText(""); // Or logic to show "last seen"
                 }
             }
             @Override public void onCancelled(@NonNull DatabaseError error) {}
         });
    }

    private String getChatId(String uid1, String uid2) {
        return uid1.compareTo(uid2) > 0 ? uid1 + "_" + uid2 : uid2 + "_" + uid1;
    }

    private void loadMessages() {
        mChatsRef.child(currentChatId).child("messages").limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Message> messages = new ArrayList<>();
                for (DataSnapshot msgSnapshot : snapshot.getChildren()) {
                    Message msg = msgSnapshot.getValue(Message.class);
                    if (msg != null) {
                        msg.setMessageId(msgSnapshot.getKey());
                        messages.add(msg);
                    }
                }
                chatAdapter.setMessages(messages);
                chatRecyclerView.scrollToPosition(chatAdapter.getItemCount() - 1);
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {}
        });
    }

    private void sendMessage() {
        String text = messageInput.getText().toString().trim();
        if (text.isEmpty()) return;

        String messageId = mChatsRef.child(currentChatId).child("messages").push().getKey();
        Message message = new Message(messageId, text, currentUser.getUid(), System.currentTimeMillis());

        if (messageToReplyTo != null) {
            message.setReplyToMessageId(messageToReplyTo.getMessageId());
            message.setReplyToMessageText(messageToReplyTo.getText());
            message.setReplyToSenderName(messageToReplyTo.getSenderId().equals(currentUser.getUid()) ? "You" : chatPartner.getName());
        }

        if (messageId != null) {
            mChatsRef.child(currentChatId).child("messages").child(messageId).setValue(message);
        }

        messageInput.setText("");
        clearReply();
    }
    
    private void setupMessageInputListener() {
        messageInput.addTextChangedListener(new TextWatcher() {
            private final Runnable typingEndedRunnable = () -> {
                if(currentChatId != null && currentUser != null) {
                   mTypingRef.child(currentChatId).child(currentUser.getUid()).setValue(false);
                }
            };
            
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(currentChatId != null && currentUser != null) {
                    typingHandler.removeCallbacks(typingEndedRunnable);
                    mTypingRef.child(currentChatId).child(currentUser.getUid()).setValue(true);
                }
            }
            
            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() > 0) {
                    typingHandler.postDelayed(typingEndedRunnable, 2000); // 2 seconds
                } else {
                     typingHandler.removeCallbacks(typingEndedRunnable);
                     if(currentChatId != null && currentUser != null) {
                        mTypingRef.child(currentChatId).child(currentUser.getUid()).setValue(false);
                     }
                }
            }
        });
    }
    
    public void showMessageOptions(View anchor, Message message) {
        PopupMenu popup = new PopupMenu(this, anchor, Gravity.END);
        popup.getMenuInflater().inflate(R.menu.message_menu, popup.getMenu());
        
        // Only show "Delete for Everyone" for own messages within a time limit (e.g., 1 hour)
        if (!message.getSenderId().equals(currentUser.getUid()) || (System.currentTimeMillis() - message.getTimestamp() > 3600 * 1000)) {
            popup.getMenu().findItem(R.id.menu_delete_everyone).setVisible(false);
        }

        popup.setOnMenuItemClickListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.menu_react) {
                showReactionPicker(anchor, message);
                return true;
            } else if (itemId == R.id.menu_reply) {
                setupReply(message);
                return true;
            } else if (itemId == R.id.menu_delete_everyone) {
                deleteMessageForEveryone(message);
                return true;
            }
            return false;
        });
        popup.show();
    }
    
    private void showReactionPicker(View anchor, Message message) {
        // A simple dialog for reactions
        String[] reactions = {"👍", "❤️", "😂", "😮", "😢", "🙏"};
        new AlertDialog.Builder(this)
            .setTitle("React")
            .setItems(reactions, (dialog, which) -> {
                String reaction = reactions[which];
                reactToMessage(message, reaction);
            })
            .show();
    }

    private void reactToMessage(Message message, String reaction) {
        if(currentChatId == null || currentUser == null) return;
        mChatsRef.child(currentChatId).child("messages").child(message.getMessageId())
            .child("reactions").child(currentUser.getUid()).setValue(reaction);
    }

    private void deleteMessageForEveryone(Message message) {
        if(currentChatId == null) return;
        Map<String, Object> updates = new HashMap<>();
        updates.put("text", "This message was deleted");
        updates.put("deleted", true);
        mChatsRef.child(currentChatId).child("messages").child(message.getMessageId()).updateChildren(updates);
    }
    
    private void setupSwipeToReply() {
        ItemTouchHelper.SimpleCallback simpleCallback = new ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.RIGHT) {
            @Override
            public boolean onMove(@NonNull RecyclerView recyclerView, @NonNull RecyclerView.ViewHolder viewHolder, @NonNull RecyclerView.ViewHolder target) {
                return false;
            }
            @Override
            public void onSwiped(@NonNull RecyclerView.ViewHolder viewHolder, int direction) {
                int position = viewHolder.getAdapterPosition();
                Message message = chatAdapter.getMessageAt(position);
                setupReply(message);
                chatAdapter.notifyItemChanged(position); // Reset swipe
            }
        };
        new ItemTouchHelper(simpleCallback).attachToRecyclerView(chatRecyclerView);
    }

    private void setupReply(Message message) {
        messageToReplyTo = message;
        replyLayout.setVisibility(View.VISIBLE);
        replyingToName.setText(message.getSenderId().equals(currentUser.getUid()) ? "You" : chatPartner.getName());
        replyingToText.setText(message.getText());
        messageInput.requestFocus();
    }
    
    private void clearReply() {
        messageToReplyTo = null;
        replyLayout.setVisibility(View.GONE);
    }

    // =====================================================================================
    // Call Logic (WebRTC)
    // =====================================================================================
    
    private void listenForIncomingCalls() {
        if (currentUser == null) return;
        
        if(incomingCallListener != null) {
            mCallsRef.child(currentUser.getUid()).removeEventListener(incomingCallListener);
        }

        incomingCallListener = mCallsRef.child(currentUser.getUid()).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    currentCallId = snapshot.getKey();
                    String callerId = snapshot.child("callerId").getValue(String.class);
                    String callType = snapshot.child("type").getValue(String.class);
                    
                    if ("offer".equals(callType) && callerId != null) {
                        isCallInitiator = false;
                        
                        // Check if caller is blocked
                        mUsersRef.child(currentUser.getUid()).child("blocked_users").child(callerId).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot blockedSnapshot) {
                                if (blockedSnapshot.exists()) {
                                    // Caller is blocked, ignore the call and remove the node.
                                    Log.d(TAG, "Incoming call from blocked user " + callerId + ". Ignoring.");
                                    mCallsRef.child(currentUser.getUid()).removeValue();
                                } else {
                                    // Not blocked, proceed with call
                                    String callerNameStr = snapshot.child("callerName").getValue(String.class);
                                    handleIncomingCall(callerNameStr, callerId);
                                }
                            }
                            @Override
                            public void onCancelled(@NonNull DatabaseError error) {}
                        });
                    }
                }
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {}
        });
    }

    private void handleIncomingCall(String name, String callerId) {
        if(callView.getVisibility() == View.VISIBLE) return; // Already in a call
        
        // Show call UI
        callerName.setText(name);
        callStatus.setText("Incoming Call...");
        acceptCallButton.setVisibility(View.VISIBLE);
        switchView(callView);
        
        // Start ringing
        playRingtone();
    }
    
    private void playRingtone() {
        try {
            Uri ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
            ringtone = RingtoneManager.getRingtone(getApplicationContext(), ringtoneUri);
            ringtone.play();
        } catch (Exception e) {
            Log.e(TAG, "Could not play ringtone", e);
        }
    }
    
    private void stopRingtone() {
        if (ringtone != null && ringtone.isPlaying()) {
            ringtone.stop();
        }
        if(toneGenerator != null) {
            toneGenerator.stopTone();
            toneGenerator.release();
            toneGenerator = null;
        }
    }
    
    private void setAudioManagerMode(boolean inCommunication) {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        if (inCommunication) {
            audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            audioManager.setSpeakerphoneOn(true); 
        } else {
            audioManager.setMode(AudioManager.MODE_NORMAL);
            audioManager.setSpeakerphoneOn(false);
        }
    }

    private void initiateCall(User partner, String callType) {
        // Check if we are blocked by the partner
        mUsersRef.child(partner.getUid()).child("blocked_users").child(currentUser.getUid()).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    Toast.makeText(MainActivity.this, "You cannot call this user.", Toast.LENGTH_SHORT).show();
                } else {
                    startCallFlow(partner, callType);
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(MainActivity.this, "Error checking permissions.", Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void startCallFlow(User partner, String callType) {
        isCallInitiator = true;
        currentCallId = partner.getUid();

        callerName.setText(partner.getName());
        callStatus.setText("Calling...");
        acceptCallButton.setVisibility(View.GONE);
        switchView(callView);
        
        // Play outgoing call tone
        toneGenerator = new ToneGenerator(AudioManager.STREAM_VOICE_CALL, 100);
        toneGenerator.startTone(ToneGenerator.TONE_CDMA_NETWORK_USA_RINGBACK, 20000);

        executor.execute(() -> {
            setAudioManagerMode(true);
            createPeerConnection();
            createMediaTracks(callType.equals("video"));

            MediaConstraints constraints = new MediaConstraints();
            constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
            constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));

            peerConnection.createOffer(new SimpleSdpObserver() {
                @Override
                public void onCreateSuccess(SessionDescription sdp) {
                    peerConnection.setLocalDescription(new SimpleSdpObserver(), sdp);
                    
                    HashMap<String, Object> callData = new HashMap<>();
                    callData.put("callerId", currentUser.getUid());
                    callData.put("callerName", currentUser.getName());
                    callData.put("callerAvatar", currentUser.getAvatar());
                    callData.put("type", "offer");
                    callData.put("sdp", sdp.description);
                    callData.put("accepted", false);
                    
                    mCallsRef.child(currentCallId).setValue(callData)
                        .addOnSuccessListener(aVoid -> listenForAnswer());
                }
            }, constraints);
        });
    }

    private void acceptCall() {
        stopRingtone();
        callStatus.setText("Connecting...");
        acceptCallButton.setVisibility(View.GONE);

        executor.execute(() -> {
            setAudioManagerMode(true);
            createPeerConnection();
            
            mCallsRef.child(currentUser.getUid()).addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    String sdpString = snapshot.child("sdp").getValue(String.class);
                    SessionDescription remoteSdp = new SessionDescription(SessionDescription.Type.OFFER, sdpString);
                    peerConnection.setRemoteDescription(new SimpleSdpObserver(), remoteSdp);
                    
                    boolean isVideoCall = remoteSdp.description.contains("m=video");
                    createMediaTracks(isVideoCall);

                    MediaConstraints constraints = new MediaConstraints();
                    constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
                    constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
                    
                    peerConnection.createAnswer(new SimpleSdpObserver() {
                        @Override
                        public void onCreateSuccess(SessionDescription sdp) {
                            peerConnection.setLocalDescription(new SimpleSdpObserver(), sdp);
                            
                            HashMap<String, Object> answerData = new HashMap<>();
                            answerData.put("type", "answer");
                            answerData.put("sdp", sdp.description);
                            
                            mCallsRef.child(currentUser.getUid()).updateChildren(answerData);
                            mCallsRef.child(currentUser.getUid()).child("accepted").setValue(true);
                        }
                    }, constraints);
                }
                @Override public void onCancelled(@NonNull DatabaseError error) {}
            });
        });
    }

    private void listenForAnswer() {
        mCallsRef.child(currentCallId).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.child("type").getValue(String.class).equals("answer")) {
                    stopRingtone();
                    String sdp = snapshot.child("sdp").getValue(String.class);
                    SessionDescription remoteSdp = new SessionDescription(SessionDescription.Type.ANSWER, sdp);
                    peerConnection.setRemoteDescription(new SimpleSdpObserver(), remoteSdp);
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
    }
    
    private void createPeerConnection() {
        PeerConnection.RTCConfiguration rtcConfig = new PeerConnection.RTCConfiguration(iceServers);
        peerConnection = peerConnectionFactory.createPeerConnection(rtcConfig, new PeerConnection.Observer() {
            @Override
            public void onSignalingChange(PeerConnection.SignalingState signalingState) {
                Log.d(TAG, "onSignalingChange: " + signalingState);
            }

            @Override
            public void onIceConnectionChange(PeerConnection.IceConnectionState iceConnectionState) {
                Log.d(TAG, "onIceConnectionChange: " + iceConnectionState);
                mainHandler.post(() -> {
                    if(iceConnectionState == PeerConnection.IceConnectionState.CONNECTED) {
                        callStatus.setText("");
                        callStartTime = System.currentTimeMillis();
                    }
                    if(iceConnectionState == PeerConnection.IceConnectionState.DISCONNECTED || iceConnectionState == PeerConnection.IceConnectionState.FAILED) {
                        endCall();
                    }
                });
            }
            
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState iceGatheringState) {}

            @Override
            public void onIceCandidate(IceCandidate iceCandidate) {
                String candidatePath = isCallInitiator ? "caller" : "receiver";
                mCallsRef.child(currentCallId).child("candidates").child(candidatePath).push().setValue(iceCandidate);
            }
            
            @Override public void onIceCandidatesRemoved(IceCandidate[] iceCandidates) {}

            @Override
            public void onAddStream(MediaStream mediaStream) {
                 Log.d(TAG, "onAddStream called");
                 if (mediaStream.videoTracks.size() > 0) {
                     VideoTrack remoteVideoTrack = mediaStream.videoTracks.get(0);
                     mainHandler.post(() -> {
                         remoteVideoTrack.addSink(remoteVideoView);
                     });
                 }
            }
            
            @Override public void onRemoveStream(MediaStream mediaStream) {}
            @Override public void onDataChannel(org.webrtc.DataChannel dataChannel) {}
            @Override public void onRenegotiationNeeded() {}
        });
        
        listenForIceCandidates();
    }
    
    private void listenForIceCandidates() {
        String remoteCandidatePath = isCallInitiator ? "receiver" : "caller";
        mCallsRef.child(currentCallId).child("candidates").child(remoteCandidatePath).addChildEventListener(new SimpleChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                IceCandidate candidate = snapshot.getValue(IceCandidate.class);
                if (peerConnection != null && peerConnection.getRemoteDescription() != null) {
                    peerConnection.addIceCandidate(candidate);
                }
            }
        });
    }

    private void createMediaTracks(boolean videoEnabled) {
        // Audio
        AudioSource audioSource = peerConnectionFactory.createAudioSource(new MediaConstraints());
        localAudioTrack = peerConnectionFactory.createAudioTrack("ARDAMSa0", audioSource);
        peerConnection.addTrack(localAudioTrack);

        if (videoEnabled) {
            // Video
            surfaceTextureHelper = SurfaceTextureHelper.create("VideoCapturerThread", eglBase.getEglBaseContext());
            videoCapturer = createVideoCapturer();
            VideoSource videoSource = peerConnectionFactory.createVideoSource(videoCapturer.isScreencast());
            videoCapturer.initialize(surfaceTextureHelper, this, videoSource.getCapturerObserver());
            videoCapturer.startCapture(480, 640, 30);
            
            localVideoTrack = peerConnectionFactory.createVideoTrack("ARDAMSv0", videoSource);
            localVideoTrack.addSink(localVideoView);
            peerConnection.addTrack(localVideoTrack);
        }
    }
    
    private VideoCapturer createVideoCapturer() {
        CameraEnumerator enumerator = new Camera2Enumerator(this);
        String[] deviceNames = enumerator.getDeviceNames();
        // Try to find front-facing camera
        for (String deviceName : deviceNames) {
            if (enumerator.isFrontFacing(deviceName)) {
                return enumerator.createCapturer(deviceName, null);
            }
        }
        // Fallback to any camera
        for (String deviceName : deviceNames) {
            return enumerator.createCapturer(deviceName, null);
        }
        return null;
    }

    private void endCall() {
        stopRingtone();
        setAudioManagerMode(false);

        // Save call history
        if (callStartTime > 0) {
            long duration = (System.currentTimeMillis() - callStartTime) / 1000;
            String partnerId = isCallInitiator ? chatPartner.getUid() : null; // Need to fetch caller details if receiver
            String partnerName = callerName.getText().toString();
            String type = isCallInitiator ? "outgoing" : "incoming";
            
            // This is simplified, a real app would fetch the partner details more robustly
            if(currentUser != null && partnerId != null) {
                CallHistory call = new CallHistory(partnerName, null, duration, System.currentTimeMillis(), type, "video");
                FirebaseDatabase.getInstance().getReference("call_history").child(currentUser.getUid()).push().setValue(call);
            }
        }

        executor.execute(() -> {
            if (peerConnection != null) {
                peerConnection.close();
                peerConnection = null;
            }
            if (localVideoTrack != null) {
                localVideoTrack.removeSink(localVideoView);
                localVideoTrack.dispose();
                localVideoTrack = null;
            }
            if (videoCapturer != null) {
                try {
                    videoCapturer.stopCapture();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                videoCapturer.dispose();
                videoCapturer = null;
            }
            if(surfaceTextureHelper != null) {
                surfaceTextureHelper.dispose();
                surfaceTextureHelper = null;
            }
            if (localAudioTrack != null) {
                localAudioTrack.dispose();
                localAudioTrack = null;
            }
            
             mainHandler.post(() -> {
                localVideoView.release();
                remoteVideoView.release();
                switchView(mainView);
             });
        });
        
        if (currentCallId != null) {
            mCallsRef.child(currentCallId).removeValue();
            currentCallId = null;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        isAppInForeground = true;
        if (currentUser != null) {
            mUsersRef.child(currentUser.getUid()).child("online").setValue(true);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isAppInForeground = false;
        if (currentUser != null) {
            mUsersRef.child(currentUser.getUid()).child("online").setValue(false);
            mUsersRef.child(currentUser.getUid()).child("lastSeen").setValue(System.currentTimeMillis());
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        isAppInForeground = false;
        endCall(); // Clean up any active call
        executor.execute(() -> {
             if (peerConnectionFactory != null) {
                peerConnectionFactory.dispose();
                peerConnectionFactory = null;
             }
             if (eglBase != null) {
                eglBase.release();
                eglBase = null;
             }
        });
        executor.shutdown();
        cleanupAfterLogout();
    }
    
    // =====================================================================================
    // Utility Methods
    // =====================================================================================

    public void loadAvatar(String base64, ImageView imageView) {
        if(base64 == null || base64.isEmpty()) {
            imageView.setImageResource(R.drawable.emoji_bg);
            return;
        }
        try {
            byte[] decodedString = Base64.decode(base64, Base64.DEFAULT);
            Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
            Glide.with(this).load(decodedByte).apply(RequestOptions.circleCropTransform()).into(imageView);
        } catch (Exception e) {
            Log.e(TAG, "Failed to decode Base64 image", e);
            imageView.setImageResource(R.drawable.emoji_bg);
        }
    }

    private String bitmapToBase64(Bitmap bitmap) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        return Base64.encodeToString(byteArray, Base64.DEFAULT);
    }

    private Bitmap scaleBitmap(Bitmap original, int maxSize) {
        int width = original.getWidth();
        int height = original.getHeight();
        float bitmapRatio = (float) width / (float) height;
        if (bitmapRatio > 1) {
            width = maxSize;
            height = (int) (width / bitmapRatio);
        } else {
            height = maxSize;
            width = (int) (height * bitmapRatio);
        }
        return Bitmap.createScaledBitmap(original, width, height, true);
    }
}


// Adapter classes and helper classes should be defined here or in separate files
// For a single script, they are defined as inner or sibling classes

class MainAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    
    public enum Mode { CHATS, UPDATES, CALLS }
    
    private final MainActivity context;
    private Mode currentMode = Mode.CHATS;
    private List<ChatContact> chatsData = new ArrayList<>();
    private List<ChatContact> updatesData = new ArrayList<>();
    private List<CallHistory> callsData = new ArrayList<>();

    private static final int VIEW_TYPE_CHAT = 1;
    private static final int VIEW_TYPE_UPDATE = 2;
    private static final int VIEW_TYPE_CALL = 3;

    public MainAdapter(MainActivity context) {
        this.context = context;
    }
    
    public void setMode(Mode mode) {
        this.currentMode = mode;
        notifyDataSetChanged();
    }
    
    public void setChatsData(List<ChatContact> data) {
        this.chatsData = data;
        if(currentMode == Mode.CHATS) notifyDataSetChanged();
    }
    
    public void setUpdatesData(List<ChatContact> data) {
        this.updatesData = data;
        if(currentMode == Mode.UPDATES) notifyDataSetChanged();
    }
    
    public void setCallsData(List<CallHistory> data) {
        this.callsData = data;
        if(currentMode == Mode.CALLS) notifyDataSetChanged();
    }

    public void clearData() {
        chatsData.clear();
        updatesData.clear();
        callsData.clear();
        notifyDataSetChanged();
    }

    @Override
    public int getItemViewType(int position) {
        switch (currentMode) {
            case UPDATES: return VIEW_TYPE_UPDATE;
            case CALLS: return VIEW_TYPE_CALL;
            case CHATS:
            default: return VIEW_TYPE_CHAT;
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(context);
        switch (viewType) {
            case VIEW_TYPE_UPDATE:
                return new UpdateViewHolder(inflater.inflate(R.layout.item_list_update, parent, false));
            case VIEW_TYPE_CALL:
                return new CallViewHolder(inflater.inflate(R.layout.item_list_call, parent, false));
            case VIEW_TYPE_CHAT:
            default:
                return new ChatContactViewHolder(inflater.inflate(R.layout.item_list_contact, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        switch (holder.getItemViewType()) {
            case VIEW_TYPE_CHAT:
                ((ChatContactViewHolder) holder).bind(chatsData.get(position));
                break;
            case VIEW_TYPE_UPDATE:
                ((UpdateViewHolder) holder).bind(updatesData.get(position));
                break;
            case VIEW_TYPE_CALL:
                ((CallViewHolder) holder).bind(callsData.get(position));
                break;
        }
    }

    @Override
    public int getItemCount() {
        switch (currentMode) {
            case CHATS: return chatsData.size();
            case UPDATES: return updatesData.size();
            case CALLS: return callsData.size();
            default: return 0;
        }
    }
    
    class ChatContactViewHolder extends RecyclerView.ViewHolder {
        ImageView avatar, onlineIndicator;
        TextView name, lastMessage, timestamp, unreadBadge;
        ChatContactViewHolder(@NonNull View itemView) {
            super(itemView);
            avatar = itemView.findViewById(R.id.item_avatar);
            onlineIndicator = itemView.findViewById(R.id.online_indicator);
            name = itemView.findViewById(R.id.item_name);
            lastMessage = itemView.findViewById(R.id.item_last_message);
            timestamp = itemView.findViewById(R.id.item_timestamp);
            unreadBadge = itemView.findViewById(R.id.item_unread_badge);
        }
        
        void bind(ChatContact contact) {
            name.setText(contact.getName());
            context.loadAvatar(contact.getAvatar(), avatar);
            onlineIndicator.setVisibility(contact.isOnline() ? View.VISIBLE : View.GONE);
            // lastMessage, timestamp, unreadBadge would be populated by listeners
            lastMessage.setText("Tap to chat...");

            itemView.setOnClickListener(v -> {
                User partner = new User(contact.getUid(), contact.getName(), null, contact.getAvatar(), contact.isOnline());
                context.openChat(partner);
            });
        }
    }
    
    class UpdateViewHolder extends RecyclerView.ViewHolder {
        ImageView avatar;
        TextView message;
        Button acceptButton, rejectButton;
        UpdateViewHolder(@NonNull View itemView) {
            super(itemView);
            avatar = itemView.findViewById(R.id.item_avatar);
            message = itemView.findViewById(R.id.item_message);
            acceptButton = itemView.findViewById(R.id.accept_button);
            rejectButton = itemView.findViewById(R.id.reject_button);
        }
        
        void bind(ChatContact request) {
            message.setText("Friend request from " + request.getName());
            context.loadAvatar(request.getAvatar(), avatar);
            acceptButton.setOnClickListener(v -> context.acceptFriendRequest(request));
            rejectButton.setOnClickListener(v -> context.rejectFriendRequest(request));
        }
    }
    
    class CallViewHolder extends RecyclerView.ViewHolder {
        ImageView avatar, callDirectionIcon, callTypeIcon;
        TextView name, timestamp;
        CallViewHolder(@NonNull View itemView) {
            super(itemView);
            avatar = itemView.findViewById(R.id.item_avatar);
            callDirectionIcon = itemView.findViewById(R.id.item_call_direction_icon);
            callTypeIcon = itemView.findViewById(R.id.item_call_type_icon);
            name = itemView.findViewById(R.id.item_name);
            timestamp = itemView.findViewById(R.id.item_timestamp);
        }
        
        void bind(CallHistory call) {
            name.setText(call.getPartnerName());
            context.loadAvatar(call.getPartnerAvatar(), avatar);
            
            SimpleDateFormat sdf = new SimpleDateFormat("MMM d, h:mm a", Locale.getDefault());
            timestamp.setText(sdf.format(new Date(call.getTimestamp())));
            
            if("incoming".equals(call.getType())) {
                callDirectionIcon.setImageResource(R.drawable.ic_call_received_24);
            } else {
                callDirectionIcon.setImageResource(R.drawable.ic_call_made_24);
            }
            
            if("video".equals(call.getCallMedium())) {
                ((ImageButton)callTypeIcon).setImageResource(R.drawable.ic_baseline_videocam_24);
            } else {
                ((ImageButton)callTypeIcon).setImageResource(R.drawable.ic_baseline_call_24);
            }
        }
    }
}

class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.MessageViewHolder> {
    private final MainActivity context;
    private final String currentUserId;
    private List<Message> messages = new ArrayList<>();
    private static final int VIEW_TYPE_OUTGOING = 1;
    private static final int VIEW_TYPE_INCOMING = 2;

    public ChatAdapter(MainActivity context, String currentUserId) {
        this.context = context;
        this.currentUserId = currentUserId;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
        notifyDataSetChanged();
    }
    
    public Message getMessageAt(int position) {
        return messages.get(position);
    }
    
    public void clearData() {
        messages.clear();
        notifyDataSetChanged();
    }
    
    public void cleanup() {
        messages.clear();
    }

    @Override
    public int getItemViewType(int position) {
        if (messages.get(position).getSenderId().equals(currentUserId)) {
            return VIEW_TYPE_OUTGOING;
        } else {
            return VIEW_TYPE_INCOMING;
        }
    }

    @NonNull
    @Override
    public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_message, parent, false);
        return new MessageViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {
        holder.bind(messages.get(position));
    }

    @Override
    public int getItemCount() {
        return messages.size();
    }

    class MessageViewHolder extends RecyclerView.ViewHolder {
        LinearLayout messageBubble;
        TextView messageText, messageTimestamp, reactionsText;
        LinearLayout replyPreviewLayout;
        TextView repliedToName, repliedToMessage;
        
        MessageViewHolder(@NonNull View itemView) {
            super(itemView);
            messageBubble = itemView.findViewById(R.id.message_bubble);
            messageText = itemView.findViewById(R.id.message_text);
            messageTimestamp = itemView.findViewById(R.id.message_timestamp);
            reactionsText = itemView.findViewById(R.id.reactions_text);
            replyPreviewLayout = itemView.findViewById(R.id.reply_preview_layout);
            repliedToName = itemView.findViewById(R.id.replied_to_name);
            repliedToMessage = itemView.findViewById(R.id.replied_to_message);
        }
        
        void bind(Message message) {
            messageText.setText(message.getText());
            SimpleDateFormat sdf = new SimpleDateFormat("h:mm a", Locale.getDefault());
            messageTimestamp.setText(sdf.format(new Date(message.getTimestamp())));

            ConstraintLayout.LayoutParams lp = (ConstraintLayout.LayoutParams) itemView.findViewById(R.id.message_card).getLayoutParams();
            
            if (getItemViewType() == VIEW_TYPE_OUTGOING) {
                messageBubble.setBackgroundResource(R.drawable.msg_out_bg);
                lp.horizontalBias = 1.0f;
                ((TextView)messageBubble.findViewById(R.id.message_text)).setTextColor(Color.WHITE);
                ((TextView)messageBubble.findViewById(R.id.message_timestamp)).setTextColor(Color.LTGRAY);
            } else {
                messageBubble.setBackgroundResource(R.drawable.msg_in_bg);
                lp.horizontalBias = 0.0f;
                ((TextView)messageBubble.findViewById(R.id.message_text)).setTextColor(Color.BLACK);
                ((TextView)messageBubble.findViewById(R.id.message_timestamp)).setTextColor(Color.GRAY);
            }
            itemView.findViewById(R.id.message_card).setLayoutParams(lp);

            // Handle reply view
            if (message.getReplyToMessageId() != null) {
                replyPreviewLayout.setVisibility(View.VISIBLE);
                repliedToName.setText(message.getReplyToSenderName());
                repliedToMessage.setText(message.getReplyToMessageText());
            } else {
                replyPreviewLayout.setVisibility(View.GONE);
            }

            // Handle reactions view
            if (message.getReactions() != null && !message.getReactions().isEmpty()) {
                reactionsText.setVisibility(View.VISIBLE);
                StringBuilder reactionsStr = new StringBuilder();
                Map<String, Integer> reactionCounts = new HashMap<>();
                for (String reaction : message.getReactions().values()) {
                    reactionCounts.put(reaction, reactionCounts.getOrDefault(reaction, 0) + 1);
                }
                for (Map.Entry<String, Integer> entry : reactionCounts.entrySet()) {
                    reactionsStr.append(entry.getKey()).append(" ").append(entry.getValue()).append(" ");
                }
                reactionsText.setText(reactionsStr.toString().trim());
            } else {
                reactionsText.setVisibility(View.GONE);
            }
            
            itemView.setOnLongClickListener(v -> {
                context.showMessageOptions(v, message);
                return true;
            });
        }
    }
}


// --- Helper classes for WebRTC Observers ---
class SimpleSdpObserver implements org.webrtc.SdpObserver {
    private static final String TAG = "SdpObserver";
    @Override public void onCreateSuccess(SessionDescription sessionDescription) { Log.d(TAG, "onCreateSuccess"); }
    @Override public void onSetSuccess() { Log.d(TAG, "onSetSuccess"); }
    @Override public void onCreateFailure(String s) { Log.e(TAG, "onCreateFailure: " + s); }
    @Override public void onSetFailure(String s) { Log.e(TAG, "onSetFailure: " + s); }
}

class SimpleChildEventListener implements com.google.firebase.database.ChildEventListener {
    @Override public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}
    @Override public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}
    @Override public void onChildRemoved(@NonNull DataSnapshot snapshot) {}
    @Override public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}
    @Override public void onCancelled(@NonNull DatabaseError error) {}
}

// --- Inflate custom chat toolbar layout ---
// This is done programmatically in setupChatToolbar()
// But the layout file is needed:
EOF

cat <<'EOF' > app/src/main/res/layout/chat_toolbar_layout.xml
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="?attr/actionBarSize"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/chat_toolbar_custom_view">

    <ImageView
        android:id="@+id/toolbar_avatar"
        android:layout_width="40dp"
        android:layout_height="40dp"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"/>

    <TextView
        android:id="@+id/toolbar_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="12dp"
        android:textColor="@color/white"
        android:textSize="18sp"
        android:textStyle="bold"
        tools:text="Partner Name"
        app:layout_constraintStart_toEndOf="@id/toolbar_avatar"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toTopOf="@id/toolbar_subtitle"
        app:layout_constraintVertical_chainStyle="packed"/>

    <TextView
        android:id="@+id/toolbar_subtitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/light_gray"
        android:textSize="12sp"
        tools:text="online"
        app:layout_constraintStart_toStartOf="@id/toolbar_title"
        app:layout_constraintTop_toBottomOf="@id/toolbar_title"
        app:layout_constraintBottom_toBottomOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# --- Menu XML files ---
cat <<'EOF' > app/src/main/res/menu/main_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/menu_profile"
        android:title="Profile"
        android:icon="@drawable/ic_baseline_more_vert_24"
        app:showAsAction="ifRoom" />
</menu>
EOF

cat <<'EOF' > app/src/main/res/menu/chat_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/menu_video_call"
        android:title="Video Call"
        android:icon="@drawable/ic_baseline_videocam_24"
        app:showAsAction="ifRoom" />
    <item
        android:id="@+id/menu_voice_call"
        android:title="Voice Call"
        android:icon="@drawable/ic_baseline_call_24"
        app:showAsAction="ifRoom" />
    <item
        android:id="@+id/menu_block_user"
        android:title="Block User"
        app:showAsAction="never"/>
</menu>
EOF

cat <<'EOF' > app/src/main/res/menu/message_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/menu_react" android:title="React" />
    <item android:id="@+id/menu_reply" android:title="Reply" />
    <item android:id="@+id/menu_delete_everyone" android:title="Delete for everyone" />
</menu>
EOF

# /app/src/main/java/com/example/callingapp/BackgroundService.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/BackgroundService.java
package ${PACKAGE_NAME};

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.Person;
import androidx.core.graphics.drawable.IconCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class BackgroundService extends android.app.Service {

    private static final String TAG = "BackgroundService";
    private static final int PERSISTENT_NOTIFICATION_ID = 1;
    private static final int CALL_NOTIFICATION_ID = 2;

    private DatabaseReference callsRef;
    private ValueEventListener callListener;
    private String currentUid;

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user != null) {
            currentUid = user.getUid();
            callsRef = FirebaseDatabase.getInstance().getReference("calls").child(currentUid);
            listenForIncomingCalls();
        } else {
            stopSelf();
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForeground(PERSISTENT_NOTIFICATION_ID, createPersistentNotification());
        return START_STICKY;
    }

    private Notification createPersistentNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, getString(R.string.persistent_channel_id))
                .setContentTitle("Java Goat is running")
                .setContentText("Listening for calls and messages.")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .build();
    }

    private void listenForIncomingCalls() {
        if (callListener != null) {
            callsRef.removeEventListener(callListener);
        }
        callListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists() && !MainActivity.isAppInForeground) {
                    String callType = snapshot.child("type").getValue(String.class);
                    if ("offer".equals(callType)) {
                        String callerName = snapshot.child("callerName").getValue(String.class);
                        String callerId = snapshot.child("callerId").getValue(String.class);
                        showIncomingCallNotification(callerName, callerId);
                    }
                }
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.w(TAG, "Call listener cancelled", error.toException());
            }
        };
        callsRef.addValueEventListener(callListener);
    }
    
    private void showIncomingCallNotification(String callerName, String callerId) {
        Intent fullScreenIntent = new Intent(this, MainActivity.class);
        fullScreenIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        // We can add extras here to tell MainActivity to open the call screen directly
        // fullScreenIntent.putExtra("caller_id", callerId);
        
        PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(this, 0,
                fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Person caller = new Person.Builder()
                .setName(callerName)
                .setKey(callerId)
                .setIcon(IconCompat.createWithResource(this, R.drawable.ic_baseline_person_add_24))
                .build();
                
        // For Android 12+, CallStyle is deprecated. We build a custom notification
        // for full screen intent.
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, getString(R.string.call_notification_channel_id))
                        .setSmallIcon(R.drawable.ic_baseline_call_24)
                        .setContentTitle("Incoming Call")
                        .setContentText(callerName)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setCategory(NotificationCompat.CATEGORY_CALL)
                        .setFullScreenIntent(fullScreenPendingIntent, true);

        // Add actions (This part is complex as they need BroadcastReceivers to handle actions)
        // For simplicity, tapping the notification opens the app to the call screen
        
        Notification incomingCallNotification = notificationBuilder.build();
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Check for USE_FULL_SCREEN_INTENT permission. Assumed granted by manifest.
             notificationManager.notify(CALL_NOTIFICATION_ID, incomingCallNotification);
        } else {
             notificationManager.notify(CALL_NOTIFICATION_ID, incomingCallNotification);
        }
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
        if (callsRef != null && callListener != null) {
            callsRef.removeEventListener(callListener);
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
EOF

# /app/src/main/java/com/example/callingapp/models/User.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/models/User.java
package ${PACKAGE_NAME}.models;

import com.google.firebase.database.IgnoreExtraProperties;

@IgnoreExtraProperties
public class User {
    private String uid;
    private String name;
    private String friendId;
    private String avatar; // Base64 encoded string
    private boolean online;
    private long lastSeen;

    public User() {}

    public User(String uid, String name, String friendId, String avatar, boolean online) {
        this.uid = uid;
        this.name = name;
        this.friendId = friendId;
        this.avatar = avatar;
        this.online = online;
    }

    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getFriendId() { return friendId; }
    public void setFriendId(String friendId) { this.friendId = friendId; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public boolean isOnline() { return online; }
    public void setOnline(boolean online) { this.online = online; }
    public long getLastSeen() { return lastSeen; }
    public void setLastSeen(long lastSeen) { this.lastSeen = lastSeen; }
}
EOF

# /app/src/main/java/com/example/callingapp/models/Message.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/models/Message.java
package ${PACKAGE_NAME}.models;

import com.google.firebase.database.IgnoreExtraProperties;
import java.util.Map;

@IgnoreExtraProperties
public class Message {
    private String messageId;
    private String text;
    private String senderId;
    private long timestamp;
    private boolean isDeleted;
    
    private String replyToMessageId;
    private String replyToMessageText;
    private String replyToSenderName;
    
    private Map<String, String> reactions;

    public Message() {}

    public Message(String messageId, String text, String senderId, long timestamp) {
        this.messageId = messageId;
        this.text = text;
        this.senderId = senderId;
        this.timestamp = timestamp;
        this.isDeleted = false;
    }

    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean deleted) { isDeleted = deleted; }
    
    public String getReplyToMessageId() { return replyToMessageId; }
    public void setReplyToMessageId(String replyToMessageId) { this.replyToMessageId = replyToMessageId; }
    public String getReplyToMessageText() { return replyToMessageText; }
    public void setReplyToMessageText(String replyToMessageText) { this.replyToMessageText = replyToMessageText; }
    public String getReplyToSenderName() { return replyToSenderName; }
    public void setReplyToSenderName(String replyToSenderName) { this.replyToSenderName = replyToSenderName; }
    
    public Map<String, String> getReactions() { return reactions; }
    public void setReactions(Map<String, String> reactions) { this.reactions = reactions; }
}
EOF

# /app/src/main/java/com/example/callingapp/models/ChatContact.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/models/ChatContact.java
package ${PACKAGE_NAME}.models;

import com.google.firebase.database.IgnoreExtraProperties;

@IgnoreExtraProperties
public class ChatContact {
    private String name;
    private String avatar;
    private String status;
    private String uid;
    private boolean online;

    public ChatContact() {}

    public ChatContact(String name, String avatar, String status) {
        this.name = name;
        this.avatar = avatar;
        this.status = status;
    }
    
    public ChatContact(String name, String avatar, String uid, boolean online) {
        this.name = name;
        this.avatar = avatar;
        this.uid = uid;
        this.online = online;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }
    public boolean isOnline() { return online; }
    public void setOnline(boolean online) { this.online = online; }
}
EOF

# /app/src/main/java/com/example/callingapp/models/CallHistory.java
cat <<EOF > app/src/main/java/$PACKAGE_PATH/models/CallHistory.java
package ${PACKAGE_NAME}.models;

import com.google.firebase.database.IgnoreExtraProperties;

@IgnoreExtraProperties
public class CallHistory {
    private String partnerName;
    private String partnerAvatar;
    private long duration; // in seconds
    private long timestamp;
    private String type; // "incoming" or "outgoing"
    private String callMedium; // "voice" or "video"

    public CallHistory() {}

    public CallHistory(String partnerName, String partnerAvatar, long duration, long timestamp, String type, String callMedium) {
        this.partnerName = partnerName;
        this.partnerAvatar = partnerAvatar;
        this.duration = duration;
        this.timestamp = timestamp;
        this.type = type;
        this.callMedium = callMedium;
    }

    public String getPartnerName() { return partnerName; }
    public void setPartnerName(String partnerName) { this.partnerName = partnerName; }
    public String getPartnerAvatar() { return partnerAvatar; }
    public void setPartnerAvatar(String partnerAvatar) { this.partnerAvatar = partnerAvatar; }
    public long getDuration() { return duration; }
    public void setDuration(long duration) { this.duration = duration; }
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getCallMedium() { return callMedium; }
    public void setCallMedium(String callMedium) { this.callMedium = callMedium; }
}
EOF

# --- 9. Gradle Wrapper and Build ---
echo "--- Installing Gradle Wrapper ---"
# Download Gradle binary, unzip it, and use it to create the wrapper
wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip -O gradle-bin.zip
unzip -q gradle-bin.zip
./gradle-8.2/bin/gradle wrapper --gradle-version 8.2
rm -rf gradle-8.2 gradle-bin.zip
chmod +x gradlew

echo "--- Building the project ---"
# The ANDROID_HOME is already exported at the top of the script
./gradlew clean assembleRelease

echo "--- Build Complete! ---"
echo "Signed release APK is located at: $(pwd)/app/build/outputs/apk/release/app-release.apk"

# Return to the original directory
cd ..