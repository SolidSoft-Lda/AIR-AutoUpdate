
# AIR AutoUpdate 

Adobe AIR it's a great runtime to target Apps and games in a common denominator way.
You can easily develop in macOS or Windows and publish only once thru Adobe AIR shared runtime (air file extension), however this requires that the AIR runtime is installed on the target machine (macOS or Windows XP-10 and even Linux limited to version 2.6).

The common issues with AIR shared runtime are:
* Forces users to install AIR runtime (this can be integrated with a Windows installer and macOS package installer);
* Annoys user with AIR updates (users hate this);
* Sometimes (not usual but happens), users can't install AIR because of Windows system or registry issues (mainly on very old Windows XP installations);

On the other hand AIR provides a way to bundle the runtime along with your App called Captive Runtime:
* No need to install a separated runtime (can even work on a pen-drive);
* Don't forces the user to update the runtime;
* You know the runtime that is runtime along with your App and avoid issues related with different runtime versions between users and the developer machine.
* ANE (AIR extensions to take advantage of OS specific features) are only available on Captive Runtime;
* The new Windows x64 it's available only on the Captive Runtime

What's the issue with Captive Runtime:
* You have to do a separated build on a macOS (if you want to provide that);
* You have to do a separated build on a Windows (if you want to provide that);
* Every single update, comes with the overloaded runtime;
* You have to handle the updates your self.

-------------

## Version 1.0
This is the first release on Github, so please be patient!

The name says all.
AIR AutoUpdate is a 100% pure AS3 AIR class that auto updates your App and the runtime only when it's needed.
AIR AutoUpdate supports macOS, Windows x86 and Windows x64!
You can build your App updates only on a macOS machine and provide the updates accross all supported runtimes!
 
 Usage:
````xml
<?xml version="1.0" encoding="utf-8"?>
<s:WindowedApplication xmlns:fx="http://ns.adobe.com/mxml/2009"
                       xmlns:s="library://ns.adobe.com/flex/spark"
                       xmlns:os="pt.solidsoft.framework.os.*"
                       visible="false"
                       creationComplete="updater.initialize(splashScreen)">
...
`````

````xml
<fx:Declarations>
    <os:Updater id="updater"
                updateURL="https://myurl/Update/updates.xml"
                updated="updated()"/>
</fx:Declarations>
`````
````actionscript
private function updated():void
{
    this.visible = true;
}
`````

## Runtime
##### Windows:
The runtime updates uses WinRar SFX (you may use any SFX tool that you want).
The updater detectes if the system is x64 or x86 and uses the proper runtime.
Automatically downloads the packager and runs it.
The SFX first closes your App, self extract (silently) and run your App again.

##### macOS:
The runtime it's just a normal ZIP with YourApp.app/Contents.
Updater, downloads your ZIP file, auto-extract to the Contents folder, open a new instance of your App and auto-close it self the previous one.

## App updates
The updates are just a normal ZIP with only what is needed for macOS and Windows with the following structure:

````shell
Info.plist
MacOS/YourAppName
PkgInfo
Resources/Main.swf
Resources/META-INF/signatures.xml
Resources/META-INF/AIR/application.xml
Resources/META-INF/AIR/hash
`````
## License

- This library is MIT licensed
- Feel free to use it in any way you wish
- Please contribute improvements back to this repository!
