#!/bin/bash
set -e
echo "═══════════════════════════════════════"
echo "  🌍 GlobeTalk APK Builder v2.0"
echo "  Gradle 8.7 Compatible"
echo "═══════════════════════════════════════"

# Setup Android SDK
export ANDROID_SDK_ROOT=$HOME/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

if [ ! -f "$ANDROID_SDK_ROOT/platform-tools/adb" ]; then
    echo "📥 Downloading Android SDK..."
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
    cd $ANDROID_SDK_ROOT/cmdline-tools
    curl -sO https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip -qo commandlinetools-linux-11076708_latest.zip
    mv cmdline-tools latest 2>/dev/null || true
    yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1
    cd - > /dev/null
    echo "✅ SDK Ready"
fi

# Create project
rm -rf GlobeTalk
mkdir -p GlobeTalk/app/src/main/java/com/globetalk/app/{ui,services}
mkdir -p GlobeTalk/app/src/main/res/values
cd GlobeTalk

echo "📁 Creating project files..."

# settings.gradle
echo "pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }" > settings.gradle
echo "dependencyResolutionManagement { repositories { google(); mavenCentral() } }" >> settings.gradle
echo "rootProject.name = 'GlobeTalk'" >> settings.gradle
echo "include ':app'" >> settings.gradle

# root build.gradle  
echo "plugins {" > build.gradle
echo "    id 'com.android.application' version '8.2.0' apply false" >> build.gradle
echo "    id 'com.google.gms.google-services' version '4.4.0' apply false" >> build.gradle
echo "}" >> build.gradle

# gradle.properties
echo "org.gradle.jvmargs=-Xmx2048m" > gradle.properties
echo "android.useAndroidX=true" >> gradle.properties

# app/build.gradle
cat > app/build.gradle << 'EOF'
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
        versionName "1.0"
    }
    buildTypes {
        release { minifyEnabled false }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
}
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
    implementation 'com.google.firebase:firebase-messaging'
}
EOF

# AndroidManifest.xml
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application
        android:name=".GlobeTalkApp"
        android:allowBackup="true"
        android:label="GlobeTalk"
        android:theme="@style/Theme.GlobeTalk">
        <activity android:name=".ui.SplashActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <activity android:name=".ui.auth.LoginActivity"/>
        <activity android:name=".ui.auth.RegisterActivity"/>
        <activity android:name=".ui.main.MainActivity"/>
        <activity android:name=".ui.chat.ChatListActivity"/>
        <activity android:name=".ui.profile.ProfileActivity"/>
        <activity android:name=".ui.chat.PrivateChatActivity"/>
        <activity android:name=".ui.call.VideoCallActivity"/>
        <service android:name=".services.FCMMessagingService" android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>
    </application>
</manifest>
EOF

# themes.xml
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.GlobeTalk" parent="Theme.MaterialComponents.Light.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="android:statusBarColor">@color/primary_dark</item>
    </style>
    <color name="primary">#FF6B35</color>
    <color name="primary_dark">#E55A25</color>
    <color name="accent">#FFA500</color>
    <color name="white">#FFFFFF</color>
    <color name="background">#F5F5F5</color>
</resources>
EOF

# Create Java directories
mkdir -p app/src/main/java/com/globetalk/app/ui/{auth,main,chat,profile,call}
mkdir -p app/src/main/java/com/globetalk/app/services

# GlobeTalkApp.java
cat > app/src/main/java/com/globetalk/app/GlobeTalkApp.java << 'EOF'
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
EOF

# SplashActivity.java
cat > app/src/main/java/com/globetalk/app/ui/SplashActivity.java << 'EOF'
package com.globetalk.app.ui;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.globetalk.app.ui.auth.LoginActivity;
import com.globetalk.app.ui.main.MainActivity;
public class SplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(android.R.layout.activity_list_item);
        new Handler().postDelayed(() -> {
            if(FirebaseAuth.getInstance().getCurrentUser() != null) {
                startActivity(new Intent(this, MainActivity.class));
            } else {
                startActivity(new Intent(this, LoginActivity.class));
            }
            finish();
        }, 2000);
    }
}
EOF

