/* Ofront+ 1.0 -sx3 -21 */

#ifndef NesLib__h
#define NesLib__h

#include "SYSTEM.h"




__EXTERN void NesLib__init (void);
__EXTERN void __FASTCALL oam_clear (void);
__EXTERN BYTE __FASTCALL oam_spr (BYTE x, BYTE y, BYTE chrnum, BYTE attr, BYTE sprid);
__EXTERN SET __FASTCALL pad_poll (BYTE pad);
__EXTERN void __FASTCALL pal_all (CHAR *data);
__EXTERN void __FASTCALL pal_bg (CHAR *data);
__EXTERN void __FASTCALL pal_col (BYTE index, BYTE color);
__EXTERN void __FASTCALL pal_spr (CHAR *data);
__EXTERN void __FASTCALL ppu_off (void);
__EXTERN void __FASTCALL ppu_on_all (void);
__EXTERN void __FASTCALL ppu_on_bg (void);
__EXTERN void __FASTCALL ppu_on_spr (void);
__EXTERN BOOLEAN __FASTCALL ppu_system (void);
__EXTERN void __FASTCALL ppu_wait_frame (void);
__EXTERN void __FASTCALL ppu_wait_nmi (void);
__EXTERN SHORTINT __FASTCALL rand16 (void);
__EXTERN CHAR __FASTCALL rand8 (void);
__EXTERN void __FASTCALL set_rand (SHORTINT seed);
__EXTERN void __FASTCALL set_vram_update (BYTE *buf);
__EXTERN void __FASTCALL vram_adr (SHORTINT adr);
__EXTERN void __FASTCALL vram_fill (CHAR n, SHORTINT len);
__EXTERN void __FASTCALL vram_inc (BYTE n);
__EXTERN void __FASTCALL vram_put (CHAR n);
#define NesLib__init()

#define NesLib_LSB(x)	(((x)&0xff))
#define NesLib_MSB(x)	(((x)>>8))
#define NesLib_NTADR_A(x, y)	(0x2000|(((y)<<5)|(x)))

#endif
