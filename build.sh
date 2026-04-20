mkdir -p videocallpro
cd videocallpro

# Setup Android SDK
mkdir -p sdk/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip -d sdk/cmdline-tools
mv sdk/cmdline-tools/cmdline-tools sdk/cmdline-tools/latest
export ANDROID_HOME=$PWD/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
yes | sdkmanager --licenses > /dev/null 2>&1
sdkmanager "platforms;android-34" "build-tools;34.0.0" > /dev/null

# Generate Keystore
keytool -genkeypair -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias javagoat -dname "CN=Java Goat, OU=Dev, O=JavaGoat, L=Tech, ST=State, C=IN" -storepass "javagoat123" -keypass "javagoat123"

# Create Directories
mkdir -p app/src/main/java/com/example/callingapp
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p app/src/main/res/menu

# Dummy Google Services JSON (Required for build)
cat << 'EOF' > app/google-services.json
{
  "project_info": {"project_number": "123","project_id": "javagoat-dummy"},
  "client":[{"client_info": {"mobilesdk_app_id": "1:123:android:abc"},"api_key": [{"current_key": "DUMMY_KEY"}],"package_name": "com.example.callingapp"}]
}
EOF

# Gradle Files
cat << 'EOF' > settings.gradle
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral(); maven { url 'https://jitpack.io' } }
}
rootProject.name = "Java Goat"
include ':app'
EOF

cat << 'EOF' > build.gradle
buildscript {
    repositories { google(); mavenCentral() }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
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
            storeFile file("../release.jks")
            storePassword "javagoat123"
            keyAlias "javagoat"
            keyPassword "javagoat123"
        }
    }
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
            signingConfig signingConfigs.release
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
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'io.getstream:stream-webrtc-android:1.1.1'
}
EOF

# Manifest
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

    <application
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="Java Goat"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.JavaGoat">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:windowSoftInputMode="adjustResize">
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

# Resources
cat << 'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#075E54</color>
    <color name="primary_dark">#128C7E</color>
    <color name="accent">#25D366</color>
    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="bg_light">#ECE5DD</color>
    <color name="msg_out">#DCF8C6</color>
    <color name="msg_in">#FFFFFF</color>
    <color name="red">#E53935</color>
    <color name="green">#43A047</color>
    <color name="gray">#808080</color>
    <color name="overlay">#B3000000</color>
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
        <item name="android:statusBarColor">?attr/colorPrimaryVariant</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/drawable/msg_out_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_out"/>
    <corners android:topLeftRadius="12dp" android:bottomLeftRadius="12dp" android:bottomRightRadius="12dp" android:topRightRadius="2dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/msg_in_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_in"/>
    <corners android:topLeftRadius="2dp" android:bottomLeftRadius="12dp" android:bottomRightRadius="12dp" android:topRightRadius="12dp"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/emoji_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/primary"/>
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_launcher_background.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#075E54" android:pathData="M0,0h108v108h-108z"/>
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_launcher_foreground.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF" android:pathData="M34,44 L74,44 L74,64 L34,64 Z" />
    <path android:fillColor="#25D366" android:pathData="M54,20 C35.2,20 20,35.2 20,54 C20,60.8 22,67.1 25.4,72.4 L22,86 L36.2,82.8 C41.5,85.8 47.6,87.6 54,87.6 C72.8,87.6 88,72.4 88,54 C88,35.2 72.8,20 54,20 Z M54,80 C48.4,80 43.2,78.5 38.6,75.8 L36.5,74.6 L26.8,76.8 L29.2,67.6 L27.8,65.3 C24.9,60.4 23.2,54.7 23.2,48.7 C23.2,31.7 37.1,17.8 54,17.8 C70.9,17.8 84.8,31.7 84.8,48.7 C84.8,65.7 70.9,79.5 54,80 Z"/>
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

cat << 'EOF' > app/src/main/res/menu/bottom_nav.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_chats" android:title="Chats" />
    <item android:id="@+id/nav_updates" android:title="Updates" />
    <item android:id="@+id/nav_calls" android:title="Calls" />
</menu>
EOF

cat << 'EOF' > app/src/main/res/layout/item_list.xml
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="wrap_content" android:padding="12dp">
    <TextView android:id="@+id/tvIcon" android:layout_width="48dp" android:layout_height="48dp" android:background="@drawable/emoji_bg" android:gravity="center" android:textSize="24sp" app:layout_constraintStart_toStartOf="parent" app:layout_constraintTop_toTopOf="parent"/>
    <TextView android:id="@+id/tvTitle" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_marginStart="12dp" android:textSize="16sp" android:textStyle="bold" android:textColor="@color/black" app:layout_constraintStart_toEndOf="@id/tvIcon" app:layout_constraintTop_toTopOf="@id/tvIcon"/>
    <TextView android:id="@+id/tvSubtitle" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_marginStart="12dp" android:textColor="@color/gray" android:maxLines="1" app:layout_constraintStart_toEndOf="@id/tvIcon" app:layout_constraintTop_toBottomOf="@id/tvTitle"/>
    <TextView android:id="@+id/tvBadge" android:layout_width="wrap_content" android:layout_height="wrap_content" android:background="@drawable/emoji_bg" android:backgroundTint="@color/accent" android:textColor="@color/white" android:paddingHorizontal="6dp" android:text="1" android:visibility="gone" app:layout_constraintEnd_toEndOf="parent" app:layout_constraintTop_toTopOf="parent" app:layout_constraintBottom_toBottomOf="parent"/>
    <LinearLayout android:id="@+id/llActions" android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal" android:visibility="gone" app:layout_constraintEnd_toEndOf="parent" app:layout_constraintTop_toTopOf="parent" app:layout_constraintBottom_toBottomOf="parent">
        <Button android:id="@+id/btnAccept" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Accept" android:backgroundTint="@color/primary"/>
        <Button android:id="@+id/btnReject" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Reject" android:backgroundTint="@color/red"/>
    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_message.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:padding="8dp">
    <TextView android:id="@+id/tvMsgIn" android:layout_width="wrap_content" android:layout_height="wrap_content" android:maxWidth="280dp" android:background="@drawable/msg_in_bg" android:padding="12dp" android:textColor="@color/black" android:layout_alignParentStart="true" android:visibility="gone"/>
    <TextView android:id="@+id/tvMsgOut" android:layout_width="wrap_content" android:layout_height="wrap_content" android:maxWidth="280dp" android:background="@drawable/msg_out_bg" android:padding="12dp" android:textColor="@color/black" android:layout_alignParentEnd="true" android:visibility="gone"/>
</RelativeLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/dialog_input.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="20dp">
    <EditText android:id="@+id/etInput" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter details..."/>
    <EditText android:id="@+id/etEmoji" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Emoji Avatar" android:maxLength="2"/>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:background="@color/bg_light">

    <!-- Auth View -->
    <LinearLayout android:id="@+id/viewAuth" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:gravity="center" android:padding="32dp" android:background="@color/white" android:visibility="gone">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Java Goat" android:textSize="32sp" android:textStyle="bold" android:textColor="@color/primary"/>
        <EditText android:id="@+id/etEmail" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Email" android:inputType="textEmailAddress" android:layout_marginTop="24dp"/>
        <EditText android:id="@+id/etPass" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Password" android:inputType="textPassword" android:layout_marginTop="8dp"/>
        <Button android:id="@+id/btnLogin" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Login" android:layout_marginTop="16dp" android:backgroundTint="@color/primary"/>
        <Button android:id="@+id/btnSignup" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Sign Up" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/primary"/>
    </LinearLayout>

    <!-- Main View -->
    <LinearLayout android:id="@+id/viewMain" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:visibility="gone" android:background="@color/white">
        <androidx.appcompat.widget.Toolbar android:id="@+id/toolbarMain" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@color/primary">
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Java Goat" android:textColor="@color/white" android:textSize="20sp" android:textStyle="bold"/>
            <Button android:id="@+id/btnAddFriend" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="end" android:text="+ Add" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/white"/>
            <Button android:id="@+id/btnProfile" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_gravity="end" android:text="Me" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/white"/>
        </androidx.appcompat.widget.Toolbar>
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rvMain" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1"/>
        <com.google.android.material.bottomnavigation.BottomNavigationView android:id="@+id/bottomNav" android:layout_width="match_parent" android:layout_height="wrap_content" app:menu="@menu/bottom_nav" android:background="@color/white"/>
    </LinearLayout>

    <!-- Chat View -->
    <LinearLayout android:id="@+id/viewChat" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:visibility="gone">
        <androidx.appcompat.widget.Toolbar android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@color/primary">
            <Button android:id="@+id/btnChatBack" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="&lt;" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/white" android:minWidth="48dp"/>
            <TextView android:id="@+id/tvChatTitle" android:layout_width="0dp" android:layout_weight="1" android:layout_height="wrap_content" android:textColor="@color/white" android:textSize="18sp" android:textStyle="bold"/>
            <Button android:id="@+id/btnVoiceCall" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="📞" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/white" android:minWidth="48dp"/>
            <Button android:id="@+id/btnVideoCall" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="📹" style="@style/Widget.MaterialComponents.Button.TextButton" android:textColor="@color/white" android:minWidth="48dp"/>
        </androidx.appcompat.widget.Toolbar>
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rvChat" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:padding="8dp" android:clipToPadding="false"/>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:background="@color/white">
            <EditText android:id="@+id/etChatInput" android:layout_width="0dp" android:layout_weight="1" android:layout_height="wrap_content" android:hint="Message..." android:background="@null" android:padding="12dp"/>
            <Button android:id="@+id/btnSend" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Send" android:backgroundTint="@color/primary"/>
        </LinearLayout>
    </LinearLayout>

    <!-- Call View -->
    <FrameLayout android:id="@+id/viewCall" android:layout_width="match_parent" android:layout_height="match_parent" android:background="@color/black" android:visibility="gone">
        <org.webrtc.SurfaceViewRenderer android:id="@+id/remoteVideo" android:layout_width="match_parent" android:layout_height="match_parent"/>
        <org.webrtc.SurfaceViewRenderer android:id="@+id/localVideo" android:layout_width="120dp" android:layout_height="160dp" android:layout_gravity="top|end" android:layout_margin="16dp" app:layout_constraintTop_toTopOf="parent" app:layout_constraintEnd_toEndOf="parent"/>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:layout_gravity="bottom" android:gravity="center" android:padding="32dp" android:background="@color/overlay">
            <TextView android:id="@+id/tvCallStatus" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="@color/white" android:textSize="18sp" android:layout_marginBottom="16dp"/>
            <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="horizontal">
                <Button android:id="@+id/btnAcceptCall" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Accept" android:backgroundTint="@color/green" android:layout_marginEnd="16dp" android:visibility="gone"/>
                <Button android:id="@+id/btnEndCall" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="End" android:backgroundTint="@color/red"/>
            </LinearLayout>
        </LinearLayout>
    </FrameLayout>
</FrameLayout>
EOF

cat << 'EOF' > app/src/main/java/com/example/callingapp/BackgroundService.java
package com.example.callingapp;

import android.app.*;
import android.content.Intent;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class BackgroundService extends Service {
    private DatabaseReference db;
    private ValueEventListener callListener;

    @Override
    public void onCreate() {
        super.onCreate();
        NotificationManager nm = getSystemService(NotificationManager.class);
        nm.createNotificationChannel(new NotificationChannel("sync", "Sync", NotificationManager.IMPORTANCE_LOW));
        nm.createNotificationChannel(new NotificationChannel("calls", "Calls", NotificationManager.IMPORTANCE_HIGH));

        startForeground(1, new NotificationCompat.Builder(this, "sync")
            .setContentTitle("Java Goat")
            .setContentText("Listening for messages...")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .build());

        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
            db = FirebaseDatabase.getInstance().getReference();
            
            callListener = db.child("calls").child(uid).addValueEventListener(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot s) {
                    if (s.exists() && s.hasChild("offer") && !MainActivity.isAppInForeground) {
                        Intent i = new Intent(BackgroundService.this, MainActivity.class);
                        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        PendingIntent pi = PendingIntent.getActivity(BackgroundService.this, 0, i, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                        Notification n = new NotificationCompat.Builder(BackgroundService.this, "calls")
                            .setSmallIcon(android.R.drawable.sym_call_incoming)
                            .setContentTitle("Incoming Call")
                            .setContentText("Java Goat Video Call")
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setFullScreenIntent(pi, true)
                            .setAutoCancel(true)
                            .build();
                        nm.notify(2, n);
                    }
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
        }
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) { return START_STICKY; }
    @Override public IBinder onBind(Intent intent) { return null; }
    @Override public void onDestroy() {
        if(db != null && callListener != null) db.child("calls").child(FirebaseAuth.getInstance().getCurrentUser().getUid()).removeEventListener(callListener);
        super.onDestroy();
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/example/callingapp/MainActivity.java
package com.example.callingapp;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Bundle;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.*;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.util.*;

public class MainActivity extends AppCompatActivity {

    public static boolean isAppInForeground = false;
    private FrameLayout root;
    private View viewAuth, viewMain, viewChat, viewCall;
    private BottomNavigationView bottomNav;
    private RecyclerView rvMain, rvChat;
    
    private FirebaseAuth auth;
    private DatabaseReference db;
    private String myUid, myJgId, activeChatUid, activeCallUid;
    private boolean isVideoCall;
    private GenericAdapter mainAdapter;
    private ChatAdapter chatAdapter;
    private List<Map<String, String>> listData = new ArrayList<>();
    private List<Map<String, String>> chatData = new ArrayList<>();

    // WebRTC
    private EglBase eglBase;
    private PeerConnectionFactory peerConnectionFactory;
    private PeerConnection peerConnection;
    private SurfaceViewRenderer localVideo, remoteVideo;
    private VideoTrack localVideoTrack;
    private AudioTrack localAudioTrack;
    private VideoCapturer videoCapturer;
    private SurfaceTextureHelper surfaceTextureHelper;
    private AudioManager audioManager;
    private DatabaseReference callRef;
    private ValueEventListener callListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        ActivityCompat.requestPermissions(this, new String[]{
            Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO, 
            Manifest.permission.POST_NOTIFICATIONS
        }, 100);

        auth = FirebaseAuth.getInstance();
        db = FirebaseDatabase.getInstance().getReference();
        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        viewAuth = findViewById(R.id.viewAuth);
        viewMain = findViewById(R.id.viewMain);
        viewChat = findViewById(R.id.viewChat);
        viewCall = findViewById(R.id.viewCall);
        
        setupAuthUI();
        setupMainUI();
        setupChatUI();
        setupCallUI();

        if (auth.getCurrentUser() != null) {
            myUid = auth.getCurrentUser().getUid();
            initApp();
        } else {
            showView(viewAuth);
        }
    }

    private void showView(View v) {
        viewAuth.setVisibility(v == viewAuth ? View.VISIBLE : View.GONE);
        viewMain.setVisibility(v == viewMain ? View.VISIBLE : View.GONE);
        viewChat.setVisibility(v == viewChat ? View.VISIBLE : View.GONE);
        viewCall.setVisibility(v == viewCall ? View.VISIBLE : View.GONE);
    }

    @Override protected void onResume() { super.onResume(); isAppInForeground = true; if(myUid!=null) db.child("users").child(myUid).child("online").setValue(true); }
    @Override protected void onPause() { super.onPause(); isAppInForeground = false; if(myUid!=null) db.child("users").child(myUid).child("online").setValue(false); }

    // --- AUTH FLOW ---
    private void setupAuthUI() {
        EditText etEmail = findViewById(R.id.etEmail), etPass = findViewById(R.id.etPass);
        findViewById(R.id.btnLogin).setOnClickListener(v -> {
            auth.signInWithEmailAndPassword(etEmail.getText().toString(), etPass.getText().toString())
                .addOnSuccessListener(authResult -> { myUid = auth.getCurrentUser().getUid(); initApp(); })
                .addOnFailureListener(e -> Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show());
        });
        findViewById(R.id.btnSignup).setOnClickListener(v -> {
            auth.createUserWithEmailAndPassword(etEmail.getText().toString(), etPass.getText().toString())
                .addOnSuccessListener(authResult -> {
                    myUid = auth.getCurrentUser().getUid();
                    showProfileSetupDialog();
                });
        });
    }

    private void showProfileSetupDialog() {
        View dView = getLayoutInflater().inflate(R.layout.dialog_input, null);
        EditText etName = dView.findViewById(R.id.etInput), etEmoji = dView.findViewById(R.id.etEmoji);
        etName.setHint("Name");
        new AlertDialog.Builder(this).setTitle("Setup Profile").setView(dView).setPositiveButton("Save", (d,w) -> {
            myJgId = "jg-" + UUID.randomUUID().toString().substring(0,4);
            Map<String, Object> u = new HashMap<>();
            u.put("name", etName.getText().toString()); u.put("emoji", etEmoji.getText().toString());
            u.put("jgId", myJgId); u.put("online", true);
            db.child("users").child(myUid).setValue(u);
            initApp();
        }).show();
    }

    private void initApp() {
        showView(viewMain);
        startService(new Intent(this, BackgroundService.class));
        db.child("users").child(myUid).child("online").onDisconnect().setValue(false);
        db.child("users").child(myUid).child("jgId").get().addOnSuccessListener(s -> myJgId = s.getValue(String.class));
        
        loadTab("chats");
        listenForCalls();
    }

    // --- MAIN UI ---
    private void setupMainUI() {
        rvMain = findViewById(R.id.rvMain);
        rvMain.setLayoutManager(new LinearLayoutManager(this));
        mainAdapter = new GenericAdapter();
        rvMain.setAdapter(mainAdapter);
        
        bottomNav = findViewById(R.id.bottomNav);
        bottomNav.setOnItemSelectedListener(item -> {
            String title = item.getTitle().toString().toLowerCase();
            loadTab(title);
            return true;
        });

        findViewById(R.id.btnAddFriend).setOnClickListener(v -> {
            View dView = getLayoutInflater().inflate(R.layout.dialog_input, null);
            EditText et = dView.findViewById(R.id.etInput); et.setHint("Enter jg-XXXX");
            dView.findViewById(R.id.etEmoji).setVisibility(View.GONE);
            new AlertDialog.Builder(this).setTitle("Add Friend").setView(dView).setPositiveButton("Send", (d,w) -> {
                String q = et.getText().toString();
                db.child("users").orderByChild("jgId").equalTo(q).addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override public void onDataChange(DataSnapshot s) {
                        if(s.exists()) {
                            String fUid = s.getChildren().iterator().next().getKey();
                            db.child("requests").child(fUid).child(myUid).setValue("pending");
                            Toast.makeText(MainActivity.this, "Sent!", Toast.LENGTH_SHORT).show();
                        } else Toast.makeText(MainActivity.this, "Not found", Toast.LENGTH_SHORT).show();
                    }
                    @Override public void onCancelled(DatabaseError e){}
                });
            }).show();
        });

        findViewById(R.id.btnProfile).setOnClickListener(v -> {
            new AlertDialog.Builder(this).setTitle("Profile").setMessage("ID: " + myJgId)
                .setPositiveButton("Logout", (d,w) -> { auth.signOut(); stopService(new Intent(this, BackgroundService.class)); showView(viewAuth); })
                .setNegativeButton("Close", null).show();
        });
    }

    private void loadTab(String tab) {
        listData.clear(); mainAdapter.notifyDataSetChanged();
        if (tab.equals("chats")) {
            db.child("friends").child(myUid).addValueEventListener(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    if(!viewMain.isShown() || !bottomNav.getMenu().getItem(0).isChecked()) return;
                    listData.clear();
                    for(DataSnapshot s : snap.getChildren()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("type", "chat"); item.put("uid", s.getKey());
                        db.child("users").child(s.getKey()).get().addOnSuccessListener(uSnap -> {
                            if(uSnap.exists()){
                                item.put("title", uSnap.child("name").getValue(String.class));
                                item.put("icon", uSnap.child("emoji").getValue(String.class));
                                item.put("sub", Boolean.TRUE.equals(uSnap.child("online").getValue(Boolean.class)) ? "Online" : "Offline");
                                listData.add(item); mainAdapter.notifyDataSetChanged();
                            }
                        });
                    }
                }
                @Override public void onCancelled(DatabaseError e){}
            });
        } else if (tab.equals("updates")) {
            db.child("requests").child(myUid).addValueEventListener(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    if(!viewMain.isShown() || !bottomNav.getMenu().getItem(1).isChecked()) return;
                    listData.clear();
                    for(DataSnapshot s : snap.getChildren()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("type", "request"); item.put("uid", s.getKey());
                        db.child("users").child(s.getKey()).get().addOnSuccessListener(uSnap -> {
                            item.put("title", uSnap.child("name").getValue(String.class));
                            item.put("icon", uSnap.child("emoji").getValue(String.class));
                            listData.add(item); mainAdapter.notifyDataSetChanged();
                        });
                    }
                }
                @Override public void onCancelled(DatabaseError e){}
            });
        } else if (tab.equals("calls")) {
            db.child("users").child(myUid).child("call_history").addValueEventListener(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snap) {
                    if(!viewMain.isShown() || !bottomNav.getMenu().getItem(2).isChecked()) return;
                    listData.clear();
                    for(DataSnapshot s : snap.getChildren()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("type", "call_hist"); item.put("title", s.child("target").getValue(String.class));
                        item.put("sub", s.child("duration").getValue(String.class) + "s");
                        item.put("icon", "📞");
                        listData.add(item);
                    }
                    mainAdapter.notifyDataSetChanged();
                }
                @Override public void onCancelled(DatabaseError e){}
            });
        }
    }

    class GenericAdapter extends RecyclerView.Adapter<GenericAdapter.VH> {
        class VH extends RecyclerView.ViewHolder {
            TextView icon, title, sub, badge; LinearLayout actions; Button acc, rej;
            VH(View v) { super(v); icon=v.findViewById(R.id.tvIcon); title=v.findViewById(R.id.tvTitle); sub=v.findViewById(R.id.tvSubtitle); badge=v.findViewById(R.id.tvBadge); actions=v.findViewById(R.id.llActions); acc=v.findViewById(R.id.btnAccept); rej=v.findViewById(R.id.btnReject); }
        }
        @Override public VH onCreateViewHolder(ViewGroup p, int t) { return new VH(getLayoutInflater().inflate(R.layout.item_list, p, false)); }
        @Override public int getItemCount() { return listData.size(); }
        @Override public void onBindViewHolder(VH h, int pos) {
            Map<String, String> item = listData.get(pos);
            h.title.setText(item.get("title")); h.icon.setText(item.get("icon")); h.sub.setText(item.get("sub"));
            h.actions.setVisibility("request".equals(item.get("type")) ? View.VISIBLE : View.GONE);
            h.itemView.setOnClickListener(v -> {
                if("chat".equals(item.get("type"))) openChat(item.get("uid"), item.get("title"), item.get("icon"));
            });
            h.acc.setOnClickListener(v -> {
                db.child("friends").child(myUid).child(item.get("uid")).setValue(true);
                db.child("friends").child(item.get("uid")).child(myUid).setValue(true);
                db.child("requests").child(myUid).child(item.get("uid")).removeValue();
            });
            h.rej.setOnClickListener(v -> db.child("requests").child(myUid).child(item.get("uid")).removeValue());
        }
    }

    // --- CHAT UI ---
    private void setupChatUI() {
        rvChat = findViewById(R.id.rvChat);
        rvChat.setLayoutManager(new LinearLayoutManager(this));
        chatAdapter = new ChatAdapter();
        rvChat.setAdapter(chatAdapter);

        findViewById(R.id.btnChatBack).setOnClickListener(v -> showView(viewMain));
        EditText et = findViewById(R.id.etChatInput);
        findViewById(R.id.btnSend).setOnClickListener(v -> {
            String txt = et.getText().toString().trim();
            if(txt.isEmpty() || activeChatUid == null) return;
            String chatId = myUid.compareTo(activeChatUid) < 0 ? myUid+"_"+activeChatUid : activeChatUid+"_"+myUid;
            Map<String, Object> m = new HashMap<>();
            m.put("sender", myUid); m.put("text", txt); m.put("ts", ServerValue.TIMESTAMP);
            db.child("chats").child(chatId).push().setValue(m);
            et.setText("");
        });
        findViewById(R.id.btnVoiceCall).setOnClickListener(v -> startCall(activeChatUid, false));
        findViewById(R.id.btnVideoCall).setOnClickListener(v -> startCall(activeChatUid, true));
    }

    private void openChat(String uid, String name, String emoji) {
        activeChatUid = uid;
        TextView tv = findViewById(R.id.tvChatTitle); tv.setText(emoji + " " + name);
        showView(viewChat);
        chatData.clear(); chatAdapter.notifyDataSetChanged();
        
        String chatId = myUid.compareTo(uid) < 0 ? myUid+"_"+uid : uid+"_"+myUid;
        db.child("chats").child(chatId).limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot snap) {
                if(!viewChat.isShown()) return;
                chatData.clear();
                for(DataSnapshot s : snap.getChildren()) {
                    Map<String, String> m = new HashMap<>();
                    m.put("sender", s.child("sender").getValue(String.class));
                    m.put("text", s.child("text").getValue(String.class));
                    chatData.add(m);
                }
                chatAdapter.notifyDataSetChanged();
                if(chatData.size()>0) rvChat.scrollToPosition(chatData.size()-1);
            }
            @Override public void onCancelled(DatabaseError e){}
        });
    }

    class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.VH> {
        class VH extends RecyclerView.ViewHolder { TextView in, out; VH(View v){super(v); in=v.findViewById(R.id.tvMsgIn); out=v.findViewById(R.id.tvMsgOut);} }
        @Override public VH onCreateViewHolder(ViewGroup p, int t) { return new VH(getLayoutInflater().inflate(R.layout.item_message, p, false)); }
        @Override public int getItemCount() { return chatData.size(); }
        @Override public void onBindViewHolder(VH h, int pos) {
            Map<String, String> m = chatData.get(pos);
            boolean isMe = myUid.equals(m.get("sender"));
            h.in.setVisibility(isMe ? View.GONE : View.VISIBLE); h.in.setText(m.get("text"));
            h.out.setVisibility(isMe ? View.VISIBLE : View.GONE); h.out.setText(m.get("text"));
        }
    }

    // --- WEBRTC & CALLS ---
    private void setupCallUI() {
        localVideo = findViewById(R.id.localVideo); remoteVideo = findViewById(R.id.remoteVideo);
        findViewById(R.id.btnEndCall).setOnClickListener(v -> endCall());
        findViewById(R.id.btnAcceptCall).setOnClickListener(v -> acceptCall());
    }

    private void initWebRTC() {
        if(eglBase != null) return;
        eglBase = EglBase.create();
        localVideo.init(eglBase.getEglBaseContext(), null); remoteVideo.init(eglBase.getEglBaseContext(), null);
        PeerConnectionFactory.InitializationOptions opts = PeerConnectionFactory.InitializationOptions.builder(this).createInitializationOptions();
        PeerConnectionFactory.initialize(opts);
        
        PeerConnectionFactory.Options po = new PeerConnectionFactory.Options();
        DefaultVideoEncoderFactory enc = new DefaultVideoEncoderFactory(eglBase.getEglBaseContext(), true, true);
        DefaultVideoDecoderFactory dec = new DefaultVideoDecoderFactory(eglBase.getEglBaseContext());
        peerConnectionFactory = PeerConnectionFactory.builder().setOptions(po).setVideoEncoderFactory(enc).setVideoDecoderFactory(dec).createPeerConnectionFactory();
    }

    private void createMediaTracks(boolean isVideo) {
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        audioManager.setSpeakerphoneOn(isVideo);
        
        localAudioTrack = peerConnectionFactory.createAudioTrack("ARDAMSa0", peerConnectionFactory.createAudioSource(new MediaConstraints()));
        if(isVideo) {
            Camera2Enumerator enumCam = new Camera2Enumerator(this);
            String[] devs = enumCam.getDeviceNames();
            String camName = devs[0];
            for(String d : devs) if(enumCam.isFrontFacing(d)) { camName = d; break; }
            videoCapturer = enumCam.createCapturer(camName, null);
            surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", eglBase.getEglBaseContext());
            VideoSource vs = peerConnectionFactory.createVideoSource(videoCapturer.isScreencast());
            videoCapturer.initialize(surfaceTextureHelper, this, vs.getCapturerObserver());
            videoCapturer.startCapture(480, 640, 30);
            localVideoTrack = peerConnectionFactory.createVideoTrack("ARDAMSv0", vs);
            localVideoTrack.addSink(localVideo);
            localVideo.setVisibility(View.VISIBLE);
        } else { localVideo.setVisibility(View.GONE); }
    }

    private void createPeerConnection() {
        List<PeerConnection.IceServer> iceServers = Collections.singletonList(PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer());
        PeerConnection.RTCConfiguration rtcConfig = new PeerConnection.RTCConfiguration(iceServers);
        peerConnection = peerConnectionFactory.createPeerConnection(rtcConfig, new PeerConnection.Observer() {
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {}
            @Override public void onIceConnectionChange(PeerConnection.IceConnectionState s) {}
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}
            @Override public void onIceCandidate(IceCandidate c) {
                if(callRef != null) callRef.child("candidates").child(myUid).push().setValue(
                    new HashMap<String,Object>(){{ put("sdp", c.sdp); put("sdpMLineIndex", c.sdpMLineIndex); put("sdpMid", c.sdpMid); }}
                );
            }
            @Override public void onIceCandidatesRemoved(IceCandidate[] c) {}
            @Override public void onAddStream(MediaStream s) {
                if(s.videoTracks.size() > 0) runOnUiThread(() -> s.videoTracks.get(0).addSink(remoteVideo));
            }
            @Override public void onRemoveStream(MediaStream s) {}
            @Override public void onDataChannel(DataChannel d) {}
            @Override public void onRenegotiationNeeded() {}
            @Override public void onAddTrack(RtpReceiver r, MediaStream[] s) {}
        });
        peerConnection.addTrack(localAudioTrack);
        if(localVideoTrack != null) peerConnection.addTrack(localVideoTrack);
    }

    private void startCall(String targetUid, boolean isVideo) {
        initWebRTC(); isVideoCall = isVideo; activeCallUid = targetUid;
        showView(viewCall); findViewById(R.id.btnAcceptCall).setVisibility(View.GONE);
        ((TextView)findViewById(R.id.tvCallStatus)).setText("Calling...");
        createMediaTracks(isVideo);
        createPeerConnection();

        callRef = db.child("calls").child(targetUid);
        Map<String, Object> callData = new HashMap<>();
        callData.put("caller", myUid); callData.put("type", isVideo ? "video" : "voice");
        callRef.setValue(callData);

        peerConnection.createOffer(new SimpleSdpObserver() {
            @Override public void onCreateSuccess(SessionDescription desc) {
                peerConnection.setLocalDescription(new SimpleSdpObserver(), desc);
                callRef.child("offer").setValue(new HashMap<String,String>(){{ put("type", desc.type.canonicalForm()); put("sdp", desc.description); }});
            }
        }, new MediaConstraints());

        listenForAnswerAndCandidates(targetUid);
    }

    private void listenForCalls() {
        db.child("calls").child(myUid).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot s) {
                if(s.exists() && s.hasChild("offer") && activeCallUid == null) {
                    activeCallUid = s.child("caller").getValue(String.class);
                    isVideoCall = "video".equals(s.child("type").getValue(String.class));
                    callRef = db.child("calls").child(myUid);
                    showView(viewCall);
                    ((TextView)findViewById(R.id.tvCallStatus)).setText("Incoming Call...");
                    findViewById(R.id.btnAcceptCall).setVisibility(View.VISIBLE);
                } else if (!s.exists() && activeCallUid != null) {
                    endCall();
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
    }

    private void acceptCall() {
        findViewById(R.id.btnAcceptCall).setVisibility(View.GONE);
        ((TextView)findViewById(R.id.tvCallStatus)).setText("Connecting...");
        initWebRTC(); createMediaTracks(isVideoCall); createPeerConnection();
        
        callRef.child("offer").get().addOnSuccessListener(snap -> {
            String sdp = snap.child("sdp").getValue(String.class);
            peerConnection.setRemoteDescription(new SimpleSdpObserver(), new SessionDescription(SessionDescription.Type.OFFER, sdp));
            peerConnection.createAnswer(new SimpleSdpObserver() {
                @Override public void onCreateSuccess(SessionDescription desc) {
                    peerConnection.setLocalDescription(new SimpleSdpObserver(), desc);
                    callRef.child("answer").setValue(new HashMap<String,String>(){{ put("type", desc.type.canonicalForm()); put("sdp", desc.description); }});
                }
            }, new MediaConstraints());
        });
        listenForAnswerAndCandidates(myUid);
    }

    private void listenForAnswerAndCandidates(String nodeUid) {
        db.child("calls").child(nodeUid).child("answer").addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot s) {
                if(s.exists() && peerConnection.getRemoteDescription() == null) {
                    peerConnection.setRemoteDescription(new SimpleSdpObserver(), new SessionDescription(SessionDescription.Type.ANSWER, s.child("sdp").getValue(String.class)));
                }
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
        db.child("calls").child(nodeUid).child("candidates").addChildEventListener(new ChildEventListener() {
            @Override public void onChildAdded(DataSnapshot s, String p) {
                if(!s.getKey().equals(myUid)) {
                    for(DataSnapshot cs : s.getChildren()) {
                        peerConnection.addIceCandidate(new IceCandidate(cs.child("sdpMid").getValue(String.class), cs.child("sdpMLineIndex").getValue(Integer.class), cs.child("sdp").getValue(String.class)));
                    }
                }
            }
            @Override public void onChildChanged(DataSnapshot s, String p){} @Override public void onChildRemoved(DataSnapshot s){} @Override public void onChildMoved(DataSnapshot s, String p){} @Override public void onCancelled(DatabaseError e){}
        });
    }

    private void endCall() {
        if(activeCallUid == null) return;
        if(callRef != null) callRef.removeValue();
        if(peerConnection != null) { peerConnection.close(); peerConnection = null; }
        if(videoCapturer != null) { try{videoCapturer.stopCapture(); videoCapturer.dispose();}catch(Exception e){} videoCapturer = null; }
        if(surfaceTextureHelper != null) { surfaceTextureHelper.dispose(); surfaceTextureHelper = null; }
        if(localVideo != null) localVideo.release(); if(remoteVideo != null) remoteVideo.release();
        if(peerConnectionFactory != null) { peerConnectionFactory.dispose(); peerConnectionFactory = null; }
        if(eglBase != null) { eglBase.release(); eglBase = null; }
        
        audioManager.setMode(AudioManager.MODE_NORMAL);
        activeCallUid = null; callRef = null;
        db.child("users").child(myUid).child("call_history").push().setValue(new HashMap<String,String>(){{put("target", activeChatUid!=null?activeChatUid:"Unknown"); put("duration", "0");}});
        showView(viewMain);
    }

    class SimpleSdpObserver implements SdpObserver {
        @Override public void onCreateSuccess(SessionDescription s) {}
        @Override public void onSetSuccess() {}
        @Override public void onCreateFailure(String s) {}
        @Override public void onSetFailure(String s) {}
    }
}
EOF

# Build Application
wget -q https://services.gradle.org/distributions/gradle-8.2-bin.zip
unzip -q -o gradle-8.2-bin.zip -d /opt/gradle || unzip -q -o gradle-8.2-bin.zip -d $PWD/gradle_bin
GRADLE_DIR=$PWD/gradle_bin/gradle-8.2/bin
if [ -d "/opt/gradle/gradle-8.2/bin" ]; then GRADLE_DIR="/opt/gradle/gradle-8.2/bin"; fi

$GRADLE_DIR/gradle wrapper --gradle-version 8.2
chmod +x gradlew
./gradlew clean assembleRelease