# LoginActivity.java
cat > app/src/main/java/com/globetalk/app/ui/auth/LoginActivity.java << 'EOF'
package com.globetalk.app.ui.auth;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.globetalk.app.ui.main.MainActivity;
public class LoginActivity extends AppCompatActivity {
    FirebaseAuth auth;
    EditText email, pass;
    Button login;
    TextView register;
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        auth = FirebaseAuth.getInstance();
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setGravity(Gravity.CENTER);
        l.setPadding(50,100,50,50);
        
        TextView t = new TextView(this);
        t.setText("🌍 GlobeTalk");
        t.setTextSize(32);
        l.addView(t);
        
        email = new EditText(this);
        email.setHint("Email");
        l.addView(email);
        
        pass = new EditText(this);
        pass.setHint("Password");
        l.addView(pass);
        
        login = new Button(this);
        login.setText("Login");
        login.setBackgroundColor(0xFFFF6B35);
        login.setTextColor(0xFFFFFFFF);
        l.addView(login);
        
        register = new TextView(this);
        register.setText("Create New Account");
        register.setTextColor(0xFF3B82F6);
        l.addView(register);
        
        setContentView(l);
        
        login.setOnClickListener(v -> {
            String e = email.getText().toString().trim();
            String p = pass.getText().toString().trim();
            if(e.isEmpty() || p.isEmpty()) {
                Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
                return;
            }
            auth.signInWithEmailAndPassword(e, p)
                .addOnCompleteListener(task -> {
                    if(task.isSuccessful()) {
                        startActivity(new Intent(this, MainActivity.class));
                        finish();
                    } else {
                        Toast.makeText(this, "Login failed: " + 
                            task.getException().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
        });
        
        register.setOnClickListener(v -> 
            startActivity(new Intent(this, RegisterActivity.class)));
    }
}
EOF

# RegisterActivity.java
cat > app/src/main/java/com/globetalk/app/ui/auth/RegisterActivity.java << 'EOF'
package com.globetalk.app.ui.auth;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import com.globetalk.app.ui.main.MainActivity;
import java.util.HashMap;
import java.util.Map;
public class RegisterActivity extends AppCompatActivity {
    FirebaseAuth auth;
    DatabaseReference db;
    EditText email, user, pass;
    Button register;
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        auth = FirebaseAuth.getInstance();
        db = FirebaseDatabase.getInstance("https://videocallpro-f5f1b-default-rtdb.firebaseio.com").getReference();
        
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setGravity(Gravity.CENTER);
        l.setPadding(50,100,50,50);
        
        TextView t = new TextView(this);
        t.setText("✨ Register");
        t.setTextSize(28);
        l.addView(t);
        
        email = new EditText(this);
        email.setHint("Email");
        l.addView(email);
        
        user = new EditText(this);
        user.setHint("Username");
        l.addView(user);
        
        pass = new EditText(this);
        pass.setHint("Password (6+ chars)");
        l.addView(pass);
        
        register = new Button(this);
        register.setText("Register");
        register.setBackgroundColor(0xFFFF6B35);
        register.setTextColor(0xFFFFFFFF);
        l.addView(register);
        
        setContentView(l);
        
        register.setOnClickListener(v -> {
            String e = email.getText().toString().trim();
            String u = user.getText().toString().trim();
            String p = pass.getText().toString().trim();
            
            if(e.isEmpty() || u.isEmpty() || p.isEmpty()) {
                Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
                return;
            }
            if(p.length() < 6) {
                Toast.makeText(this, "Password must be 6+ characters", Toast.LENGTH_SHORT).show();
                return;
            }
            
            String finalE = e;
            String finalU = u;
            String finalP = p;
            
            db.child("usernames").child(u).get().addOnCompleteListener(task -> {
                if(task.isSuccessful() && task.getResult().exists()) {
                    Toast.makeText(this, "Username already taken!", Toast.LENGTH_SHORT).show();
                } else {
                    auth.createUserWithEmailAndPassword(finalE, finalP)
                        .addOnCompleteListener(task2 -> {
                            if(task2.isSuccessful()) {
                                String uid = auth.getCurrentUser().getUid();
                                Map<String, Object> userData = new HashMap<>();
                                userData.put("userId", uid);
                                userData.put("username", finalU);
                                userData.put("email", finalE);
                                userData.put("isOnline", true);
                                userData.put("lastSeen", ServerValue.TIMESTAMP);
                                
                                db.child("users").child(uid).setValue(userData);
                                db.child("usernames").child(finalU).setValue(uid);
                                
                                Toast.makeText(this, "Welcome to GlobeTalk! 🎉", Toast.LENGTH_SHORT).show();
                                startActivity(new Intent(this, MainActivity.class));
                                finish();
                            } else {
                                Toast.makeText(this, "Error: " + 
                                    task2.getException().getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        });
                }
            });
        });
    }
}
EOF

# MainActivity.java
cat > app/src/main/java/com/globetalk/app/ui/main/MainActivity.java << 'EOF'
package com.globetalk.app.ui.main;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import com.globetalk.app.ui.auth.LoginActivity;
import com.globetalk.app.ui.chat.ChatListActivity;
import com.globetalk.app.ui.profile.ProfileActivity;
public class MainActivity extends AppCompatActivity {
    DatabaseReference db;
    String uid, username;
    LinearLayout msgContainer;
    EditText input;
    ScrollView scroll;
    
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        db = FirebaseDatabase.getInstance("https://videocallpro-f5f1b-default-rtdb.firebaseio.com").getReference();
        
        // Load username
        db.child("users").child(uid).child("username").addListenerForSingleValueEvent(
            new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot s) {
                    username = s.getValue(String.class);
                }
                @Override
                public void onCancelled(DatabaseError e) {}
            });
        
        // Main Layout
        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        
        // Top Bar
        LinearLayout top = new LinearLayout(this);
        top.setOrientation(LinearLayout.HORIZONTAL);
        top.setBackgroundColor(0xFFFF6B35);
        top.setPadding(20,50,20,20);
        top.setGravity(Gravity.CENTER_VERTICAL);
        
        TextView title = new TextView(this);
        title.setText("🌍 Global Chat");
        title.setTextColor(0xFFFFFFFF);
        title.setTextSize(20);
        top.addView(title);
        
        Button chats = new Button(this);
        chats.setText("💬");
        chats.setBackgroundColor(0x00FFFFFF);
        chats.setOnClickListener(v -> startActivity(new Intent(this, ChatListActivity.class)));
        top.addView(chats);
        
        Button logout = new Button(this);
        logout.setText("🚪");
        logout.setBackgroundColor(0x00FFFFFF);
        logout.setOnClickListener(v -> {
            FirebaseAuth.getInstance().signOut();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
        });
        top.addView(logout);
        
        main.addView(top);
        
        // Messages
        scroll = new ScrollView(this);
        msgContainer = new LinearLayout(this);
        msgContainer.setOrientation(LinearLayout.VERTICAL);
        msgContainer.setPadding(10,10,10,10);
        scroll.addView(msgContainer);
        main.addView(scroll);
        
        // Input
        LinearLayout inputBar = new LinearLayout(this);
        inputBar.setOrientation(LinearLayout.HORIZONTAL);
        inputBar.setPadding(10,10,10,30);
        
        input = new EditText(this);
        input.setHint("Type message...");
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, -2, 1);
        input.setLayoutParams(lp);
        inputBar.addView(input);
        
        Button send = new Button(this);
        send.setText("Send");
        send.setBackgroundColor(0xFFFF6B35);
        send.setTextColor(0xFFFFFFFF);
        inputBar.addView(send);
        
        main.addView(inputBar);
        setContentView(main);
        
        // Load messages
        loadMessages();
        
        send.setOnClickListener(v -> {
            String msg = input.getText().toString().trim();
            if(!msg.isEmpty() && username != null) {
                DatabaseReference ref = db.child("global_chat").push();
                ref.child("senderId").setValue(uid);
                ref.child("senderUsername").setValue(username);
                ref.child("message").setValue(msg);
                ref.child("timestamp").setValue(ServerValue.TIMESTAMP);
                input.setText("");
            }
        });
        
        // Online status
        db.child("users").child(uid).child("isOnline").setValue(true);
        db.child("users").child(uid).child("isOnline").onDisconnect().setValue(false);
    }
    
