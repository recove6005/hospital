# 기본 Proguard 규칙
-keep class * { *; }
-dontwarn j$.util.**

# 애너테이션 유지 (예: Gson, Retrofit)
-keep class com.google.gson.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# Enum 유지
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 로그 메시지 제거
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# AndroidX 라이브러리 보호
-keep class androidx.** { *; }

# Glide 설정
-keep class com.bumptech.glide.** { *; }

# Play Core 라이브러리 유지
-keep class com.google.android.play.** { *; }
-keepclassmembers class com.google.android.play.** { *; }

# OkHttp 클래스 유지
-keep class okhttp3.** { *; }
-keepclassmembers class okhttp3.** { *; }

# OkHttp2 클래스 유지 (gRPC에서 필요 시)
-keep class com.squareup.okhttp.** { *; }
-keepclassmembers class com.squareup.okhttp.** { *; }

# gRPC 관련 클래스 유지
-keep class io.grpc.okhttp.** { *; }

# Reflection 관련 클래스 유지
-keep class java.lang.reflect.** { *; }
-keepattributes *Annotation*

# 모든 익명 클래스 유지 (안전 조치)
-keep class **.* { *; }

# Play Core Task 관련 클래스 유지
-keep class com.google.android.play.core.tasks.** { *; }
-keepclassmembers class com.google.android.play.core.tasks.** { *; }

# Play Core Task 관련 경고 무시
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# OkHttp 관련 경고 무시
-dontwarn com.squareup.okhttp.CipherSuite
-dontwarn com.squareup.okhttp.ConnectionSpec
-dontwarn com.squareup.okhttp.TlsVersion

# Reflection 관련 경고 무시
-dontwarn java.lang.reflect.AnnotatedType