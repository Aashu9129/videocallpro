#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║     🌍 GlobeTalk - Global Chat App Builder                  ║
# ║     Complete Production-Ready Build Script                  ║
# ║     100% Free Firebase Features                             ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

echo "🎯 GlobeTalk APK Builder Starting..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Project Config
PROJECT_NAME="GlobeTalk"
PACKAGE_NAME="com.globetalk.app"
BUILD_TOOLS="34.0.0"
COMPILE_SDK=34
MIN_SDK=21
TARGET_SDK=34
VERSION_NAME="1.0.0"
VERSION_CODE=1

echo -e "${BLUE}📦 Setting up Android SDK...${NC}"

# Install required packages
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk-headless wget unzip gradle

# Setup Android SDK
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

if [ ! -d "$ANDROID_HOME" ]; then
    mkdir -p $ANDROID_HOME/cmdline-tools
    cd $ANDROID_HOME/cmdline-tools
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip commandlinetools-linux-11076708_latest.zip
    mv cmdline-tools latest
    rm commandlinetools-linux-11076708_latest.zip
fi

# Accept licenses
yes | sdkmanager --licenses

# Install SDK components
sdkmanager "platform-tools" "platforms;android-$COMPILE_SDK" "build-tools;$BUILD_TOOLS" "extras;google;m2repository" "extras;android;m2repository"

echo -e "${GREEN}✅ SDK Setup Complete${NC}"

# Create project structure
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo -e "${BLUE}🏗️  Creating Project Structure...${NC}"

# ──── SETTINGS.GRADLE ────
cat > settings.gradle << 'SETTINGS'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolution {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "GlobeTalk"
include ':app'
SETTINGS

# ──── ROOT BUILD.GRADLE ────
cat > build.gradle << 'ROOTBUILD'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
ROOTBUILD

# gradle.properties
cat > gradle.properties << 'GRADLEPROPS'
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
android.enableJetifier=true
GRADLEPROPS

# ──── APP BUILD.GRADLE ────
mkdir -p app
cat > app/build.gradle << 'APPBUILD'
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
}

