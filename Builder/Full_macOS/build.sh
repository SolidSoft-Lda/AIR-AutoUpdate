codesign -f -v -s "CompanyName" MyApp/MyApp.app/Contents/Frameworks/Adobe\ AIR.framework/Versions/1.0/Adobe\ AIR_64
codesign -f -v -s "CompanyName" MyApp/MyApp.app/Contents/Frameworks/Adobe\ AIR.framework
codesign -f -v -s "CompanyName" --keychain CompanyName.p12 MyApp/MyApp.app/Contents/MacOS/MyApp