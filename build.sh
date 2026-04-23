            .setView(etForgotEmail)
            .setPositiveButton("Send", (dialog, which) -> {
                String email = etForgotEmail.getText().toString().trim();
                if (!TextUtils.isEmpty(email)) {
                    auth.sendPasswordResetEmail(email)
                            .addOnSuccessListener(aVoid -> Toast.makeText(this,
                                    "Reset email sent to " + email, Toast.LENGTH_LONG).show())
                            .addOnFailureListener(e -> Toast.makeText(this,
                                    "Error: " + e.getMessage(), Toast.LENGTH_LONG).show());
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }
}
EOF

# RegisterActivity.java
cat <<'EOF' > "$PROJECT_ROOT/app/src/main/java/com/aashu/app/activities/RegisterActivity.java"
package com.aashu.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.aashu.app.R;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.SignInMethodQueryResult;

public class RegisterActivity extends AppCompatActivity {
    private