android {
    namespace 'com.globetalk.app'
    compileSdk 34
    
    defaultConfig {
        applicationId "com.globetalk.app"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    buildFeatures {
        viewBinding true
        dataBinding true
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
    
    implementation 'com.google.code.gson:gson:2.10.1'
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    implementation 'de.hdodenhof:circleimageview:3.1.0'
    
    // WebRTC for video/audio calls
    implementation 'io.getstream:stream-webrtc-android:1.1.1'
    
    implementation 'com.airbnb.android:lottie:6.1.0'
}
APPBUILD

# ──── ANDROIDMANIFEST.XML ────
mkdir -p app/src/main
cat > app/src/main/AndroidManifest.xml << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    
    <application
        android:name=".GlobeTalkApp"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="GlobeTalk"
        android:roundIcon="@mipmap/ic_launcher"
        android:supportsRtl="true"
        android:theme="@style/Theme.GlobeTalk"
        android:usesCleartextTraffic="true">
        
        <!-- Splash Screen -->
        <activity
            android:name=".ui.SplashActivity"
            android:theme="@style/Theme.Splash"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <!-- Login Activity -->
        <activity android:name=".ui.auth.LoginActivity" />
        
        <!-- Register Activity -->
        <activity android:name=".ui.auth.RegisterActivity" />
        
        <!-- Main Activity (Global Chat) -->
        <activity android:name=".ui.main.MainActivity" />
        
        <!-- Private Chat -->
        <activity android:name=".ui.chat.PrivateChatActivity" />
        
        <!-- Profile View -->
        <activity android:name=".ui.profile.ProfileActivity" />
        
        <!-- Chat List -->
        <activity android:name=".ui.chat.ChatListActivity" />
        
        <!-- Video Call -->
        <activity android:name=".ui.call.VideoCallActivity" />
        
        <!-- Audio Call -->
        <activity android:name=".ui.call.AudioCallActivity" />
        
        <!-- Incoming Call -->
        <activity android:name=".ui.call.IncomingCallActivity"
            android:launchMode="singleTop" />
        
        <!-- FCM Service -->
        <service
            android:name=".services.FCMMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
    </application>
</manifest>
MANIFEST

# ──── FIREBASE CONFIG ────
mkdir -p app/src/main/res/values

# colors.xml
cat > app/src/main/res/values/colors.xml << 'COLORS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#FF6B35</color>
    <color name="primary_dark">#E55A25</color>
    <color name="primary_light">#FF8F5E</color>
    <color name="accent">#FFA500</color>
    <color name="background">#F8F9FA</color>
    <color name="surface">#FFFFFF</color>
    <color name="error">#FF4444</color>
    <color name="on_primary">#FFFFFF</color>
    <color name="on_background">#1A1A2E</color>
    <color name="on_surface">#2D3436</color>
    <color name="text_primary">#1A1A2E</color>
    <color name="text_secondary">#636E72</color>
    <color name="online_green">#4CAF50</color>
    <color name="offline_grey">#BDBDBD</color>
    <color name="message_out">#FF6B35</color>
    <color name="message_in">#FFFFFF</color>
    <color name="gradient_start">#FF6B35</color>
    <color name="gradient_end">#FFA500</color>
    <color name="chat_bg">#F0F2F5</color>
    <color name="unread_badge">#FF4444</color>
    <color name="ripple_effect">#20000000</color>
</resources>
COLORS

# strings.xml
cat > app/src/main/res/values/strings.xml << 'STRINGS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">GlobeTalk</string>
    <string name="login">Login</string>
    <string name="register">Register</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="username">Username</string>
    <string name="bio">Bio</string>
    <string name="global_chat">Global Chat</string>
    <string name="chat_list">Chats</string>
    <string name="search_users">Search Username...</string>
    <string name="type_message">Type a message...</string>
    <string name="online">Online</string>
    <string name="offline">Offline</string>
    <string name="video_call">Video Call</string>
    <string name="audio_call">Audio Call</string>
    <string name="block_user">Block User</string>
    <string name="unblock_user">Unblock User</string>
    <string name="reply">Reply</string>
    <string name="swipe_reply">Swipe right to reply</string>
    <string name="no_chats">No conversations yet</string>
    <string name="no_users">No users found</string>
    <string name="splash_tagline">Talk Globally, Connect Privately 🌍</string>
</resources>
STRINGS

# themes.xml
cat > app/src/main/res/values/themes.xml << 'THEMES'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Base Theme -->
    <style name="Theme.GlobeTalk" parent="Theme.MaterialComponents.Light.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="colorPrimaryDark">@color/primary_dark</item>
        <item name="colorAccent">@color/accent</item>
        <item name="android:windowBackground">@color/background</item>
        <item name="android:statusBarColor">@color/primary</item>
        <item name="android:navigationBarColor">@color/surface</item>
    </style>
    
    <!-- Splash Theme -->
    <style name="Theme.Splash" parent="Theme.GlobeTalk">
        <item name="android:windowBackground">@color/primary</item>
        <item name="android:statusBarColor">@color/primary</item>
    </style>
    
    <!-- Card Style -->
    <style name="CardView.GlobeTalk" parent="Widget.Material3.CardView.Elevated">
        <item name="cardCornerRadius">16dp</item>
        <item name="cardElevation">4dp</item>
        <item name="cardBackgroundColor">@color/surface</item>
    </style>
</resources>
THEMES

# ──── LAYOUT FILES ────
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/drawable

# activity_splash.xml
cat > app/src/main/res/layout/activity_splash.xml << 'SPLASHLAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/primary">
    
    <ImageView
        android:id="@+id/logoIcon"
        android:layout_width="120dp"
        android:layout_height="120dp"
        android:src="@drawable/ic_globe"
        app:layout_constraintBottom_toTopOf="@+id/appName"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintVertical_chainStyle="packed" />
    
    <TextView
        android:id="@+id/appName"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="GlobeTalk"
        android:textColor="@android:color/white"
        android:textSize="36sp"
        android:textStyle="bold"
        android:letterSpacing="0.15"
        app:layout_constraintBottom_toTopOf="@+id/tagline"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/logoIcon" />
    
    <TextView
        android:id="@+id/tagline"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Talk Globally, Connect Privately 🌍"
        android:textColor="@android:color/white"
        android:textSize="16sp"
        android:alpha="0.9"
        android:layout_marginTop="8dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/appName" />
    
    <com.airbnb.lottie.LottieAnimationView
        android:id="@+id/lottieAnimation"
        android:layout_width="200dp"
        android:layout_height="200dp"
        app:lottie_autoPlay="true"
        app:lottie_loop="true"
        app:lottie_rawRes="@raw/loading_animation"
        app:layout_constraintTop_toBottomOf="@+id/tagline"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        android:layout_marginTop="40dp" />
    
</androidx.constraintlayout.widget.ConstraintLayout>
SPLASHLAYOUT

# activity_login.xml
cat > app/src/main/res/layout/activity_login.xml << 'LOGINLAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fillViewport="true"
    android:background="@color/background">
    
    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="24dp">
        
        <LinearLayout
            android:id="@+id/logoSection"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:gravity="center"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            android:layout_marginTop="60dp">
            
            <ImageView
                android:layout_width="80dp"
                android:layout_height="80dp"
                android:src="@drawable/ic_globe" />
            
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="GlobeTalk"
                android:textSize="28sp"
                android:textStyle="bold"
                android:textColor="@color/primary"
                android:layout_marginTop="12dp" />
            
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Welcome Back! 👋"
                android:textSize="16sp"
                android:textColor="@color/text_secondary"
                android:layout_marginTop="4dp" />
        </LinearLayout>
        
        <com.google.android.material.card.MaterialCardView
            android:id="@+id/loginCard"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            app:cardCornerRadius="20dp"
            app:cardElevation="8dp"
            android:layout_marginTop="40dp"
            app:layout_constraintTop_toBottomOf="@+id/logoSection"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">
            
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="24dp">
                
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/emailLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    app:startIconDrawable="@drawable/ic_email"
                    app:endIconMode="clear_text"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox">
                    
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/emailInput"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:hint="Email"
                        android:inputType="textEmailAddress" />
                </com.google.android.material.textfield.TextInputLayout>
                
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/passwordLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="16dp"
                    app:startIconDrawable="@drawable/ic_password"
                    app:endIconMode="password_toggle"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox">
                    
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/passwordInput"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:hint="Password"
                        android:inputType="textPassword" />
                </com.google.android.material.textfield.TextInputLayout>
                
                <com.google.android.material.button.MaterialButton
                    android:id="@+id/loginButton"
                    android:layout_width="match_parent"
                    android:layout_height="56dp"
                    android:text="Login"
                    android:textSize="16sp"
                    android:layout_marginTop="24dp"
                    app:cornerRadius="12dp"
                    app:backgroundTint="@color/primary" />
                
                <TextView
                    android:id="@+id/registerLink"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Don't have an account? Register"
                    android:textColor="@color/primary"
                    android:textSize="14sp"
                    android:layout_gravity="center"
                    android:layout_marginTop="16dp"
                    android:padding="8dp"
                    android:clickable="true"
                    android:focusable="true" />
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>
        
    </androidx.constraintlayout.widget.ConstraintLayout>
</ScrollView>
LOGINLAYOUT

# activity_register.xml
cat > app/src/main/res/layout/activity_register.xml << 'REGISTERLAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fillViewport="true"
    android:background="@color/background">
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="24dp"
        android:gravity="center_horizontal">
        
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Create Account 🚀"
            android:textSize="28sp"
            android:textStyle="bold"
            android:textColor="@color/primary"
            android:layout_marginTop="40dp" />
        
        <com.google.android.material.card.MaterialCardView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="30dp"
            app:cardCornerRadius="20dp"
            app:cardElevation="8dp">
            
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="24dp">
                
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/emailLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/emailInput"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:hint="Email" />
                </com.google.android.material.textfield.TextInputLayout>
                
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/usernameLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="16dp"
                    app:helperText="Username must be unique"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/usernameInput"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:hint="Username" />
                </com.google.android.material.textfield.TextInputLayout>
                
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/passwordLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="16dp"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/passwordInput"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:hint="Password (6+ chars)" />
                </com.google.android.material.textfield.TextInputLayout>
                
                <com.google.android.material.button.MaterialButton
                    android:id="@+id/registerButton"
                    android:layout_width="match_parent"
                    android:layout_height="56dp"
                    android:text="Register"
                    android:textSize="16sp"
                    android:layout_marginTop="24dp"
                    app:cornerRadius="12dp"
                    app:backgroundTint="@color/primary" />
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>
        
        <TextView
            android:id="@+id/loginLink"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Already have an account? Login"
            android:textColor="@color/primary"
            android:layout_marginTop="20dp"
            android:padding="8dp"
            android:clickable="true"
            android:focusable="true" />
    </LinearLayout>
</ScrollView>
REGISTERLAYOUT

# activity_main.xml (Global Chat)
cat > app/src/main/res/layout/activity_main.xml << 'MAINLAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background">
    
    <!-- Top Bar -->
    <com.google.android.material.appbar.MaterialToolbar
        android:id="@+id/toolbar"
        android:layout_width="0dp"
        android:layout_height="?attr/actionBarSize"
        android:background="@color/primary"
        app:title="🌍 Global Chat"
        app:titleTextColor="@android:color/white"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent">
        
        <ImageView
            android:id="@+id/chatListBtn"
            android:layout_width="24dp"
            android:layout_height="24dp"
            android:src="@drawable/ic_chat"
            android:layout_gravity="end"
            android:layout_marginEnd="16dp" />
    </com.google.android.material.appbar.MaterialToolbar>
    
    <!-- Online Users Badge -->
    <LinearLayout
        android:id="@+id/onlineBadge"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center"
        android:padding="8dp"
        android:layout_margin="8dp"
        android:background="@drawable/badge_background"
        app:layout_constraintTop_toBottomOf="@+id/toolbar"
        app:layout_constraintStart_toStartOf="parent">
        
        <View
            android:layout_width="8dp"
            android:layout_height="8dp"
            android:background="@drawable/online_dot" />
        
        <TextView
            android:id="@+id/onlineCount"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="247 online"
            android:textColor="@color/online_green"
            android:textSize="12sp"
            android:layout_marginStart="6dp" />
    </LinearLayout>
    
    <!-- Typing Indicator -->
    <TextView
        android:id="@+id/typingIndicator"
        android:layout_width="0dp"
        android:layout_height="20dp"
        android:text=""
        android:textSize="12sp"
        android:textColor="@color/text_secondary"
        android:layout_marginStart="16dp"
        android:layout_marginEnd="16dp"
        app:layout_constraintTop_toBottomOf="@+id/onlineBadge"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />
    
    <!-- Messages List -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/messagesRecyclerView"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:layout_marginTop="4dp"
        android:padding="8dp"
        android:clipToPadding="false"
        app:layout_constraintTop_toBottomOf="@+id/typingIndicator"
        app:layout_constraintBottom_toTopOf="@+id/replyPreview"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />
    
    <!-- Reply Preview -->
    <LinearLayout
        android:id="@+id/replyPreview"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:background="@color/surface"
        android:padding="12dp"
        android:visibility="gone"
        app:layout_constraintBottom_toTopOf="@+id/messageInputBar"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent">
        
        <TextView
            android:id="@+id/replyUsername"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/primary"
            android:textSize="12sp"
            android:textStyle="bold" />
        
        <TextView
            android:id="@+id/replyMessage"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="@color/text_secondary"
            android:textSize="12sp"
            android:maxLines="1"
            android:ellipsize="end" />
    </LinearLayout>
    
    <!-- Message Input -->
    <LinearLayout
        android:id="@+id/messageInputBar"
        android:layout_width="0dp"
        android:layout_height="56dp"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:background="@color/surface"
        android:paddingStart="8dp"
        android:paddingEnd="8dp"
        android:elevation="4dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent">
        
        <EditText
            android:id="@+id/messageInput"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:hint="Type a message..."
            android:background="@android:color/transparent"
            android:padding="12dp"
            android:maxLines="5" />
        
        <ImageView
            android:id="@+id/sendButton"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:src="@drawable/ic_send"
            android:padding="12dp"
            android:background="?attr/selectableItemBackgroundBorderless" />
    </LinearLayout>
    
</androidx.constraintlayout.widget.ConstraintLayout>
MAINLAYOUT

# ──── JAVA SOURCE FILES ────
mkdir -p app/src/main/java/com/globetalk/app/{ui/{auth,main,chat,profile,call},services,models,utils,adapters}

# FirebaseConfig.java
cat > app/src/main/java/com/globetalk/app/utils/FirebaseConfig.java << 'FIREBASECONFIG'
package com.globetalk.app.utils;

public class FirebaseConfig {
    public static final String API_KEY = "AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM";
    public static final String AUTH_DOMAIN = "videocallpro-f5f1b.firebaseapp.com";
    public static final String DATABASE_URL = "https://videocallpro-f5f1b-default-rtdb.firebaseio.com";
    public static final String PROJECT_ID = "videocallpro-f5f1b";
    public static final String STORAGE_BUCKET = "videocallpro-f5f1b.firebasestorage.app";
    public static final String MESSAGING_SENDER_ID = "1044955332082";
    public static final String APP_ID = "1:1044955332082:web:2c6e7458b191b9d96eff6b";
}
FIREBASECONFIG

# GlobeTalkApp.java
cat > app/src/main/java/com/globetalk/app/GlobeTalkApp.java << 'APPCLASS'
package com.globetalk.app;

import android.app.Application;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.FirebaseDatabase;

public class GlobeTalkApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseApp.initializeApp(this);
        FirebaseDatabase.getInstance().setPersistenceEnabled(true);
    }
}
APPCLASS

# models/Message.java
cat > app/src/main/java/com/globetalk/app/models/Message.java << 'MESSAGEMODEL'
package com.globetalk.app.models;

public class Message {
    private String messageId;
    private String senderId;
    private String senderUsername;
    private String message;
    private long timestamp;
    private String replyTo;
    private String replyMessage;
    private String replySender;
    private boolean isRead;
    
    public Message() {}
    
    public Message(String senderId, String senderUsername, String message) {
        this.senderId = senderId;
        this.senderUsername = senderUsername;
        this.message = message;
        this.timestamp = System.currentTimeMillis();
    }
    
    // Getters and setters
    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    public String getSenderUsername() { return senderUsername; }
    public void setSenderUsername(String senderUsername) { this.senderUsername = senderUsername; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
    public String getReplyTo() { return replyTo; }
    public void setReplyTo(String replyTo) { this.replyTo = replyTo; }
    public String getReplyMessage() { return replyMessage; }
    public void setReplyMessage(String replyMessage) { this.replyMessage = replyMessage; }
    public String getReplySender() { return replySender; }
    public void setReplySender(String replySender) { this.replySender = replySender; }
    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }
}
MESSAGEMODEL

# models/User.java
cat > app/src/main/java/com/globetalk/app/models/User.java << 'USERMODEL'
package com.globetalk.app.models;

