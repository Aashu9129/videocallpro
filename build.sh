#!/bin/bash
set -e

echo "🚀 Building Java Goat - Complete Video Calling App"
echo "=================================================="

WORKSPACE="videocallpro"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# Setup Android SDK
export ANDROID_HOME=$PWD/android-sdk
mkdir -p "$ANDROID_HOME/cmdline-tools"
echo "📦 Downloading Android SDK..."
wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip
mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest/"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

echo "📜 Accepting licenses..."
yes | sdkmanager --licenses >/dev/null 2>&1
echo "📱 Installing SDK platforms..."
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null 2>&1

# Create directory structure
mkdir -p app/src/main/java/com/example/callingapp
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p app/src/main/res/menu
mkdir -p app/src/main/res/anim

# Generate Keystore
echo "🔐 Generating keystore..."
keytool -genkey -v -keystore app/keystore.jks -alias javagoat -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Java Goat, OU=Dev, O=JavaGoat, L=Tech, S=State, C=IN" -storepass javagoat123 -keypass javagoat123

# ==================== GRADLE FILES ====================

cat << 'EOF' > settings.gradle
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
rootProject.name = "Java Goat"
include ':app'
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
EOF

cat << 'EOF' > build.gradle
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
EOF

cat << 'EOF' > app/build.gradle
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
            storeFile file("keystore.jks")
            storePassword "javagoat123"
            keyAlias "javagoat"
            keyPassword "javagoat123"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'io.getstream:stream-webrtc-android:1.1.1'
    implementation 'de.hdodenhof:circleimageview:3.1.0'
    implementation 'com.github.bumptech.glide:glide:4.16.0'
}
EOF

# ==================== GOOGLE-SERVICES.JSON ====================

cat << 'EOF' > app/google-services.json
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

# ==================== ANDROID MANIFEST ====================

cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-feature android:name="android.hardware.microphone" android:required="true" />
    
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <application
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="Java Goat"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.JavaGoat"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize"
            android:showWhenLocked="true"
            android:turnScreenOn="true">
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

# ==================== RESOURCE FILES ====================

cat << 'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#6C63FF</color>
    <color name="primary_dark">#5B52D9</color>
    <color name="primary_light">#8B84FF</color>
    <color name="accent">#FF6584</color>
    <color name="accent_green">#4CD964</color>
    <color name="white">#FFFFFF</color>
    <color name="black">#1A1A1A</color>
    <color name="gray_light">#F5F5F5</color>
    <color name="gray_medium">#E0E0E0</color>
    <color name="gray_dark">#9E9E9E</color>
    <color name="msg_out">#6C63FF</color>
    <color name="msg_in">#FFFFFF</color>
    <color name="red">#FF3B30</color>
    <color name="green">#34C759</color>
    <color name="yellow">#FFCC00</color>
    <color name="orange">#FF9500</color>
    <color name="teal">#5AC8FA</color>
    <color name="gradient_start">#6C63FF</color>
    <color name="gradient_end">#FF6584</color>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Java Goat</string>
    <string name="login">Login</string>
    <string name="signup">Sign Up</string>
    <string name="logout">Logout</string>
    <string name="add_friend">Add Friend</string>
    <string name="profile">Profile</string>
    <string name="chats">Chats</string>
    <string name="updates">Updates</string>
    <string name="calls">Calls</string>
    <string name="message_hint">Type a message...</string>
    <string name="send">Send</string>
    <string name="accept">Accept</string>
    <string name="reject">Reject</string>
    <string name="end_call">End Call</string>
    <string name="call_accepted">Call Accepted</string>
    <string name="connecting">Connecting...</string>
    <string name="incoming_call">Incoming Call</string>
    <string name="calling">Calling...</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.JavaGoat" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="colorPrimaryVariant">@color/primary_dark</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/accent</item>
        <item name="colorSecondaryVariant">@color/accent</item>
        <item name="colorOnSecondary">@color/white</item>
        <item name="android:statusBarColor">@color/primary_dark</item>
        <item name="android:windowAnimationStyle">@style/WindowAnimationTransition</item>
    </style>
    
    <style name="WindowAnimationTransition" parent="@android:style/Animation.Activity">
        <item name="android:activityOpenEnterAnimation">@anim/slide_in_right</item>
        <item name="android:activityOpenExitAnimation">@anim/slide_out_left</item>
        <item name="android:activityCloseEnterAnimation">@anim/slide_in_left</item>
        <item name="android:activityCloseExitAnimation">@anim/slide_out_right</item>
    </style>
</resources>
EOF

# Animation files
cat << 'EOF' > app/src/main/res/anim/slide_in_right.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromXDelta="100%" android:toXDelta="0%" android:duration="300"/>
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="300"/>
</set>
EOF

cat << 'EOF' > app/src/main/res/anim/slide_out_left.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromXDelta="0%" android:toXDelta="-100%" android:duration="300"/>
    <alpha android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="300"/>
</set>
EOF

cat << 'EOF' > app/src/main/res/anim/slide_in_left.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromXDelta="-100%" android:toXDelta="0%" android:duration="300"/>
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="300"/>
</set>
EOF

cat << 'EOF' > app/src/main/res/anim/slide_out_right.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromXDelta="0%" android:toXDelta="100%" android:duration="300"/>
    <alpha android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="300"/>
</set>
EOF

cat << 'EOF' > app/src/main/res/anim/fade_in.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="500"/>
</set>
EOF

cat << 'EOF' > app/src/main/res/anim/bounce.xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <scale android:fromXScale="1.0" android:toXScale="1.1" android:fromYScale="1.0" android:toYScale="1.1" android:duration="100"/>
    <scale android:fromXScale="1.1" android:toXScale="1.0" android:fromYScale="1.1" android:toYScale="1.0" android:duration="100" android:startOffset="100"/>
</set>
EOF