    void loadMessages() {
        db.child("global_chat").orderByChild("timestamp").limitToLast(50)
            .addChildEventListener(new ChildEventListener() {
                @Override
                public void onChildAdded(DataSnapshot s, String prev) {
                    String user = s.child("senderUsername").getValue(String.class);
                    String msg = s.child("message").getValue(String.class);
                    
                    LinearLayout msgBox = new LinearLayout(MainActivity.this);
                    msgBox.setOrientation(LinearLayout.VERTICAL);
                    msgBox.setPadding(10,8,10,8);
                    
                    TextView userTv = new TextView(MainActivity.this);
                    userTv.setText("@" + user);
                    userTv.setTextColor(0xFFFF6B35);
                    userTv.setTextSize(12);
                    userTv.setOnClickListener(v -> {
                        Intent i = new Intent(MainActivity.this, ProfileActivity.class);
                        i.putExtra("userId", s.child("senderId").getValue(String.class));
                        startActivity(i);
                    });
                    msgBox.addView(userTv);
                    
                    TextView msgTv = new TextView(MainActivity.this);
                    msgTv.setText(msg);
                    msgTv.setTextSize(16);
                    msgBox.addView(msgTv);
                    
                    msgContainer.addView(msgBox);
                    scroll.post(() -> scroll.fullScroll(ScrollView.FOCUS_DOWN));
                }
                @Override public void onChildChanged(DataSnapshot s, String p) {}
                @Override public void onChildRemoved(DataSnapshot s) {}
                @Override public void onChildMoved(DataSnapshot s, String p) {}
                @Override public void onCancelled(DatabaseError e) {}
            });
    }
}
EOF

