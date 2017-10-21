xcopy C:\Projects\MyApp\Desktop\bin\MyApp C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp /s/h/e/k/f/c/i
copy x86\*.dll C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp
copy CloseApp.cmd C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp
"c:\program files\winrar\winrar" a -r -sfx -iicon"icon.ico" -iimg"banner.bmp" -z"xfs.conf" Fullx86 pt.solidsoft.myapp
rmdir /s /q C:\Projects\MyApp\Builder\Full_Win\pt.solidsoft.myapp