# Drawable files
cat << 'EOF' > app/src/main/res/drawable/msg_out_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_out"/>
    <corners android:topLeftRadius="20dp" android:topRightRadius="20dp" android:bottomLeftRadius="20dp" android:bottomRightRadius="4dp"/>
    <padding android:left="12dp" android:top="8dp" android:right="12dp" android:bottom="8dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/msg_in_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_in"/>
    <corners android:topLeftRadius="4dp" android:topRightRadius="20dp" android:bottomLeftRadius="20dp" android:bottomRightRadius="20dp"/>
    <padding android:left="12dp" android:top="8dp" android:right="12dp" android:bottom="8dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/emoji_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/gradient_start"/>
    <stroke android:width="2dp" android:color="@color/white"/>
    <size android:width="48dp" android:height="48dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/gradient_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:startColor="@color/gradient_start" android:endColor="@color/gradient_end" android:angle="135"/>
    <corners android:radius="16dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/button_gradient.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:startColor="@color/gradient_start" android:endColor="@color/gradient_end" android:angle="45"/>
    <corners android:radius="25dp"/>
    <padding android:left="20dp" android:top="12dp" android:right="20dp" android:bottom="12dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/call_button_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/accent_green"/>
    <size android:width="64dp" android:height="64dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/end_call_button_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/red"/>
    <size android:width="64dp" android:height="64dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_launcher_background.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#6C63FF" android:pathData="M0,0h108v108h-108z"/>
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_launcher_foreground.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF" android:pathData="M54,30 C41.8,30 32,39.8 32,52 C32,64.2 41.8,74 54,74 C66.2,74 76,64.2 76,52 C76,39.8 66.2,30 54,30 Z M54,68 C45.2,68 38,60.8 38,52 C38,43.2 45.2,36 54,36 C62.8,36 70,43.2 70,52 C70,60.8 62.8,68 54,68 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M54,42 C48.5,42 44,46.5 44,52 C44,57.5 48.5,62 54,62 C59.5,62 64,57.5 64,52 C64,46.5 59.5,42 54,42 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M28,84 L80,84 L80,76 L28,76 Z"/>
</vector>
EOF

cat << 'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF
cp app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml

cat << 'EOF' > app/src/main/res/menu/bottom_nav_menu.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_chats" android:title="Chats" android:icon="@drawable/ic_launcher_foreground"/>
    <item android:id="@+id/nav_updates" android:title="Updates" android:icon="@drawable/ic_launcher_foreground"/>
    <item android:id="@+id/nav_calls" android:title="Calls" android:icon="@drawable/ic_launcher_foreground"/>
</menu>
EOF

# ==================== LAYOUT FILES ====================

cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/gray_light">

    <!-- Auth View -->
    <LinearLayout android:id="@+id/viewAuth"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:gravity="center"
        android:padding="32dp"
        android:background="@drawable/gradient_bg"
        android:visibility="gone">
        
        <TextView android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="🐐 Java Goat"
            android:textSize="42sp"
            android:textStyle="bold"
            android:textColor="@color/white"
            android:layout_marginBottom="48dp"
            android:animation="@anim/bounce"/>
        
        <com.google.android.material.textfield.TextInputLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginBottom="16dp"
            style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/etEmail"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Email"
                android:textColor="@color/white"
                android:textColorHint="@color/gray_medium"
                android:inputType="textEmailAddress"/>
        </com.google.android.material.textfield.TextInputLayout>
        
        <com.google.android.material.textfield.TextInputLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginBottom="24dp"
            style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/etPassword"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Password"
                android:textColor="@color/white"
                android:textColorHint="@color/gray_medium"
                android:inputType="textPassword"/>
        </com.google.android.material.textfield.TextInputLayout>
        
        <Button android:id="@+id/btnLogin"
            android:layout_width="match_parent"
            android:layout_height="56dp"
            android:text="Login"
            android:background="@drawable/button_gradient"
            android:textColor="@color/white"
            android:textSize="16sp"
            android:textStyle="bold"/>
        
        <Button android:id="@+id/btnSignup"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Create New Account"
            android:background="@android:color/transparent"
            android:textColor="@color/white"
            android:textSize="14sp"
            android:layout_marginTop="16dp"/>
    </LinearLayout>

    <!-- Main View -->
    <LinearLayout android:id="@+id/viewMain"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:visibility="gone"
        android:background="@color/white">
        
        <androidx.appcompat.widget.Toolbar android:id="@+id/toolbarMain"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@drawable/gradient_bg"
            android:elevation="4dp">
            
            <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="🐐 Java Goat"
                android:textColor="@color/white"
                android:textSize="20sp"
                android:textStyle="bold"/>
            
            <LinearLayout android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="end"
                android:orientation="horizontal">
                
                <Button android:id="@+id/btnAddFriend"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="+ Add"
                    style="@style/Widget.MaterialComponents.Button.TextButton"
                    android:textColor="@color/white"/>
                
                <Button android:id="@+id/btnProfile"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="👤"
                    style="@style/Widget.MaterialComponents.Button.TextButton"
                    android:textColor="@color/white"
                    android:textSize="20sp"/>
            </LinearLayout>
        </androidx.appcompat.widget.Toolbar>
        
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rvMain"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"/>
        
        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottomNav"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            app:menu="@menu/bottom_nav_menu"
            android:background="@color/white"
            app:itemIconTint="@color/primary"
            app:itemTextColor="@color/primary"
            android:elevation="8dp"/>
    </LinearLayout>

    <!-- Chat View -->
    <LinearLayout android:id="@+id/viewChat"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:visibility="gone"
        android:background="#E8E8E8">
        
        <androidx.appcompat.widget.Toolbar android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="@drawable/gradient_bg">
            
            <LinearLayout android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:orientation="horizontal"
                android:gravity="center_vertical">
                
                <Button android:id="@+id/btnChatBack"
                    android:layout_width="48dp"
                    android:layout_height="48dp"
                    android:text="←"
                    style="@style/Widget.MaterialComponents.Button.TextButton"
                    android:textColor="@color/white"
                    android:textSize="24sp"/>
                
                <TextView android:id="@+id/tvChatEmoji"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:text="🐐"
                    android:textSize="24sp"
                    android:background="@drawable/emoji_bg"
                    android:gravity="center"
                    android:layout_marginStart="8dp"/>
                
                <LinearLayout android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:layout_marginStart="12dp">
                    
                    <TextView android:id="@+id/tvChatName"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:textColor="@color/white"
                        android:textSize="16sp"
                        android:textStyle="bold"/>
                    
                    <TextView android:id="@+id/tvChatStatus"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:textColor="@color/gray_medium"
                        android:textSize="12sp"/>
                </LinearLayout>
                
                <Button android:id="@+id/btnVoiceCall"
                    android:layout_width="48dp"
                    android:layout_height="48dp"
                    android:text="📞"
                    style="@style/Widget.MaterialComponents.Button.TextButton"
                    android:textColor="@color/white"
                    android:textSize="20sp"/>
                
                <Button android:id="@+id/btnVideoCall"
                    android:layout_width="48dp"
                    android:layout_height="48dp"
                    android:text="📹"
                    style="@style/Widget.MaterialComponents.Button.TextButton"
                    android:textColor="@color/white"
                    android:textSize="20sp"/>
            </LinearLayout>
        </androidx.appcompat.widget.Toolbar>
        
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rvMessages"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"
            android:padding="12dp"
            android:clipToPadding="false"/>
        
        <LinearLayout android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:padding="12dp"
            android:background="@color/white"
            android:elevation="4dp">
            
            <EditText android:id="@+id/etMessage"
                android:layout_width="0dp"
                android:layout_weight="1"
                android:layout_height="wrap_content"
                android:hint="Type a message..."
                android:background="@drawable/msg_in_bg"
                android:padding="12dp"
                android:textColor="@color/black"/>
            
            <Button android:id="@+id/btnSend"
                android:layout_width="56dp"
                android:layout_height="48dp"
                android:text="Send"
                android:layout_marginStart="8dp"
                android:backgroundTint="@color/primary"
                android:textColor="@color/white"/>
        </LinearLayout>
    </LinearLayout>

    <!-- Call View -->
    <FrameLayout android:id="@+id/viewCall"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/black"
        android:visibility="gone">
        
        <org.webrtc.SurfaceViewRenderer android:id="@+id/remoteVideo"
            android:layout_width="match_parent"
            android:layout_height="match_parent"/>
        
        <org.webrtc.SurfaceViewRenderer android:id="@+id/localVideo"
            android:layout_width="120dp"
            android:layout_height="160dp"
            android:layout_gravity="top|end"
            android:layout_margin="16dp"
            android:elevation="8dp"/>
        
        <LinearLayout android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="top"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="24dp"
            android:background="#66000000">
            
            <TextView android:id="@+id/tvCallName"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/white"
                android:textSize="28sp"
                android:textStyle="bold"/>
            
            <TextView android:id="@+id/tvCallStatus"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textColor="@color/gray_medium"
                android:textSize="16sp"
                android:layout_marginTop="8dp"/>
        </LinearLayout>
        
        <LinearLayout android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="bottom"
            android:orientation="horizontal"
            android:gravity="center"
            android:padding="32dp"
            android:background="#66000000">
            
            <Button android:id="@+id/btnAcceptCall"
                android:layout_width="64dp"
                android:layout_height="64dp"
                android:text="✓"
                android:background="@drawable/call_button_bg"
                android:textSize="32sp"
                android:textColor="@color/white"
                android:visibility="gone"
                android:layout_marginEnd="24dp"/>
            
            <Button android:id="@+id/btnEndCall"
                android:layout_width="64dp"
                android:layout_height="64dp"
                android:text="✗"
                android:background="@drawable/end_call_button_bg"
                android:textSize="32sp"
                android:textColor="@color/white"/>
        </LinearLayout>
    </FrameLayout>
</FrameLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_list.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="8dp"
    app:cardCornerRadius="12dp"
    app:cardElevation="2dp">
    
    <LinearLayout android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="16dp"
        android:gravity="center_vertical">
        
        <TextView android:id="@+id/tvListEmoji"
            android:layout_width="56dp"
            android:layout_height="56dp"
            android:background="@drawable/emoji_bg"
            android:gravity="center"
            android:textSize="28sp"
            android:text="🐐"/>
        
        <LinearLayout android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:layout_marginStart="16dp">
            
            <TextView android:id="@+id/tvListTitle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textSize="16sp"
                android:textStyle="bold"
                android:textColor="@color/black"/>
            
            <TextView android:id="@+id/tvListSubtitle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textSize="12sp"
                android:textColor="@color/gray_dark"/>
        </LinearLayout>
        
        <TextView android:id="@+id/tvListBadge"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:background="@drawable/emoji_bg"
            android:backgroundTint="@color/accent"
            android:textColor="@color/white"
            android:paddingHorizontal="10dp"
            android:paddingVertical="4dp"
            android:textSize="12sp"
            android:textStyle="bold"
            android:visibility="gone"/>
        
        <LinearLayout android:id="@+id/actionsLayout"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:visibility="gone">
            
            <Button android:id="@+id/btnListAccept"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="Accept"
                android:backgroundTint="@color/green"
                android:textSize="12sp"
                android:layout_marginEnd="8dp"/>
            
            <Button android:id="@+id/btnListReject"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="Reject"
                android:backgroundTint="@color/red"
                android:textSize="12sp"/>
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_message.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/msgRoot"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:paddingTop="4dp"
    android:paddingBottom="4dp">
    
    <TextView android:id="@+id/tvMessage"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:padding="12dp"
        android:textColor="@color/white"
        android:textSize="14sp"
        android:maxWidth="280dp"/>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/dialog_input.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="24dp">
    
    <TextView android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Profile Setup"
        android:textSize="20sp"
        android:textStyle="bold"
        android:textColor="@color/primary"
        android:layout_marginBottom="16dp"/>
    
    <com.google.android.material.textfield.TextInputLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="16dp"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
        
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput1"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="Your Name"/>
    </com.google.android.material.textfield.TextInputLayout>
    
    <com.google.android.material.textfield.TextInputLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
        
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etInput2"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="Emoji Avatar (e.g., 🐐)"/>
    </com.google.android.material.textfield.TextInputLayout>
</LinearLayout>
EOF

# ==================== JAVA CLASSES ====================

# Data Models
cat << 'EOF' > app/src/main/java/com/example/callingapp/User.java
package com.example.callingapp;

public class User {
    public String uid, name, emoji, jgId, status;
    public boolean online;
    public long lastSeen;
    
    public User() {}
    
