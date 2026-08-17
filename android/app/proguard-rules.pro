# Keep WorkManager's Room database implementation that is created via generated code.
# These classes are usually discovered by reflection and can be removed by aggressive R8.
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase {
    <init>(...);
}
