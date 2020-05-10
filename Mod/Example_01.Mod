(*$MAIN*) MODULE Example_01; IMPORT n := NesLib, SYSTEM;

(*
  this example code shows how to put some text in nametable
  it assumes that you have ASCII-encoded font in the CHR tiles $00-$3f
  it also shows how to detect PAL/NTSC video system
*)

(* put a string into the nametable *)

PROCEDURE PutStr (adr: ADRINT; str: ARRAY [notag] OF CHAR);
BEGIN
  n.VramAdr(adr);
  WHILE str[0] # 0X DO
    n.VramPut(CHR(ORD(str[0]) - 20H)); (*-0x20 because ASCII code 0x20 is placed in tile 0 of the CHR *)
    INC(SYSTEM.VAL(ADRINT, str));
  END;
END PutStr;

BEGIN
  (* rendering is disabled at the startup, the palette is all black *)

  n.PalCol(1, 30H); (* set while color *)

  (* you can't put data into vram through vram_put while rendering is enabled
     so you have to disable rendering to put things like text or a level map
     into the nametable

     there is a way to update small number of nametable tiles while rendering
     is enabled, using set_vram_update and an update list *)

  PutStr(n.NTADR_A(2, 2), "HELLO, WORLD!");
  PutStr(n.NTADR_A(2, 6), "THIS CODE PRINTS SOME TEXT");
  PutStr(n.NTADR_A(2, 7), "USING ASCII-ENCODED CHARSET");
  PutStr(n.NTADR_A(2, 8), "(WITH CAPITAL LETTERS ONLY)");
  PutStr(n.NTADR_A(2, 10), "TO USE CHR MORE EFFICIENTLY");
  PutStr(n.NTADR_A(2, 11), "YOU'D NEED A CUSTOM ENCODING");
  PutStr(n.NTADR_A(2, 12), "AND A CONVERSION TABLE");

  PutStr(n.NTADR_A(2, 16), "CURRENT VIDEO MODE IS");
  IF n.PpuSystem() THEN PutStr(n.NTADR_A(24, 16), "NTSC");
  ELSE PutStr(n.NTADR_A(24, 16), "PAL");
  END;

  n.PpuOnAll; (* enable rendering *)

  LOOP END (* do nothing, infinite loop *)

END Example_01.
