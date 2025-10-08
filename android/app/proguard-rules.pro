# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# AdMob
-keep class com.google.android.gms.ads.** { *; }
-keep public class com.google.android.gms.ads.MobileAds {
    public *;
}
-keep public class com.google.android.gms.ads.initialization.InitializationStatus {
    public *;
}
-keep public class com.google.android.gms.ads.initialization.AdapterStatus {
    public *;
}
-keep public class com.google.android.gms.ads.AdRequest$Builder {
    public *;
}
-keep public class com.google.android.gms.ads.formats.NativeAdOptions$Builder {
    public *;
}

# MongoDB
-keep class org.bson.** { *; }
-keep class com.mongodb.** { *; }
-dontwarn org.bson.**
-dontwarn com.mongodb.**

# File Picker
-keep class com.lyrebirdstudio.fileapi.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class androidx.core.** { *; }

# Keep your application classes
-keep class com.company.yks_mentor.** { *; }

# Keep Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Keep Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Keep `Companion` object fields of serializable classes.
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

# Keep `serializer()` on companion objects
-if @kotlinx.serialization.Serializable class ** {
    static **$* *;
}
-keepclassmembers class <2>$<3> {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep Multidex
-keep class androidx.multidex.** { *; }

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keep class android.** { *; }
-keep interface android.** { *; }

# Basic Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.android.material.** { *; }

# Keep setters in Views so that animations can still work.
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# MongoDB Realm
-keep class io.realm.** { *; }
-keep class io.realm.internal.Keep
-keep @io.realm.internal.Keep class *
-dontwarn javax.**
-dontwarn io.realm.** 