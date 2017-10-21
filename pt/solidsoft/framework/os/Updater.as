package pt.solidsoft.webframework.os
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
    import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
    import flash.system.Capabilities;
    import flash.utils.ByteArray;

    import pt.fzip.FZip;
    import pt.fzip.FZipFile;
    import pt.solidsoft.framework.utils.Strings;

    [Event(name="updated", type="flash.events.Event")]
    [Event(name="updateError", type="flash.events.Event")]
	public class Updater extends EventDispatcher
	{
		namespace UPDATE_XMLNS = "http://www.solidsoft.pt";

        private static const UPDATED:String = "updated";
        private static const UPDATEERROR:String = "updateError";

        private static const TYPE_FULL:String = "full";
        private static const TYPE_UPDATE:String = "update";

		private var updatePackageURL:String;
        private var downloadingType:String;
        private var updateDescriptorLoader:URLLoader;
		private var downloadedFile:File;
		private var urlStream:URLStream;
		private var fileStream:FileStream;

        public var updateURL:String;
        public var updateDescription:String;

        /**
		 * ------------------------------------ CHECK FOR UPDATE SECTION -------------------------------------
		 */

        public function initialize(imageSplashScreen:Class):void
        {
            UpdaterDialog.splashScreen = imageSplashScreen;

            updateDescriptorLoader = new URLLoader();
            updateDescriptorLoader.addEventListener(Event.COMPLETE, updateDescriptorLoaderCompleted);
            updateDescriptorLoader.addEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoaderError);
            updateDescriptorLoader.load(new URLRequest(updateURL));
        }

        private function updateDescriptorLoaderCompleted(event:Event):void
        {
            //development mode
            if (Strings.endsWith(File.applicationDirectory.nativePath, "bin"))
            {
                dispatchEvent(new Event(UPDATED));
                return;
            }

            updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoaderCompleted);
            updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoaderError);
            updateDescriptorLoader.close();

            if (isNewVersionAvailable(TYPE_FULL) || isNewVersionAvailable(TYPE_UPDATE))
                downloadUpdate();
            else
                dispatchEvent(new Event(UPDATED));
        }

        private function updateDescriptorLoaderError(event:IOErrorEvent):void
        {
            updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoaderCompleted);
            updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoaderError);
            updateDescriptorLoader.close();

            dispatchEvent(new Event(UPDATEERROR));
        }

        private function isNewVersionAvailable(updateType:String):Boolean
        {
            var typeXml:XMLList = new XML(updateDescriptorLoader.data).UPDATE_XMLNS::[updateType];
            var updateVersion:String = null;
            downloadingType = updateType;

            if (updateType == TYPE_FULL)
            {
                if (DetectSystem.isMac())
                {
                    updateVersion = typeXml.UPDATE_XMLNS::macOSVersion;
                    updatePackageURL = typeXml.UPDATE_XMLNS::macOSURL;
                }
                else if (Capabilities.supports64BitProcesses)
                {
                    updateVersion = typeXml.UPDATE_XMLNS::winx64Version;
                    updatePackageURL = typeXml.UPDATE_XMLNS::winx64URL;
                }
                else
                {
                    updateVersion = typeXml.UPDATE_XMLNS::winx86Version;
                    updatePackageURL = typeXml.UPDATE_XMLNS::winx86URL;
                }
            }
            else
            {
                updateVersion = typeXml.UPDATE_XMLNS::version;
                updatePackageURL = typeXml.UPDATE_XMLNS::url;
            }

            if (updateType == TYPE_FULL)
                return NativeApplication.nativeApplication.runtimeVersion != updateVersion;

            updateDescription = typeXml.UPDATE_XMLNS::description;

            var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
            var xmlns:Namespace = new Namespace(applicationDescriptor.namespace());
            var currentVersion:String = applicationDescriptor.xmlns::versionNumber;
            return currentVersion != updateVersion;
        }

		/**
		 * ------------------------------------ DOWNLOAD UPDATE SECTION -------------------------------------
		 */

        private function downloadUpdate():void
		{
            var fileName:String = updatePackageURL.substr(updatePackageURL.lastIndexOf("/") + 1);
            if (DetectSystem.isMac())
                downloadedFile = File.createTempDirectory().resolvePath(fileName);
            else
                downloadedFile = File.userDirectory.resolvePath(fileName);

            urlStream = new URLStream();
            urlStream.addEventListener(ProgressEvent.PROGRESS, downloadProgress);
            urlStream.addEventListener(Event.COMPLETE, downloadCompleted);
            urlStream.addEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);

            fileStream = new FileStream();
            fileStream.addEventListener(Event.CLOSE, downloadFinished);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);
            fileStream.openAsync(downloadedFile, FileMode.WRITE);

            try
            {
                urlStream.load(new URLRequest(updatePackageURL));
            }
            catch(error:Error)
            {
                dispatchEvent(new Event(UPDATEERROR));
            }
		}

        private function downloadProgress(event:ProgressEvent):void
        {
            var bytes:ByteArray = new ByteArray();
            urlStream.readBytes(bytes);
            fileStream.writeBytes(bytes);

            UpdaterDialog.show(Math.round((Number(event.bytesLoaded) / Number(event.bytesTotal)) * 100));
        }

        private function downloadCompleted(event:Event):void
        {
            urlStream.removeEventListener(ProgressEvent.PROGRESS, downloadProgress);
            urlStream.removeEventListener(Event.COMPLETE, downloadCompleted);
            urlStream.removeEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);
            urlStream.close();

            fileStream.close();
        }

        private function downloadFinished(event:Event):void
        {
            fileStream.removeEventListener(Event.CLOSE, downloadFinished);
            fileStream.removeEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);

            installUpdate();
        }

        private function downloadUpdateError(event:IOErrorEvent):void
        {
            fileStream.removeEventListener(Event.CLOSE, downloadFinished);
            fileStream.removeEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);
            fileStream.close();

            urlStream.removeEventListener(ProgressEvent.PROGRESS, downloadProgress);
            urlStream.removeEventListener(Event.COMPLETE, downloadCompleted);
            urlStream.removeEventListener(IOErrorEvent.IO_ERROR, downloadUpdateError);
            urlStream.close();

            dispatchEvent(new Event(UPDATEERROR));
        }

		/**
		 * ------------------------------------ INSTALL UPDATE SECTION -------------------------------------
		 */

        private function installUpdate():void
		{
            if (DetectSystem.isWindows() && downloadingType == TYPE_FULL)
            {
                //run the self extractor and installer zip file (on windows we cant override the application binaries while is running)
                var infoFullWin:NativeProcessStartupInfo = new NativeProcessStartupInfo();
                infoFullWin.executable = downloadedFile;
                var nativeProcessWin:NativeProcess = new NativeProcess();
                nativeProcessWin.start(infoFullWin);
            }
            else
            {
                //show indeterminate processing
                UpdaterDialog.show();

                //save the download stream
                var fileStreamZip:FileStream = new FileStream();
                fileStreamZip.open(downloadedFile, FileMode.READ);
                var bytesZip:ByteArray = new ByteArray();
                fileStreamZip.readBytes(bytesZip);
                fileStreamZip.close();

                //decompress
                var zipProcessor:FZip = new FZip();
                zipProcessor.loadBytes(bytesZip);

                //save the decompressed data to the application folder
                var folderApp:String = File.applicationDirectory.nativePath;
                if (DetectSystem.isMac())
                    folderApp = folderApp.replace("Resources", "");
                for (var i:int = 0; i < zipProcessor.getFileCount(); i++)
                {
                    var zipFile:FZipFile = zipProcessor.getFileAt(i);
                    var extracted:File = new File(folderApp + "/" + zipFile.filename);
                    if (DetectSystem.isWindows() && Strings.contains(extracted.nativePath, "Resources"))
                        extracted = new File(Strings.replace(extracted.nativePath, "Resources", ""));

                    if (extracted.isDirectory || Strings.endsWith(zipFile.filename, "/"))
                    {
                        extracted.createDirectory();
                    }
                    else
                    {
                        var stream:FileStream = new FileStream();
                        stream.open(extracted, FileMode.WRITE);
                        stream.writeBytes(zipFile.content);
                        stream.close();
                    }
                }

                //restart
                var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
                var xmlns:Namespace = new Namespace(applicationDescriptor.namespace());
                var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
                if (DetectSystem.isWindows())
                    info.executable = new File(folderApp + "/" + applicationDescriptor.xmlns::filename + ".exe");
                else
                    info.executable = new File(File.applicationDirectory.nativePath.replace("Resources", "MacOS/" + applicationDescriptor.xmlns::filename));
                var nativeProcessMacOS:NativeProcess = new NativeProcess();
                nativeProcessMacOS.start(info);
                NativeApplication.nativeApplication.exit();
            }
        }
	}
}
