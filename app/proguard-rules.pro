# WebView JavaScript interface
-keepattributes JavascriptInterface
-keepattributes *Annotation*

# Keep WebView related classes
-keep class * extends android.webkit.WebViewClient
-keep class * extends android.webkit.WebChromeClient

# AndroidX
-keep class androidx.** { *; }
