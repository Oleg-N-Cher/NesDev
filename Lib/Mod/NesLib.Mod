(* NES hardware-dependent functions by Shiru (shiru@mail.ru)
   Feel free to do anything you want with this code, consider it Public Domain

   Versions history:
     050517 - pad polling code optimized, button bits order reversed
     280215 - fixed palette glitch caused by the active DMC DMA glitch
     030914 - minor fixes in the VRAM update system
     310814 - added vram_flush_update
     120414 - removed adr argument from vram_write and vram_read,
            unrle_vram renamed to vram_unrle, with adr argument removed
     060414 - many fixes and improvements, including sequental VRAM updates
     previous versions were created since mid-2011, there were many updates
*)

MODULE [foreign] NesLib; IMPORT SYSTEM;

CONST
  PAD_A      * = 7;
  PAD_B      * = 6;
  PAD_SELECT * = 5;
  PAD_START  * = 4;
  PAD_UP     * = 3;
  PAD_DOWN   * = 2;
  PAD_LEFT   * = 1;
  PAD_RIGHT  * = 0;

(*#define OAM_FLIP_V    0x80
#define OAM_FLIP_H    0x40
#define OAM_BEHIND    0x20

#define MAX(x1,x2)    ((x1)<(x2)?(x2):(x1))
#define MIN(x1,x2)    ((x1)<(x2)?(x1):(x2))

#define MASK_SPR    0x10
#define MASK_BG      0x08
#define MASK_EDGE_SPR  0x04
#define MASK_EDGE_BG  0x02
*)
  NAMETABLE_A * = 2000H;
  NAMETABLE_B * = 2400H;
  NAMETABLE_C * = 2800H;
  NAMETABLE_D * = 2C00H;

  NULL        * = 0;

  NT_UPD_HORZ * = 40H;
  NT_UPD_VERT * = 80H;
  NT_UPD_EOF  * = 0FFH;

PROCEDURE NesLib__init*; (* fake __init procedure, needs for compilation *)

(* set bg and spr palettes, data is 32 bytes array *)

PROCEDURE [fastcall] PalAll* ["pal_all"] (data: ARRAY [notag] OF CHAR);

(* set bg palette only, data is 16 bytes array *)

PROCEDURE [fastcall] PalBg* ["pal_bg"] (data: ARRAY [notag] OF CHAR);

(* set spr palette only, data is 16 bytes array *)

PROCEDURE [fastcall] PalSpr* ["pal_spr"] (data: ARRAY [notag] OF CHAR);

(* set a palette entry, index is 0..31 *)

PROCEDURE [fastcall] PalCol* ["pal_col"] (index, color: BYTE);

(* reset palette to $0f

void __fastcall__ pal_clear(void);

//set virtual bright both for sprites and background, 0 is black, 4 is normal, 8 is white

void __fastcall__ pal_bright(unsigned char bright);

//set virtual bright for sprites only

void __fastcall__ pal_spr_bright(unsigned char bright);

//set virtual bright for sprites background only

void __fastcall__ pal_bg_bright(unsigned char bright);
*)

(* wait actual TV frame, 50hz for PAL, 60hz for NTSC *)

PROCEDURE [fastcall] PpuWaitNmi* ["ppu_wait_nmi"];

(* wait virtual frame, it is always 50hz, frame-to-frame in PAL, frameskip in NTSC *)

PROCEDURE [fastcall] PpuWaitFrame* ["ppu_wait_frame"];

(* turn off rendering, nmi still enabled when rendering is disabled *)

PROCEDURE [fastcall] PpuOff* ["ppu_off"];

(* turn on bg, spr *)

PROCEDURE [fastcall] PpuOnAll* ["ppu_on_all"];

(* turn on bg only *)

PROCEDURE [fastcall] PpuOnBg* ["ppu_on_bg"];

(* turn on spr only *)

PROCEDURE [fastcall] PpuOnSpr* ["ppu_on_spr"];

(* set PPU_MASK directly

void __fastcall__ ppu_mask(unsigned char mask);
*)
(* get current video system, 0 for PAL, not 0 for NTSC *)

PROCEDURE [fastcall] PpuSystem* ["ppu_system"] (): BOOLEAN;

(* clear OAM buffer, all the sprites are hidden *)

PROCEDURE [fastcall] OamClear* ["oam_clear"];

