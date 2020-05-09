/* Ofront+ 1.0 -sx3 -21 */

#ifndef NesLib__h
#define NesLib__h

#include "SYSTEM.h"




import void __FASTCALL oam_clear (void);
import BYTE __FASTCALL oam_spr (BYTE x, BYTE y, BYTE chrnum, BYTE attr, BYTE sprid);
import void __FASTCALL pal_all (CHAR *data);
import void __FASTCALL pal_bg (CHAR *data);
import void __FASTCALL pal_col (BYTE index, BYTE color);
import void __FASTCALL pal_spr (CHAR *data);
import void __FASTCALL ppu_off (void);
import void __FASTCALL ppu_on_all (void);
import void __FASTCALL ppu_on_bg (void);
import void __FASTCALL ppu_on_spr (void);
import BOOLEAN __FASTCALL ppu_system (void);
import void __FASTCALL ppu_wait_frame (void);
import void __FASTCALL ppu_wait_nmi (void);
import SHORTINT __FASTCALL rand16 (void);
import CHAR __FASTCALL rand8 (void);
import void __FASTCALL set_rand (SHORTINT seed);
import void __FASTCALL vram_adr (SHORTINT adr);
import void __FASTCALL vram_fill (CHAR n, SHORTINT len);
import void __FASTCALL vram_inc (BYTE n);
import void __FASTCALL vram_put (CHAR n);
#define NesLib__init()

#define NesLib_NTADR_A(x, y)	(0x2000|(((y)<<5)|(x)))

#endif