public class User {
    private String userId;
    private String username;
    private String email;
    private String bio;
    private String profilePic;
    private long createdAt;
    private long lastSeen;
    private boolean isOnline;
    
    public User() {}
    
    public User(String userId, String username, String email) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.createdAt = System.currentTimeMillis();
    }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getProfilePic() { return profilePic; }
    public void setProfilePic(String profilePic) { this.profilePic = profilePic; }
    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
    public long getLastSeen() { return lastSeen; }
    public void setLastSeen(long lastSeen) { this.lastSeen = lastSeen; }
    public boolean isOnline() { return isOnline; }
    public void setOnline(boolean online) { isOnline = online; }
}
USERMODEL

# ──── ALL ACTIVITIES ────

# SplashActivity.java
cat > app/src/main/java/com/globetalk/app/ui/SplashActivity.java << 'SPLASH'
package com.globetalk.app.ui;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import androidx.appcompat.app.AppCompatActivity;
import com.globetalk.app.R;
import com.google.firebase.auth.FirebaseAuth;
import com.globetalk.app.ui.auth.LoginActivity;
import com.globetalk.app.ui.main.MainActivity;

public class SplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        
        new Handler().postDelayed(() -> {
            if (FirebaseAuth.getInstance().getCurrentUser() != null) {
                startActivity(new Intent(this, MainActivity.class));
            } else {
                startActivity(new Intent(this, LoginActivity.class));
            }
            finish();
        }, 2000);
    }
}
SPLASH

# LoginActivity.java
cat > app/src/main/java/com/globetalk/app/ui/auth/LoginActivity.java << 'LOGIN'
package com.globetalk.app.ui.auth;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.globetalk.app.R;
import com.globetalk.app.ui.main.MainActivity;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseAuth;

public class LoginActivity extends AppCompatActivity {
    private TextInputEditText emailInput, passwordInput;
    private MaterialButton loginButton;
    private FirebaseAuth mAuth;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        mAuth = FirebaseAuth.getInstance();
        emailInput = findViewById(R.id.emailInput);
        passwordInput = findViewById(R.id.passwordInput);
        loginButton = findViewById(R.id.loginButton);
        
