@rem compile C source file with given name into NES file
@rem useful to compile few projects at once without repeating the build script

@set CC65_HOME=..\Bin\cc65\
@set PATH=%PATH%;%CC65_HOME%bin\

@cc65 -Oi %1.c -I..\Lib\Mod -I..\Lib -I..\Lib\Obj --add-source || goto fail
@ca65 %1.s || goto fail
@ld65 -C nrom_128_horz.cfg -o ..\%1.nes ..\Lib\Obj\crt0.o %1.o ..\Lib\runtime.lib || goto fail

@goto exit

:fail

pause

:exit

@del %1.s
