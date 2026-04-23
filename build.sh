#!/usr/bin/env bash
set -e

# ═══════════════════════════════════════════════════════════════════════════════
# AASHU APP - COMPLETE FULL CODE - NO PARTS
# Login/Register Tabs + Base64 Image + SQLite + WebRTC + Firebase
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_ROOT="$(pwd)"
APP_NAME="Aashu"
APP_PACKAGE="com.aashu.app"
APP_PACKAGE_DIR="$PROJECT_ROOT/app/src/main/java/com/aashu/app"
RES_DIR="$PROJECT_ROOT/app/src/main/res"

echo "=========================================="
echo "  $APP_NAME - FULL BUILD"
echo "  Project: $PROJECT_ROOT"
echo "  5-Digit ID + Base64 Image + SQLite"
echo "=========================================="

# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM SETUP
# ═══════════════════════════════════════════════════════════════════════════════
sudo apt-get update -qq
sudo apt-get install -y wget unzip openjdk-17-jdk zipalign apksigner python3 2>/dev/null || true
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

# ═══════════════════════════════════════════════════════════════════════════════
# DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════════
mkdir -p "$APP_PACKAGE_DIR"/{model,utils,adapters,services,views}
mkdir -p "$RES_DIR"/{layout,values,values-night,drawable,drawable-v24,anim,menu,font,xml}
mkdir -p "$RES_DIR"/{mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi,mipmap-xxxhdpi,mipmap-anydpi-v26}
mkdir -p "$PROJECT_ROOT/app/src/main/assets"
mkdir -p "$PROJECT_ROOT/gradle/wrapper"

# ═══════════════════════════════════════════════════════════════════════════════
# ANDROID SDK
# ═══════════════════════════════════════════════════════════════════════════════
echo "=== Android SDK Setup ==="
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

# ═══════════════════════════════════════════════════════════════════════════════
# KEYSTORE
# ═══════════════════════════════════════════════════════════════════════════════
keytool -genkeypair -v -keystore "$PROJECT_ROOT/app/aashu-release.jks" \
    -alias aashu -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass aashu123 -keypass aashu123 \
    -dname "CN=Aashu,OU=Dev,O=Aashu,L=City,S=State,C=IN" \
    -storetype JKS 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
# GOOGLE-SERVICES.JSON
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$PROJECT_ROOT/app/google-services.json"
{
  "project_info": {"project_number":"1044955332082","project_id":"videocallpro-f5f1b","storage_bucket":"videocallpro-f5f1b.firebasestorage.app"},
  "client":[{
    "client_info":{"mobilesdk_app_id":"1:1044955332082:android:2c6e7458b191b9d96eff6b","android_client_info":{"package_name":"com.aashu.app"}},
    "oauth_client":[],
    "api_key":[{"current_key":"AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM"}],
    "services":{"appinvite_service":{"other_platform_oauth_client":[]}}
  }],
  "configuration_version":"1"
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# GRADLE FILES
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$PROJECT_ROOT/settings.gradle"
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral(); maven { url 'https://jitpack.io' } } }
rootProject.name = "Aashu"; include ':app'
EOF

cat <<'EOF' > "$PROJECT_ROOT/build.gradle"
plugins { id 'com.android.application' version '8.2.0' apply false; id 'com.google.gms.google-services' version '4.4.0' apply false }
EOF

cat <<'EOF' > "$PROJECT_ROOT/gradle.properties"
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
org.gradle.parallel=true
org.gradle.caching=true
android.nonTransitiveRClass=true
EOF