# ChatListActivity.java
cat > app/src/main/java/com/globetalk/app/ui/chat/ChatListActivity.java << 'EOF'
package com.globetalk.app.ui.chat;
import android.content.Intent;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
public class ChatListActivity extends AppCompatActivity {
    DatabaseReference db;
    String uid;
    LinearLayout list;
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        db = FirebaseDatabase.getInstance("https://videocallpro-f5f1b-default-rtdb.firebaseio.com").getReference();
        
        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        
        TextView title = new TextView(this);
        title.setText("💬 Your Chats");
        title.setTextSize(24);
        title.setPadding(20,50,20,20);
        title.setBackgroundColor(0xFFFF6B35);
        title.setTextColor(0xFFFFFFFF);
        main.addView(title);
        
        // Search
        EditText search = new EditText(this);
        search.setHint("Search username...");
        search.setPadding(20,15,20,15);
        main.addView(search);
        
        Button searchBtn = new Button(this);
        searchBtn.setText("Search");
        searchBtn.setOnClickListener(v -> {
            String q = search.getText().toString().trim();
            if(!q.isEmpty()) {
                db.child("usernames").child(q).addListenerForSingleValueEvent(
                    new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot s) {
                            if(s.exists()) {
                                String foundUid = s.getValue(String.class);
                                Intent i = new Intent(ChatListActivity.this, PrivateChatActivity.class);
                                i.putExtra("otherUserId", foundUid);
                                i.putExtra("otherUsername", q);
                                startActivity(i);
                            } else {
                                Toast.makeText(ChatListActivity.this, "User not found", Toast.LENGTH_SHORT).show();
                            }
                        }
                        @Override
                        public void onCancelled(DatabaseError e) {}
                    });
            }
        });
        main.addView(searchBtn);
        
        list = new LinearLayout(this);
        list.setOrientation(LinearLayout.VERTICAL);
        main.addView(list);
        
        setContentView(main);
        
        loadChats();
    }
    
    void loadChats() {
        db.child("user_chats").child(uid).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot s) {
                list.removeAllViews();
                for(DataSnapshot chat : s.getChildren()) {
                    TextView tv = new TextView(ChatListActivity.this);
                    String otherUser = chat.child("otherUsername").getValue(String.class);
                    String lastMsg = chat.child("lastMessage").getValue(String.class);
                    tv.setText("@" + otherUser + "\n" + lastMsg);
                    tv.setPadding(20,15,20,15);
                    tv.setOnClickListener(v -> {
                        Intent i = new Intent(ChatListActivity.this, PrivateChatActivity.class);
                        i.putExtra("otherUserId", chat.child("otherUserId").getValue(String.class));
                        i.putExtra("otherUsername", otherUser);
                        startActivity(i);
                    });
                    list.addView(tv);
                }
            }
            @Override
            public void onCancelled(DatabaseError e) {}
        });
    }
}
EOF

