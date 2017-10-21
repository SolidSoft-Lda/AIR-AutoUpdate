xcopy C:\Projects\MyApp\Desktop\bin\MyApp C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp /s/h/e/k/f/c/i
copy x64\*.dll C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp
copy CloseApp.cmd C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp
"c:\program files\winrar\winrar" a -r -sfx -z"xfs.conf" Fullx64 pt.solidsoft.myapp
rmdir /s /q C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp