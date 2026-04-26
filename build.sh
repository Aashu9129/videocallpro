mkdir -p videocallpro
cd videocallpro

# 1. Setup Android SDK (Local Directory)
export ANDROID_HOME="$PWD/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"
wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
yes | sdkmanager --licenses > /dev/null
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null

# 2. Keystore Generation
mkdir -p keystore
keytool -genkey -v -keystore keystore/release.jks -alias javagoat -keyalg RSA -keysize 2048 -validity 10000 -storepass "javagoat123" -keypass "javagoat123" -dname "CN=Java Goat, OU=Dev, O=Videocallpro, L=City, S=State, C=IN"

# 3. Project Structure
APP_DIR="app/src/main"
mkdir -p $APP_DIR/java/com/example/callingapp
mkdir -p $APP_DIR/res/layout
mkdir -p $APP_DIR/res/values
mkdir -p $APP_DIR/res/drawable
mkdir -p $APP_DIR/res/menu
mkdir -p $APP_DIR/res/mipmap-anydpi-v26

# 4. Gradle Files
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
rootProject.name = "Java Goat"
include ':app'
EOF

cat <<'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
EOF

cat <<'EOF' > build.gradle
plugins {
    id 'com.android.application' version '8.2.0' apply false
}
EOF

cat <<'EOF' > app/build.gradle
plugins {
    id 'com.android.application'
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
            storeFile file("../keystore/release.jks")
            storePassword "javagoat123"
            keyAlias "javagoat"
            keyPassword "javagoat123"
        }
    }

    buildTypes {
        release {
            minifyEnabled false
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
    implementation 'io.getstream:stream-webrtc-android:1.1.1'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
}
EOF

# 5. Manifest
cat <<'EOF' > $APP_DIR/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="Java Goat"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.JavaGoat">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="portrait"
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

# 6. Resources (Values, Drawables, Layouts)
cat <<'EOF' > $APP_DIR/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#075E54</color>
    <color name="primary_dark">#054C44</color>
    <color name="accent">#34B7F1</color>
    <color name="msg_out">#E2FFC7</color>
    <color name="msg_in">#FFFFFF</color>
    <color name="bg_chat">#ECE5DD</color>
    <color name="call_accept">#25D366</color>
    <color name="call_reject">#FF3B30</color>
    <color name="text_dark">#303030</color>
    <color name="text_light">#FFFFFF</color>
</resources>
EOF

cat <<'EOF' > $APP_DIR/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.JavaGoat" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="colorPrimaryVariant">@color/primary_dark</item>
        <item name="colorOnPrimary">@color/text_light</item>
        <item name="colorSecondary">@color/accent</item>
        <item name="colorSecondaryVariant">@color/accent</item>
        <item name="colorOnSecondary">@color/text_dark</item>
        <item name="android:statusBarColor">?attr/colorPrimaryVariant</item>
    </style>
</resources>
EOF

cat <<'EOF' > $APP_DIR/res/drawable/msg_out_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_out"/>
    <corners android:topLeftRadius="12dp" android:topRightRadius="0dp" android:bottomLeftRadius="12dp" android:bottomRightRadius="12dp"/>
</shape>
EOF

cat <<'EOF' > $APP_DIR/res/drawable/msg_in_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="@color/msg_in"/>
    <corners android:topLeftRadius="0dp" android:topRightRadius="12dp" android:bottomLeftRadius="12dp" android:bottomRightRadius="12dp"/>
</shape>
EOF

cat <<'EOF' > $APP_DIR/res/drawable/emoji_bg.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="@color/accent"/>
</shape>
EOF

cat <<'EOF' > $APP_DIR/res/drawable/ic_launcher_background.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="@color/primary" android:pathData="M0,0h108v108h-108z"/>
</vector>
EOF

cat <<'EOF' > $APP_DIR/res/drawable/ic_launcher_foreground.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#FFFFFF" android:pathData="M20,4H4C2.9,4 2.01,4.9 2.01,6L2,18C2,19.1 2.9,20 4,20H20C21.1,20 22,19.1 22,18V6C22,4.9 21.1,4 20,4ZM20,8L12,13L4,8V6L12,11L20,6V8Z"/>
</vector>
EOF

cat <<'EOF' > $APP_DIR/res/mipmap-anydpi-v26/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat <<'EOF' > $APP_DIR/res/mipmap-anydpi-v26/ic_launcher_round.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat <<'EOF' > $APP_DIR/res/menu/bottom_nav_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_chats" android:title="Chats" />
    <item android:id="@+id/nav_updates" android:title="Updates" />
    <item android:id="@+id/nav_calls" android:title="Calls" />
</menu>
EOF

cat <<'EOF' > $APP_DIR/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <!-- Auth View -->
    <LinearLayout android:id="@+id/auth_view" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:gravity="center" android:padding="32dp" android:visibility="gone">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Java Goat" android:textSize="32sp" android:textStyle="bold" android:textColor="@color/primary" android:layout_marginBottom="24dp"/>
        <EditText android:id="@+id/et_email" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Email" android:inputType="textEmailAddress"/>
        <EditText android:id="@+id/et_pass" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Password" android:inputType="textPassword" android:layout_marginTop="8dp"/>
        <Button android:id="@+id/btn_login" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Login / Signup" android:layout_marginTop="16dp"/>
    </LinearLayout>

    <!-- Main View -->
    <LinearLayout android:id="@+id/main_view" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:visibility="gone">
        <androidx.appcompat.widget.Toolbar android:id="@+id/toolbar" android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@color/primary" app:titleTextColor="@color/text_light" app:title="Java Goat"/>
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rv_main" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1"/>
        <com.google.android.material.bottomnavigation.BottomNavigationView android:id="@+id/bottom_nav" android:layout_width="match_parent" android:layout_height="wrap_content" app:menu="@menu/bottom_nav_menu" app:itemTextColor="@color/primary" app:itemIconTint="@color/primary" />
    </LinearLayout>

    <!-- Chat View -->
    <LinearLayout android:id="@+id/chat_view" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/bg_chat" android:visibility="gone">
        <LinearLayout android:layout_width="match_parent" android:layout_height="?attr/actionBarSize" android:background="@color/primary" android:gravity="center_vertical" android:padding="8dp">
            <Button android:id="@+id/btn_chat_back" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Back" style="?attr/borderlessButtonStyle" android:textColor="@color/text_light"/>
            <TextView android:id="@+id/tv_chat_title" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:textColor="@color/text_light" android:textSize="18sp" android:textStyle="bold" android:layout_marginStart="8dp"/>
            <Button android:id="@+id/btn_call_voice" android:layout_width="48dp" android:layout_height="48dp" android:text="📞" style="?attr/borderlessButtonStyle" android:textColor="@color/text_light"/>
            <Button android:id="@+id/btn_call_video" android:layout_width="48dp" android:layout_height="48dp" android:text="📹" style="?attr/borderlessButtonStyle" android:textColor="@color/text_light"/>
        </LinearLayout>
        <androidx.recyclerview.widget.RecyclerView android:id="@+id/rv_chat" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:padding="8dp" android:clipToPadding="false"/>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="8dp" android:background="@color/text_light">
            <EditText android:id="@+id/et_msg" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:hint="Message" android:background="@null" android:padding="12dp"/>
            <Button android:id="@+id/btn_send" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Send" android:backgroundTint="@color/primary"/>
        </LinearLayout>
    </LinearLayout>

    <!-- Call View -->
    <FrameLayout android:id="@+id/call_view" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#000000" android:visibility="gone">
        <org.webrtc.SurfaceViewRenderer android:id="@+id/remote_video_view" android:layout_width="match_parent" android:layout_height="match_parent" />
        <org.webrtc.SurfaceViewRenderer android:id="@+id/local_video_view" android:layout_width="120dp" android:layout_height="160dp" android:layout_gravity="bottom|end" android:layout_margin="16dp" />
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center" android:layout_marginTop="48dp">
            <TextView android:id="@+id/tv_call_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="@color/text_light" android:textSize="24sp" android:textStyle="bold" />
            <TextView android:id="@+id/tv_call_status" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="@color/text_light" android:textSize="16sp" />
        </LinearLayout>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_gravity="bottom|center_horizontal" android:gravity="center" android:padding="32dp" android:orientation="horizontal">
            <Button android:id="@+id/btn_accept_call" android:layout_width="64dp" android:layout_height="64dp" android:backgroundTint="@color/call_accept" android:text="✔️" android:visibility="gone" android:layout_marginEnd="32dp" app:cornerRadius="32dp"/>
            <Button android:id="@+id/btn_end_call" android:layout_width="64dp" android:layout_height="64dp" android:backgroundTint="@color/call_reject" android:text="✖️" app:cornerRadius="32dp"/>
        </LinearLayout>
    </FrameLayout>
</FrameLayout>
EOF

cat <<'EOF' > $APP_DIR/res/layout/item_list.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center_vertical">
    <TextView android:id="@+id/tv_avatar" android:layout_width="48dp" android:layout_height="48dp" android:background="@drawable/emoji_bg" android:gravity="center" android:textSize="24sp" android:textColor="@color/text_light"/>
    <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical" android:layout_marginStart="16dp">
        <TextView android:id="@+id/tv_title" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textStyle="bold" android:textSize="16sp" android:textColor="@color/text_dark"/>
        <TextView android:id="@+id/tv_subtitle" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="14sp" android:maxLines="1" android:ellipsize="end"/>
    </LinearLayout>
    <Button android:id="@+id/btn_action1" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Accept" android:visibility="gone" android:layout_marginStart="8dp"/>
    <Button android:id="@+id/btn_action2" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Reject" android:visibility="gone" android:layout_marginStart="8dp" android:backgroundTint="@color/call_reject"/>
</LinearLayout>
EOF

cat <<'EOF' > $APP_DIR/res/layout/item_message.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/msg_container" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="4dp">
    <TextView android:id="@+id/tv_msg" android:layout_width="wrap_content" android:layout_height="wrap_content" android:padding="12dp" android:textColor="@color/text_dark" android:textSize="16sp" android:maxWidth="260dp"/>
</LinearLayout>
EOF

cat <<'EOF' > $APP_DIR/res/layout/dialog_input.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp">
    <EditText android:id="@+id/et_input1" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Input 1"/>
    <EditText android:id="@+id/et_input2" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Input 2" android:layout_marginTop="8dp"/>
</LinearLayout>
EOF

# 7. Java Source Files
cat <<'EOF' > $APP_DIR/java/com/example/callingapp/BackgroundService.java
package com.example.callingapp;

import android.app.*;
import android.content.Intent;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;

public class BackgroundService extends Service {
    private static final String CHANNEL_ID = "JavaGoatChannel";
    private static final String CALL_CHANNEL_ID = "JavaGoatCallChannel";
    private DatabaseReference dbRef;
    private ValueEventListener callListener;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannels();
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Java Goat")
                .setContentText("Listening for messages and calls")
                .setSmallIcon(android.R.drawable.sym_def_app_icon)
                .build();
        startForeground(1, notification);

        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
            dbRef = FirebaseDatabase.getInstance().getReference();
            
            callListener = dbRef.child("calls").child(uid).addValueEventListener(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot snapshot) {
                    if (snapshot.exists() && !MainActivity.isAppInForeground) {
                        Intent fullScreenIntent = new Intent(BackgroundService.this, MainActivity.class);
                        fullScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        PendingIntent pi = PendingIntent.getActivity(BackgroundService.this, 0, fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                        
                        Notification callNotif = new NotificationCompat.Builder(BackgroundService.this, CALL_CHANNEL_ID)
                                .setSmallIcon(android.R.drawable.sym_call_incoming)
                                .setContentTitle("Incoming Call")
                                .setContentText("You have an incoming call on Java Goat")
                                .setPriority(NotificationCompat.PRIORITY_MAX)
                                .setCategory(NotificationCompat.CATEGORY_CALL)
                                .setFullScreenIntent(pi, true)
                                .build();
                        NotificationManager nm = getSystemService(NotificationManager.class);
                        nm.notify(2, callNotif);
                    }
                }
                @Override public void onCancelled(DatabaseError error) {}
            });
        }
    }

    private void createNotificationChannels() {
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel c1 = new NotificationChannel(CHANNEL_ID, "Background Sync", NotificationManager.IMPORTANCE_LOW);
            NotificationChannel c2 = new NotificationChannel(CALL_CHANNEL_ID, "Incoming Calls", NotificationManager.IMPORTANCE_HIGH);
            nm.createNotificationChannel(c1);
            nm.createNotificationChannel(c2);
        }
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) { return START_STICKY; }
    @Override public IBinder onBind(Intent intent) { return null; }
    @Override public void onDestroy() {
        super.onDestroy();
        if (dbRef != null && callListener != null && FirebaseAuth.getInstance().getCurrentUser() != null) {
            dbRef.child("calls").child(FirebaseAuth.getInstance().getCurrentUser().getUid()).removeEventListener(callListener);
        }
    }
}
EOF

