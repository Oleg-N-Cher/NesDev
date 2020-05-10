(*$MAIN*) MODULE Example_03; IMPORT n := NesLib, Ignore, SYSTEM;

(*
  this example shows how to poll the gamepad
  and how to use nametable update system that allows to modify nametable
  while rendering is enabled
*)

VAR
  x, y: UINT8; i: SET;

(* the update list, there is room for 6 non-sequental tiles (3 bytes per tile), two sequences of 4 tiles (3+4 bytes each), and end marker *)

  list: ARRAY 6*3+7+7+1 OF INT8;

BEGIN

(* init data for the update list, it contains MSB and LSB of a tile address *)
(* in the nametable, then the tile number *)

  list[ 0] := n.MSB(n.NTADR_A(2,2)); list[ 1] := n.LSB(n.NTADR_A(2,2));
  list[ 2] := 0; (* non-sequental updates *)
  list[ 3] := n.MSB(n.NTADR_A(3,2)); list[ 4] := n.LSB(n.NTADR_A(3,2));
  list[ 5] := 0;
  list[ 6] := n.MSB(n.NTADR_A(4,2)); list[ 7] := n.LSB(n.NTADR_A(4,2));
  list[ 8] := 0;
  list[ 9] := n.MSB(n.NTADR_A(6,2)); list[10] := n.LSB(n.NTADR_A(6,2));
  list[11] := 0;
  list[12] := n.MSB(n.NTADR_A(7,2)); list[13] := n.LSB(n.NTADR_A(7,2));
  list[14] := 0;
  list[15] := n.MSB(n.NTADR_A(8,2)); list[16] := n.LSB(n.NTADR_A(8,2));
  list[17] := 0;
  list[18] := n.MSB(n.NTADR_A(2,4)) + n.NT_UPD_HORZ;
  list[19] := n.LSB(n.NTADR_A(2,4));
  list[20] := 4;
  list[21] := ORD("H") - 20H;
  list[22] := ORD("O") - 20H;
  list[23] := ORD("R") - 20H;
  list[24] := ORD("Z") - 20H; (* horizontal update sequence *)
  list[25] := n.MSB(n.NTADR_A(2,6)) + (n.NT_UPD_VERT - 100H);
  list[26] := n.LSB(n.NTADR_A(2,6));
  list[27] := 4;
  list[28] := ORD("V") - 20H;
  list[29] := ORD("E") - 20H;
  list[30] := ORD("R") - 20H;
  list[31] := ORD("T") - 20H; (* vertical update sequence *)
  list[32] := n.NT_UPD_EOF - 100H;

  n.PalCol( 1, 21H); (* blue color for text *)
  n.PalCol(17, 30H); (* white color for sprite *)
  n.SetVramUpdate(list);
  n.PpuOnAll; (* enable rendering *)

  x := 124; y := 116;

  LOOP (* now the main loop *)
    n.PpuWaitFrame; (*wait for next TV frame *)
    Ignore.Int(
      n.OamSpr(SHORT(x), SHORT(y), 41H, 0, 0) (* put sprite *)
    );
    (* poll the pad and change coordinates according to pressed buttons *)
    i := n.PadPoll(0);
    IF (n.PAD_LEFT  IN i) & (x>  0) THEN DEC(x, 2) END;
    IF (n.PAD_RIGHT IN i) & (x<248) THEN INC(x, 2) END;
    IF (n.PAD_UP    IN i) & (y>  0) THEN DEC(y, 2) END;
    IF (n.PAD_DOWN  IN i) & (y<232) THEN INC(y, 2) END;
    (* put x 3-digit number into the update list *)
    list[ 2] := SHORT( x DIV 100 + 10H );
    list[ 5] := SHORT( x DIV 10 MOD 10 + 10H );
    list[ 8] := SHORT( x MOD 10 + 10H );
    (* put y 3-digit number into the update list *)
    list[11] := SHORT( y DIV 100 + 10H );
    list[14] := SHORT( y DIV 10 MOD 10 + 10H );
    list[17] := SHORT( y MOD 10 + 10H );
  END
END Example_03.
