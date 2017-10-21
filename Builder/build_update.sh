cd /Volumes/Projects/MyApp/Desktop/bin/MyApp.app/Contents
zip -r Update.zip * -x Frameworks/\* -x Resources/assets\* -x Resources/Icon.icns -x Resources/mimetype -x Resources/META-INF/AIR/extensions\*
mv Update.zip /Volumes/Users/MyUser/Desktop
killall Terminal