cat <<'EOF' > $APP_DIR/java/com/example/callingapp/MainActivity.java
package com.example.callingapp;

import android.Manifest;
import android.app.AlertDialog;
import android.app.NotificationManager;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.*;
import org.webrtc.*;
import java.util.*;

public class MainActivity extends AppCompatActivity {
    public static boolean isAppInForeground = false;
    private FrameLayout authView, callView;
    private LinearLayout mainView, chatView;
    private EditText etEmail, etPass, etMsg;
    private TextView tvChatTitle, tvCallName, tvCallStatus;
    private RecyclerView rvMain, rvChat;
    private Button btnAcceptCall, btnEndCall;
    private BottomNavigationView bottomNav;
    private SurfaceViewRenderer localVideoView, remoteVideoView;

    private FirebaseAuth auth;
    private DatabaseReference db;
    private String myUid, myJgId, currentPartnerUid, currentCallPartnerUid;
    private boolean isCaller = false, isVideoCall = false;

    // WebRTC
    private EglBase rootEglBase;
    private PeerConnectionFactory factory;
    private PeerConnection peerConnection;
    private AudioSource audioSource;
    private VideoSource videoSource;
    private AudioTrack localAudioTrack;
    private VideoTrack localVideoTrack;
    private VideoCapturer videoCapturer;
    private SurfaceTextureHelper surfaceTextureHelper;
    private List<PeerConnection.IceServer> iceServers;