cat <<'EOF' > "$PROJECT_ROOT/app/build.gradle"
plugins { id 'com.android.application'; id 'com.google.gms.google-services' }
android {
    namespace 'com.aashu.app'; compileSdk 34
    defaultConfig { applicationId "com.aashu.app"; minSdk 24; targetSdk 34; versionCode 1; versionName "1.0" }
    signingConfigs { release { storeFile file('aashu-release.jks'); storePassword 'aashu123'; keyAlias 'aashu'; keyPassword 'aashu123' } }
    buildTypes { release { minifyEnabled false; signingConfig signingConfigs.release; proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro' } debug { signingConfig signingConfigs.release } }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
    packagingOptions { pickFirst 'META-INF/INDEX.LIST'; pickFirst 'META-INF/io.netty.versions.properties'; pickFirst '**/libc++_shared.so'; pickFirst '**/libjingle_peerconnection_so.so'; exclude 'META-INF/DEPENDENCIES' }
}
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    implementation 'androidx.viewpager2:viewpager2:1.0.0'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'org.webrtc:google-webrtc:1.0.32006'
    implementation 'com.airbnb.android:lottie:6.1.0'
    implementation 'com.facebook.shimmer:shimmer:0.5.0'
    implementation 'de.hdodenhof:circleimageview:3.1.0'
}
EOF

cat <<'EOF' > "$PROJECT_ROOT/app/proguard-rules.pro"
-keep class com.aashu.app.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
EOF

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
cat <<'EOF' > "$PROJECT_ROOT/gradlew"
#!/bin/sh
exec /opt/gradle/gradle-8.2/bin/gradle "$@"
EOF
chmod +x "$PROJECT_ROOT/gradlew"

# ═══════════════════════════════════════════════════════════════════════════════
# ANDROIDMANIFEST.XML
# ═══════════════════════════════════════════════════════════════════════════════
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
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.front" android:required="false"/>
    <uses-feature android:name="android.hardware.microphone" android:required="false"/>
    <application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:roundIcon="@mipmap/ic_launcher_round" android:label="@string/app_name" android:theme="@style/Theme.Aashu" android:usesCleartextTraffic="true" android:supportsRtl="true">
        <activity android:name=".SplashActivity" android:exported="true" android:theme="@style/Theme.Aashu.Splash">
            <intent-filter><action android:name="android.intent.action.MAIN"/><category android:name="android.intent.category.LAUNCHER"/></intent-filter>
        </activity>
        <activity android:name=".MainActivity" android:exported="false" android:launchMode="singleTop" android:windowSoftInputMode="adjustResize" android:screenOrientation="portrait" android:showOnLockScreen="true" android:turnScreenOn="true"/>
        <activity android:name=".CallActivity" android:exported="false" android:launchMode="singleTop" android:screenOrientation="portrait" android:showOnLockScreen="true" android:turnScreenOn="true"/>
        <activity android:name=".ImagePreviewActivity" android:exported="false" android:theme="@style/Theme.Aashu.Transparent"/>
        <service android:name=".services.AashuForegroundService" android:exported="false" android:foregroundServiceType="dataSync"/>
        <receiver android:name=".services.CallActionReceiver" android:exported="false"/>
        <service android:name=".services.AashuMessagingService" android:exported="false">
            <intent-filter><action android:name="com.google.firebase.MESSAGING_EVENT"/></intent-filter>
        </service>
    </application>
</manifest>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# RESOURCES - COLORS, STRINGS, STYLES, DIMENS
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$RES_DIR/values/colors.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="neuBackground">#E4E9F2</color>
    <color name="neuSurface">#E8EDF5</color>
    <color name="neuCardBackground">#EBF0F8</color>
    <color name="neuShadowDark">#A3B1C6</color>
    <color name="neuShadowLight">#FFFFFF</color>
    <color name="aashuPrimary">#FF6B6B</color>
    <color name="aashuPrimaryDark">#E85555</color>
    <color name="aashuSecondary">#4ECDC4</color>
    <color name="aashuAccent">#FFE66D</color>
    <color name="aashuGradientStart">#FF6B6B</color>
    <color name="aashuGradientEnd">#FF8E53</color>
    <color name="chatBubbleOut">#4ECDC4</color>
    <color name="chatBubbleIn">#FFFFFF</color>
    <color name="chatTextOut">#FFFFFF</color>
    <color name="chatTextIn">#2C3E50</color>
    <color name="chatTime">#95A5A6</color>
    <color name="online">#2ECC71</color>
    <color name="offline">#95A5A6</color>
    <color name="unreadBadge">#FF6B6B</color>
    <color name="textPrimary">#2C3E50</color>
    <color name="textSecondary">#7F8C8D</color>
    <color name="textHint">#BDC3C7</color>
    <color name="textWhite">#FFFFFF</color>
    <color name="callAccept">#2ECC71</color>
    <color name="callReject">#E74C3C</color>
    <color name="callBackground">#1A1A2E</color>
    <color name="tabActive">#FF6B6B</color>
    <color name="tabInactive">#95A5A6</color>
</resources>
EOF

cat <<'EOF' > "$RES_DIR/values-night/colors.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="neuBackground">#1A1C20</color>
    <color name="neuSurface">#24262B</color>
    <color name="neuCardBackground">#2D3036</color>
    <color name="neuShadowDark">#0F1012</color>
    <color name="neuShadowLight">#3A3E45</color>
    <color name="chatBubbleOut">#4ECDC4</color>
    <color name="chatBubbleIn">#2D3036</color>
    <color name="chatTextOut">#FFFFFF</color>
    <color name="chatTextIn">#FFFFFF</color>
    <color name="chatTime">#7F8C8D</color>
    <color name="textPrimary">#FFFFFF</color>
    <color name="textSecondary">#95A5A6</color>
    <color name="textHint">#5D6D7E</color>
</resources>
EOF

cat <<'EOF' > "$RES_DIR/values/strings.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Aashu</string>
    <string name="tab_login">Login</string>
    <string name="tab_signup">Sign Up</string>
    <string name="email">Email</string>
    <string name="password">Password</string>
    <string name="your_name">Your Name</string>
    <string name="choose_emoji">Choose Your Emoji Avatar</string>
    <string name="or_upload_photo">Or Upload a Photo</string>
    <string name="tab_chats">Chats</string>
    <string name="tab_calls">Calls</string>
    <string name="tab_profile">Profile</string>
    <string name="type_message">Type a message…</string>
    <string name="online">Online</string>
    <string name="offline">Offline</string>
    <string name="typing">typing…</string>
    <string name="voice_call">Voice Call</string>
    <string name="video_call">Video Call</string>
    <string name="incoming_call">Incoming call…</string>
    <string name="calling">Calling…</string>
    <string name="connecting">Connecting…</string>
    <string name="call_ended">Call Ended</string>
    <string name="accept">Accept</string>
    <string name="decline">Decline</string>
    <string name="end_call">End</string>
    <string name="send">Send</string>
    <string name="add_friend">Add Friend</string>
    <string name="enter_5digit_id">Enter 5-digit ID</string>
    <string name="your_5digit_id">Your ID: #%1$s</string>
    <string name="friend_request_sent">Friend request sent!</string>
    <string name="logout">Logout</string>
    <string name="profile">Profile</string>
    <string name="change_photo">Change Photo</string>
    <string name="remove_photo">Remove Photo</string>
    <string name="no_chats">No chats yet. Add a friend!</string>
    <string name="no_calls">No call history</string>
</resources>
EOF

cat <<'EOF' > "$RES_DIR/values/styles.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Aashu" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/aashuPrimary</item>
        <item name="colorPrimaryDark">@color/aashuPrimaryDark</item>
        <item name="android:statusBarColor">@color/neuBackground</item>
        <item name="android:windowBackground">@color/neuBackground</item>
        <item name="android:navigationBarColor">@color/neuBackground</item>
        <item name="android:windowLightStatusBar">true</item>
    </style>
    <style name="Theme.Aashu.Splash" parent="Theme.Aashu">
        <item name="android:windowBackground">@color/aashuPrimary</item>
    </style>
    <style name="Theme.Aashu.Transparent" parent="Theme.Aashu">
        <item name="android:windowIsTranslucent">true</item>
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="android:windowNoTitle">true</item>
    </style>
</resources>
EOF

cat <<'EOF' > "$RES_DIR/values/dimens.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="neu_corner">16dp</dimen>
    <dimen name="neu_button_corner">30dp</dimen>
    <dimen name="avatar_size">52dp</dimen>
    <dimen name="avatar_large">80dp</dimen>
    <dimen name="chat_bubble_max">280dp</dimen>
    <dimen name="call_button_size">64dp</dimen>
    <dimen name="online_dot">12dp</dimen>
    <dimen name="badge_size">18dp</dimen>
</resources>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# DRAWABLES (Neumorphism + Icons)
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$RES_DIR/drawable/neu_card_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item><shape><solid android:color="@color/neuShadowDark"/><corners android:radius="16dp"/></shape></item>
    <item android:bottom="4dp" android:left="4dp" android:right="4dp" android:top="4dp"><shape><solid android:color="@color/neuShadowLight"/><corners android:radius="16dp"/></shape></item>
    <item android:bottom="2dp" android:left="2dp" android:right="2dp" android:top="2dp"><shape><solid android:color="@color/neuCardBackground"/><corners android:radius="16dp"/></shape></item>
</layer-list>
EOF

cat <<'EOF' > "$RES_DIR/drawable/neu_button_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_pressed="true"><layer-list><item><shape><solid android:color="@color/neuShadowDark"/><corners android:radius="30dp"/></shape></item><item android:bottom="2dp" android:left="2dp" android:right="2dp" android:top="2dp"><shape><solid android:color="@color/neuCardBackground"/><corners android:radius="30dp"/></shape></item></layer-list></item>
    <item><layer-list><item><shape><solid android:color="@color/neuShadowLight"/><corners android:radius="30dp"/></shape></item><item android:bottom="4dp" android:left="4dp" android:right="4dp" android:top="4dp"><shape><solid android:color="@color/neuCardBackground"/><corners android:radius="30dp"/></shape></item></layer-list></item>
</selector>
EOF

cat <<'EOF' > "$RES_DIR/drawable/neu_input_bg.xml"
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item><shape><solid android:color="@color/neuShadowDark"/><corners android:radius="30dp"/></shape></item>
    <item android:bottom="2dp" android:left="2dp" android:right="2dp" android:top="2dp"><shape><solid android:color="@color/neuCardBackground"/><corners android:radius="30dp"/></shape></item>
</layer-list>
EOF

cat <<'EOF' > "$RES_DIR/drawable/neu_chat_out.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/chatBubbleOut"/><corners android:topLeftRadius="18dp" android:topRightRadius="18dp" android:bottomLeftRadius="18dp" android:bottomRightRadius="4dp"/></shape>
EOF

cat <<'EOF' > "$RES_DIR/drawable/neu_chat_in.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/chatBubbleIn"/><corners android:topLeftRadius="4dp" android:topRightRadius="18dp" android:bottomLeftRadius="18dp" android:bottomRightRadius="18dp"/></shape>
EOF

cat <<'EOF' > "$RES_DIR/drawable/circle_accept.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval"><solid android:color="@color/callAccept"/></shape>
EOF

cat <<'EOF' > "$RES_DIR/drawable/circle_reject.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval"><solid android:color="@color/callReject"/></shape>
EOF

cat <<'EOF' > "$RES_DIR/drawable/ic_aashu_logo.xml"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FF6B6B" android:pathData="M54,54m-48,0a48,48 0,1 1,96 0a48,48 0,1 1,-96 0"/>
    <path android:fillColor="#FFFFFF" android:pathData="M40,42 L68,42 L68,48 L40,48 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M46,56 L62,56 L62,62 L46,62 Z"/>
    <path android:fillColor="#4ECDC4" android:pathData="M54,30 C38,30 30,40 30,52 C30,60 38,66 46,68 L44,76 L52,72 C56,74 60,74 62,74 C70,74 78,68 78,58 C78,44 68,30 54,30 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M48,50 L60,50 C62,50 64,52 64,54 C64,56 62,58 60,58 L48,58 C46,58 44,56 44,54 C44,52 46,50 48,50 Z"/>
</vector>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# ANIMATIONS
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$RES_DIR/anim/slide_in_right.xml"
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"><translate android:fromXDelta="100%" android:toXDelta="0%" android:duration="300" android:interpolator="@android:anim/decelerate_interpolator"/></set>
EOF

cat <<'EOF' > "$RES_DIR/anim/slide_out_right.xml"
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"><translate android:fromXDelta="0%" android:toXDelta="100%" android:duration="300" android:interpolator="@android:anim/accelerate_interpolator"/></set>
EOF

cat <<'EOF' > "$RES_DIR/anim/slide_in_left.xml"
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"><translate android:fromXDelta="-100%" android:toXDelta="0%" android:duration="300" android:interpolator="@android:anim/decelerate_interpolator"/></set>
EOF

cat <<'EOF' > "$RES_DIR/anim/slide_out_left.xml"
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"><translate android:fromXDelta="0%" android:toXDelta="-100%" android:duration="300" android:interpolator="@android:anim/accelerate_interpolator"/></set>
EOF

cat <<'EOF' > "$RES_DIR/anim/fade_in.xml"
<?xml version="1.0" encoding="utf-8"?>
<alpha xmlns:android="http://schemas.android.com/apk/res/android" android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="300"/>
EOF

cat <<'EOF' > "$RES_DIR/anim/fade_out.xml"
<?xml version="1.0" encoding="utf-8"?>
<alpha xmlns:android="http://schemas.android.com/apk/res/android" android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="300"/>
EOF

cat <<'EOF' > "$RES_DIR/anim/scale_up.xml"
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"><scale android:fromXScale="0.8" android:toXScale="1.0" android:fromYScale="0.8" android:toYScale="1.0" android:pivotX="50%" android:pivotY="50%" android:duration="200"/><alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="200"/></set>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$RES_DIR/menu/bottom_nav_menu.xml"
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_chats" android:title="@string/tab_chats"/>
    <item android:id="@+id/nav_calls" android:title="@string/tab_calls"/>
    <item android:id="@+id/nav_profile" android:title="@string/tab_profile"/>
</menu>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# LAYOUTS
# ═══════════════════════════════════════════════════════════════════════════════

# --- activity_main.xml ---
cat <<'EOF' > "$RES_DIR/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/rootLayout"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/neuBackground">

    <!-- AUTH LAYOUT -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/authLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/neuBackground"
        android:visibility="visible">

        <!-- Logo -->
        <ImageView
            android:id="@+id/ivLogo"
            android:layout_width="100dp"
            android:layout_height="100dp"
            android:src="@drawable/ic_aashu_logo"
            android:layout_marginTop="60dp"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <!-- Tab Layout -->
        <com.google.android.material.tabs.TabLayout
            android:id="@+id/authTabLayout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="40dp"
            android:layout_marginEnd="40dp"
            android:layout_marginTop="30dp"
            app:layout_constraintTop_toBottomOf="@id/ivLogo"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:tabIndicatorColor="@color/aashuPrimary"
            app:tabTextColor="@color/textPrimary"
            app:tabSelectedTextColor="@color/aashuPrimary"
            app:tabMode="fixed">

            <com.google.android.material.tabs.TabItem
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/tab_login"/>
            <com.google.android.material.tabs.TabItem
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/tab_signup"/>
        </com.google.android.material.tabs.TabLayout>

        <!-- Auth Card -->
        <androidx.cardview.widget.CardView
            android:id="@+id/authCard"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_margin="24dp"
            android:layout_marginTop="10dp"
            app:cardBackgroundColor="@color/neuCardBackground"
            app:cardElevation="8dp"
            app:cardCornerRadius="16dp"
            app:layout_constraintTop_toBottomOf="@id/authTabLayout"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="24dp">

                <!-- Email Input -->
                <com.google.android.material.textfield.TextInputLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="@string/email"
                    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                    app:boxCornerRadiusBottomEnd="12dp"
                    app:boxCornerRadiusBottomStart="12dp"
                    app:boxCornerRadiusTopEnd="12dp"
                    app:boxCornerRadiusTopStart="12dp"
                    android:layout_marginBottom="12dp">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etEmail"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textEmailAddress"
                        android:maxLines="1"/>
                </com.google.android.material.textfield.TextInputLayout>

                <!-- Password Input -->
                <com.google.android.material.textfield.TextInputLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="@string/password"
                    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                    app:boxCornerRadiusBottomEnd="12dp"
                    app:boxCornerRadiusBottomStart="12dp"
                    app:boxCornerRadiusTopEnd="12dp"
                    app:boxCornerRadiusTopStart="12dp"
                    app:passwordToggleEnabled="true"
                    android:layout_marginBottom="20dp">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etPassword"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPassword"
                        android:maxLines="1"/>
                </com.google.android.material.textfield.TextInputLayout>

                <!-- Name Input (for signup) -->
                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/nameInputLayout"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="@string/your_name"
                    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                    app:boxCornerRadiusBottomEnd="12dp"
                    app:boxCornerRadiusBottomStart="12dp"
                    app:boxCornerRadiusTopEnd="12dp"
                    app:boxCornerRadiusTopStart="12dp"
                    android:layout_marginBottom="12dp"
                    android:visibility="gone">
                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etName"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPersonName"
                        android:maxLines="1"/>
                </com.google.android.material.textfield.TextInputLayout>

                <!-- Action Button -->
                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnAuthAction"
                    android:layout_width="match_parent"
                    android:layout_height="50dp"
                    android:text="Login"
                    app:cornerRadius="25dp"
                    app:backgroundTint="@color/aashuPrimary"
                    android:textColor="@color/textWhite"
                    android:textSize="16sp"
                    android:fontFamily="sans-serif-medium"/>

                <!-- Error Text -->
                <TextView
                    android:id="@+id/tvAuthError"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textColor="@color/callReject"
                    android:textSize="13sp"
                    android:layout_marginTop="8dp"
                    android:visibility="gone"/>
            </LinearLayout>
        </androidx.cardview.widget.CardView>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- MAIN LAYOUT -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/mainLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:visibility="gone">

        <!-- Top Bar -->
        <LinearLayout
            android:id="@+id/topBar"
            android:layout_width="match_parent"
            android:layout_height="56dp"
            android:background="@color/neuBackground"
            android:gravity="center_vertical"
            android:paddingStart="16dp"
            android:paddingEnd="16dp"
            android:elevation="0dp"
            app:layout_constraintTop_toTopOf="parent">

            <TextView
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="Aashu"
                android:textColor="@color/aashuPrimary"
                android:textSize="24sp"
                android:fontFamily="sans-serif-medium"/>

            <ImageView
                android:id="@+id/btnSearch"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:padding="8dp"
                android:src="@android:drawable/ic_menu_search"
                android:contentDescription="Search"/>

            <ImageView
                android:id="@+id/btnAddFriend"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:padding="8dp"
                android:src="@android:drawable/ic_menu_add"
                android:contentDescription="Add Friend"/>
        </LinearLayout>

        <!-- RecyclerView -->
        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/mainRecyclerView"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:clipToPadding="false"
            android:paddingTop="4dp"
            app:layout_constraintTop_toBottomOf="@id/topBar"
            app:layout_constraintBottom_toTopOf="@id/bottomNav"/>

        <!-- Empty State -->
        <TextView
            android:id="@+id/tvEmpty"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/no_chats"
            android:textColor="@color/textSecondary"
            android:textSize="16sp"
            android:visibility="gone"
            app:layout_constraintTop_toBottomOf="@id/topBar"
            app:layout_constraintBottom_toTopOf="@id/bottomNav"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"/>

        <!-- Bottom Nav -->
        <com.google.android.material.bottomnavigation.BottomNavigationView
            android:id="@+id/bottomNav"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@color/neuSurface"
            app:menu="@menu/bottom_nav_menu"
            app:itemIconTint="@color/tabActive"
            app:itemTextColor="@color/tabActive"
            app:labelVisibilityMode="labeled"
            app:layout_constraintBottom_toBottomOf="parent"/>
    </androidx.constraintlayout.widget.ConstraintLayout>

    <!-- CHAT LAYOUT -->
    <androidx.constraintlayout.widget.ConstraintLayout
        android:id="@+id/chatLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:visibility="gone">

        <LinearLayout
            android:id="@+id/chatTopBar"
            android:layout_width="match_parent"
            android:layout_height="56dp"
            android:gravity="center_vertical"
            android:background="@color/neuBackground"
            android:paddingStart="8dp"
            android:paddingEnd="8dp"
            app:layout_constraintTop_toTopOf="parent">

            <ImageButton
                android:id="@+id/btnChatBack"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_media_previous"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Back"/>

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/ivChatAvatar"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:layout_marginStart="4dp"
                android:src="@color/neuCardBackground"/>

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical"
                android:layout_marginStart="10dp">

                <TextView
                    android:id="@+id/tvChatName"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textColor="@color/textPrimary"
                    android:textSize="16sp"
                    android:fontFamily="sans-serif-medium"
                    android:maxLines="1"/>

                <TextView
                    android:id="@+id/tvChatStatus"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textColor="@color/textHint"
                    android:textSize="12sp"/>
            </LinearLayout>

            <ImageButton
                android:id="@+id/btnVoiceCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_call"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Voice Call"/>

            <ImageButton
                android:id="@+id/btnVideoCall"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_camera"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="Video Call"/>
        </LinearLayout>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/chatRecyclerView"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:padding="8dp"
            app:layout_constraintTop_toBottomOf="@id/chatTopBar"
            app:layout_constraintBottom_toTopOf="@id/chatInputLayout"/>

        <LinearLayout
            android:id="@+id/chatInputLayout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center_vertical"
            android:padding="8dp"
            android:background="@color/neuSurface"
            app:layout_constraintBottom_toBottomOf="parent">

            <ImageButton
                android:id="@+id/btnAttach"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@android:drawable/ic_menu_attachment"
                android:background="?attr/selectableItemBackgroundBorderless"/>

            <com.google.android.material.textfield.TextInputLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
                app:boxCornerRadiusEnd="20dp"
                app:boxCornerRadiusStart="20dp"
                android:hint="@string/type_message">
                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/etMessage"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:maxLines="4"
                    android:inputType="textMultiLine"/>
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.floatingactionbutton.FloatingActionButton
                android:id="@+id/btnSend"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:src="@android:drawable/ic_menu_send"
                android:layout_marginStart="4dp"
                app:fabSize="mini"
                app:backgroundTint="@color/aashuPrimary"
                app:tint="@color/textWhite"/>
        </LinearLayout>
    </androidx.constraintlayout.widget.ConstraintLayout>

</FrameLayout>
EOF

# --- item_chat.xml ---
cat <<'EOF' > "$RES_DIR/layout/item_chat.xml"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:paddingStart="16dp"
    android:paddingEnd="16dp"
    android:paddingTop="8dp"
    android:paddingBottom="8dp"
    android:background="?attr/selectableItemBackground">

    <de.hdodenhof.circleimageview.CircleImageView
        android:id="@+id/ivAvatar"
        android:layout_width="52dp"
        android:layout_height="52dp"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"/>

    <View
        android:id="@+id/onlineDot"
        android:layout_width="12dp"
        android:layout_height="12dp"
        android:background="@drawable/circle_accept"
        android:layout_marginEnd="2dp"
        android:layout_marginBottom="2dp"
        app:layout_constraintEnd_toEndOf="@id/ivAvatar"
        app:layout_constraintBottom_toBottomOf="@id/ivAvatar"/>

    <TextView
        android:id="@+id/tvName"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="12dp"
        android:textColor="@color/textPrimary"
        android:textSize="16sp"
        android:fontFamily="sans-serif-medium"
        android:maxLines="1"
        app:layout_constraintStart_toEndOf="@id/ivAvatar"
        app:layout_constraintTop_toTopOf="@id/ivAvatar"
        app:layout_constraintEnd_toStartOf="@id/tvTime"/>

    <TextView
        android:id="@+id/tvLastMessage"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="12dp"
        android:textColor="@color/textSecondary"
        android:textSize="14sp"
        android:maxLines="1"
        app:layout_constraintStart_toEndOf="@id/ivAvatar"
        app:layout_constraintTop_toBottomOf="@id/tvName"
        app:layout_constraintBottom_toBottomOf="@id/ivAvatar"
        app:layout_constraintEnd_toStartOf="@id/tvBadge"/>

    <TextView
        android:id="@+id/tvTime"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/textHint"
        android:textSize="12sp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="@id/tvName"/>

    <TextView
        android:id="@+id/tvBadge"
        android:layout_width="20dp"
        android:layout_height="20dp"
        android:gravity="center"
        android:background="@drawable/circle_reject"
        android:textColor="@color/textWhite"
        android:textSize="11sp"
        android:visibility="gone"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toBottomOf="@id/tvTime"/>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# --- item_message.xml ---
cat <<'EOF' > "$RES_DIR/layout/item_message.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:paddingStart="8dp"
    android:paddingEnd="8dp"
    android:paddingTop="4dp"
    android:paddingBottom="4dp">

    <LinearLayout
        android:id="@+id/outgoingLayout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="end"
        android:orientation="vertical"
        android:background="@drawable/neu_chat_out"
        android:maxWidth="280dp"
        android:padding="12dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvMsgOut"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/chatTextOut"
            android:textSize="15sp"/>

        <TextView
            android:id="@+id/tvTimeOut"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:textColor="@color/chatTime"
            android:textSize="11sp"
            android:layout_marginTop="4dp"/>
    </LinearLayout>

    <LinearLayout
        android:id="@+id/incomingLayout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="start"
        android:orientation="vertical"
        android:background="@drawable/neu_chat_in"
        android:maxWidth="280dp"
        android:padding="12dp"
        android:visibility="gone">

        <TextView
            android:id="@+id/tvMsgIn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/chatTextIn"
            android:textSize="15sp"/>

        <TextView
            android:id="@+id/tvTimeIn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:textColor="@color/chatTime"
            android:textSize="11sp"
            android:layout_marginTop="4dp"/>
    </LinearLayout>
</FrameLayout>
EOF

# --- activity_call.xml ---
cat <<'EOF' > "$RES_DIR/layout/activity_call.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/callBackground">

    <org.webrtc.SurfaceViewRenderer
        android:id="@+id/remoteVideoView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>

    <org.webrtc.SurfaceViewRenderer
        android:id="@+id/localVideoView"
        android:layout_width="120dp"
        android:layout_height="160dp"
        android:layout_gravity="top|end"
        android:layout_margin="16dp"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:orientation="horizontal"
        android:gravity="center"
        android:paddingBottom="60dp">

        <LinearLayout
            android:id="@+id/btnAcceptLayout"
            android:layout_width="64dp"
            android:layout_height="64dp"
            android:background="@drawable/circle_accept"
            android:gravity="center"
            android:layout_marginEnd="40dp"
            android:visibility="gone">
            <ImageView
                android:id="@+id/btnAccept"
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@android:drawable/ic_menu_call"
                android:tint="@color/textWhite"/>
        </LinearLayout>

        <LinearLayout
            android:id="@+id/btnEndLayout"
            android:layout_width="64dp"
            android:layout_height="64dp"
            android:background="@drawable/circle_reject"
            android:gravity="center">
            <ImageView
                android:id="@+id/btnEnd"
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@android:drawable/ic_delete"
                android:tint="@color/textWhite"/>
        </LinearLayout>
    </LinearLayout>

    <TextView
        android:id="@+id/tvCallStatus"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:textColor="@color/textWhite"
        android:textSize="18sp"
        android:layout_marginTop="120dp"/>
</FrameLayout>
EOF

# --- dialog_add_friend.xml ---
cat <<'EOF' > "$RES_DIR/layout/dialog_add_friend.xml"
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="20dp">

    <com.google.android.material.textfield.TextInputLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="@string/enter_5digit_id"
        style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">
        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/etFriendId"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="number"
            android:maxLength="5"/>
    </com.google.android.material.textfield.TextInputLayout>

    <TextView
        android:id="@+id/tvFriendDialogMsg"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/callReject"
        android:textSize="13sp"
        android:layout_marginTop="8dp"
        android:visibility="gone"/>
</LinearLayout>
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# JAVA FILES - MODELS
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/model/User.java"
package com.aashu.app.model;
public class User {
    public String uid, name, avatar, fiveDigitId, email, base64Photo, fcmToken;
    public boolean online;
    public long lastSeen;
    public User() {}
    public User(String uid, String name, String email) {
        this.uid = uid; this.name = name; this.email = email;
        this.avatar = "🙂"; this.online = false;
        this.lastSeen = System.currentTimeMillis();
    }
    public String getFormattedId() { return "#" + fiveDigitId; }
    public boolean hasPhoto() { return base64Photo != null && !base64Photo.isEmpty(); }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/Contact.java"
package com.aashu.app.model;
public class Contact {
    public String uid, name, avatar, fiveDigitId, lastMessage, base64Photo;
    public long lastMessageTime;
    public int unreadCount;
    public boolean online, isBlocked, isPinned, isArchived;
    public long muteUntil;
    public Contact() {}
    public boolean hasPhoto() { return base64Photo != null && !base64Photo.isEmpty(); }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/ChatMessage.java"
package com.aashu.app.model;
public class ChatMessage {
    public String id, senderId, text, replyTo, imageBase64;
    public long timestamp;
    public boolean isOutgoing, isDeleted, isRead;
    public ChatMessage() {}
    public ChatMessage(String senderId, String text, long timestamp) {
        this.senderId = senderId; this.text = text; this.timestamp = timestamp;
        this.isOutgoing = false; this.isDeleted = false; this.isRead = false;
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/model/CallRecord.java"
package com.aashu.app.model;
public class CallRecord {
    public String id, partnerId, partnerName, callType, direction;
    public long timestamp, duration;
    public CallRecord() {}
    public String getFormattedDuration() {
        if (duration < 60) return duration + "s";
        return (duration/60) + "m " + (duration%60) + "s";
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# UTILS
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/utils/FiveDigitIdGenerator.java"
package com.aashu.app.utils;
import java.util.Random;
public class FiveDigitIdGenerator {
    private static final Random random = new Random();
    public static String generate() { return String.format("%05d", random.nextInt(100000)); }
    public static boolean isValid(String id) {
        if (id == null || id.length() != 5) return false;
        for (char c : id.toCharArray()) if (!Character.isDigit(c)) return false;
        return true;
    }
    public static String format(String id) { return "#" + id; }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/utils/Base64ImageHelper.java"
package com.aashu.app.utils;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import java.io.ByteArrayOutputStream;

public class Base64ImageHelper {
    
    public static String bitmapToBase64(Bitmap bitmap) {
        Bitmap resized = Bitmap.createScaledBitmap(bitmap, 150, 150, true);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        resized.compress(Bitmap.CompressFormat.JPEG, 70, baos);
        byte[] bytes = baos.toByteArray();
        return Base64.encodeToString(bytes, Base64.DEFAULT);
    }
    
    public static Bitmap base64ToBitmap(String base64) {
        try {
            byte[] bytes = Base64.decode(base64, Base64.DEFAULT);
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        } catch (Exception e) {
            return null;
        }
    }
    
    public static String bitmapToBase64Message(Bitmap bitmap, int maxWidth) {
        float ratio = (float) bitmap.getWidth() / bitmap.getHeight();
        int newWidth = Math.min(bitmap.getWidth(), maxWidth);
        int newHeight = Math.round(newWidth / ratio);
        Bitmap resized = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        resized.compress(Bitmap.CompressFormat.JPEG, 60, baos);
        return Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT);
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/utils/AashuDatabase.java"
package com.aashu.app.utils;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import com.aashu.app.model.*;
import java.util.ArrayList;
import java.util.List;

public class AashuDatabase extends SQLiteOpenHelper {
    private static AashuDatabase instance;
    public static synchronized AashuDatabase get(Context ctx) {
        if (instance == null) instance = new AashuDatabase(ctx.getApplicationContext());
        return instance;
    }
    
    public AashuDatabase(Context ctx) { super(ctx, "aashu.db", null, 1); }
    
    @Override public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE contacts(uid TEXT PRIMARY KEY, name TEXT, avatar TEXT, fiveDigitId TEXT, lastMessage TEXT, lastMessageTime INTEGER, unreadCount INTEGER DEFAULT 0, base64Photo TEXT, isPinned INTEGER DEFAULT 0, isBlocked INTEGER DEFAULT 0, muteUntil INTEGER DEFAULT 0)");
        db.execSQL("CREATE TABLE messages(msgId TEXT PRIMARY KEY, chatId TEXT, senderId TEXT, text TEXT, timestamp INTEGER, isOutgoing INTEGER, isRead INTEGER DEFAULT 0, imageBase64 TEXT)");
        db.execSQL("CREATE TABLE calls(callId TEXT PRIMARY KEY, partnerId TEXT, partnerName TEXT, callType TEXT, direction TEXT, timestamp INTEGER, duration INTEGER)");
        db.execSQL("CREATE INDEX idx_msg ON messages(chatId, timestamp)");
    }
    
    @Override public void onUpgrade(SQLiteDatabase db, int o, int n) { db.execSQL("DROP TABLE IF EXISTS contacts"); db.execSQL("DROP TABLE IF EXISTS messages"); db.execSQL("DROP TABLE IF EXISTS calls"); onCreate(db); }
    
    public void saveContact(Contact c) {
        ContentValues v = new ContentValues();
        v.put("uid", c.uid); v.put("name", c.name); v.put("avatar", c.avatar);
        v.put("fiveDigitId", c.fiveDigitId); v.put("lastMessage", c.lastMessage);
        v.put("lastMessageTime", c.lastMessageTime); v.put("unreadCount", c.unreadCount);
        v.put("base64Photo", c.base64Photo); v.put("isPinned", c.isPinned ? 1 : 0);
        v.put("isBlocked", c.isBlocked ? 1 : 0); v.put("muteUntil", c.muteUntil);
        getWritableDatabase().insertWithOnConflict("contacts", null, v, SQLiteDatabase.CONFLICT_REPLACE);
    }
    
    public List<Contact> getContacts() {
        List<Contact> list = new ArrayList<>();
        Cursor cur = getReadableDatabase().query("contacts", null, null, null, null, null, "isPinned DESC, lastMessageTime DESC");
        while (cur.moveToNext()) {
            Contact c = new Contact();
            c.uid = cur.getString(0); c.name = cur.getString(1); c.avatar = cur.getString(2);
            c.fiveDigitId = cur.getString(3); c.lastMessage = cur.getString(4);
            c.lastMessageTime = cur.getLong(5); c.unreadCount = cur.getInt(6);
            c.base64Photo = cur.getString(7); c.isPinned = cur.getInt(8) == 1;
            c.isBlocked = cur.getInt(9) == 1; c.muteUntil = cur.getLong(10);
            list.add(c);
        }
        cur.close(); return list;
    }
    
    public void saveMessage(ChatMessage m, String chatId) {
        ContentValues v = new ContentValues();
        v.put("msgId", m.id); v.put("chatId", chatId); v.put("senderId", m.senderId);
        v.put("text", m.text); v.put("timestamp", m.timestamp);
        v.put("isOutgoing", m.isOutgoing ? 1 : 0); v.put("isRead", m.isRead ? 1 : 0);
        v.put("imageBase64", m.imageBase64);
        getWritableDatabase().insertWithOnConflict("messages", null, v, SQLiteDatabase.CONFLICT_REPLACE);
    }
    
    public List<ChatMessage> getMessages(String chatId, int limit) {
        List<ChatMessage> list = new ArrayList<>();
        Cursor cur = getReadableDatabase().query("messages", null, "chatId=?", new String[]{chatId}, null, null, "timestamp DESC", String.valueOf(limit));
        while (cur.moveToNext()) {
            ChatMessage m = new ChatMessage();
            m.id = cur.getString(0); m.senderId = cur.getString(2); m.text = cur.getString(3);
            m.timestamp = cur.getLong(4); m.isOutgoing = cur.getInt(5) == 1;
            m.isRead = cur.getInt(6) == 1; m.imageBase64 = cur.getString(7);
            list.add(0, m);
        }
        cur.close(); return list;
    }
    
    public void saveCall(CallRecord r) {
        ContentValues v = new ContentValues();
        v.put("callId", r.id); v.put("partnerId", r.partnerId); v.put("partnerName", r.partnerName);
        v.put("callType", r.callType); v.put("direction", r.direction);
        v.put("timestamp", r.timestamp); v.put("duration", r.duration);
        getWritableDatabase().insertWithOnConflict("calls", null, v, SQLiteDatabase.CONFLICT_REPLACE);
    }
    
    public List<CallRecord> getCalls(int limit) {
        List<CallRecord> list = new ArrayList<>();
        Cursor cur = getReadableDatabase().query("calls", null, null, null, null, null, "timestamp DESC", String.valueOf(limit));
        while (cur.moveToNext()) {
            CallRecord r = new CallRecord();
            r.id = cur.getString(0); r.partnerId = cur.getString(1); r.partnerName = cur.getString(2);
            r.callType = cur.getString(3); r.direction = cur.getString(4);
            r.timestamp = cur.getLong(5); r.duration = cur.getLong(6);
            list.add(r);
        }
        cur.close(); return list;
    }
    
    public void clear() { getWritableDatabase().delete("contacts", null, null); getWritableDatabase().delete("messages", null, null); getWritableDatabase().delete("calls", null, null); }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/utils/FirebaseConfig.java"
package com.aashu.app.utils;
public class FirebaseConfig {
    public static final String API_KEY = "AIzaSyAlf2Ev0YMOUMHKcaXbORAQXyByPPJEPdM";
    public static final String DATABASE_URL = "https://videocallpro-f5f1b-default-rtdb.firebaseio.com";
    public static final String PROJECT_ID = "videocallpro-f5f1b";
    public static final String APP_ID = "1:1044955332082:android:2c6e7458b191b9d96eff6b";
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# ADAPTERS
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/adapters/ChatListAdapter.java"
package com.aashu.app.adapters;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.aashu.app.R;
import com.aashu.app.model.Contact;
import com.aashu.app.utils.Base64ImageHelper;
import de.hdodenhof.circleimageview.CircleImageView;
import java.text.SimpleDateFormat;
import java.util.*;

public class ChatListAdapter extends RecyclerView.Adapter<ChatListAdapter.Holder> {
    private List<Contact> items = new ArrayList<>();
    private OnItemClickListener listener;
    
    public interface OnItemClickListener { void onClick(Contact c); void onLongClick(Contact c); }
    
    public void setListener(OnItemClickListener l) { this.listener = l; }
    public void setItems(List<Contact> list) { items = list; notifyDataSetChanged(); }
    
    @NonNull @Override public Holder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new Holder(LayoutInflater.from(p.getContext()).inflate(R.layout.item_chat, p, false)); }
    
    @Override public void onBindViewHolder(@NonNull Holder h, int pos) {
        Contact c = items.get(pos);
        h.name.setText(c.name != null ? c.name : "User");
        h.lastMsg.setText(c.lastMessage != null ? c.lastMessage : "");
        h.time.setText(c.lastMessageTime > 0 ? new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date(c.lastMessageTime)) : "");
        h.avatar.setImageResource(android.R.color.darker_gray);
        if (c.hasPhoto()) {
            Bitmap b = Base64ImageHelper.base64ToBitmap(c.base64Photo);
            if (b != null) h.avatar.setImageBitmap(b);
        } else {
            h.avatarText.setText(c.avatar != null ? c.avatar : "🙂");
        }
        h.onlineDot.setVisibility(c.online ? View.VISIBLE : View.GONE);
        if (c.unreadCount > 0) { h.badge.setVisibility(View.VISIBLE); h.badge.setText(String.valueOf(c.unreadCount)); }
        else h.badge.setVisibility(View.GONE);
        h.itemView.setOnClickListener(v -> { if (listener != null) listener.onClick(c); });
        h.itemView.setOnLongClickListener(v -> { if (listener != null) listener.onLongClick(c); return true; });
    }
    
    @Override public int getItemCount() { return items.size(); }
    
    static class Holder extends RecyclerView.ViewHolder {
        CircleImageView avatar; TextView avatarText; TextView name; TextView lastMsg; TextView time; TextView badge; View onlineDot;
        Holder(View v) {
            super(v);
            avatar = v.findViewById(R.id.ivAvatar); name = v.findViewById(R.id.tvName);
            lastMsg = v.findViewById(R.id.tvLastMessage); time = v.findViewById(R.id.tvTime);
            badge = v.findViewById(R.id.tvBadge); onlineDot = v.findViewById(R.id.onlineDot);
            avatarText = v.findViewById(R.id.tvName); // fallback
        }
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/adapters/MessageAdapter.java"
package com.aashu.app.adapters;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.aashu.app.R;
import com.aashu.app.model.ChatMessage;
import java.text.SimpleDateFormat;
import java.util.*;

public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.Holder> {
    private List<ChatMessage> items = new ArrayList<>();
    
    public void setItems(List<ChatMessage> list) { items = list; notifyDataSetChanged(); }
    
    @NonNull @Override public Holder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new Holder(LayoutInflater.from(p.getContext()).inflate(R.layout.item_message, p, false)); }
    
    @Override public void onBindViewHolder(@NonNull Holder h, int pos) {
        ChatMessage m = items.get(pos);
        if (m.isOutgoing) {
            h.outLayout.setVisibility(View.VISIBLE); h.inLayout.setVisibility(View.GONE);
            h.outText.setText(m.text);
            h.outTime.setText(new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date(m.timestamp)));
        } else {
            h.outLayout.setVisibility(View.GONE); h.inLayout.setVisibility(View.VISIBLE);
            h.inText.setText(m.text);
            h.inTime.setText(new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date(m.timestamp)));
        }
    }
    
    @Override public int getItemCount() { return items.size(); }
    
    static class Holder extends RecyclerView.ViewHolder {
        View outLayout, inLayout; TextView outText, outTime, inText, inTime;
        Holder(View v) {
            super(v);
            outLayout = v.findViewById(R.id.outgoingLayout); inLayout = v.findViewById(R.id.incomingLayout);
            outText = v.findViewById(R.id.tvMsgOut); outTime = v.findViewById(R.id.tvTimeOut);
            inText = v.findViewById(R.id.tvMsgIn); inTime = v.findViewById(R.id.tvTimeIn);
        }
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/adapters/CallHistoryAdapter.java"
package com.aashu.app.adapters;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.aashu.app.R;
import com.aashu.app.model.CallRecord;
import java.text.SimpleDateFormat;
import java.util.*;

public class CallHistoryAdapter extends RecyclerView.Adapter<CallHistoryAdapter.Holder> {
    private List<CallRecord> items = new ArrayList<>();
    
    public void setItems(List<CallRecord> list) { items = list; notifyDataSetChanged(); }
    
    @NonNull @Override public Holder onCreateViewHolder(@NonNull ViewGroup p, int t) { return new Holder(LayoutInflater.from(p.getContext()).inflate(R.layout.item_chat, p, false)); }
    
    @Override public void onBindViewHolder(@NonNull Holder h, int pos) {
        CallRecord r = items.get(pos);
        h.name.setText(r.partnerName != null ? r.partnerName : "Unknown");
        String typeIcon = "video".equals(r.callType) ? "📹" : "📞";
        String dirIcon = "incoming".equals(r.direction) ? "↙" : "↗";
        h.lastMsg.setText(dirIcon + " " + typeIcon + " " + r.getFormattedDuration());
        h.time.setText(new SimpleDateFormat("dd/MM", Locale.getDefault()).format(new Date(r.timestamp)));
        h.badge.setVisibility(View.GONE);
        h.onlineDot.setVisibility(View.GONE);
    }
    
    @Override public int getItemCount() { return items.size(); }
    
    static class Holder extends RecyclerView.ViewHolder {
        TextView name, lastMsg, time, badge; View onlineDot;
        Holder(View v) {
            super(v);
            name = v.findViewById(R.id.tvName); lastMsg = v.findViewById(R.id.tvLastMessage);
            time = v.findViewById(R.id.tvTime); badge = v.findViewById(R.id.tvBadge);
            onlineDot = v.findViewById(R.id.onlineDot);
        }
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICES
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/services/AashuForegroundService.java"
package com.aashu.app.services;
import android.app.*;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;
import com.aashu.app.MainActivity;
import com.aashu.app.R;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class AashuForegroundService extends Service {
    private DatabaseReference db;
    private String myUid;
    
    @Override public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel ch = new NotificationChannel("aashu_persistent", "Aashu Service", NotificationManager.IMPORTANCE_MIN);
            ((NotificationManager) getSystemService(NOTIFICATION_SERVICE)).createNotificationChannel(ch);
        }
        Intent i = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, i, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        startForeground(1001, new NotificationCompat.Builder(this, "aashu_persistent").setContentTitle("Aashu").setContentText("Connected").setSmallIcon(android.R.drawable.ic_dialog_info).setContentIntent(pi).setOngoing(true).build());
        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            myUid = FirebaseAuth.getInstance().getCurrentUser().getUid();
            db = com.google.firebase.database.FirebaseDatabase.getInstance(com.aashu.app.utils.FirebaseConfig.DATABASE_URL).getReference();
            db.child("users").child(myUid).child("online").setValue(true);
            db.child("users").child(myUid).child("online").onDisconnect().setValue(false);
        }
    }
    
    @Override public int onStartCommand(Intent i, int f, int id) { return START_STICKY; }
    @Override public IBinder onBind(Intent i) { return null; }
    @Override public void onDestroy() { if (myUid != null && db != null) db.child("users").child(myUid).child("online").setValue(false); super.onDestroy(); }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/services/CallActionReceiver.java"
package com.aashu.app.services;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.aashu.app.CallActivity;

public class CallActionReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context ctx, Intent i) {
        if (i == null || i.getAction() == null) return;
        Intent ci = new Intent(ctx, CallActivity.class);
        ci.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        ci.setAction(i.getAction());
        ci.putExtra("callerId", i.getStringExtra("callerId"));
        ci.putExtra("callerName", i.getStringExtra("callerName"));
        ci.putExtra("isVideo", i.getBooleanExtra("isVideo", false));
        ctx.startActivity(ci);
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/services/AashuMessagingService.java"
package com.aashu.app.services;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class AashuMessagingService extends FirebaseMessagingService {
    @Override public void onMessageReceived(RemoteMessage msg) { }
    @Override public void onNewToken(String token) {
        com.google.firebase.auth.FirebaseUser user = com.google.firebase.auth.FirebaseAuth.getInstance().getCurrentUser();
        if (user != null) {
            com.google.firebase.database.FirebaseDatabase.getInstance(com.aashu.app.utils.FirebaseConfig.DATABASE_URL)
                .getReference().child("users").child(user.getUid()).child("fcmToken").setValue(token);
        }
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# WebRTCManager
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/utils/WebRTCManager.java"
package com.aashu.app.utils;
import android.content.Context;
import android.media.AudioManager;
import android.util.Log;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.util.*;

public class WebRTCManager {
    private Context ctx; private EglBase eglBase;
    private PeerConnectionFactory factory; private PeerConnection pc;
    private VideoTrack localVideo; private AudioTrack localAudio;
    private VideoCapturer capturer; private SurfaceTextureHelper surfaceHelper;
    private SurfaceViewRenderer localView, remoteView;
    private AudioManager audio; private int savedMode; private boolean savedSpeaker;
    private DatabaseReference db; private String myUid, partnerUid;
    private boolean isCaller, isVideo, remoteDescSet;
    private List<IceCandidate> pending = new ArrayList<>();
    private CallStateListener listener; private long startTime;
    private ValueEventListener answerListener, candidateListener;
    
    public interface CallStateListener { void onConnected(); void onEnded(); void onRemoteVideo(VideoTrack t); }
    
    public WebRTCManager(Context ctx, EglBase egl) { this.ctx = ctx; this.eglBase = egl; this.audio = (AudioManager) ctx.getSystemService(Context.AUDIO_SERVICE); this.db = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL).getReference(); }
    
    public void setListener(CallStateListener l) { this.listener = l; }
    
    public void initFactory() {
        PeerConnectionFactory.InitializationOptions opt = PeerConnectionFactory.InitializationOptions.builder(ctx).createInitializationOptions();
        PeerConnectionFactory.initialize(opt);
        factory = PeerConnectionFactory.builder().setVideoEncoderFactory(new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true)).setVideoDecoderFactory(new DefaultVideoDecoderFactory(eglBase.getEglBaseContext())).createPeerConnectionFactory();
    }
    
    public void initViews(SurfaceViewRenderer local, SurfaceViewRenderer remote) {
        this.localView = local; this.remoteView = remote;
        local.init(eglBase.getEglBaseContext(), null); local.setMirror(true);
        remote.init(eglBase.getEglBaseContext(), null);
    }
    
    public void startCall(String myUid, String partnerUid, boolean isCaller, boolean isVideo) {
        this.myUid = myUid; this.partnerUid = partnerUid; this.isCaller = isCaller; this.isVideo = isVideo;
        savedMode = audio.getMode(); savedSpeaker = audio.isSpeakerphoneOn();
        audio.setMode(AudioManager.MODE_IN_COMMUNICATION); audio.setSpeakerphoneOn(isVideo);
        AudioSource as = factory.createAudioSource(new MediaConstraints());
        localAudio = factory.createAudioTrack("audio0", as); localAudio.setEnabled(true);
        if (isVideo) { startVideoCapture(); }
        createPeerConnection();
        if (isCaller) createOffer();
        else listenForOffer();
    }
    
    private void startVideoCapture() {
        Camera2Enumerator e = new Camera2Enumerator(ctx);
        for (String n : e.getDeviceNames()) { if (e.isFrontFacing(n)) { capturer = e.createCapturer(n, null); break; } }
        if (capturer == null) { for (String n : e.getDeviceNames()) { capturer = e.createCapturer(n, null); break; } }
        if (capturer != null) {
            surfaceHelper = SurfaceTextureHelper.create("Capture", eglBase.getEglBaseContext());
            VideoSource vs = factory.createVideoSource(false);
            capturer.initialize(surfaceHelper, ctx, vs.getCapturerObserver());
            capturer.startCapture(640, 480, 30);
            localVideo = factory.createVideoTrack("video0", vs);
            if (localView != null) localVideo.addSink(localView);
        }
    }
    
    private void createPeerConnection() {
        List<PeerConnection.IceServer> servers = new ArrayList<>();
        servers.add(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer());
        PeerConnection.RTCConfiguration cfg = new PeerConnection.RTCConfiguration(servers);
        pc = factory.createPeerConnection(cfg, new PeerConnection.Observer() {
            @Override public void onIceCandidate(IceCandidate c) { sendIce(c); }
            @Override public void onIceConnectionChange(PeerConnection.IceConnectionState s) {
                if (s == PeerConnection.IceConnectionState.CONNECTED) { startTime = System.currentTimeMillis(); if (listener != null) listener.onConnected(); }
                else if (s == PeerConnection.IceConnectionState.DISCONNECTED || s == PeerConnection.IceConnectionState.FAILED || s == PeerConnection.IceConnectionState.CLOSED) { if (listener != null) listener.onEnded(); }
            }
            @Override public void onAddTrack(RtpReceiver r, MediaStream[] ss) { if (r.track() instanceof VideoTrack && remoteView != null) { VideoTrack vt = (VideoTrack) r.track(); vt.addSink(remoteView); if (listener != null) listener.onRemoteVideo(vt); } }
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {}
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}
            @Override public void onAddStream(MediaStream s) {}
            @Override public void onRemoveStream(MediaStream s) {}
            @Override public void onDataChannel(DataChannel d) {}
            @Override public void onRenegotiationNeeded() {}
            @Override public void onTrack(RtpTransceiver t) {}
        });
        if (pc != null) { pc.addTrack(localAudio); if (localVideo != null) pc.addTrack(localVideo); }
    }
    
    private void createOffer() {
        pc.createOffer(new SdpObserver() {
            @Override public void onCreateSuccess(SessionDescription sdp) {
                pc.setLocalDescription(new SdpObserver() {
                    @Override public void onSetSuccess() {
                        Map<String, Object> data = new HashMap<>();
                        data.put("callerId", myUid); data.put("calleeId", partnerUid);
                        data.put("offer", sdp.description); data.put("isVideo", isVideo);
                        db.child("calls").child(partnerUid).setValue(data);
                        listenForAnswer(); listenForCandidates();
                    }
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetFailure(String s) {}
                    @Override public void onCreateFailure(String s) {}
                }, sdp);
            }
            @Override public void onSetSuccess() {}
            @Override public void onCreateFailure(String s) {}
            @Override public void onSetFailure(String s) {}
        }, new MediaConstraints());
    }
    
    private void listenForOffer() {
        db.child("calls").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                if (!snap.exists()) return;
                String offer = snap.child("offer").getValue(String.class);
                if (offer == null) return;
                pc.setRemoteDescription(new SdpObserver() {
                    @Override public void onSetSuccess() {
                        remoteDescSet = true;
                        for (IceCandidate c : pending) pc.addIceCandidate(c);
                        pending.clear();
                        pc.createAnswer(new SdpObserver() {
                            @Override public void onCreateSuccess(SessionDescription sdp) {
                                pc.setLocalDescription(new SdpObserver() {
                                    @Override public void onSetSuccess() {
                                        Map<String, Object> u = new HashMap<>();
                                        u.put("answer", sdp.description); u.put("accepted", true);
                                        db.child("calls").child(myUid).updateChildren(u);
                                    }
                                    @Override public void onCreateSuccess(SessionDescription sd) {}
                                    @Override public void onSetFailure(String s) {}
                                    @Override public void onCreateFailure(String s) {}
                                }, sdp);
                            }
                            @Override public void onSetSuccess() {}
                            @Override public void onCreateFailure(String s) {}
                            @Override public void onSetFailure(String s) {}
                        }, new MediaConstraints());
                    }
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetFailure(String s) {}
                    @Override public void onCreateFailure(String s) {}
                }, new SessionDescription(SessionDescription.Type.OFFER, offer));
                listenForCandidates();
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
    }
    
    private void listenForAnswer() {
        answerListener = db.child("calls").child(partnerUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                String answer = snap.child("answer").getValue(String.class);
                if (answer == null) return;
                pc.setRemoteDescription(new SdpObserver() {
                    @Override public void onSetSuccess() { remoteDescSet = true; for (IceCandidate c : pending) pc.addIceCandidate(c); pending.clear(); }
                    @Override public void onCreateSuccess(SessionDescription sd) {}
                    @Override public void onSetFailure(String s) {}
                    @Override public void onCreateFailure(String s) {}
                }, new SessionDescription(SessionDescription.Type.ANSWER, answer));
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
    }
    
    private void sendIce(IceCandidate c) {
        Map<String, Object> m = new HashMap<>();
        m.put("sdp", c.sdp); m.put("sdpMid", c.sdpMid); m.put("sdpMLineIndex", c.sdpMLineIndex);
        db.child("calls").child(isCaller ? partnerUid : myUid).child("candidates").push().setValue(m);
    }
    
    private void listenForCandidates() {
        String target = isCaller ? partnerUid : myUid;
        candidateListener = db.child("calls").child(target).child("candidates").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                for (DataSnapshot c : snap.getChildren()) {
                    IceCandidate ice = new IceCandidate(c.child("sdpMid").getValue(String.class), c.child("sdpMLineIndex").getValue(Integer.class), c.child("sdp").getValue(String.class));
                    if (remoteDescSet) pc.addIceCandidate(ice); else pending.add(ice);
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
    }
    
    public long getDuration() { return startTime > 0 ? (System.currentTimeMillis() - startTime) / 1000 : 0; }
    
    public void endCall() {
        try { if (capturer != null) { capturer.stopCapture(); capturer.dispose(); } } catch (Exception e) {}
        try { if (localVideo != null) localVideo.dispose(); if (localAudio != null) localAudio.dispose(); } catch (Exception e) {}
        try { if (pc != null) pc.close(); } catch (Exception e) {}
        try { db.child("calls").child(myUid).removeValue(); db.child("calls").child(partnerUid).removeValue(); } catch (Exception e) {}
        try { audio.setMode(savedMode); audio.setSpeakerphoneOn(savedSpeaker); } catch (Exception e) {}
    }
    
    public void dispose() { endCall(); try { if (factory != null) factory.dispose(); } catch (Exception e) {} }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# ACTIVITIES
# ═══════════════════════════════════════════════════════════════════════════════

cat <<'EOF' > "$APP_PACKAGE_DIR/SplashActivity.java"
package com.aashu.app;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;

public class SplashActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle s) {
        super.onCreate(s);
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(this, MainActivity.class));
            finish();
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
        }, 2000);
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/ImagePreviewActivity.java"
package com.aashu.app;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.widget.ImageView;
import androidx.appcompat.app.AppCompatActivity;
import com.aashu.app.utils.Base64ImageHelper;

public class ImagePreviewActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle s) {
        super.onCreate(s);
        ImageView iv = new ImageView(this);
        String base64 = getIntent().getStringExtra("imageBase64");
        if (base64 != null) {
            Bitmap b = Base64ImageHelper.base64ToBitmap(base64);
            if (b != null) iv.setImageBitmap(b);
        }
        iv.setScaleType(ImageView.ScaleType.FIT_CENTER);
        iv.setBackgroundColor(0xFF000000);
        iv.setOnClickListener(v -> finish());
        setContentView(iv);
    }
}
EOF

cat <<'EOF' > "$APP_PACKAGE_DIR/CallActivity.java"
package com.aashu.app;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.aashu.app.utils.*;
import com.google.firebase.database.*;
import org.webrtc.*;

public class CallActivity extends AppCompatActivity {
    private SurfaceViewRenderer localView, remoteView;
    private TextView tvStatus;
    private View btnAccept, btnEnd;
    private WebRTCManager webRTC;
    private EglBase eglBase;
    private Handler handler = new Handler(Looper.getMainLooper());
    private String myUid, partnerUid, partnerName;
    private boolean isIncoming, isVideo;
    private DatabaseReference db;
    
    @Override protected void onCreate(Bundle s) {
        super.onCreate(s);
        setContentView(R.layout.activity_call);
        
        localView = findViewById(R.id.localVideoView);
        remoteView = findViewById(R.id.remoteVideoView);
        tvStatus = findViewById(R.id.tvCallStatus);
        btnAccept = findViewById(R.id.btnAcceptLayout);
        btnEnd = findViewById(R.id.btnEndLayout);
        
        eglBase = EglBase.create();
        db = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL).getReference();
        
        Intent i = getIntent();
        partnerUid = i.getStringExtra("partnerUid");
        partnerName = i.getStringExtra("partnerName");
        isVideo = i.getBooleanExtra("isVideo", false);
        myUid = com.google.firebase.auth.FirebaseAuth.getInstance().getCurrentUser().getUid();
        
        if (com.aashu.app.services.CallActionReceiver.class.getName().equals(i.getAction())) {
            isIncoming = true;
            tvStatus.setText("Incoming call...");
            btnAccept.setVisibility(View.VISIBLE);
        } else {
            isIncoming = false;
            tvStatus.setText("Calling...");
            btnAccept.setVisibility(View.GONE);
            initWebRTC();
        }
        
        btnAccept.setOnClickListener(v -> { btnAccept.setVisibility(View.GONE); initWebRTC(); });
        btnEnd.setOnClickListener(v -> finishCall());
    }
    
    private void initWebRTC() {
        webRTC = new WebRTCManager(this, eglBase);
        webRTC.initFactory();
        if (isVideo) webRTC.initViews(localView, remoteView);
        webRTC.setListener(new WebRTCManager.CallStateListener() {
            @Override public void onConnected() { handler.post(() -> tvStatus.setText("Connected")); }
            @Override public void onEnded() { handler.post(() -> finishCall()); }
            @Override public void onRemoteVideo(VideoTrack t) {}
        });
        if (isIncoming) {
            webRTC.startCall(myUid, partnerUid, false, isVideo);
        } else {
            webRTC.startCall(myUid, partnerUid, true, isVideo);
        }
    }
    
    private void finishCall() {
        long dur = webRTC != null ? webRTC.getDuration() : 0;
        if (webRTC != null) webRTC.endCall();
        if (db != null && partnerUid != null && myUid != null) {
            String id = db.child("users").child(myUid).child("call_history").push().getKey();
            java.util.Map<String, Object> r = new java.util.HashMap<>();
            r.put("partnerId", partnerUid); r.put("partnerName", partnerName);
            r.put("callType", isVideo ? "video" : "voice");
            r.put("direction", isIncoming ? "incoming" : "outgoing");
            r.put("timestamp", System.currentTimeMillis()); r.put("duration", dur);
            db.child("users").child(myUid).child("call_history").child(id).setValue(r);
        }
        finish();
    }
    
    @Override protected void onDestroy() {
        super.onDestroy();
        if (webRTC != null) webRTC.dispose();
        if (eglBase != null) eglBase.release();
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# MAINACTIVITY.JAVA (THE BIG ONE)
# ═══════════════════════════════════════════════════════════════════════════════
cat <<'EOF' > "$APP_PACKAGE_DIR/MainActivity.java"
package com.aashu.app;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.View;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import com.aashu.app.adapters.*;
import com.aashu.app.model.*;
import com.aashu.app.utils.*;
import com.google.android.material.tabs.TabLayout;
import com.google.firebase.auth.*;
import com.google.firebase.database.*;
import com.google.firebase.messaging.FirebaseMessaging;
import de.hdodenhof.circleimageview.CircleImageView;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class MainActivity extends AppCompatActivity {
    
    // Auth views
    private View authLayout;
    private TabLayout authTabs;
    private com.google.android.material.textfield.TextInputEditText etEmail, etPassword, etName;
    private com.google.android.material.button.MaterialButton btnAuthAction;
    private TextView tvAuthError;
    private com.google.android.material.textfield.TextInputLayout nameInputLayout;
    private boolean isLoginTab = true;
    
    // Main views
    private View mainLayout;
    private androidx.recyclerview.widget.RecyclerView mainRecyclerView;
    private TextView tvEmpty;
    private com.google.android.material.bottomnavigation.BottomNavigationView bottomNav;
    private int currentTab = 0; // 0=chats, 1=calls, 2=profile
    
    // Chat views
    private View chatLayout;
    private CircleImageView ivChatAvatar;
    private TextView tvChatName, tvChatStatus;
    private androidx.recyclerview.widget.RecyclerView chatRecyclerView;
    private com.google.android.material.textfield.TextInputEditText etMessage;
    private com.google.android.material.floatingactionbutton.FloatingActionButton btnSend;
    private String chatPartnerUid;
    
    // Firebase
    private FirebaseAuth auth;
    private DatabaseReference db;
    private String myUid;
    private User myProfile;
    
    // Local DB
    private AashuDatabase localDb;
    private Handler handler = new Handler(Looper.getMainLooper());
    
    // Adapters
    private ChatListAdapter chatListAdapter;
    private com.aashu.app.adapters.CallHistoryAdapter callHistoryAdapter;
    private MessageAdapter messageAdapter;
    
    // Listeners
    private ValueEventListener contactsListener, callsListener, incomingCallListener;
    private ValueEventListener messagesListener, partnerStatusListener;
    
    // Lists
    private List<Contact> contactsList = new ArrayList<>();
    private List<CallRecord> callsList = new ArrayList<>();
    
    private static final int PICK_IMAGE = 101;
    private static final int PERM_REQUEST = 100;
    
    @Override protected void onCreate(Bundle s) {
        super.onCreate(s);
        setContentView(R.layout.activity_main);
        
        localDb = AashuDatabase.get(this);
        auth = FirebaseAuth.getInstance();
        db = FirebaseDatabase.getInstance(FirebaseConfig.DATABASE_URL).getReference();
        db.keepSynced(true);
        
        initViews();
        initAdapters();
        requestPermissions();
        
        if (auth.getCurrentUser() != null) {
            myUid = auth.getCurrentUser().getUid();
            onAuthSuccess();
        } else {
            showAuth();
        }
    }
    
    private void initViews() {
        authLayout = findViewById(R.id.authLayout);
        mainLayout = findViewById(R.id.mainLayout);
        chatLayout = findViewById(R.id.chatLayout);
        
        authTabs = findViewById(R.id.authTabLayout);
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        etName = findViewById(R.id.etName);
        btnAuthAction = findViewById(R.id.btnAuthAction);
        tvAuthError = findViewById(R.id.tvAuthError);
        nameInputLayout = findViewById(R.id.nameInputLayout);
        
        mainRecyclerView = findViewById(R.id.mainRecyclerView);
        tvEmpty = findViewById(R.id.tvEmpty);
        bottomNav = findViewById(R.id.bottomNav);
        
        ivChatAvatar = findViewById(R.id.ivChatAvatar);
        tvChatName = findViewById(R.id.tvChatName);
        tvChatStatus = findViewById(R.id.tvChatStatus);
        chatRecyclerView = findViewById(R.id.chatRecyclerView);
        etMessage = findViewById(R.id.etMessage);
        btnSend = findViewById(R.id.btnSend);
        
        // Auth Tab
        authTabs.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override public void onTabSelected(TabLayout.Tab t) {
                isLoginTab = t.getPosition() == 0;
                nameInputLayout.setVisibility(isLoginTab ? View.GONE : View.VISIBLE);
                btnAuthAction.setText(isLoginTab ? "Login" : "Sign Up");
                tvAuthError.setVisibility(View.GONE);
            }
            @Override public void onTabUnselected(TabLayout.Tab t) {}
            @Override public void onTabReselected(TabLayout.Tab t) {}
        });
        
        btnAuthAction.setOnClickListener(v -> {
            if (isLoginTab) doLogin(); else doSignup();
        });
        
        // Main buttons
        findViewById(R.id.btnAddFriend).setOnClickListener(v -> showAddFriendDialog());
        
        // Bottom Nav
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_chats) { currentTab = 0; refreshMainList(); return true; }
            if (id == R.id.nav_calls) { currentTab = 1; refreshMainList(); return true; }
            if (id == R.id.nav_profile) { currentTab = 2; showProfileDialog(); return true; }
            return false;
        });
        
        // Chat buttons
        findViewById(R.id.btnChatBack).setOnClickListener(v -> showMain());
        findViewById(R.id.btnVoiceCall).setOnClickListener(v -> startCall(false));
        findViewById(R.id.btnVideoCall).setOnClickListener(v -> startCall(true));
        btnSend.setOnClickListener(v -> sendMessage());
    }
    
    private void initAdapters() {
        chatListAdapter = new ChatListAdapter();
        chatListAdapter.setListener(new ChatListAdapter.OnItemClickListener() {
            @Override public void onClick(Contact c) { openChat(c); }
            @Override public void onLongClick(Contact c) { showChatOptions(c); }
        });
        
        callHistoryAdapter = new com.aashu.app.adapters.CallHistoryAdapter();
        messageAdapter = new MessageAdapter();
        
        mainRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        chatRecyclerView.setLayoutManager(new LinearLayoutManager(this));
    }
    
    // ── AUTH ─────────────────────────────────────────────────────────────
    private void doLogin() {
        String email = getText(etEmail), pass = getText(etPassword);
        if (email.isEmpty() || pass.isEmpty()) { showAuthError("Fill all fields"); return; }
        auth.signInWithEmailAndPassword(email, pass).addOnSuccessListener(r -> {
            myUid = r.getUser().getUid();
            onAuthSuccess();
        }).addOnFailureListener(e -> showAuthError(e.getMessage()));
    }
    
    private void doSignup() {
        String email = getText(etEmail), pass = getText(etPassword), name = getText(etName);
        if (email.isEmpty() || pass.isEmpty() || name.isEmpty()) { showAuthError("Fill all fields"); return; }
        if (pass.length() < 6) { showAuthError("Password min 6 chars"); return; }
        auth.createUserWithEmailAndPassword(email, pass).addOnSuccessListener(r -> {
            myUid = r.getUser().getUid();
            createProfile(name);
        }).addOnFailureListener(e -> showAuthError(e.getMessage()));
    }
    
    private void createProfile(String name) {
        String fiveDigitId = FiveDigitIdGenerator.generate();
        // Check uniqueness
        db.child("fiveDigitIds").child(fiveDigitId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                String finalId = fiveDigitId;
                if (snap.exists()) finalId = FiveDigitIdGenerator.generate();
                
                myProfile = new User(myUid, name, "");
                myProfile.fiveDigitId = finalId;
                
                Map<String, Object> userMap = new HashMap<>();
                userMap.put("uid", myUid); userMap.put("name", name);
                userMap.put("fiveDigitId", finalId); userMap.put("online", true);
                userMap.put("lastSeen", ServerValue.TIMESTAMP); userMap.put("avatar", "🙂");
                
                db.child("users").child(myUid).setValue(userMap);
                db.child("fiveDigitIds").child(finalId).setValue(myUid);
                
                FirebaseMessaging.getInstance().getToken().addOnSuccessListener(token -> {
                    db.child("users").child(myUid).child("fcmToken").setValue(token);
                });
                
                onAuthSuccess();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void onAuthSuccess() {
        loadMyProfile(() -> {
            showMain();
            startService(new Intent(this, com.aashu.app.services.AashuForegroundService.class));
            setupListeners();
            loadCachedData();
        });
    }
    
    private void loadMyProfile(Runnable done) {
        db.child("users").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                myProfile = new User();
                myProfile.uid = myUid;
                myProfile.name = snap.child("name").getValue(String.class);
                myProfile.fiveDigitId = snap.child("fiveDigitId").getValue(String.class);
                myProfile.base64Photo = snap.child("base64Photo").getValue(String.class);
                myProfile.avatar = snap.child("avatar").getValue(String.class);
                if (myProfile.name == null) myProfile.name = "User";
                if (myProfile.fiveDigitId == null) myProfile.fiveDigitId = "00000";
                if (done != null) done.run();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) { if (done != null) done.run(); }
        });
    }
    
    // ── VIEWS ────────────────────────────────────────────────────────────
    private void showAuth() {
        authLayout.setVisibility(View.VISIBLE);
        mainLayout.setVisibility(View.GONE);
        chatLayout.setVisibility(View.GONE);
    }
    
    private void showMain() {
        authLayout.setVisibility(View.GONE);
        mainLayout.setVisibility(View.VISIBLE);
        chatLayout.setVisibility(View.GONE);
        refreshMainList();
    }
    
    private void openChat(Contact c) {
        chatPartnerUid = c.uid;
        tvChatName.setText(c.name);
        tvChatStatus.setText(c.online ? "Online" : "Offline");
        
        if (c.hasPhoto()) {
            Bitmap b = Base64ImageHelper.base64ToBitmap(c.base64Photo);
            if (b != null) ivChatAvatar.setImageBitmap(b);
        }
        
        mainLayout.setVisibility(View.GONE);
        chatLayout.setVisibility(View.VISIBLE);
        
        // Load cached messages first
        List<ChatMessage> cached = localDb.getMessages(getChatId(), 50);
        messageAdapter.setItems(cached);
        
        // Load from Firebase
        loadMessages();
        listenPartnerStatus();
        clearUnread(c.uid);
    }
    
    // ── MAIN LIST ───────────────────────────────────────────────────────
    private void refreshMainList() {
        if (currentTab == 0) {
            mainRecyclerView.setAdapter(chatListAdapter);
            chatListAdapter.setItems(contactsList);
            tvEmpty.setVisibility(contactsList.isEmpty() ? View.VISIBLE : View.GONE);
        } else if (currentTab == 1) {
            mainRecyclerView.setAdapter(callHistoryAdapter);
            callHistoryAdapter.setItems(callsList);
            tvEmpty.setVisibility(callsList.isEmpty() ? View.VISIBLE : View.GONE);
        }
    }
    
    private void loadCachedData() {
        contactsList = localDb.getContacts();
        callsList = localDb.getCalls(50);
        refreshMainList();
    }
    
    // ── FIREBASE LISTENERS ──────────────────────────────────────────────
    private void setupListeners() {
        // Contacts
        contactsListener = db.child("users").child(myUid).child("contacts").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                contactsList.clear();
                for (DataSnapshot c : snap.getChildren()) {
                    Contact contact = new Contact();
                    contact.uid = c.getKey();
                    contact.name = c.child("name").getValue(String.class);
                    contact.avatar = c.child("avatar").getValue(String.class);
                    contact.fiveDigitId = c.child("fiveDigitId").getValue(String.class);
                    contact.lastMessage = c.child("lastMessage").getValue(String.class);
                    Long lmt = c.child("lastMessageTime").getValue(Long.class);
                    contact.lastMessageTime = lmt != null ? lmt : 0;
                    Long unread = c.child("unread").getValue(Long.class);
                    contact.unreadCount = unread != null ? unread.intValue() : 0;
                    contact.base64Photo = c.child("base64Photo").getValue(String.class);
                    contactsList.add(contact);
                    localDb.saveContact(contact);
                    fetchOnlineStatus(contact);
                }
                refreshMainList();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
        
        // Calls
        callsListener = db.child("users").child(myUid).child("call_history").orderByChild("timestamp").limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                callsList.clear();
                for (DataSnapshot c : snap.getChildren()) {
                    CallRecord r = new CallRecord();
                    r.id = c.getKey();
                    r.partnerId = c.child("partnerId").getValue(String.class);
                    r.partnerName = c.child("partnerName").getValue(String.class);
                    r.callType = c.child("callType").getValue(String.class);
                    r.direction = c.child("direction").getValue(String.class);
                    Long ts = c.child("timestamp").getValue(Long.class);
                    r.timestamp = ts != null ? ts : 0;
                    Long dur = c.child("duration").getValue(Long.class);
                    r.duration = dur != null ? dur : 0;
                    callsList.add(0, r);
                    localDb.saveCall(r);
                }
                refreshMainList();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
        
        // Incoming calls
        incomingCallListener = db.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                if (!snap.exists()) return;
                String callerId = snap.child("callerId").getValue(String.class);
                if (callerId == null || callerId.equals(myUid)) return;
                Boolean acc = snap.child("accepted").getValue(Boolean.class);
                if (acc != null && acc) return;
                Boolean isVid = snap.child("isVideo").getValue(Boolean.class);
                
                db.child("users").child(callerId).addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override public void onDataChange(@NonNull DataSnapshot us) {
                        String name = us.child("name").getValue(String.class);
                        Intent ci = new Intent(MainActivity.this, CallActivity.class);
                        ci.putExtra("partnerUid", callerId);
                        ci.putExtra("partnerName", name != null ? name : "Unknown");
                        ci.putExtra("isVideo", isVid != null && isVid);
                        startActivity(ci);
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void fetchOnlineStatus(Contact c) {
        db.child("users").child(c.uid).child("online").addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                Boolean online = snap.getValue(Boolean.class);
                c.online = online != null && online;
                if (currentTab == 0) chatListAdapter.notifyDataSetChanged();
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    // ── CHAT ─────────────────────────────────────────────────────────────
    private void loadMessages() {
        String chatId = getChatId();
        Query q = db.child("messages").child(chatId).orderByChild("timestamp").limitToLast(50);
        if (messagesListener != null) db.child("messages").child(chatId).removeEventListener(messagesListener);
        messagesListener = q.addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                List<ChatMessage> msgs = new ArrayList<>();
                for (DataSnapshot c : snap.getChildren()) {
                    ChatMessage m = new ChatMessage();
                    m.id = c.getKey();
                    m.senderId = c.child("senderId").getValue(String.class);
                    m.text = c.child("text").getValue(String.class);
                    Long ts = c.child("timestamp").getValue(Long.class);
                    m.timestamp = ts != null ? ts : 0;
                    m.isOutgoing = myUid.equals(m.senderId);
                    m.imageBase64 = c.child("imageBase64").getValue(String.class);
                    if (m.text != null || m.imageBase64 != null) {
                        msgs.add(m);
                        localDb.saveMessage(m, chatId);
                    }
                }
                messageAdapter.setItems(msgs);
                chatRecyclerView.setAdapter(messageAdapter);
                if (!msgs.isEmpty()) chatRecyclerView.scrollToPosition(msgs.size() - 1);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void sendMessage() {
        if (chatPartnerUid == null) return;
        String text = getText(etMessage);
        if (text.isEmpty()) return;
        etMessage.setText("");
        
        String chatId = getChatId();
        String msgId = db.child("messages").child(chatId).push().getKey();
        Map<String, Object> msg = new HashMap<>();
        msg.put("senderId", myUid);
        msg.put("text", text);
        msg.put("timestamp", ServerValue.TIMESTAMP);
        
        if (msgId != null) db.child("messages").child(chatId).child(msgId).setValue(msg);
        
        // Update last message on both sides
        Map<String, Object> lastMsg = new HashMap<>();
        lastMsg.put("lastMessage", text);
        lastMsg.put("lastMessageTime", ServerValue.TIMESTAMP);
        db.child("users").child(myUid).child("contacts").child(chatPartnerUid).updateChildren(lastMsg);
        
        db.child("users").child(chatPartnerUid).child("contacts").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                Long unread = snap.child("unread").getValue(Long.class);
                Map<String, Object> up = new HashMap<>();
                up.put("unread", (unread != null ? unread : 0) + 1);
                up.put("lastMessage", text);
                up.put("lastMessageTime", ServerValue.TIMESTAMP);
                if (myProfile != null) {
                    up.put("name", myProfile.name);
                    up.put("fiveDigitId", myProfile.fiveDigitId);
                    if (myProfile.base64Photo != null) up.put("base64Photo", myProfile.base64Photo);
                }
                db.child("users").child(chatPartnerUid).child("contacts").child(myUid).updateChildren(up);
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void listenPartnerStatus() {
        if (partnerStatusListener != null) db.child("users").child(chatPartnerUid).child("online").removeEventListener(partnerStatusListener);
        partnerStatusListener = db.child("users").child(chatPartnerUid).child("online").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                Boolean online = snap.getValue(Boolean.class);
                tvChatStatus.setText(online != null && online ? "Online" : "Offline");
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    private void clearUnread(String partnerUid) {
        db.child("users").child(myUid).child("contacts").child(partnerUid).child("unread").setValue(0);
    }
    
    private String getChatId() {
        String a = myUid, b = chatPartnerUid;
        return a.compareTo(b) < 0 ? a + "_" + b : b + "_" + a;
    }
    
    // ── CALLS ────────────────────────────────────────────────────────────
    private void startCall(boolean isVideo) {
        if (chatPartnerUid == null) return;
        Intent i = new Intent(this, CallActivity.class);
        i.putExtra("partnerUid", chatPartnerUid);
        i.putExtra("partnerName", tvChatName.getText().toString());
        i.putExtra("isVideo", isVideo);
        startActivity(i);
    }
    
    // ── FRIEND SYSTEM ───────────────────────────────────────────────────
    private void showAddFriendDialog() {
        View v = getLayoutInflater().inflate(R.layout.dialog_add_friend, null);
        com.google.android.material.textfield.TextInputEditText etId = v.findViewById(R.id.etFriendId);
        TextView tvMsg = v.findViewById(R.id.tvFriendDialogMsg);
        
        new AlertDialog.Builder(this).setTitle("Add Friend").setView(v)
            .setPositiveButton("Add", (d, w) -> {
                String id = etId.getText() != null ? etId.getText().toString().trim() : "";
                if (!FiveDigitIdGenerator.isValid(id)) {
                    tvMsg.setVisibility(View.VISIBLE);
                    tvMsg.setText("Enter valid 5-digit ID");
                    return;
                }
                addFriend(id, tvMsg, (AlertDialog) d);
            })
            .setNegativeButton("Cancel", null).show();
    }
    
    private void addFriend(String friendId, TextView tvMsg, AlertDialog dialog) {
        db.child("fiveDigitIds").child(friendId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                String uid = snap.getValue(String.class);
                if (uid == null) { tvMsg.setVisibility(View.VISIBLE); tvMsg.setText("User not found"); return; }
                if (uid.equals(myUid)) { tvMsg.setVisibility(View.VISIBLE); tvMsg.setText("That's your own ID!"); return; }
                
                // Check if already friends
                db.child("users").child(myUid).child("contacts").child(uid).addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override public void onDataChange(@NonNull DataSnapshot snap) {
                        if (snap.exists()) {
                            tvMsg.setVisibility(View.VISIBLE);
                            tvMsg.setText("Already in your contacts!");
                            return;
                        }
                        
                        // Add to both contacts
                        if (myProfile == null) return;
                        Map<String, Object> myContact = new HashMap<>();
                        myContact.put("name", ""); myContact.put("unread", 0);
                        myContact.put("lastMessage", "Start chatting!");
                        myContact.put("lastMessageTime", System.currentTimeMillis());
                        
                        Map<String, Object> theirContact = new HashMap<>();
                        theirContact.put("name", myProfile.name);
                        theirContact.put("fiveDigitId", myProfile.fiveDigitId);
                        theirContact.put("avatar", myProfile.avatar != null ? myProfile.avatar : "🙂");
                        theirContact.put("unread", 0);
                        theirContact.put("lastMessage", "Say hi!");
                        theirContact.put("lastMessageTime", System.currentTimeMillis());
                        if (myProfile.base64Photo != null) theirContact.put("base64Photo", myProfile.base64Photo);
                        
                        db.child("users").child(myUid).child("contacts").child(uid).setValue(myContact);
                        db.child("users").child(uid).child("contacts").child(myUid).setValue(theirContact);
                        
                        // Get friend's info for my contact
                        db.child("users").child(uid).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override public void onDataChange(@NonNull DataSnapshot snap) {
                                String name = snap.child("name").getValue(String.class);
                                Map<String, Object> update = new HashMap<>();
                                update.put("name", name != null ? name : "User");
                                update.put("fiveDigitId", snap.child("fiveDigitId").getValue(String.class));
                                update.put("avatar", snap.child("avatar").getValue(String.class));
                                String photo = snap.child("base64Photo").getValue(String.class);
                                if (photo != null) update.put("base64Photo", photo);
                                db.child("users").child(myUid).child("contacts").child(uid).updateChildren(update);
                            }
                            @Override public void onCancelled(@NonNull DatabaseError e) {}
                        });
                        
                        Toast.makeText(MainActivity.this, "Friend added!", Toast.LENGTH_SHORT).show();
                        dialog.dismiss();
                    }
                    @Override public void onCancelled(@NonNull DatabaseError e) {}
                });
            }
            @Override public void onCancelled(@NonNull DatabaseError e) {}
        });
    }
    
    // ── PROFILE ──────────────────────────────────────────────────────────
    private void showProfileDialog() {
        if (myProfile == null) return;
        View v = getLayoutInflater().inflate(R.layout.dialog_add_friend, null);
        TextView tvTitle = new TextView(this);
        tvTitle.setText("Profile"); tvTitle.setTextSize(20);
        
        String info = "Name: " + myProfile.name + "\nID: " + myProfile.getFormattedId();
        new AlertDialog.Builder(this)
            .setTitle(myProfile.getFormattedId())
            .setMessage(info)
            .setPositiveButton("Change Photo", (d, w) -> pickImage())
            .setNegativeButton("Logout", (d, w) -> logout())
            .setNeutralButton("Close", null)
            .show();
    }
    
    private void pickImage() {
        Intent i = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(i, PICK_IMAGE);
    }
    
    @Override protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (req == PICK_IMAGE && res == RESULT_OK && data != null) {
            try {
                Uri uri = data.getData();
                Bitmap b = MediaStore.Images.Media.getBitmap(getContentResolver(), uri);
                String base64 = Base64ImageHelper.bitmapToBase64(b);
                db.child("users").child(myUid).child("base64Photo").setValue(base64);
                myProfile.base64Photo = base64;
                Toast.makeText(this, "Photo updated!", Toast.LENGTH_SHORT).show();
            } catch (Exception e) {
                Toast.makeText(this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }
        }
    }
    
    private void showChatOptions(Contact c) {
        new AlertDialog.Builder(this)
            .setTitle(c.name)
            .setItems(new String[]{"Delete Chat", c.isBlocked ? "Unblock" : "Block"}, (d, w) -> {
                if (w == 0) {
                    db.child("users").child(myUid).child("contacts").child(c.uid).removeValue();
                    localDb.deleteContact(c.uid);
                } else if (w == 1) {
                    c.isBlocked = !c.isBlocked;
                    localDb.saveContact(c);
                    refreshMainList();
                }
            }).show();
    }
    
    // ── HELPERS ──────────────────────────────────────────────────────────
    private void requestPermissions() {
        List<String> perms = new ArrayList<>();
        perms.add(Manifest.permission.RECORD_AUDIO);
        perms.add(Manifest.permission.CAMERA);
        if (Build.VERSION.SDK_INT >= 33) perms.add(Manifest.permission.POST_NOTIFICATIONS);
        if (Build.VERSION.SDK_INT >= 33) perms.add(Manifest.permission.READ_MEDIA_IMAGES);
        else perms.add(Manifest.permission.READ_EXTERNAL_STORAGE);
        
        List<String> needed = new ArrayList<>();
        for (String p : perms) if (ContextCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED) needed.add(p);
        if (!needed.isEmpty()) ActivityCompat.requestPermissions(this, needed.toArray(new String[0]), PERM_REQUEST);
    }
    
    private void logout() {
        if (myUid != null) {
            db.child("users").child(myUid).child("online").setValue(false);
            cleanup();
        }
        localDb.clear();
        auth.signOut();
        contactsList.clear();
        callsList.clear();
        myUid = null;
        myProfile = null;
        stopService(new Intent(this, com.aashu.app.services.AashuForegroundService.class));
        showAuth();
    }
    
    private void cleanup() {
        if (db != null && myUid != null) {
            if (contactsListener != null) db.child("users").child(myUid).child("contacts").removeEventListener(contactsListener);
            if (callsListener != null) db.child("users").child(myUid).child("call_history").removeEventListener(callsListener);
            if (incomingCallListener != null) db.child("calls").child(myUid).removeEventListener(incomingCallListener);
        }
    }
    
    private String getText(EditText et) { return et.getText() != null ? et.getText().toString().trim() : ""; }
    private void showAuthError(String msg) { tvAuthError.setVisibility(View.VISIBLE); tvAuthError.setText(msg); }
    
    @Override protected void onResume() { super.onResume(); if (myUid != null && db != null) db.child("users").child(myUid).child("online").setValue(true); }
    @Override protected void onPause() { super.onPause(); if (myUid != null && db != null) db.child("users").child(myUid).child("online").setValue(false); }
    
    @Override public void onBackPressed() {
        if (chatLayout.getVisibility() == View.VISIBLE) { showMain(); return; }
        super.onBackPressed();
    }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "=========================================="
echo "  ALL FILES WRITTEN - STARTING BUILD"
echo "=========================================="

cd "$PROJECT_ROOT"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$JAVA_HOME/bin:$PATH"

yes | sdkmanager --licenses > /dev/null 2>&1 || true

./gradlew clean assembleRelease --stacktrace --no-daemon 2>&1 | tail -80

echo ""
echo "=========================================="
echo "  BUILD COMPLETE!"
echo "  APK: $PROJECT_ROOT/app/build/outputs/apk/release/app-release.apk"
echo "=========================================="
ls -lh "$PROJECT_ROOT/app/build/outputs/apk/release/" 2>/dev/null