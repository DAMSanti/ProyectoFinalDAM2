# Keep the classes referenced by flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep the classes referenced by Tink (Google's cryptographic library)
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.errorprone.annotations.Immutable { *; }
-keep class javax.annotation.concurrent.GuardedBy { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep the class members
-keepclassmembers class * {
    @com.google.errorprone.annotations.Immutable *;
    @javax.annotation.concurrent.GuardedBy *;
}

# Keep the classes referenced by protobuf
-keep class com.google.crypto.tink.proto.** { *; }
-keep class com.google.protobuf.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }

# Keep the classes referenced by Guava (Google's core libraries for Java)
-keep class com.google.common.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }

# Keep the classes referenced by AutoValue (Google's library for immutable value types)
-keep class com.google.auto.value.** { *; }

# Keep the classes referenced by error-prone annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep the classes referenced by javax annotations
-keep class javax.annotation.** { *; }

# Keep the classes referenced by javax concurrent annotations
-keep class javax.annotation.concurrent.** { *; }

# Suppress warnings for missing classes
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn java.lang.reflect.AnnotatedType