    private GenericAdapter mainAdapter;
    private ChatAdapter chatAdapter;
    private List<Map<String, String>> mainItems = new ArrayList<>();
    private List<Map<String, String>> chatItems = new ArrayList<>();
    private int currentTab = R.id.nav_chats;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Dummy Firebase Init (Hardcoded credentials request)
        if (FirebaseApp.getApps(this).isEmpty()) {
            FirebaseOptions options = new FirebaseOptions.Builder()
                .setApiKey("AIzaSyDummyKeyForScriptGenerationOnly")
                .setApplicationId("1:1234567890:android:abcdef123456")
                .setDatabaseUrl("https://dummy-default-rtdb.firebaseio.com")
                .setProjectId("dummy-project")
                .build();
            FirebaseApp.initializeApp(this, options);
        }

        auth = FirebaseAuth.getInstance();
        db = FirebaseDatabase.getInstance().getReference();

        authView = findViewById(R.id.auth_view);
        mainView = findViewById(R.id.main_view);
        chatView = findViewById(R.id.chat_view);
        callView = findViewById(R.id.call_view);
        
        etEmail = findViewById(R.id.et_email);
        etPass = findViewById(R.id.et_pass);
        etMsg = findViewById(R.id.et_msg);
        tvChatTitle = findViewById(R.id.tv_chat_title);
        tvCallName = findViewById(R.id.tv_call_name);
        tvCallStatus = findViewById(R.id.tv_call_status);
        rvMain = findViewById(R.id.rv_main);
        rvChat = findViewById(R.id.rv_chat);
        btnAcceptCall = findViewById(R.id.btn_accept_call);
        btnEndCall = findViewById(R.id.btn_end_call);
        bottomNav = findViewById(R.id.bottom_nav);
        localVideoView = findViewById(R.id.local_video_view);
        remoteVideoView = findViewById(R.id.remote_video_view);