(* set sprite display mode, 0 for 8x8 sprites, 1 for 8x16 sprites

void __fastcall__ oam_size(unsigned char size);

//set sprite in OAM buffer, chrnum is tile, attr is attribute, sprid is offset in OAM in bytes
//returns sprid+4, which is offset for a next sprite *)

PROCEDURE [fastcall] OamSpr* ["oam_spr"] (x, y, chrnum, attr, sprid: BYTE): BYTE;

(* set metasprite in OAM buffer
//meta sprite is a const unsigned char array, it contains four bytes per sprite
//in order x offset, y offset, tile, attribute
//x=128 is end of a meta sprite
//returns sprid+4, which is offset for a next sprite

unsigned char __fastcall__ oam_meta_spr(unsigned char x,unsigned char y,unsigned char sprid,const unsigned char *data);

//hide all remaining sprites from given offset

void __fastcall__ oam_hide_rest(unsigned char sprid);



//play a music in FamiTone format

void __fastcall__ music_play(unsigned char song);

//stop music

void __fastcall__ music_stop(void);

//pause and unpause music

void __fastcall__ music_pause(unsigned char pause);

//play FamiTone sound effect on channel 0..3

void __fastcall__ sfx_play(unsigned char sound,unsigned char channel);

//play a DPCM sample, 1..63

void __fastcall__ sample_play(unsigned char sample);



//poll controller and return flags like PAD_LEFT etc, input is pad number (0 or 1) *)

PROCEDURE [fastcall] PadPoll* ["pad_poll"] (pad: BYTE): SET;

(* poll controller in trigger mode, a flag is set only on button down, not hold
//if you need to poll the pad in both normal and trigger mode, poll it in the
//trigger mode for first, then use pad_state

unsigned char __fastcall__ pad_trigger(unsigned char pad);

//get previous pad state without polling ports

unsigned char __fastcall__ pad_state(unsigned char pad);


//set scroll, including rhe top bits
//it is always applied at beginning of a TV frame, not at the function call

void __fastcall__ scroll(unsigned int x,unsigned int y);

//set scroll after screen split invoked by the sprite 0 hit
//warning: all CPU time between the function call and the actual split point will be wasted!
//warning: the program loop has to fit into the frame time, ppu_wait_frame should not be used
//         otherwise empty frames without split will be inserted, resulting in jumpy screen
//warning: only X scroll could be changed in this version

void __fastcall__ split(unsigned int x,unsigned int y);


//select current chr bank for sprites, 0..1

void __fastcall__ bank_spr(unsigned char n);

//select current chr bank for background, 0..1

void __fastcall__ bank_bg(unsigned char n);

*)

(* get random number 0..255 or 0..65535 *)

PROCEDURE [fastcall] Rand8* ["rand8"] (): UINT8;
PROCEDURE [fastcall] Rand16* ["rand16"] (): INT16;

(* set random seed *)

PROCEDURE [fastcall] SetRand* ["set_rand"] (seed: SHORTINT);

(* when display is enabled, vram access could only be done with this vram update system
//the function sets a pointer to the update buffer that contains data and addresses
//in a special format. It allows to write non-sequental bytes, as well as horizontal or
//vertical nametable sequences.
//buffer pointer could be changed during rendering, but it only takes effect on a new frame
//number of transferred bytes is limited by vblank time
//to disable updates, call this function with NULL pointer

//the update data format:
// MSB, LSB, byte for a non-sequental write
// MSB|NT_UPD_HORZ, LSB, LEN, [bytes] for a horizontal sequence
// MSB|NT_UPD_VERT, LSB, LEN, [bytes] for a vertical sequence
// NT_UPD_EOF to mark end of the buffer

//length of this data should be under 256 bytes *)

PROCEDURE [fastcall] SetVramUpdate* ["set_vram_update"] (buf: ARRAY [notag] OF INT8);

(* all following vram functions only work when display is disabled

//do a series of VRAM writes, the same format as for set_vram_update, but writes done right away

void __fastcall__ flush_vram_update(unsigned char *buf);
*)
(* set vram pointer to write operations if you need to write some data to vram *)

PROCEDURE [fastcall] VramAdr* ["vram_adr"] (adr: ADRINT);

(* put a byte at current vram address, works only when rendering is turned off *)

PROCEDURE [fastcall] VramPut* ["vram_put"] (n: CHAR);

(* fill a block with a byte at current vram address, works only when rendering is turned off *)

PROCEDURE [fastcall] VramFill* ["vram_fill"] (n: CHAR; len: INT16);

(* set vram autoincrement, 0 for +1 and not 0 for +32 *)

PROCEDURE [fastcall] VramInc* ["vram_inc"] (n: BYTE);

(* read a block from current address of vram, works only when rendering is turned off

void __fastcall__ vram_read(unsigned char *dst,unsigned int size);

//write a block to current address of vram, works only when rendering is turned off

void __fastcall__ vram_write(unsigned char *src,unsigned int size);


//unpack RLE data to current address of vram, mostly used for nametables

void __fastcall__ vram_unrle(const unsigned char *data);



//like a normal memcpy, but does not return anything

void __fastcall__ memcpy(void *dst,void *src,unsigned int len);

//like memset, but does not return anything

void __fastcall__ memfill(void *dst,unsigned char value,unsigned int len);

//delay for N frames

void __fastcall__ delay(unsigned char frames);



//macro to calculate nametable address from X,Y in compile time *)

PROCEDURE- NTADR_A* (x, y: SHORTINT): ADRINT
  "(0x2000|(((y)<<5)|(x)))"; (* NAMETABLE_A = 2000H *)
(*
#define NTADR_B(x,y)   (NAMETABLE_B|(((y)<<5)|(x)))
#define NTADR_C(x,y)   (NAMETABLE_C|(((y)<<5)|(x)))
#define NTADR_D(x,y)   (NAMETABLE_D|(((y)<<5)|(x)))
*)
(* macro to get MSB and LSB *)

PROCEDURE- MSB* (x: INTEGER): BYTE "(((x)>>8))";
PROCEDURE- LSB* (x: INTEGER): BYTE "(((x)&0xff))";

END NesLib.
