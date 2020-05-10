(*$MAIN*) MODULE Example_02; IMPORT n := NesLib, SYSTEM;
(*
  this example shows how to set up a palette and use 8x8 HW sprites
  also shows how fast (or slow) C code is
*)

TYPE
  PalSprites = ARRAY 16 OF CHAR;

CONST
  BALLS_MAX = 64; (* total number of balls on the screen *)
  (* since there are 64 HW sprites, it is absolute max *)

  (* palette for balls, there are four sets for different ball colors *)
  palSprites = PalSprites(
    0FX, 17X, 27X, 37X,
    0FX, 11X, 21X, 31X,
    0FX, 15X, 25X, 35X,
    0FX, 19X, 29X, 39X
  );

VAR
  i, j: UINT8; spr: INT8; (* general purpose vars *)
  ball_x, ball_y, ball_dx, ball_dy: ARRAY BALLS_MAX OF UINT8; (* balls parameters *)

BEGIN
  n.PalSpr(palSprites); (* set palette for sprites *)
  n.PpuOnAll; (* enable rendering *)

  (* initialize balls parameters *)
  i := 0; REPEAT
    (* starting coordinates *)
    ball_x[i] := n.Rand8(); ball_y[i] := n.Rand8();
    (* direction bits *)
    j := n.Rand8();
    (* horizontal speed -3..-3, excluding 0 *)
    spr := SHORT(1 + n.Rand8() REM0 3);
      IF ODD(j) THEN spr := -spr END;
        ball_dx[i] := USHORT(spr);
    (* vertical speed *)
    spr := SHORT(1 + n.Rand8() REM0 3);
      IF ODD(j DIV 2) THEN spr := -spr END;
        ball_dy[i] := USHORT(spr);
  INC(i) UNTIL i >= BALLS_MAX;

  LOOP (* now the main loop *)
    n.PpuWaitFrame; (* wait for next TV frame *)
    spr := 0;
    i := 0; REPEAT
      (* set a sprite for current ball *)
      spr := n.OamSpr(SHORT(ball_x[i]), SHORT(ball_y[i]), 40H, SHORT(i REM0 4), spr); (* 40H is tile number, i&3 is palette *)

      (* move the ball *)
      INC(ball_x[i], ball_dx[i]);
      INC(ball_y[i], ball_dy[i]);
      (* bounce the ball off the edges *)
      IF ball_x[i] >= 256-8 THEN ball_dx[i] := -ball_dx[i] END;
      IF ball_y[i] >= 240-8 THEN ball_dy[i] := -ball_dy[i] END;
    INC(i) UNTIL i >= BALLS_MAX;
  END
END Example_02.