        rvMain.setLayoutManager(new LinearLayoutManager(this));
        rvChat.setLayoutManager(new LinearLayoutManager(this));

        checkPermissions();

        findViewById(R.id.btn_login).setOnClickListener(v -> doLogin());
        findViewById(R.id.btn_chat_back).setOnClickListener(v -> showView(mainView));
        findViewById(R.id.btn_send).setOnClickListener(v -> sendMsg());
        findViewById(R.id.btn_call_voice).setOnClickListener(v -> initiateCall(false));
        findViewById(R.id.btn_call_video).setOnClickListener(v -> initiateCall(true));
        btnAcceptCall.setOnClickListener(v -> acceptCall());
        btnEndCall.setOnClickListener(v -> endCall());

        bottomNav.setOnItemSelectedListener(item -> {
            currentTab = item.getItemId();
            loadTabData();
            return true;
        });

        initWebRTC();

        if (auth.getCurrentUser() != null) {
            setupUser(auth.getCurrentUser());
        } else {
            showView(authView);
        }
    }

    private void checkPermissions() {
        String[] perms = {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO, Manifest.permission.POST_NOTIFICATIONS};
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            perms = new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO, Manifest.permission.POST_NOTIFICATIONS, Manifest.permission.FOREGROUND_SERVICE_DATA_SYNC};
        }
        boolean need = false;
        for (String p : perms) if (ActivityCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED) need = true;
        if (need) ActivityCompat.requestPermissions(this, perms, 1);
    }

    private void doLogin() {
        String e = etEmail.getText().toString(), p = etPass.getText().toString();
        if (e.isEmpty() || p.isEmpty()) return;
        auth.signInWithEmailAndPassword(e, p).addOnSuccessListener(res -> setupUser(res.getUser()))
            .addOnFailureListener(ex -> auth.createUserWithEmailAndPassword(e, p).addOnSuccessListener(res -> {
                showProfileSetup(res.getUser());
            }));
    }

    private void showProfileSetup(FirebaseUser u) {
        View v = getLayoutInflater().inflate(R.layout.dialog_input, null);
        EditText e1 = v.findViewById(R.id.et_input1); e1.setHint("Name");
        EditText e2 = v.findViewById(R.id.et_input2); e2.setHint("Emoji Avatar");
        new AlertDialog.Builder(this).setTitle("Setup Profile").setView(v).setPositiveButton("Save", (d, w) -> {
            String jgId = "jg-" + (1000 + new Random().nextInt(9000));
            Map<String, Object> data = new HashMap<>();
            data.put("name", e1.getText().toString());
            data.put("emoji", e2.getText().toString());
            data.put("jgid", jgId);
            data.put("uid", u.getUid());
            db.child("users").child(u.getUid()).setValue(data);
            setupUser(u);
        }).show();
    }

    private void setupUser(FirebaseUser u) {
        myUid = u.getUid();
        db.child("users").child(myUid).child("jgid").get().addOnSuccessListener(s -> myJgId = s.getValue(String.class));
        db.child("users").child(myUid).child("online").setValue(true);
        db.child("users").child(myUid).child("online").onDisconnect().setValue(false);
        
        Intent svc = new Intent(this, BackgroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(svc); else startService(svc);

        listenForCalls();
        showView(mainView);
        loadTabData();
    }

    private void loadTabData() {
        mainItems.clear();
        mainAdapter = new GenericAdapter();
        rvMain.setAdapter(mainAdapter);
        if (currentTab == R.id.nav_chats) {
            db.child("friends").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot s) {
                    for (DataSnapshot c : s.getChildren()) {
                        db.child("users").child(c.getKey()).get().addOnSuccessListener(us -> {
                            if(us.exists()){
                                Map<String, String> m = new HashMap<>();
                                m.put("uid", us.child("uid").getValue(String.class));
                                m.put("name", us.child("name").getValue(String.class));
                                m.put("emoji", us.child("emoji").getValue(String.class));
                                mainItems.add(m);
                                mainAdapter.notifyDataSetChanged();
                            }
                        });
                    }
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
        } else if (currentTab == R.id.nav_updates) {
            db.child("requests").child(myUid).addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot s) {
                    for (DataSnapshot c : s.getChildren()) {
                        Map<String, String> m = new HashMap<>();
                        m.put("uid", c.getKey());
                        m.put("name", "Friend Request");
                        mainItems.add(m);
                    }
                    mainAdapter.notifyDataSetChanged();
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
        } else if (currentTab == R.id.nav_calls) {
            db.child("users").child(myUid).child("call_history").addListenerForSingleValueEvent(new ValueEventListener() {
                @Override public void onDataChange(DataSnapshot s) {
                    for (DataSnapshot c : s.getChildren()) {
                        Map<String, String> m = new HashMap<>();
                        m.put("name", "Call Log");
                        m.put("duration", c.getValue(String.class));
                        mainItems.add(m);
                    }
                    mainAdapter.notifyDataSetChanged();
                }
                @Override public void onCancelled(DatabaseError e) {}
            });
        }
    }

    private void openChat(Map<String, String> user) {
        currentPartnerUid = user.get("uid");
        tvChatTitle.setText(user.get("emoji") + " " + user.get("name"));
        showView(chatView);
        chatItems.clear();
        chatAdapter = new ChatAdapter();
        rvChat.setAdapter(chatAdapter);

        String chatId = myUid.compareTo(currentPartnerUid) < 0 ? myUid + "_" + currentPartnerUid : currentPartnerUid + "_" + myUid;
        db.child("chats").child(chatId).limitToLast(50).addValueEventListener(new ValueEventListener() {
            @Override public void onDataChange(DataSnapshot s) {
                chatItems.clear();
                for (DataSnapshot c : s.getChildren()) {
                    Map<String, String> msg = new HashMap<>();
                    msg.put("text", c.child("text").getValue(String.class));
                    msg.put("sender", c.child("sender").getValue(String.class));
                    chatItems.add(msg);
                }
                chatAdapter.notifyDataSetChanged();
                if(chatItems.size()>0) rvChat.scrollToPosition(chatItems.size()-1);
            }
            @Override public void onCancelled(DatabaseError e) {}
        });
    }

    private void sendMsg() {
        String txt = etMsg.getText().toString();
        if (txt.isEmpty() || currentPartnerUid == null) return;
        String chatId = myUid.compareTo(currentPartnerUid) < 0 ? myUid + "_" + currentPartnerUid : currentPartnerUid + "_" + myUid;
        Map<String, Object> m = new HashMap<>();
        m.put("text", txt); m.put("sender", myUid); m.put("ts", ServerValue.TIMESTAMP);
        db.child("chats").child(chatId).push().setValue(m);
        etMsg.setText("");
    }

    // WebRTC Implementation
    private void initWebRTC() {
        rootEglBase = EglBase.create();
        localVideoView.init(rootEglBase.getEglBaseContext(), null);
        remoteVideoView.init(rootEglBase.getEglBaseContext(), null);
        localVideoView.setZOrderMediaOverlay(true);
        localVideoView.setMirror(true);

        PeerConnectionFactory.InitializationOptions opts = PeerConnectionFactory.InitializationOptions.builder(this).createInitializationOptions();
        PeerConnectionFactory.initialize(opts);

        PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
        DefaultVideoEncoderFactory encoderFactory = new DefaultVideoEncoderFactory(rootEglBase.getEglBaseContext(), true, true);
        DefaultVideoDecoderFactory decoderFactory = new DefaultVideoDecoderFactory(rootEglBase.getEglBaseContext());
        factory = PeerConnectionFactory.builder().setOptions(options).setVideoEncoderFactory(encoderFactory).setVideoDecoderFactory(decoderFactory).createPeerConnectionFactory();

        iceServers = Arrays.asList(
            PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer(),
            PeerConnection.IceServer.builder("stun:stun1.l.google.com:19302").createIceServer()
        );
    }

    private void createMediaTracks() {
        audioSource = factory.createAudioSource(new MediaConstraints());
        localAudioTrack = factory.createAudioTrack("101", audioSource);

        videoCapturer = createCameraCapturer(new Camera2Enumerator(this));
        if (videoCapturer != null) {
            surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", rootEglBase.getEglBaseContext());
            videoSource = factory.createVideoSource(videoCapturer.isScreencast());
            videoCapturer.initialize(surfaceTextureHelper, this, videoSource.getCapturerObserver());
            videoCapturer.startCapture(1280, 720, 30);
            localVideoTrack = factory.createVideoTrack("100", videoSource);
            localVideoTrack.addSink(localVideoView);
        }
    }

    private VideoCapturer createCameraCapturer(CameraEnumerator enumerator) {
        String[] devNames = enumerator.getDeviceNames();
        for (String dev : devNames) if (enumerator.isFrontFacing(dev)) return enumerator.createCapturer(dev, null);
        for (String dev : devNames) if (enumerator.isBackFacing(dev)) return enumerator.createCapturer(dev, null);
        return null;
    }

    private void createPeerConnection() {
        PeerConnection.RTCConfiguration rtcConfig = new PeerConnection.RTCConfiguration(iceServers);
        peerConnection = factory.createPeerConnection(rtcConfig, new PeerConnection.Observer() {
            @Override public void onSignalingChange(PeerConnection.SignalingState s) {}
            @Override public void onIceConnectionChange(PeerConnection.IceConnectionState s) {
                runOnUiThread(() -> { if (s == PeerConnection.IceConnectionState.DISCONNECTED || s == PeerConnection.IceConnectionState.FAILED) endCall(); });
            }
            @Override public void onIceConnectionReceivingChange(boolean b) {}
            @Override public void onIceGatheringChange(PeerConnection.IceGatheringState s) {}
            @Override public void onIceCandidate(IceCandidate iceCandidate) {
                if(currentCallPartnerUid != null) {
                    db.child("calls").child(currentCallPartnerUid).child("candidates").child(isCaller ? "caller" : "receiver").push().setValue(
                        new HashMap<String, String>() {{ put("sdpMid", iceCandidate.sdpMid); put("sdpMLineIndex", String.valueOf(iceCandidate.sdpMLineIndex)); put("sdp", iceCandidate.sdp); }}
                    );
                }
            }
            @Override public void onIceCandidatesRemoved(IceCandidate[] iceCandidates) {}
            @Override public void onAddStream(MediaStream mediaStream) {
                if (mediaStream.videoTracks.size() > 0) {
                    runOnUiThread(() -> mediaStream.videoTracks.get(0).addSink(remoteVideoView));
                }
            }
            @Override public void onRemoveStream(MediaStream mediaStream) {}
            @Override public void onDataChannel(DataChannel dataChannel) {}
            @Override public void onRenegotiationNeeded() {}
            @Override public void onAddTrack(RtpReceiver rtpReceiver, MediaStream