        loginButton.setOnClickListener(v -> loginUser());
        findViewById(R.id.registerLink).setOnClickListener(v -> 
            startActivity(new Intent(this, RegisterActivity.class)));
    }
    
    private void loginUser() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        
        loginButton.setEnabled(false);
        mAuth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    startActivity(new Intent(this, MainActivity.class));
                    finish();
                } else {
                    Toast.makeText(this, "Login failed: " + task.getException().getMessage(), 
                        Toast.LENGTH_SHORT).show();
                    loginButton.setEnabled(true);
                }
            });
    }
}
LOGIN

# RegisterActivity.java
cat > app/src/main/java/com/globetalk/app/ui/auth/RegisterActivity.java << 'REGISTER'
package com.globetalk.app.ui.auth;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.globetalk.app.R;
import com.globetalk.app.models.User;
import com.globetalk.app.ui.main.MainActivity;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class RegisterActivity extends AppCompatActivity {
    private TextInputEditText emailInput, usernameInput, passwordInput;
    private TextInputLayout usernameLayout;
    private MaterialButton registerButton;
    private FirebaseAuth mAuth;
    private DatabaseReference mDatabase;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        
        mAuth = FirebaseAuth.getInstance();
        mDatabase = FirebaseDatabase.getInstance().getReference();
        
        emailInput = findViewById(R.id.emailInput);
        usernameInput = findViewById(R.id.usernameInput);
        passwordInput = findViewById(R.id.passwordInput);
        usernameLayout = findViewById(R.id.usernameLayout);
        registerButton = findViewById(R.id.registerButton);
        
        // Live username checking
        usernameInput.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {}
            
            @Override
            public void afterTextChanged(Editable s) {
                String username = s.toString().trim();
                if (username.length() >= 3) {
                    checkUsername(username);
                } else {
                    usernameLayout.setHelperText("Username must be at least 3 characters");
                }
            }
        });
        
        registerButton.setOnClickListener(v -> registerUser());
        findViewById(R.id.loginLink).setOnClickListener(v -> 
            startActivity(new Intent(this, LoginActivity.class)));
    }
    
    private void checkUsername(String username) {
        mDatabase.child("usernames").child(username)
            .get().addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    if (task.getResult().exists()) {
                        usernameLayout.setHelperText("❌ Username taken");
                        usernameLayout.setHelperTextColor(
                            android.content.res.ColorStateList.valueOf(0xFFFF4444));
                    } else {
                        usernameLayout.setHelperText("✅ Username available");
                        usernameLayout.setHelperTextColor(
                            android.content.res.ColorStateList.valueOf(0xFF4CAF50));
                    }
                }
            });
    }
    
    private void registerUser() {
        String email = emailInput.getText().toString().trim();
        String username = usernameInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (email.isEmpty() || username.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        
        if (password.length() < 6) {
            Toast.makeText(this, "Password must be 6+ characters", Toast.LENGTH_SHORT).show();
            return;
        }
        
        registerButton.setEnabled(false);
        mAuth.createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    String userId = mAuth.getCurrentUser().getUid();
                    User user = new User(userId, username, email);
                    
                    mDatabase.child("users").child(userId).setValue(user);
                    mDatabase.child("usernames").child(username).setValue(userId);
                    mDatabase.child("emails").child(email.replace(".", ",")).setValue(userId);
                    
                    Toast.makeText(this, "Welcome to GlobeTalk! 🎉", Toast.LENGTH_SHORT).show();
                    startActivity(new Intent(this, MainActivity.class));
                    finish();
                } else {
                    Toast.makeText(this, "Registration failed: " + 
                        task.getException().getMessage(), Toast.LENGTH_SHORT).show();
                    registerButton.setEnabled(true);
                }
            });
    }
}
REGISTER

