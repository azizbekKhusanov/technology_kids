# Flutter Launcher Icons
-keep class com.dexterous.flutter_launcher_icons.** { *; }

# YouTube Player / WebView
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keep class android.webkit.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Prevent shrinking of Javascript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