# ProfileActivity.java
cat > app/src/main/java/com/globetalk/app/ui/profile/ProfileActivity.java << 'EOF'
package com.globetalk.app.ui.profile;
import android.content.Intent;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.database.*;
import com.globetalk.app.ui.chat.PrivateChatActivity;
public class ProfileActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        String userId = getIntent().getStringExtra("userId");
        DatabaseReference db = FirebaseDatabase.getInstance(
            "https://videocallpro-f5f1b-default-rtdb.firebaseio.com").getReference();
        
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setPadding(30,80,30,30);
        
        db.child("users").child(userId).addListenerForSingleValueEvent(
            new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot s) {
                    String uname = s.child("username").getValue(String.class);
                    String email = s.child("email").getValue(String.class);
                    Boolean online = s.child("isOnline").getValue(Boolean.class);
                    
                    TextView nameTv = new TextView(ProfileActivity.this);
                    nameTv.setText("👤 " + uname);
                    nameTv.setTextSize(28);
                    l.addView(nameTv);
                    
                    TextView emailTv = new TextView(ProfileActivity.this);
                    emailTv.setText("📧 " + email);
                    emailTv.setTextSize(16);
                    l.addView(emailTv);
                    
                    TextView status = new TextView(ProfileActivity.this);
                    status.setText(online != null && online ? "🟢 Online" : "⚫ Offline");
                    status.setTextSize(16);
                    l.addView(status);
                    
                    Button msgBtn = new Button(ProfileActivity.this);
                    msgBtn.setText("💬 Send Message");
                    msgBtn.setBackgroundColor(0xFFFF6B35);
                    msgBtn.setTextColor(0xFFFFFFFF);
                    msgBtn.setOnClickListener(v -> {
                        Intent i = new Intent(ProfileActivity.this, PrivateChatActivity.class);
                        i.putExtra("otherUserId", userId);
                        i.putExtra("otherUsername", uname);
                        startActivity(i);
                    });
                    l.addView(msgBtn);
                }
                @Override
                public void onCancelled(DatabaseError e) {}
            });
        
        setContentView(l);
    }
}
EOF

# PrivateChatActivity.java
cat > app/src/main/java/com/globetalk/app/ui/chat/PrivateChatActivity.java << 'EOF'
package com.globetalk.app.ui.chat;
import android.content.Intent;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.*;
import com.globetalk.app.ui.call.VideoCallActivity;
import java.util.HashMap;
import java.util.Map;
public class PrivateChatActivity extends AppCompatActivity {
    DatabaseReference db;
    String uid, oid, ouser, chatId;
    LinearLayout msgContainer;
    ScrollView scroll;
    EditText input;
    
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        oid = getIntent().getStringExtra("otherUserId");
        ouser = getIntent().getStringExtra("otherUsername");
        db = FirebaseDatabase.getInstance("https://videocallpro-f5f1b-default-rtdb.firebaseio.com").getReference();
        
        chatId = uid.compareTo(oid) < 0 ? uid + "_" + oid : oid + "_" + uid;
        
        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        
        LinearLayout top = new LinearLayout(this);
        top.setOrientation(LinearLayout.HORIZONTAL);
        top.setBackgroundColor(0xFFFF6B35);
        top.setPadding(20,50,20,20);
        
        TextView title = new TextView(this);
        title.setText("💬 " + ouser);
        title.setTextColor(0xFFFFFFFF);
        title.setTextSize(18);
        top.addView(title);
        
        Button videoBtn = new Button(this);
        videoBtn.setText("📹");
        videoBtn.setBackgroundColor(0x00FFFFFF);
        videoBtn.setOnClickListener(v -> {
            Intent i = new Intent(this, VideoCallActivity.class);
            i.putExtra("otherUserId", oid);
            i.putExtra("otherUsername", ouser);
            startActivity(i);
        });
        top.addView(videoBtn);
        
        main.addView(top);
        
        scroll = new ScrollView(this);
        msgContainer = new LinearLayout(this);
        msgContainer.setOrientation(LinearLayout.VERTICAL);
        msgContainer.setPadding(10,10,10,10);
        scroll.addView(msgContainer);
        main.addView(scroll);
        
        LinearLayout inputBar = new LinearLayout(this);
        inputBar.setOrientation(LinearLayout.HORIZONTAL);
        inputBar.setPadding(10,10,10,30);
        