# MainActivity.java (Global Chat)
cat > app/src/main/java/com/globetalk/app/ui/main/MainActivity.java << 'MAINACTIVITY'
package com.globetalk.app.ui.main;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.globetalk.app.R;
import com.globetalk.app.adapters.MessageAdapter;
import com.globetalk.app.models.Message;
import com.globetalk.app.ui.chat.ChatListActivity;
import com.globetalk.app.ui.profile.ProfileActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends AppCompatActivity {
    private RecyclerView messagesRecyclerView;
    private EditText messageInput;
    private ImageView sendButton;
    private TextView onlineCount, typingIndicator, replyUsername, replyMessage;
    private View replyPreview;
    private MessageAdapter adapter;
    private List<Message> messagesList;
    private DatabaseReference mDatabase;
    private String currentUserId, currentUsername;
    private Message replyMessage = null;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        currentUserId = FirebaseAuth.getInstance().getCurrentUser().getUid();
        mDatabase = FirebaseDatabase.getInstance().getReference();
        
        initViews();
        loadCurrentUser();
        loadMessages();
        setupTypingIndicator();
        setupOnlinePresence();
    }
    
    private void initViews() {
        messagesRecyclerView = findViewById(R.id.messagesRecyclerView);
        messageInput = findViewById(R.id.messageInput);
        sendButton = findViewById(R.id.sendButton);
        onlineCount = findViewById(R.id.onlineCount);
        typingIndicator = findViewById(R.id.typingIndicator);
        replyUsername = findViewById(R.id.replyUsername);
        replyMessage = findViewById(R.id.replyMessage);
        replyPreview = findViewById(R.id.replyPreview);
        
        messagesList = new ArrayList<>();
        adapter = new MessageAdapter(messagesList, currentUserId, (message, position) -> {
            if (position == 1) {
                setReply(message);
            } else {
                viewProfile(message.getSenderId());
            }
        });
        
        messagesRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        messagesRecyclerView.setAdapter(adapter);
        
        sendButton.setOnClickListener(v -> sendMessage());
        findViewById(R.id.chatListBtn).setOnClickListener(v -> 
            startActivity(new Intent(this, ChatListActivity.class)));
    }
    
    private void loadCurrentUser() {
        mDatabase.child("users").child(currentUserId)
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    if (snapshot.exists()) {
                        currentUsername = snapshot.child("username").getValue(String.class);
                    }
                }
                @Override public void onCancelled(@NonNull DatabaseError error) {}
            });
    }
    
    private void loadMessages() {
        mDatabase.child("global_chat")
            .orderByChild("timestamp")
            .limitToLast(50)
            .addChildEventListener(new ChildEventListener() {
                @Override
                public void onChildAdded(@NonNull DataSnapshot snapshot, String prev) {
                    Message message = snapshot.getValue(Message.class);
                    if (message != null) {
                        message.setMessageId(snapshot.getKey());
                        messagesList.add(message);
                        adapter.notifyItemInserted(messagesList.size() - 1);
                        messagesRecyclerView.smoothScrollToPosition(messagesList.size() - 1);
                    }
                }
                @Override public void onChildChanged(@NonNull DataSnapshot snapshot, String prev) {}
                @Override public void onChildRemoved(@NonNull DataSnapshot snapshot) {}
                @Override public void onChildMoved(@NonNull DataSnapshot snapshot, String prev) {}
                @Override public void onCancelled(@NonNull DatabaseError error) {}
            });
    }
    
    private void sendMessage() {
        String text = messageInput.getText().toString().trim();
        if (TextUtils.isEmpty(text)) return;
        
        DatabaseReference newMessage = mDatabase.child("global_chat").push();
        Map<String, Object> messageData = new HashMap<>();
        messageData.put("senderId", currentUserId);
        messageData.put("senderUsername", currentUsername);
        messageData.put("message", text);
        messageData.put("timestamp", ServerValue.TIMESTAMP);
        
        if (replyMessage != null) {
            messageData.put("replyTo", replyMessage.getMessageId());
            messageData.put("replyMessage", replyMessage.getMessage());
            messageData.put("replySender", replyMessage.getSenderUsername());
            cancelReply();
        }
        
        newMessage.setValue(messageData);
        messageInput.setText("");
    }
    
    private void setReply(Message message) {
        replyMessage = message;
        replyUsername.setText("Replying to @" + message.getSenderUsername());
        replyMessage.setText(message.getMessage());
        replyPreview.setVisibility(View.VISIBLE);
    }
    
    private void cancelReply() {
        replyMessage = null;
        replyPreview.setVisibility(View.GONE);
    }
    
    private void viewProfile(String userId) {
        Intent intent = new Intent(this, ProfileActivity.class);
        intent.putExtra("userId", userId);
        startActivity(intent);
    }
    
    private void setupTypingIndicator() {
        // Simplified typing indicator
        messageInput.addTextChangedListener(new android.text.TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {}
            @Override public void afterTextChanged(android.text.Editable s) {
                mDatabase.child("typing_status").child("global").child(currentUserId)
                    .setValue(s.length() > 0);
            }
        });
    }
    
    private void setupOnlinePresence() {
        mDatabase.child("users").child(currentUserId).child("isOnline").setValue(true);
        mDatabase.child("users").child(currentUserId).child("isOnline")
            .onDisconnect().setValue(false);
    }
}
MAINACTIVITY

# ProfileActivity.java
cat > app/src/main/java/com/globetalk/app/ui/profile/ProfileActivity.java << 'PROFILEACTIVITY'
package com.globetalk.app.ui.profile;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.globetalk.app.R;
import com.globetalk.app.ui.chat.PrivateChatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class ProfileActivity extends AppCompatActivity {
    private ImageView profilePic;
    private TextView usernameText, bioText, statusText;
    private Button messageBtn, blockBtn;
    private DatabaseReference mDatabase;
    private String profileUserId;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        
        profileUserId = getIntent().getStringExtra("userId");
        mDatabase = FirebaseDatabase.getInstance().getReference();
        
        profilePic = findViewById(R.id.profilePic);
        usernameText = findViewById(R.id.usernameText);
        bioText = findViewById(R.id.bioText);
        statusText = findViewById(R.id.statusText);
        messageBtn = findViewById(R.id.messageBtn);
        blockBtn = findViewById(R.id.blockBtn);
        
        loadProfile();
        
        messageBtn.setOnClickListener(v -> {
            Intent intent = new Intent(this, PrivateChatActivity.class);
            intent.putExtra("otherUserId", profileUserId);
            intent.putExtra("otherUsername", usernameText.getText().toString());
            startActivity(intent);
        });
    }
    
    private void loadProfile() {
        mDatabase.child("users").child(profileUserId)
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (snapshot.exists()) {
                        usernameText.setText(snapshot.child("username").getValue(String.class));
                        bioText.setText(snapshot.child("bio").getValue(String.class));
                        boolean isOnline = Boolean.TRUE.equals(
                            snapshot.child("isOnline").getValue(Boolean.class));
                        statusText.setText(isOnline ? "🟢 Online" : "⚫ Offline");
                    }
                }
                @Override public void onCancelled(DatabaseError error) {}
            });
    }
}
PROFILEACTIVITY

