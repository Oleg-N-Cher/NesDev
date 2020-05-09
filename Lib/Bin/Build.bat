@set CC65_HOME=..\..\Bin\cc65\
@set PATH=%PATH%;%CC65_HOME%bin\

@ca65 ..\Mod\crt0.s -I..\Mod -o..\Obj\crt0.o || goto fail

:fail

pause

:exit