    public User(String uid, String name, String emoji, String jgId) {
        this.uid = uid;
        this.name = name;
        this.emoji = emoji;
        this.jgId = jgId;
        this.online = false;
        this.lastSeen = System.currentTimeMillis();
        this.status = "Hey there! I'm using Java Goat";
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/example/callingapp/Message.java
package com.example.callingapp;

public class Message {
    public String senderId, text;
    public long timestamp;
    public boolean isRead;
    
    public Message() {}
    
    public Message(String senderId, String text, long timestamp) {
        this.senderId = senderId;
        this.text = text;
        this.timestamp = timestamp;
        this.isRead = false;
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/example/callingapp/CallHistory.java
package com.example.callingapp;

public class CallHistory {
    public String callerId, calleeId, type, duration;
    public long timestamp;
    
    public CallHistory() {}
    
    public CallHistory(String callerId, String calleeId, String type, String duration) {
        this.callerId = callerId;
        this.calleeId = calleeId;
        this.type = type;
        this.duration = duration;
        this.timestamp = System.currentTimeMillis();
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/example/callingapp/ListItem.java
package com.example.callingapp;

public class ListItem {
    public String uid, title, subtitle, emoji, type, action;
    public int unreadCount;
    
    public ListItem(String uid, String title, String subtitle, String emoji, String type, int unreadCount) {
        this.uid = uid;
        this.title = title;
        this.subtitle = subtitle;
        this.emoji = emoji;
        this.type = type;
        this.unreadCount = unreadCount;
    }
}
EOF

# BackgroundService.java
cat << 'EOF' > app/src/main/java/com/example/callingapp/BackgroundService.java
package com.example.callingapp;

import android.app.*;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class BackgroundService extends Service {
    private static final String CHANNEL_ID = "javagoat_channel";
    private static final String CALL_CHANNEL_ID = "javagoat_calls";
    private DatabaseReference callsRef, messagesRef;
    private ValueEventListener callListener, messageListener;
    private NotificationManager nm;
    
    @Override
    public void onCreate() {
        super.onCreate();
        nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Java Goat Service", NotificationManager.IMPORTANCE_LOW);
            NotificationChannel callChannel = new NotificationChannel(CALL_CHANNEL_ID, "Java Goat Calls", NotificationManager.IMPORTANCE_HIGH);
            callChannel.setSound(null, null);
            nm.createNotificationChannel(channel);
            nm.createNotificationChannel(callChannel);
        }
        
        startForeground(1, new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Java Goat")
            .setContentText("Active and listening for messages...")
            .setSmallIcon(android.R.drawable.sym_def_app_icon)
            .build());
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
            DatabaseReference db = FirebaseDatabase.getInstance().getReference();
            
            callsRef = db.child("calls").child(uid);
            callListener = callsRef.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (snapshot.exists() && snapshot.hasChild("offer") && !MainActivity.isAppInForeground) {
                        Intent intent = new Intent(BackgroundService.this, MainActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        PendingIntent pi = PendingIntent.getActivity(BackgroundService.this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                        
                        Notification n = new NotificationCompat.Builder(BackgroundService.this, CALL_CHANNEL_ID)
                            .setContentTitle("Incoming Call")
                            .setContentText(snapshot.child("callerName").getValue(String.class) + " is calling...")
                            .setSmallIcon(android.R.drawable.sym_call_incoming)
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setFullScreenIntent(pi, true)
                            .setAutoCancel(true)
                            .build();
                        nm.notify(2, n);
                    }
                }
                @Override public void onCancelled(DatabaseError error) {}
            });
        }
        return START_STICKY;
    }
    
    @Override
    public void onDestroy() {
        if (callsRef != null && callListener != null) callsRef.removeEventListener(callListener);
        super.onDestroy();
    }
    
    @Override
    public IBinder onBind(Intent intent) { return null; }
}
EOF

# MainActivity.java - Complete
cat << 'EOF' > app/src/main/java/com/example/callingapp/MainActivity.java
package com.example.callingapp;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.util.*;

public class MainActivity extends AppCompatActivity {
    public static boolean isAppInForeground = false;
    
    // Firebase
    private FirebaseAuth auth;
    private DatabaseReference db;
    private String myUid, myName, myEmoji, myJgId;
    
    // Views
    private View viewAuth, viewMain, viewChat, viewCall;
    private RecyclerView rvMain, rvMessages;
    private EditText etEmail, etPassword, etMessage;
    private TextView tvChatName, tvChatStatus, tvChatEmoji, tvCallName, tvCallStatus;
    private Button btnAcceptCall, btnEndCall;
    private SurfaceViewRenderer localVideo, remoteVideo;
    private BottomNavigationView bottomNav;
    
    // Data
    private List<ListItem> mainList = new ArrayList<>();
    private List<Message> messageList = new ArrayList<>();
    private GenericAdapter mainAdapter;
    private MessageAdapter messageAdapter;
    private String currentTab = "chats";
    private String currentChatId, currentChatName, currentChatEmoji;
    private boolean isChatOpen = false;
    
    // WebRTC
    private PeerConnectionFactory pcf;
    private PeerConnection pc;
    private EglBase eglBase;
    private VideoCapturer videoCapturer;
    private VideoTrack localVideoTrack;
    private AudioTrack localAudioTrack;
    private String currentCallId;
    private boolean isCaller, isVideoCall;
    private List<IceCandidate> pendingCandidates = new ArrayList<>();
    private ValueEventListener callListener;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        requestPermissions();
        
        auth = FirebaseAuth.getInstance();
        db = FirebaseDatabase.getInstance().getReference();
        eglBase = EglBase.create();
        
        initViews();
        setupAuth();
        setupMainUI();
        setupChatUI();
        setupCallUI();
        
        if (auth.getCurrentUser() != null) {
            myUid = auth.getCurrentUser().getUid();
            loadUserData();
        } else {
            showView(viewAuth);
        }
    }
    
    private void requestPermissions() {
        String[] perms = {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO, Manifest.permission.POST_NOTIFICATIONS};
        ActivityCompat.requestPermissions(this, perms, 100);
    }
    
    private void initViews() {
        viewAuth = findViewById(R.id.viewAuth);
        viewMain = findViewById(R.id.viewMain);
        viewChat = findViewById(R.id.viewChat);
        viewCall = findViewById(R.id.viewCall);
        rvMain = findViewById(R.id.rvMain);
        rvMessages = findViewById(R.id.rvMessages);
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        etMessage = findViewById(R.id.etMessage);
        tvChatName = findViewById(R.id.tvChatName);
        tvChatStatus = findViewById(R.id.tvChatStatus);
        tvChatEmoji = findViewById(R.id.tvChatEmoji);
        tvCallName = findViewById(R.id.tvCallName);
        tvCallStatus = findViewById(R.id.tvCallStatus);
        btnAcceptCall = findViewById(R.id.btnAcceptCall);
        btnEndCall = findViewById(R.id.btnEndCall);
        localVideo = findViewById(R.id.localVideo);
        remoteVideo = findViewById(R.id.remoteVideo);
        bottomNav = findViewById(R.id.bottomNav);
    }
    
    private void showView(View view) {
        viewAuth.setVisibility(view == viewAuth ? View.VISIBLE : View.GONE);
        viewMain.setVisibility(view == viewMain ? View.VISIBLE : View.GONE);
        viewChat.setVisibility(view == viewChat ? View.VISIBLE : View.GONE);
        viewCall.setVisibility(view == viewCall ? View.VISIBLE : View.GONE);
    }
    
    @Override protected void onResume() { 
        super.onResume(); 
        isAppInForeground = true;
        if (myUid != null) db.child("users").child(myUid).child("online").setValue(true);
    }
    
    @Override protected void onPause() { 
        super.onPause(); 
        isAppInForeground = false;
        if (myUid != null) {
            db.child("users").child(myUid).child("online").setValue(false);
            db.child("users").child(myUid).child("lastSeen").setValue(System.currentTimeMillis());
        }
    }
    
    private void loadUserData() {
        db.child("users").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    myName = snapshot.child("name").getValue(String.class);
                    myEmoji = snapshot.child("emoji").getValue(String.class);
                    myJgId = snapshot.child("jgId").getValue(String.class);
                    startApp();
                } else {
                    showProfileDialog();
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
    }
    
    private void startApp() {
        startService(new Intent(this, BackgroundService.class));
        db.child("users").child(myUid).child("online").onDisconnect().setValue(false);
        showView(viewMain);
        loadTab("chats");
        listenForCalls();
        animateView(viewMain);
    }
    
    private void animateView(View view) {
        view.setAlpha(0f);
        view.setTranslationY(50f);
        view.animate().alpha(1f).translationY(0f).setDuration(500).start();
    }
    
    // ==================== AUTH ====================
    private void setupAuth() {
        findViewById(R.id.btnLogin).setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();
            String pass = etPassword.getText().toString().trim();
            if (!email.isEmpty() && !pass.isEmpty()) {
                auth.signInWithEmailAndPassword(email, pass)
                    .addOnSuccessListener(authResult -> {
                        myUid = auth.getCurrentUser().getUid();
                        loadUserData();
                    })
                    .addOnFailureListener(e -> Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show());
            }
        });
        
        findViewById(R.id.btnSignup).setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();
            String pass = etPassword.getText().toString().trim();
            if (!email.isEmpty() && !pass.isEmpty()) {
                auth.createUserWithEmailAndPassword(email, pass)
                    .addOnSuccessListener(authResult -> {
                        myUid = auth.getCurrentUser().getUid();
                        showProfileDialog();
                    })
                    .addOnFailureListener(e -> Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show());
            }
        });
    }
    
    private void showProfileDialog() {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_input, null);
        EditText etName = dialogView.findViewById(R.id.etInput1);
        EditText etEmoji = dialogView.findViewById(R.id.etInput2);
        etName.setHint("Your Name");
        etEmoji.setHint("Emoji (🐐)");
        
        new AlertDialog.Builder(this)
            .setTitle("Complete Profile")
            .setView(dialogView)
            .setPositiveButton("Start", (d, w) -> {
                String name = etName.getText().toString().trim();
                String emoji = etEmoji.getText().toString().trim();
                if (name.isEmpty()) name = "User";
                if (emoji.isEmpty()) emoji = "🐐";
                
                myJgId = "jg" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
                Map<String, Object> user = new HashMap<>();
                user.put("name", name);
                user.put("emoji", emoji);
                user.put("jgId", myJgId);
                user.put("online", true);
                user.put("lastSeen", System.currentTimeMillis());
                db.child("users").child(myUid).setValue(user);
                db.child("jgIds").child(myJgId).setValue(myUid);
                startApp();
            })
            .setCancelable(false)
            .show();
    }
    
    // ==================== MAIN UI ====================
    private void setupMainUI() {
        rvMain.setLayoutManager(new LinearLayoutManager(this));
        mainAdapter = new GenericAdapter();
        rvMain.setAdapter(mainAdapter);
        
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats) currentTab = "chats";
            else if (id == R.id.nav_updates) currentTab = "updates";
            else if (id == R.id.nav_calls) currentTab = "calls";
            loadTab(currentTab);
            return true;
        });
        
        findViewById(R.id.btnAddFriend).setOnClickListener(v -> showAddFriendDialog());
        findViewById(R.id.btnProfile).setOnClickListener(v -> showProfile());
    }
    
    private void loadTab(String tab) {
        mainList.clear();
        mainAdapter.notifyDataSetChanged();
        
        if (tab.equals("chats")) {
            db.child("friends").child(myUid).addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    if (!currentTab.equals("chats")) return;
                    mainList.clear();
                    for (DataSnapshot s : snapshot.getChildren()) {
                        String friendId = s.getKey();
                        db.child("users").child(friendId).get().addOnSuccessListener(userSnap -> {
                            String name = userSnap.child("name").getValue(String.class);
                            String emoji = userSnap.child("emoji").getValue(String.class);
                            boolean online = userSnap.child("online").getValue(Boolean.class) != null && userSnap.child("online").getValue(Boolean.class);
                            String status = online ? "● Online" : "○ Offline";
                            
                            db.child("users").child(myUid).child("unread").child(friendId).get().addOnSuccessListener(unreadSnap -> {
                                int unread = unreadSnap.exists() ? unreadSnap.getValue(Integer.class) : 0;
                                mainList.add(new ListItem(friendId, name, status, emoji, "chat", unread));
                                mainAdapter.notifyDataSetChanged();
                            });
                        });
                    }
                }
                @Override public void onCancelled(@NonNull DatabaseError error) {}
            });
        } else if (tab.equals("updates")) {
            db.child("friendRequests").child(myUid).addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    if (!currentTab.equals("updates")) return;
                    mainList.clear();
                    for (DataSnapshot s : snapshot.getChildren()) {
                        String requesterId = s.getKey();
                        String name = s.child("name").getValue(String.class);
                        String emoji = s.child("emoji").getValue(String.class);
                        mainList.add(new ListItem(requesterId, name, "Wants to be friends", emoji, "request", 0));
                    }
                    mainAdapter.notifyDataSetChanged();
                }
                @Override public void onCancelled(@NonNull DatabaseError error) {}
            });
        }
    }
    
    private void showAddFriendDialog() {
        EditText input = new EditText(this);
        input.setHint("Enter jgXXXXXX");
        new AlertDialog.Builder(this)
            .setTitle("Add Friend")
            .setView(input)
            .setPositiveButton("Add", (d, w) -> {
                String jgId = input.getText().toString().trim();
                db.child("jgIds").child(jgId).get().addOnSuccessListener(snap -> {
                    if (snap.exists()) {
                        String friendId = snap.getValue(String.class);
                        db.child("users").child(myUid).get().addOnSuccessListener(userSnap -> {
                            Map<String, Object> request = new HashMap<>();
                            request.put("name", userSnap.child("name").getValue(String.class));
                            request.put("emoji", userSnap.child("emoji").getValue(String.class));
                            db.child("friendRequests").child(friendId).child(myUid).setValue(request);
                            Toast.makeText(this, "Friend request sent!", Toast.LENGTH_SHORT).show();
                        });
                    } else {
                        Toast.makeText(this, "User not found", Toast.LENGTH_SHORT).show();
                    }
                });
            })
            .show();
    }
    
    private void showProfile() {
        new AlertDialog.Builder(this)
            .setTitle("🐐 " + myName)
            .setMessage("ID: " + myJgId + "\nEmoji: " + myEmoji)
            .setPositiveButton("Logout", (d, w) -> {
                auth.signOut();
                stopService(new Intent(this, BackgroundService.class));
                showView(viewAuth);
            })
            .setNegativeButton("Close", null)
            .show();
    }
    
    // ==================== CHAT UI ====================
    private void setupChatUI() {
        rvMessages.setLayoutManager(new LinearLayoutManager(this));
        messageAdapter = new MessageAdapter();
        rvMessages.setAdapter(messageAdapter);
        
        findViewById(R.id.btnChatBack).setOnClickListener(v -> {
            isChatOpen = false;
            showView(viewMain);
        });
        findViewById(R.id.btnSend).setOnClickListener(v -> sendMessage());
        findViewById(R.id.btnVoiceCall).setOnClickListener(v -> startCall(false));
        findViewById(R.id.btnVideoCall).setOnClickListener(v -> startCall(true));
    }
    
    private void openChat(String userId, String name, String emoji) {
        currentChatId = userId;
        currentChatName = name;
        currentChatEmoji = emoji;
        isChatOpen = true;
        
        tvChatName.setText(name);
        tvChatEmoji.setText(emoji);
        
        db.child("users").child(userId).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    boolean online = snapshot.child("online").getValue(Boolean.class) != null && snapshot.child("online").getValue(Boolean.class);
                    long lastSeen = snapshot.child("lastSeen").getValue(Long.class) != null ? snapshot.child("lastSeen").getValue(Long.class) : 0;
                    if (online) {
                        tvChatStatus.setText("● Online");
                    } else if (lastSeen > 0) {
                        CharSequence relativeTime = DateUtils.getRelativeTimeSpanString(lastSeen);
                        tvChatStatus.setText("Last seen " + relativeTime);
                    }
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
        
        db.child("users").child(myUid).child("unread").child(userId).removeValue();
        
        String chatRoom = myUid.compareTo(userId) < 0 ? myUid + "_" + userId : userId + "_" + myUid;
        db.child("chats").child(chatRoom).limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (!isChatOpen) return;
                messageList.clear();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Message msg = s.getValue(Message.class);
                    if (msg != null) messageList.add(msg);
                }
                messageAdapter.notifyDataSetChanged();
                if (messageList.size() > 0) rvMessages.scrollToPosition(messageList.size() - 1);
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
        
        showView(viewChat);
        animateView(viewChat);
    }
    
    private void sendMessage() {
        String text = etMessage.getText().toString().trim();
        if (text.isEmpty() || currentChatId == null) return;
        
        Message msg = new Message(myUid, text, System.currentTimeMillis());
        String chatRoom = myUid.compareTo(currentChatId) < 0 ? myUid + "_" + currentChatId : currentChatId + "_" + myUid;
        db.child("chats").child(chatRoom).push().setValue(msg);
        etMessage.setText("");
        
        db.child("users").child(currentChatId).child("unread").child(myUid).get().addOnSuccessListener(snap -> {
            int count = snap.exists() ? snap.getValue(Integer.class) : 0;
            db.child("users").child(currentChatId).child("unread").child(myUid).setValue(count + 1);
        });
    }
    
    // ==================== WEBRTC CALLS ====================
    private void setupCallUI() {
        localVideo.init(eglBase.getEglBaseContext(), null);
        remoteVideo.init(eglBase.getEglBaseContext(), null);
        btnAcceptCall.setOnClickListener(v -> acceptCall());
        btnEndCall.setOnClickListener(v -> endCall());
    }
    
    private void listenForCalls() {
        db.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (!snapshot.exists()) {
                    if (viewCall.getVisibility() == View.VISIBLE) endCall();
                    return;
                }
                if (viewCall.getVisibility() == View.VISIBLE) return;
                
                currentCallId = snapshot.getKey();
                isCaller = false;
                isVideoCall = snapshot.child("isVideo").getValue(Boolean.class) != null && snapshot.child("isVideo").getValue(Boolean.class);
                tvCallName.setText(snapshot.child("callerName").getValue(String.class));
                tvCallStatus.setText("Incoming " + (isVideoCall ? "Video" : "Voice") + " Call...");
                btnAcceptCall.setVisibility(View.VISIBLE);
                showView(viewCall);
                animateView(viewCall);
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
    }
    
    private void startCall(boolean isVideo) {
        isCaller = true;
        isVideoCall = isVideo;
        currentCallId = currentChatId;
        tvCallName.setText(currentChatName);
        tvCallStatus.setText("Calling...");
        btnAcceptCall.setVisibility(View.GONE);
        showView(viewCall);
        
        initWebRTC();
        db.child("users").child(myUid).get().addOnSuccessListener(snap -> {
            Map<String, Object> call = new HashMap<>();
            call.put("callerUid", myUid);
            call.put("callerName", snap.child("name").getValue(String.class));
            call.put("isVideo", isVideoCall);
            db.child("calls").child(currentCallId).setValue(call);
            
            pc.createOffer(new SdpObserver() {
                @Override public void onCreateSuccess(SessionDescription sdp) {
                    pc.setLocalDescription(new SimpleSdpObserver(), sdp);
                    db.child("calls").child(currentCallId).child("offer").setValue(sdp.description);
                }
                @Override public void onSetSuccess() {}
                @Override public void onCreateFailure(String s) {}
                @Override public void onSetFailure(String s) {}
            }, new MediaConstraints());
        });
        
        listenForAnswer();
    }
    
    private void acceptCall() {
        btnAcceptCall.setVisibility(View.GONE);
        tvCallStatus.setText("Connecting...");
        initWebRTC();
        
        db.child("calls").child(myUid).child("offer").get().addOnSuccessListener(snap -> {
            String sdp = snap.getValue(String.class);
            pc.setRemoteDescription(new SimpleSdpObserver(), new SessionDescription(SessionDescription.Type.OFFER, sdp));
            pc.createAnswer(new SdpObserver() {
                @Override public void onCreateSuccess(SessionDescription answer) {
                    pc.setLocalDescription(new SimpleSdpObserver(), answer);
                    db.child("calls").child(myUid).child("answer").setValue(answer.description);
                }
                @Override public void onSetSuccess() {}
                @Override public void onCreateFailure(String s) {}
                @Override public void onSetFailure(String s) {}
            }, new MediaConstraints());
        });
        
        listenForCandidates("caller");
    }
    
    private void listenForAnswer() {
        db.child("calls").child(currentCallId).child("answer").addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists() && pc.getRemoteDescription() == null) {
                    pc.setRemoteDescription(new SimpleSdpObserver(), new SessionDescription(SessionDescription.Type.ANSWER, snapshot.getValue(String.class)));
                    tvCallStatus.setText("Connected");
                    for (IceCandidate cand : pendingCandidates) pc.addIceCandidate(cand);
                    pendingCandidates.clear();
                }
            }
            @Override public void onCancelled(@NonNull DatabaseError error) {}
        });
        listenForCandidates("receiver");
    }
    
    private void listenForCandidates(String role) {
        String node = isCaller ? currentCallId : myUid;
        db.child("calls").child(node).child("candidates").child(role).addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, String prev) {
                if (pc.getRemoteDescription() != null) {
                    IceCandidate cand = new IceCandidate(
                        snapshot.child("sdpMid").getValue(String.class),
                        snapshot.child("sdpMLineIndex").getValue(Integer.class),
                        snapshot.child("sdp").getValue(String.class)
                    );
                    pc.addIceCandidate(cand);
                } else {
                    IceCandidate cand = new IceCandidate(
                        snapshot.child("sdpMid").getValue(String.class),
                        snapshot.child("sdpMLineIndex").getValue(Integer.class),
                        snapshot.child("sdp").getValue(String.class)
                    );
                    pendingCandidates.add(cand);
                }
            }
            @Override public void onChildChanged(@NonNull DataSnapshot s, String p) {}
            @Override public void onChildRemoved(@NonNull DataSnapshot s) {}
            @Override public void onChildMoved(@NonNull DataSnapshot s, String p) {}
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void initWebRTC() {
        AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        am.setMode(AudioManager.MODE_IN_COMMUNICATION);
        am.setSpeakerphoneOn(true);
        
        PeerConnectionFactory.InitializationOptions initOpts = PeerConnectionFactory.InitializationOptions.builder(this).createInitializationOptions();
        PeerConnectionFactory.initialize(initOpts);
        
        DefaultVideoEncoderFactory encoderFactory = new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true);
        DefaultVideoDecoderFactory decoderFactory = new DefaultVideoDecoderFactory(eglBase.getEglBaseContext());
        pcf = PeerConnectionFactory.builder()
            .setVideoEncoderFactory(encoderFactory)
            .setVideoDecoderFactory(decoderFactory)
            .createPeerConnectionFactory();
        
        List<PeerConnection.IceServer> iceServers = Arrays.asList(
            PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer(),
            PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer(),
            PeerConnection.IceServer.builder("stun:stun2.l.google.com:19302").createIceServer()
        );
        
        pc = pcf.createPeerConnection(new PeerConnection.RTCConfiguration(iceServers), new PeerConnection.Observer() {
            @Override public void onIceCandidate(IceCandidate candidate) {
                Map<String, Object> cand = new HashMap<>();
                cand.put("sdpMid", candidate.sdpMid);
                cand.put("sdpMLineIndex", candidate.sdpMLineIndex);
                cand.put("sdp", candidate.sdp);
                String role = isCaller ? "caller" : "receiver";
                db.child("calls").child(isCaller ? currentCallId : myUid).child("candidates").child(role).push().setValue(cand);
            }
            @Override public void onAddStream(MediaStream stream) {
                if (stream.videoTracks.size() > 0) {
                    runOnUiThread(() -> stream.videoTracks.get(0).addSink(remoteVideo));
                }
            }
            @Override public void onIceConnectionChange(PeerConnection.IceConnectionState state) {
                if (state == PeerConnection.IceConnectionState.CONNECTED) {
                    runOnUiThread(() -> tvCallStatus.setText("Connected"));
                } else if (state == PeerConnection.IceConnectionState.DISCONNECTED || state == PeerConnection.IceConnectionState.FAILED) {
                    runOnUiThread(() -> endCall());
                }
            }
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {}
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}
            @Override public void onIceCandidatesRemoved(IceCandidate[] candidates) {}
            @Override public void onRemoveStream(MediaStream stream) {}
            @Override public void onDataChannel(DataChannel channel) {}
            @Override public void onRenegotiationNeeded() {}
            @Override public void onAddTrack(RtpReceiver receiver, MediaStream[] streams) {}
        });
        
        AudioSource audioSource = pcf.createAudioSource(new MediaConstraints());
        localAudioTrack = pcf.createAudioTrack("audio_track", audioSource);
        pc.addTrack(localAudioTrack);
        
        if (isVideoCall) {
            localVideo.setVisibility(View.VISIBLE);
            Camera2Enumerator enumerator = new Camera2Enumerator(this);
            String cameraName = null;
            for (String name : enumerator.getDeviceNames()) {
                if (enumerator.isFrontFacing(name)) {
                    cameraName = name;
                    break;
                }
            }
            if (cameraName == null && enumerator.getDeviceNames().length > 0) cameraName = enumerator.getDeviceNames()[0];
            
            videoCapturer = enumerator.createCapturer(cameraName, null);
            VideoSource videoSource = pcf.createVideoSource(videoCapturer.isScreencast());
            surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
            videoCapturer.initialize(surfaceTextureHelper, this, videoSource.getCapturerObserver());
            videoCapturer.startCapture(720, 1280, 30);
            localVideoTrack = pcf.createVideoTrack("video_track", videoSource);
            localVideoTrack.addSink(localVideo);
            pc.addTrack(localVideoTrack);
        } else {
            localVideo.setVisibility(View.GONE);
        }
    }
    
    private void endCall() {
        if (currentCallId != null) {
            db.child("calls").child(isCaller ? currentCallId : myUid).removeValue();
            
            Map<String, Object> history = new HashMap<>();
            history.put("with", currentChatName);
            history.put("type", isVideoCall ? "Video" : "Voice");
            history.put("duration", "0:00");
            history.put("timestamp", System.currentTimeMillis());
            db.child("users").child(myUid).child("callHistory").push().setValue(history);
        }
        
        if (pc != null) { pc.close(); pc = null; }
        if (videoCapturer != null) {
            try { videoCapturer.stopCapture(); } catch (Exception e) {}
            videoCapturer.dispose();
            videoCapturer = null;
        }
        if (pcf != null) { pcf.dispose(); pcf = null; }
        
        AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        am.setMode(AudioManager.MODE_NORMAL);
        am.setSpeakerphoneOn(false);
        
        localVideo.clearImage();
        remoteVideo.clearImage();
        currentCallId = null;
        showView(viewMain);
    }
    
    // ==================== ADAPTERS ====================
    class GenericAdapter extends RecyclerView.Adapter<GenericAdapter.ViewHolder> {
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView emoji, title, subtitle, badge;
            LinearLayout actions;
            Button accept, reject;
            ViewHolder(View v) {
                super(v);
                emoji = v.findViewById(R.id.tvListEmoji);
                title = v.findViewById(R.id.tvListTitle);
                subtitle = v.findViewById(R.id.tvListSubtitle);
                badge = v.findViewById(R.id.tvListBadge);
                actions = v.findViewById(R.id.actionsLayout);
                accept = v.findViewById(R.id.btnListAccept);
                reject = v.findViewById(R.id.btnListReject);
            }
        }
        
        @NonNull @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_list, parent, false));
        }
        
        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            ListItem item = mainList.get(position);
            holder.emoji.setText(item.emoji);
            holder.title.setText(item.title);
            holder.subtitle.setText(item.subtitle);
            
            if (item.type.equals("chat")) {
                holder.actions.setVisibility(View.GONE);
                if (item.unreadCount > 0) {
                    holder.badge.setVisibility(View.VISIBLE);
                    holder.badge.setText(String.valueOf(item.unreadCount));
                } else {
                    holder.badge.setVisibility(View.GONE);
                }
                holder.itemView.setOnClickListener(v -> openChat(item.uid, item.title, item.emoji));
            } else if (item.type.equals("request")) {
                holder.actions.setVisibility(View.VISIBLE);
                holder.badge.setVisibility(View.GONE);
                holder.accept.setOnClickListener(v -> {
                    db.child("friends").child(myUid).child(item.uid).setValue(true);
                    db.child("friends").child(item.uid).child(myUid).setValue(true);
                    db.child("friendRequests").child(myUid).child(item.uid).removeValue();
                });
                holder.reject.setOnClickListener(v -> db.child("friendRequests").child(myUid).child(item.uid).removeValue());
            }
        }
        
        @Override public int getItemCount() { return mainList.size(); }
    }
    
    class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.ViewHolder> {
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView message;
            ViewHolder(View v) { super(v); message = v.findViewById(R.id.tvMessage); }
        }
        
        @NonNull @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_message, parent, false));
        }
        
        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Message msg = messageList.get(position);
            boolean isMe = msg.senderId.equals(myUid);
            holder.message.setText(msg.text);
            
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) holder.message.getLayoutParams();
            if (isMe) {
                holder.message.setBackgroundResource(R.drawable.msg_out_bg);
                holder.message.setTextColor(getColor(R.color.white));
                params.gravity = android.view.Gravity.END;
            } else {
                holder.message.setBackgroundResource(R.drawable.msg_in_bg);
                holder.message.setTextColor(getColor(R.color.black));
                params.gravity = android.view.Gravity.START;
            }
            holder.message.setLayoutParams(params);
        }
        
        @Override public int getItemCount() { return messageList.size(); }
    }
    
    class SimpleSdpObserver implements SdpObserver {
        @Override public void onCreateSuccess(SessionDescription sdp) {}
        @Override public void onSetSuccess() {}
        @Override public void onCreateFailure(String s) {}
        @Override public void onSetFailure(String s) {}
    }
}
EOF

# ==================== BUILD ====================
echo "📦 Setting up Gradle wrapper..."
wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip
unzip -q -o gradle-8.2-bin.zip -d /opt/gradle 2>/dev/null || unzip -q -o gradle-8.2-bin.zip -d $PWD/gradle_local

if [ -f "/opt/gradle/gradle-8.2/bin/gradle" ]; then
    /opt/gradle/gradle-8.2/bin/gradle wrapper --gradle-version 8.2
elif [ -f "$PWD/gradle_local/gradle-8.2/bin/gradle" ]; then
    $PWD/gradle_local/gradle-8.2/bin/gradle wrapper --gradle-version 8.2
else
    echo "⚠️ Gradle not found, downloading..."
    wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip
    unzip -q gradle-8.2-bin.zip
    ./gradle-8.2/bin/gradle wrapper --gradle-version 8.2
fi

chmod +x gradlew

echo "🔨 Building APK..."
./gradlew clean assembleRelease

echo ""
echo "✅ BUILD COMPLETE!"
echo "📱 APK Location: $(pwd)/app/build/outputs/apk/release/"
ls -la app/build/outputs/apk/release/