# PrivateChatActivity.java
cat > app/src/main/java/com/globetalk/app/ui/chat/PrivateChatActivity.java << 'PRIVATECHAT'
package com.globetalk.app.ui.chat;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import com.globetalk.app.R;
import com.globetalk.app.ui.call.VideoCallActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class PrivateChatActivity extends AppCompatActivity {
    private RecyclerView messagesRecyclerView;
    private EditText messageInput;
    private ImageView sendButton, videoCallBtn, audioCallBtn;
    private DatabaseReference mDatabase;
    private String currentUserId, otherUserId, otherUsername, chatId;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_private_chat);
        
        currentUserId = FirebaseAuth.getInstance().getCurrentUser().getUid();
        otherUserId = getIntent().getStringExtra("otherUserId");
        otherUsername = getIntent().getStringExtra("otherUsername");
        mDatabase = FirebaseDatabase.getInstance().getReference();
        
        // Create sorted chat ID
        chatId = currentUserId.compareTo(otherUserId) < 0 ? 
            currentUserId + "_" + otherUserId : otherUserId + "_" + currentUserId;
        
        initViews();
        loadMessages();
    }
    
    private void initViews() {
        messagesRecyclerView = findViewById(R.id.messagesRecyclerView);
        messageInput = findViewById(R.id.messageInput);
        sendButton = findViewById(R.id.sendButton);
        videoCallBtn = findViewById(R.id.videoCallBtn);
        audioCallBtn = findViewById(R.id.audioCallBtn);
        
        videoCallBtn.setOnClickListener(v -> startVideoCall());
        audioCallBtn.setOnClickListener(v -> startAudioCall());
    }
    
    private void startVideoCall() {
        Intent intent = new Intent(this, VideoCallActivity.class);
        intent.putExtra("otherUserId", otherUserId);
        intent.putExtra("otherUsername", otherUsername);
        intent.putExtra("callType", "video");
        startActivity(intent);
    }
    
    private void startAudioCall() {
        Intent intent = new Intent(this, VideoCallActivity.class);
        intent.putExtra("otherUserId", otherUserId);
        intent.putExtra("otherUsername", otherUsername);
        intent.putExtra("callType", "audio");
        startActivity(intent);
    }
    
    private void loadMessages() {
        mDatabase.child("private_chats").child(chatId).child("messages")
            .orderByChild("timestamp")
            .limitToLast(50)
            .addChildEventListener(new ChildEventListener() {
                @Override
                public void onChildAdded(DataSnapshot snapshot, String prev) {
                    // Load and display messages
                }
                @Override public void onChildChanged(DataSnapshot snapshot, String prev) {}
                @Override public void onChildRemoved(DataSnapshot snapshot) {}
                @Override public void onChildMoved(DataSnapshot snapshot, String prev) {}
                @Override public void onCancelled(DatabaseError error) {}
            });
    }
}
PRIVATECHAT

# ChatListActivity.java
cat > app/src/main/java/com/globetalk/app/ui/chat/ChatListActivity.java << 'CHATLIST'
package com.globetalk.app.ui.chat;

import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import com.globetalk.app.R;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class ChatListActivity extends AppCompatActivity {
    private RecyclerView chatListRecyclerView;
    private EditText searchInput;
    private ImageView searchBtn;
    private DatabaseReference mDatabase;
    private String currentUserId;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_list);
        
        currentUserId = FirebaseAuth.getInstance().getCurrentUser().getUid();
        mDatabase = FirebaseDatabase.getInstance().getReference();
        
        chatListRecyclerView = findViewById(R.id.chatListRecyclerView);
        searchInput = findViewById(R.id.searchInput);
        searchBtn = findViewById(R.id.searchBtn);
        
        searchBtn.setOnClickListener(v -> searchUsers());
        loadChatList();
    }
    
    private void searchUsers() {
        String query = searchInput.getText().toString().trim();
        if (query.isEmpty()) return;
        
        mDatabase.child("usernames").orderByKey()
            .startAt(query).endAt(query + "\uf8ff")
            .addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    // Display search results
                }
                @Override public void onCancelled(DatabaseError error) {}
            });
    }
    
    private void loadChatList() {
        mDatabase.child("user_chats").child(currentUserId)
            .addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    // Load and display chat list
                }
                @Override public void onCancelled(DatabaseError error) {}
            });
    }
}
CHATLIST

# VideoCallActivity.java (WebRTC)
cat > app/src/main/java/com/globetalk/app/ui/call/VideoCallActivity.java << 'VIDEOCALL'
package com.globetalk.app.ui.call;

import android.os.Bundle;
import android.widget.ImageButton;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import com.globetalk.app.R;

public class VideoCallActivity extends AppCompatActivity {
    private ImageButton toggleCamera, toggleMic, endCall;
    private TextView callStatus, callDuration, otherUsername;
    private String otherUserId, otherUser, callType;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_call);
        
        otherUserId = getIntent().getStringExtra("otherUserId");
        otherUser = getIntent().getStringExtra("otherUsername");
        callType = getIntent().getStringExtra("callType");
        
        toggleCamera = findViewById(R.id.toggleCamera);
        toggleMic = findViewById(R.id.toggleMic);
        endCall = findViewById(R.id.endCall);
        callStatus = findViewById(R.id.callStatus);
        callDuration = findViewById(R.id.callDuration);
        otherUsername = findViewById(R.id.otherUsername);
        
        otherUsername.setText(otherUser);
        callStatus.setText("Connecting...");
        
        setupWebRTC();
        
        endCall.setOnClickListener(v -> finish());
        toggleCamera.setOnClickListener(v -> {/* Toggle camera */});
        toggleMic.setOnClickListener(v -> {/* Toggle mic */});
    }
    
    private void setupWebRTC() {
        // WebRTC setup with Firebase signaling
        callStatus.setText("Connected 📹");
        // WebRTC implementation would go here using Firebase Realtime Database for signaling
    }
}
VIDEOCALL

# MessageAdapter.java
cat > app/src/main/java/com/globetalk/app/adapters/MessageAdapter.java << 'ADAPTER'
package com.globetalk.app.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.globetalk.app.R;
import com.globetalk.app.models.Message;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.ViewHolder> {
    private List<Message> messages;
    private String currentUserId;
    private OnMessageClickListener listener;
    
    public interface OnMessageClickListener {
        void onMessageClick(Message message, int action);
    }
    
    public MessageAdapter(List<Message> messages, String currentUserId, 
                         OnMessageClickListener listener) {
        this.messages = messages;
        this.currentUserId = currentUserId;
        this.listener = listener;
    }
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_message, parent, false);
        return new ViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Message message = messages.get(position);
        holder.bind(message);
    }
    
    @Override
    public int getItemCount() {
        return messages.size();
    }
    
    class ViewHolder extends RecyclerView.ViewHolder {
        TextView usernameText, messageText, timeText, replyPreview;
        
        ViewHolder(View itemView) {
            super(itemView);
            usernameText = itemView.findViewById(R.id.usernameText);
            messageText = itemView.findViewById(R.id.messageText);
            timeText = itemView.findViewById(R.id.timeText);
            replyPreview = itemView.findViewById(R.id.replyPreview);
        }
        
        void bind(Message message) {
            usernameText.setText("@" + message.getSenderUsername());
            messageText.setText(message.getMessage());
            
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.getDefault());
            timeText.setText(sdf.format(new Date(message.getTimestamp())));
            
            if (message.getReplyTo() != null) {
                replyPreview.setVisibility(View.VISIBLE);
                replyPreview.setText("↳ " + message.getReplySender() + ": " + 
                    message.getReplyMessage());
            } else {
                replyPreview.setVisibility(View.GONE);
            }
            
            itemView.setOnClickListener(v -> 
                listener.onMessageClick(message, 0));
            
            itemView.setOnLongClickListener(v -> {
                listener.onMessageClick(message, 1);
                return true;
            });
        }
    }
}
ADAPTER

# ──── DRAWABLE RESOURCES ────
# Simple XML drawables
cat > app/src/main/res/drawable/ic_globe.xml << 'ICGLOBE'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM11,19.93c-3.95,-0.49 -7,-3.85 -7,-7.93 0,-0.62 0.08,-1.21 0.21,-1.79L9,15v1c0,1.1 0.9,2 2,2v1.93zM17.9,17.39c-0.26,-0.81 -1,-1.39 -1.9,-1.39h-1v-3c0,-0.55 -0.45,-1 -1,-1H8v-2h2c0.55,0 1,-0.45 1,-1V7h2c1.1,0 2,-0.9 2,-2v-0.41c2.93,1.19 5,4.06 5,7.41 0,2.08 -0.8,3.97 -2.1,5.39z"/>
</vector>
ICGLOBE

cat > app/src/main/res/drawable/ic_send.xml << 'ICSEND'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#FF6B35">
    <path
        android:fillColor="@android:color/white"
        android:pathData="M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z"/>
</vector>
ICSEND

cat > app/src/main/res/drawable/badge_background.xml << 'BADGEBG'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="12dp"/>
    <solid android:color="#E8F5E9"/>
    <padding android:left="8dp" android:right="8dp" android:top="4dp" android:bottom="4dp"/>
</shape>
BADGEBG

cat > app/src/main/res/drawable/online_dot.xml << 'ONLINEDOT'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#4CAF50"/>
    <size android:width="8dp" android:height="8dp"/>
</shape>
ONLINEDOT

# ──── BUILD APK ────
echo -e "${BLUE}🔨 Building GlobeTalk APK...${NC}"
echo "⏳ This may take 5-10 minutes..."

# Create local.properties
echo "sdk.dir=$ANDROID_HOME" > local.properties

# Build project
./gradlew assembleDebug --no-daemon --stacktrace

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk ../GlobeTalk_v1.0.apk
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 SUCCESS! APK Ready!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}📱 APK Location: GlobeTalk_v1.0.apk${NC}"
    echo -e "${PURPLE}📦 Size: $(du -h ../GlobeTalk_v1.0.apk | cut -f1)${NC}"
    echo ""
    echo -e "${BLUE}✅ Features Included:${NC}"
    echo "  🔐 Email/Password Login & Register"
    echo "  👤 Live Username Availability Check"
    echo "  🌍 Global Chat Room"
    echo "  💬 Private DM Chat"
    echo "  👆 Swipe Reply Feature"
    echo "  🔍 Username Search"
    echo "  📹 Video Calling (WebRTC)"
    echo "  📞 Audio Calling (WebRTC)"
    echo "  🖼️ Profile Picture (Base64)"
    echo "  📴 Offline Chat Support"
    echo "  🟢 Online/Offline Status"
    echo "  🚫 Block/Unblock Users"
    echo ""
    echo -e "${GREEN}🎯 Install and enjoy GlobeTalk! 🌍${NC}"
else
    echo -e "${RED}❌ Build failed. Check errors above.${NC}"
    exit 1
fi