        input = new EditText(this);
        input.setHint("Message...");
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, -2, 1);
        input.setLayoutParams(lp);
        inputBar.addView(input);
        
        Button send = new Button(this);
        send.setText("Send");
        send.setBackgroundColor(0xFFFF6B35);
        send.setTextColor(0xFFFFFFFF);
        inputBar.addView(send);
        
        main.addView(inputBar);
        setContentView(main);
        
        loadMessages();
        
        send.setOnClickListener(v -> {
            String msg = input.getText().toString().trim();
            if(!msg.isEmpty()) {
                DatabaseReference ref = db.child("private_chats").child(chatId).child("messages").push();
                ref.child("senderId").setValue(uid);
                ref.child("message").setValue(msg);
                ref.child("timestamp").setValue(ServerValue.TIMESTAMP);
                ref.child("isRead").setValue(false);
                
                Map<String, Object> chatData = new HashMap<>();
                chatData.put("otherUserId", oid);
                chatData.put("otherUsername", ouser);
                chatData.put("lastMessage", msg);
                chatData.put("timestamp", ServerValue.TIMESTAMP);
                
                db.child("user_chats").child(uid).child(chatId).setValue(chatData);
                chatData.put("otherUserId", uid);
                db.child("user_chats").child(oid).child(chatId).setValue(chatData);
                
                input.setText("");
            }
        });
    }
    
    void loadMessages() {
        db.child("private_chats").child(chatId).child("messages")
            .orderByChild("timestamp").limitToLast(50)
            .addChildEventListener(new ChildEventListener() {
                @Override
                public void onChildAdded(DataSnapshot s, String prev) {
                    String msg = s.child("message").getValue(String.class);
                    TextView tv = new TextView(PrivateChatActivity.this);
                    tv.setText(msg);
                    tv.setPadding(15,10,15,10);
                    msgContainer.addView(tv);
                    scroll.post(() -> scroll.fullScroll(ScrollView.FOCUS_DOWN));
                }
                @Override public void onChildChanged(DataSnapshot s, String p) {}
                @Override public void onChildRemoved(DataSnapshot s) {}
                @Override public void onChildMoved(DataSnapshot s, String p) {}
                @Override public void onCancelled(DatabaseError e) {}
            });
    }
}
EOF

# VideoCallActivity.java
cat > app/src/main/java/com/globetalk/app/ui/call/VideoCallActivity.java << 'EOF'
package com.globetalk.app.ui.call;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
public class VideoCallActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setGravity(Gravity.CENTER);
        l.setBackgroundColor(0xFF1A1A2E);
        
        String ouser = getIntent().getStringExtra("otherUsername");
        
        TextView name = new TextView(this);
        name.setText("📹 " + ouser);
        name.setTextColor(0xFFFFFFFF);
        name.setTextSize(24);
        l.addView(name);
        
        TextView status = new TextView(this);
        status.setText("Connecting...");
        status.setTextColor(0xFF4CAF50);
        status.setTextSize(16);
        l.addView(status);
        
        Button end = new Button(this);
        end.setText("🔴 End Call");
        end.setBackgroundColor(0xFFFF4444);
        end.setTextColor(0xFFFFFFFF);
        end.setOnClickListener(v -> finish());
        l.addView(end);
        
        setContentView(l);
    }
}
EOF

# FCMMessagingService.java
cat > app/src/main/java/com/globetalk/app/services/FCMMessagingService.java << 'EOF'
package com.globetalk.app.services;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.globetalk.app.ui.main.MainActivity;
public class FCMMessagingService extends FirebaseMessagingService {
    @Override
    public void onMessageReceived(RemoteMessage msg) {
        if(msg.getNotification() != null) {
            showNotification(msg.getNotification().getTitle(), 
                           msg.getNotification().getBody());
        }
    }
    void showNotification(String title, String body) {
        String channelId = "chat";
        NotificationManager mgr = getSystemService(NotificationManager.class);
        
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mgr.createNotificationChannel(new NotificationChannel(
                channelId, "Chat Messages", NotificationManager.IMPORTANCE_HIGH));
        }
        
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        
        mgr.notify((int)System.currentTimeMillis(), 
            new NotificationCompat.Builder(this, channelId)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(body)
                .setAutoCancel(true)
                .setContentIntent(pi)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .build());
    }
}
EOF

echo "🔨 Building APK..."
echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
gradle wrapper --gradle-version 8.2
./gradlew assembleDebug --no-daemon

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk ../GlobeTalk_v1.0.apk
    echo "═══════════════════════════════════════"
    echo "  ✅ SUCCESS! APK READY!"
    echo "  📱 File: GlobeTalk_v1.0.apk"
    echo "═══════════════════════════════════════"
else
    echo "❌ Build failed, trying with --stacktrace..."
    ./gradlew assembleDebug --stacktrace
fi