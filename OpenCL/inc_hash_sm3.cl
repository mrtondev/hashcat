/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_platform.h"
#include "inc_common.h"
#include "inc_hash_sm3.h"

#define LOG_BUF_16(msg)                                             \
    printf("%s : %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x"   \
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n",         \
      msg,                                                          \
      w0[0], w0[1], w0[2], w0[3],                                   \
      w1[0], w1[1], w1[2], w1[3],                                   \
      w2[0], w2[1], w2[2], w2[3],                                   \
      w3[0], w3[1], w3[2], w3[3]                                    \
    )

#define LOG_TMP_BUF_16(msg)                                         \
    printf("%s : %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x"   \
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n",         \
      msg,                                                          \
      w0_t, w1_t, w2_t, w3_t, w4_t, w5_t, w6_t, w7_t,               \
      w8_t, w9_t, wa_t, wb_t, wc_t, wd_t, we_t, wf_t                \
    )
/*
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x"    \
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n"  \
      w0_t, w1_t, w2_t, w3_t, w4_t, w5_t, w6_t, w7_t,       \
      w8_t, w9_t, wa_t, wb_t, wc_t, wd_t, we_t, wf_t,       \
*/
#define LOG_LOOP(msg, i)                                    \
    printf("%s (%d) :"                                      \
      " Intermediate digest values :"                       \
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n", \
      msg, i,                                               \
      a, b, c, d, e, f, g, h                                \
    )

#define LOG_CTX_BUF_16(msg)                                         \
    printf("%s : %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x"   \
      " %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n",         \
      msg,                                                          \
      ctx->w0[0], ctx->w0[1],  ctx->w0[2],  ctx->w0[3],             \
      ctx->w1[0], ctx->w1[1],  ctx->w1[2],  ctx->w1[3],             \
      ctx->w2[0], ctx->w2[1],  ctx->w2[2],  ctx->w2[3],             \
      ctx->w3[0], ctx->w3[1],  ctx->w3[2],  ctx->w3[3]              \
    )

#define LOG_DIGEST(msg)                                               \
    printf("%s : %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n",  \
      msg, digest[0], digest[1], digest[2], digest[3],                \
      digest[4], digest[5], digest[6], digest[7]                      \
    )

#define LOG_CTX_DIGEST(msg)                                           \
    printf("%s : %.08x %.08x %.08x %.08x %.08x %.08x %.08x %.08x\n",  \
      msg, ctx->h[0], ctx->h[1], ctx->h[2], ctx->h[3],                \
      ctx->h[4], ctx->h[5], ctx->h[6], ctx->h[7]                      \
    )

// important notes on this:
// input buf unused bytes needs to be set to zero
// input buf needs to be in algorithm native byte order (md5 = LE, sm3 = BE, etc)
// input buf needs to be 64 byte aligned when using sm3_update()

DECLSPEC void sm3_transform (PRIVATE_AS const u32 *w0, PRIVATE_AS const u32 *w1, PRIVATE_AS const u32 *w2, PRIVATE_AS const u32 *w3, PRIVATE_AS u32 *digest)
{
  // printf("sm3_transform\n");
  u32 a = digest[0];
  u32 b = digest[1];
  u32 c = digest[2];
  u32 d = digest[3];
  u32 e = digest[4];
  u32 f = digest[5];
  u32 g = digest[6];
  u32 h = digest[7];

  // LOG_DIGEST("Digest buffer before transform");

  u32 w0_t = w0[0];
  u32 w1_t = w0[1];
  u32 w2_t = w0[2];
  u32 w3_t = w0[3];
  u32 w4_t = w1[0];
  u32 w5_t = w1[1];
  u32 w6_t = w1[2];
  u32 w7_t = w1[3];
  u32 w8_t = w2[0];
  u32 w9_t = w2[1];
  u32 wa_t = w2[2];
  u32 wb_t = w2[3];
  u32 wc_t = w3[0];
  u32 wd_t = w3[1];
  u32 we_t = w3[2];
  u32 wf_t = w3[3];
 
  // LOG_TMP_BUF_16("Buffer before rounds");
 
  int i = 0;
  // printf("Main loop execution :\n\n");
  // SM3 main loop, the Compression Function (CF) and Message Expansion (ME) are executed
  // step-by-step. SM3_R1_S use SM3_FF0 and SM3_GG0 functions for index 0 to 15 and SM3_R2_S
  // use SM3_FF1 and SM3_GG1 functions for index 16 to 63.
  SM3_R1_S(a, b, c, d, e, f, g, h, SM3_T00, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND_S(w0_t, w7_t, wd_t, w3_t, wa_t); // printf("w0_t : %.08x\n", w0_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(d, a, b, c, h, e, f, g, SM3_T01, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND_S(w1_t, w8_t, we_t, w4_t, wb_t); // printf("w1_t : %.08x\n", w1_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(c, d, a, b, g, h, e, f, SM3_T02, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND_S(w2_t, w9_t, wf_t, w5_t, wc_t);// printf("w2_t : %.08x\n", w2_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(b, c, d, a, f, g, h, e, SM3_T03, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND_S(w3_t, wa_t, w0_t, w6_t, wd_t);// printf("w3_t : %.08x\n", w3_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(a, b, c, d, e, f, g, h, SM3_T04, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND_S(w4_t, wb_t, w1_t, w7_t, we_t);// printf("w4_t : %.08x\n", w4_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(d, a, b, c, h, e, f, g, SM3_T05, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND_S(w5_t, wc_t, w2_t, w8_t, wf_t);// printf("w5_t : %.08x\n", w5_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(c, d, a, b, g, h, e, f, SM3_T06, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND_S(w6_t, wd_t, w3_t, w9_t, w0_t);// printf("w6_t : %.08x\n", w6_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(b, c, d, a, f, g, h, e, SM3_T07, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND_S(w7_t, we_t, w4_t, wa_t, w1_t);// printf("w7_t : %.08x\n", w7_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(a, b, c, d, e, f, g, h, SM3_T08, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND_S(w8_t, wf_t, w5_t, wb_t, w2_t);// printf("w8_t : %.08x\n", w8_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(d, a, b, c, h, e, f, g, SM3_T09, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND_S(w9_t, w0_t, w6_t, wc_t, w3_t);// printf("w9_t : %.08x\n", w9_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(c, d, a, b, g, h, e, f, SM3_T10, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND_S(wa_t, w1_t, w7_t, wd_t, w4_t);// printf("wa_t : %.08x\n", wa_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(b, c, d, a, f, g, h, e, SM3_T11, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND_S(wb_t, w2_t, w8_t, we_t, w5_t);// printf("wb_t : %.08x\n", wb_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(a, b, c, d, e, f, g, h, SM3_T12, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND_S(wc_t, w3_t, w9_t, wf_t, w6_t);// printf("wc_t : %.08x\n", wc_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(d, a, b, c, h, e, f, g, SM3_T13, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND_S(wd_t, w4_t, wa_t, w0_t, w7_t);// printf("wd_t : %.08x\n", wd_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(c, d, a, b, g, h, e, f, SM3_T14, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND_S(we_t, w5_t, wb_t, w1_t, w8_t);// printf("we_t : %.08x\n", we_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R1_S(b, c, d, a, f, g, h, e, SM3_T15, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND_S(wf_t, w6_t, wc_t, w2_t, w9_t);// printf("wf_t : %.08x\n", wf_t);
  //LOG_LOOP("Main loop", i); i++;
  // Index = 16, switch to SM3_R2_S
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T16, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND_S(w0_t, w7_t, wd_t, w3_t, wa_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T17, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND_S(w1_t, w8_t, we_t, w4_t, wb_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T18, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND_S(w2_t, w9_t, wf_t, w5_t, wc_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T19, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND_S(w3_t, wa_t, w0_t, w6_t, wd_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T20, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND_S(w4_t, wb_t, w1_t, w7_t, we_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T21, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND_S(w5_t, wc_t, w2_t, w8_t, wf_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T22, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND_S(w6_t, wd_t, w3_t, w9_t, w0_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T23, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND_S(w7_t, we_t, w4_t, wa_t, w1_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T24, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND_S(w8_t, wf_t, w5_t, wb_t, w2_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T25, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND_S(w9_t, w0_t, w6_t, wc_t, w3_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T26, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND_S(wa_t, w1_t, w7_t, wd_t, w4_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T27, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND_S(wb_t, w2_t, w8_t, we_t, w5_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T28, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND_S(wc_t, w3_t, w9_t, wf_t, w6_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T29, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND_S(wd_t, w4_t, wa_t, w0_t, w7_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T30, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND_S(we_t, w5_t, wb_t, w1_t, w8_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T31, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND_S(wf_t, w6_t, wc_t, w2_t, w9_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T32, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND_S(w0_t, w7_t, wd_t, w3_t, wa_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T33, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND_S(w1_t, w8_t, we_t, w4_t, wb_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T34, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND_S(w2_t, w9_t, wf_t, w5_t, wc_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T35, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND_S(w3_t, wa_t, w0_t, w6_t, wd_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T36, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND_S(w4_t, wb_t, w1_t, w7_t, we_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T37, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND_S(w5_t, wc_t, w2_t, w8_t, wf_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T38, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND_S(w6_t, wd_t, w3_t, w9_t, w0_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T39, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND_S(w7_t, we_t, w4_t, wa_t, w1_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T40, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND_S(w8_t, wf_t, w5_t, wb_t, w2_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T41, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND_S(w9_t, w0_t, w6_t, wc_t, w3_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T42, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND_S(wa_t, w1_t, w7_t, wd_t, w4_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T43, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND_S(wb_t, w2_t, w8_t, we_t, w5_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T44, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND_S(wc_t, w3_t, w9_t, wf_t, w6_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T45, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND_S(wd_t, w4_t, wa_t, w0_t, w7_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T46, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND_S(we_t, w5_t, wb_t, w1_t, w8_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T47, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND_S(wf_t, w6_t, wc_t, w2_t, w9_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T48, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND_S(w0_t, w7_t, wd_t, w3_t, wa_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T49, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND_S(w1_t, w8_t, we_t, w4_t, wb_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T50, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND_S(w2_t, w9_t, wf_t, w5_t, wc_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T51, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND_S(w3_t, wa_t, w0_t, w6_t, wd_t);
  //LOG_LOOP("Main loop", i); i++;
  // No more ME for index 52 to 63.
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T52, w4_t, w4_t ^ w8_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T53, w5_t, w5_t ^ w9_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T54, w6_t, w6_t ^ wa_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T55, w7_t, w7_t ^ wb_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T56, w8_t, w8_t ^ wc_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T57, w9_t, w9_t ^ wd_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T58, wa_t, wa_t ^ we_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T59, wb_t, wb_t ^ wf_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(a, b, c, d, e, f, g, h, SM3_T60, wc_t, wc_t ^ w0_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(d, a, b, c, h, e, f, g, SM3_T61, wd_t, wd_t ^ w1_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(c, d, a, b, g, h, e, f, SM3_T62, we_t, we_t ^ w2_t);
  //LOG_LOOP("Main loop", i); i++;
  SM3_R2_S(b, c, d, a, f, g, h, e, SM3_T63, wf_t, wf_t ^ w3_t);
  //LOG_LOOP("Main loop", i); i++;

  // LOG_BUF_16("\nBuffer after rounds of SM3");

  digest[0] ^= a;
  digest[1] ^= b;
  digest[2] ^= c;
  digest[3] ^= d;
  digest[4] ^= e;
  digest[5] ^= f;
  digest[6] ^= g;
  digest[7] ^= h;

  // LOG_DIGEST("Digest buffer after transform");
}

DECLSPEC void sm3_init (PRIVATE_AS sm3_ctx_t *ctx)
{
  // printf("sm3_init\n");
  ctx->h[0] = SM3_IV_A;
  ctx->h[1] = SM3_IV_B;
  ctx->h[2] = SM3_IV_C;
  ctx->h[3] = SM3_IV_D;
  ctx->h[4] = SM3_IV_E;
  ctx->h[5] = SM3_IV_F;
  ctx->h[6] = SM3_IV_G;
  ctx->h[7] = SM3_IV_H;

  ctx->w0[0] = 0;
  ctx->w0[1] = 0;
  ctx->w0[2] = 0;
  ctx->w0[3] = 0;
  ctx->w1[0] = 0;
  ctx->w1[1] = 0;
  ctx->w1[2] = 0;
  ctx->w1[3] = 0;
  ctx->w2[0] = 0;
  ctx->w2[1] = 0;
  ctx->w2[2] = 0;
  ctx->w2[3] = 0;
  ctx->w3[0] = 0;
  ctx->w3[1] = 0;
  ctx->w3[2] = 0;
  ctx->w3[3] = 0;

  ctx->len = 0;
}

DECLSPEC void sm3_update_64 (PRIVATE_AS sm3_ctx_t *ctx, PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const int len)
{
  // printf("sm3_update_64\n");
  if (len == 0) return;

  const int pos = ctx->len & 63;

  ctx->len += len;

  if (pos == 0)
  {
    ctx->w0[0] = w0[0];
    ctx->w0[1] = w0[1];
    ctx->w0[2] = w0[2];
    ctx->w0[3] = w0[3];
    ctx->w1[0] = w1[0];
    ctx->w1[1] = w1[1];
    ctx->w1[2] = w1[2];
    ctx->w1[3] = w1[3];
    ctx->w2[0] = w2[0];
    ctx->w2[1] = w2[1];
    ctx->w2[2] = w2[2];
    ctx->w2[3] = w2[3];
    ctx->w3[0] = w3[0];
    ctx->w3[1] = w3[1];
    ctx->w3[2] = w3[2];
    ctx->w3[3] = w3[3];

    if (len == 64)
    {
      sm3_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = 0;
      ctx->w0[1] = 0;
      ctx->w0[2] = 0;
      ctx->w0[3] = 0;
      ctx->w1[0] = 0;
      ctx->w1[1] = 0;
      ctx->w1[2] = 0;
      ctx->w1[3] = 0;
      ctx->w2[0] = 0;
      ctx->w2[1] = 0;
      ctx->w2[2] = 0;
      ctx->w2[3] = 0;
      ctx->w3[0] = 0;
      ctx->w3[1] = 0;
      ctx->w3[2] = 0;
      ctx->w3[3] = 0;
    }
  }
  else
  {
    if ((pos + len) < 64)
    {
      switch_buffer_by_offset_be_S (w0, w1, w2, w3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];
    }
    else
    {
      u32 c0[4] = { 0 };
      u32 c1[4] = { 0 };
      u32 c2[4] = { 0 };
      u32 c3[4] = { 0 };

      switch_buffer_by_offset_carry_be_S (w0, w1, w2, w3, c0, c1, c2, c3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];

      sm3_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = c0[0];
      ctx->w0[1] = c0[1];
      ctx->w0[2] = c0[2];
      ctx->w0[3] = c0[3];
      ctx->w1[0] = c1[0];
      ctx->w1[1] = c1[1];
      ctx->w1[2] = c1[2];
      ctx->w1[3] = c1[3];
      ctx->w2[0] = c2[0];
      ctx->w2[1] = c2[1];
      ctx->w2[2] = c2[2];
      ctx->w2[3] = c2[3];
      ctx->w3[0] = c3[0];
      ctx->w3[1] = c3[1];
      ctx->w3[2] = c3[2];
      ctx->w3[3] = c3[3];
    }
  }
}

DECLSPEC void sm3_update (PRIVATE_AS sm3_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  // printf("sm3_update\n");
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sm3_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sm3_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_swap (PRIVATE_AS sm3_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  // printf("sm3_update_swap\n");
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sm3_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sm3_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_utf16le (PRIVATE_AS sm3_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  // printf("sm3_update_utf16le\n");
  if (hc_enc_scan (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      sm3_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    sm3_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  sm3_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_update_utf16le_swap (PRIVATE_AS sm3_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  // printf("sm3_update_utf16le_swap\n");
  if (hc_enc_scan (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      enc_buf[ 0] = hc_swap32_S (enc_buf[ 0]);
      enc_buf[ 1] = hc_swap32_S (enc_buf[ 1]);
      enc_buf[ 2] = hc_swap32_S (enc_buf[ 2]);
      enc_buf[ 3] = hc_swap32_S (enc_buf[ 3]);
      enc_buf[ 4] = hc_swap32_S (enc_buf[ 4]);
      enc_buf[ 5] = hc_swap32_S (enc_buf[ 5]);
      enc_buf[ 6] = hc_swap32_S (enc_buf[ 6]);
      enc_buf[ 7] = hc_swap32_S (enc_buf[ 7]);
      enc_buf[ 8] = hc_swap32_S (enc_buf[ 8]);
      enc_buf[ 9] = hc_swap32_S (enc_buf[ 9]);
      enc_buf[10] = hc_swap32_S (enc_buf[10]);
      enc_buf[11] = hc_swap32_S (enc_buf[11]);
      enc_buf[12] = hc_swap32_S (enc_buf[12]);
      enc_buf[13] = hc_swap32_S (enc_buf[13]);
      enc_buf[14] = hc_swap32_S (enc_buf[14]);
      enc_buf[15] = hc_swap32_S (enc_buf[15]);

      sm3_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sm3_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sm3_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_update_global (PRIVATE_AS sm3_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  // printf("sm3_update_global\n");
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sm3_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sm3_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_global_swap (PRIVATE_AS sm3_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  // printf("sm3_update_global_swap\n");
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sm3_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sm3_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_global_utf16le (PRIVATE_AS sm3_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  // printf("sm3_update_global_utf16le\n");
  if (hc_enc_scan_global (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next_global (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      sm3_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    sm3_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  sm3_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_update_global_utf16le_swap (PRIVATE_AS sm3_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  // printf("sm3_update_global_utf16le_swap\n");
  if (hc_enc_scan_global (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next_global (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      enc_buf[ 0] = hc_swap32_S (enc_buf[ 0]);
      enc_buf[ 1] = hc_swap32_S (enc_buf[ 1]);
      enc_buf[ 2] = hc_swap32_S (enc_buf[ 2]);
      enc_buf[ 3] = hc_swap32_S (enc_buf[ 3]);
      enc_buf[ 4] = hc_swap32_S (enc_buf[ 4]);
      enc_buf[ 5] = hc_swap32_S (enc_buf[ 5]);
      enc_buf[ 6] = hc_swap32_S (enc_buf[ 6]);
      enc_buf[ 7] = hc_swap32_S (enc_buf[ 7]);
      enc_buf[ 8] = hc_swap32_S (enc_buf[ 8]);
      enc_buf[ 9] = hc_swap32_S (enc_buf[ 9]);
      enc_buf[10] = hc_swap32_S (enc_buf[10]);
      enc_buf[11] = hc_swap32_S (enc_buf[11]);
      enc_buf[12] = hc_swap32_S (enc_buf[12]);
      enc_buf[13] = hc_swap32_S (enc_buf[13]);
      enc_buf[14] = hc_swap32_S (enc_buf[14]);
      enc_buf[15] = hc_swap32_S (enc_buf[15]);

      sm3_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sm3_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sm3_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_final (PRIVATE_AS sm3_ctx_t *ctx)
{
  // printf("sm3_final\n");
  const int pos = ctx->len & 63;

  // LOG_CTX_BUF_16("Buffer before padding");

  append_0x80_4x4_S (ctx->w0, ctx->w1, ctx->w2, ctx->w3, pos ^ 3);

  // LOG_CTX_BUF_16("Buffer after padding");
  
  if (pos >= 56)
  {
    sm3_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

    ctx->w0[0] = 0;
    ctx->w0[1] = 0;
    ctx->w0[2] = 0;
    ctx->w0[3] = 0;
    ctx->w1[0] = 0;
    ctx->w1[1] = 0;
    ctx->w1[2] = 0;
    ctx->w1[3] = 0;
    ctx->w2[0] = 0;
    ctx->w2[1] = 0;
    ctx->w2[2] = 0;
    ctx->w2[3] = 0;
    ctx->w3[0] = 0;
    ctx->w3[1] = 0;
    ctx->w3[2] = 0;
    ctx->w3[3] = 0;
  }

  ctx->w3[2] = 0;
  ctx->w3[3] = ctx->len * 8;

  sm3_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

  // LOG_CTX_BUF_16("Buffer after transform");
  // LOG_CTX_DIGEST("sm3_final : computed digest");
}

// while input buf can be a vector datatype, the length of the different elements can not

DECLSPEC void sm3_transform_vector (PRIVATE_AS const u32x *w0, PRIVATE_AS const u32x *w1, PRIVATE_AS const u32x *w2, PRIVATE_AS const u32x *w3, PRIVATE_AS u32x *digest)
{
  u32x a = digest[0];
  u32x b = digest[1];
  u32x c = digest[2];
  u32x d = digest[3];
  u32x e = digest[4];
  u32x f = digest[5];
  u32x g = digest[6];
  u32x h = digest[7];

  u32x w0_t = w0[0];
  u32x w1_t = w0[1];
  u32x w2_t = w0[2];
  u32x w3_t = w0[3];
  u32x w4_t = w1[0];
  u32x w5_t = w1[1];
  u32x w6_t = w1[2];
  u32x w7_t = w1[3];
  u32x w8_t = w2[0];
  u32x w9_t = w2[1];
  u32x wa_t = w2[2];
  u32x wb_t = w2[3];
  u32x wc_t = w3[0];
  u32x wd_t = w3[1];
  u32x we_t = w3[2];
  u32x wf_t = w3[3];

  // SM3 main loop, the Compression Function (CF) and Message Expansion (ME) are executed
  // step-by-step. SM3_R1 use SM3_FF0 and SM3_GG0 functions for index 0 to 15 and SM3_R2
  // use SM3_FF1 and SM3_GG1 functions for index 16 to 63.
  SM3_R1(a, b, c, d, e, f, g, h, SM3_T00, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND(w0_t, w7_t, wd_t, w3_t, wa_t);
  SM3_R1(d, a, b, c, h, e, f, g, SM3_T01, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND(w1_t, w8_t, we_t, w4_t, wb_t);
  SM3_R1(c, d, a, b, g, h, e, f, SM3_T02, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND(w2_t, w9_t, wf_t, w5_t, wc_t);
  SM3_R1(b, c, d, a, f, g, h, e, SM3_T03, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND(w3_t, wa_t, w0_t, w6_t, wd_t);
  SM3_R1(a, b, c, d, e, f, g, h, SM3_T04, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND(w4_t, wb_t, w1_t, w7_t, we_t);
  SM3_R1(d, a, b, c, h, e, f, g, SM3_T05, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND(w5_t, wc_t, w2_t, w8_t, wf_t);
  SM3_R1(c, d, a, b, g, h, e, f, SM3_T06, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND(w6_t, wd_t, w3_t, w9_t, w0_t);
  SM3_R1(b, c, d, a, f, g, h, e, SM3_T07, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND(w7_t, we_t, w4_t, wa_t, w1_t);
  SM3_R1(a, b, c, d, e, f, g, h, SM3_T08, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND(w8_t, wf_t, w5_t, wb_t, w2_t);
  SM3_R1(d, a, b, c, h, e, f, g, SM3_T09, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND(w9_t, w0_t, w6_t, wc_t, w3_t);
  SM3_R1(c, d, a, b, g, h, e, f, SM3_T10, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND(wa_t, w1_t, w7_t, wd_t, w4_t);
  SM3_R1(b, c, d, a, f, g, h, e, SM3_T11, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND(wb_t, w2_t, w8_t, we_t, w5_t);
  SM3_R1(a, b, c, d, e, f, g, h, SM3_T12, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND(wc_t, w3_t, w9_t, wf_t, w6_t);
  SM3_R1(d, a, b, c, h, e, f, g, SM3_T13, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND(wd_t, w4_t, wa_t, w0_t, w7_t);
  SM3_R1(c, d, a, b, g, h, e, f, SM3_T14, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND(we_t, w5_t, wb_t, w1_t, w8_t);
  SM3_R1(b, c, d, a, f, g, h, e, SM3_T15, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND(wf_t, w6_t, wc_t, w2_t, w9_t);
  // Index = 16, switch to SM3_R2
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T16, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND(w0_t, w7_t, wd_t, w3_t, wa_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T17, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND(w1_t, w8_t, we_t, w4_t, wb_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T18, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND(w2_t, w9_t, wf_t, w5_t, wc_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T19, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND(w3_t, wa_t, w0_t, w6_t, wd_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T20, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND(w4_t, wb_t, w1_t, w7_t, we_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T21, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND(w5_t, wc_t, w2_t, w8_t, wf_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T22, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND(w6_t, wd_t, w3_t, w9_t, w0_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T23, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND(w7_t, we_t, w4_t, wa_t, w1_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T24, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND(w8_t, wf_t, w5_t, wb_t, w2_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T25, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND(w9_t, w0_t, w6_t, wc_t, w3_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T26, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND(wa_t, w1_t, w7_t, wd_t, w4_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T27, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND(wb_t, w2_t, w8_t, we_t, w5_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T28, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND(wc_t, w3_t, w9_t, wf_t, w6_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T29, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND(wd_t, w4_t, wa_t, w0_t, w7_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T30, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND(we_t, w5_t, wb_t, w1_t, w8_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T31, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND(wf_t, w6_t, wc_t, w2_t, w9_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T32, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND(w0_t, w7_t, wd_t, w3_t, wa_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T33, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND(w1_t, w8_t, we_t, w4_t, wb_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T34, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND(w2_t, w9_t, wf_t, w5_t, wc_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T35, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND(w3_t, wa_t, w0_t, w6_t, wd_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T36, w4_t, w4_t ^ w8_t);
  w4_t = SM3_EXPAND(w4_t, wb_t, w1_t, w7_t, we_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T37, w5_t, w5_t ^ w9_t);
  w5_t = SM3_EXPAND(w5_t, wc_t, w2_t, w8_t, wf_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T38, w6_t, w6_t ^ wa_t);
  w6_t = SM3_EXPAND(w6_t, wd_t, w3_t, w9_t, w0_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T39, w7_t, w7_t ^ wb_t);
  w7_t = SM3_EXPAND(w7_t, we_t, w4_t, wa_t, w1_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T40, w8_t, w8_t ^ wc_t);
  w8_t = SM3_EXPAND(w8_t, wf_t, w5_t, wb_t, w2_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T41, w9_t, w9_t ^ wd_t);
  w9_t = SM3_EXPAND(w9_t, w0_t, w6_t, wc_t, w3_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T42, wa_t, wa_t ^ we_t);
  wa_t = SM3_EXPAND(wa_t, w1_t, w7_t, wd_t, w4_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T43, wb_t, wb_t ^ wf_t);
  wb_t = SM3_EXPAND(wb_t, w2_t, w8_t, we_t, w5_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T44, wc_t, wc_t ^ w0_t);
  wc_t = SM3_EXPAND(wc_t, w3_t, w9_t, wf_t, w6_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T45, wd_t, wd_t ^ w1_t);
  wd_t = SM3_EXPAND(wd_t, w4_t, wa_t, w0_t, w7_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T46, we_t, we_t ^ w2_t);
  we_t = SM3_EXPAND(we_t, w5_t, wb_t, w1_t, w8_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T47, wf_t, wf_t ^ w3_t);
  wf_t = SM3_EXPAND(wf_t, w6_t, wc_t, w2_t, w9_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T48, w0_t, w0_t ^ w4_t);
  w0_t = SM3_EXPAND(w0_t, w7_t, wd_t, w3_t, wa_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T49, w1_t, w1_t ^ w5_t);
  w1_t = SM3_EXPAND(w1_t, w8_t, we_t, w4_t, wb_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T50, w2_t, w2_t ^ w6_t);
  w2_t = SM3_EXPAND(w2_t, w9_t, wf_t, w5_t, wc_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T51, w3_t, w3_t ^ w7_t);
  w3_t = SM3_EXPAND(w3_t, wa_t, w0_t, w6_t, wd_t);
  // No more ME for index 52 to 63.
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T52, w4_t, w4_t ^ w8_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T53, w5_t, w5_t ^ w9_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T54, w6_t, w6_t ^ wa_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T55, w7_t, w7_t ^ wb_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T56, w8_t, w8_t ^ wc_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T57, w9_t, w9_t ^ wd_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T58, wa_t, wa_t ^ we_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T59, wb_t, wb_t ^ wf_t);
  SM3_R2(a, b, c, d, e, f, g, h, SM3_T60, wc_t, wc_t ^ w0_t);
  SM3_R2(d, a, b, c, h, e, f, g, SM3_T61, wd_t, wd_t ^ w1_t);
  SM3_R2(c, d, a, b, g, h, e, f, SM3_T62, we_t, we_t ^ w2_t);
  SM3_R2(b, c, d, a, f, g, h, e, SM3_T63, wf_t, wf_t ^ w3_t);

  digest[0] ^= a;
  digest[1] ^= b;
  digest[2] ^= c;
  digest[3] ^= d;
  digest[4] ^= e;
  digest[5] ^= f;
  digest[6] ^= g;
  digest[7] ^= h;
}

DECLSPEC void sm3_init_vector (PRIVATE_AS sm3_ctx_vector_t *ctx)
{
  ctx->h[0] = SM3_IV_A;
  ctx->h[1] = SM3_IV_B;
  ctx->h[2] = SM3_IV_C;
  ctx->h[3] = SM3_IV_D;
  ctx->h[4] = SM3_IV_E;
  ctx->h[5] = SM3_IV_F;
  ctx->h[6] = SM3_IV_G;
  ctx->h[7] = SM3_IV_H;

  ctx->w0[0] = 0;
  ctx->w0[1] = 0;
  ctx->w0[2] = 0;
  ctx->w0[3] = 0;
  ctx->w1[0] = 0;
  ctx->w1[1] = 0;
  ctx->w1[2] = 0;
  ctx->w1[3] = 0;
  ctx->w2[0] = 0;
  ctx->w2[1] = 0;
  ctx->w2[2] = 0;
  ctx->w2[3] = 0;
  ctx->w3[0] = 0;
  ctx->w3[1] = 0;
  ctx->w3[2] = 0;
  ctx->w3[3] = 0;

  ctx->len = 0;
}

DECLSPEC void sm3_init_vector_from_scalar (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS sm3_ctx_t *ctx0)
{
  ctx->h[0] = ctx0->h[0];
  ctx->h[1] = ctx0->h[1];
  ctx->h[2] = ctx0->h[2];
  ctx->h[3] = ctx0->h[3];
  ctx->h[4] = ctx0->h[4];
  ctx->h[5] = ctx0->h[5];
  ctx->h[6] = ctx0->h[6];
  ctx->h[7] = ctx0->h[7];

  ctx->w0[0] = ctx0->w0[0];
  ctx->w0[1] = ctx0->w0[1];
  ctx->w0[2] = ctx0->w0[2];
  ctx->w0[3] = ctx0->w0[3];
  ctx->w1[0] = ctx0->w1[0];
  ctx->w1[1] = ctx0->w1[1];
  ctx->w1[2] = ctx0->w1[2];
  ctx->w1[3] = ctx0->w1[3];
  ctx->w2[0] = ctx0->w2[0];
  ctx->w2[1] = ctx0->w2[1];
  ctx->w2[2] = ctx0->w2[2];
  ctx->w2[3] = ctx0->w2[3];
  ctx->w3[0] = ctx0->w3[0];
  ctx->w3[1] = ctx0->w3[1];
  ctx->w3[2] = ctx0->w3[2];
  ctx->w3[3] = ctx0->w3[3];

  ctx->len = ctx0->len;
}

DECLSPEC void sm3_update_vector_64 (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, const int len)
{
  if (len == 0) return;

  const int pos = ctx->len & 63;

  ctx->len += len;

  if (pos == 0)
  {
    ctx->w0[0] = w0[0];
    ctx->w0[1] = w0[1];
    ctx->w0[2] = w0[2];
    ctx->w0[3] = w0[3];
    ctx->w1[0] = w1[0];
    ctx->w1[1] = w1[1];
    ctx->w1[2] = w1[2];
    ctx->w1[3] = w1[3];
    ctx->w2[0] = w2[0];
    ctx->w2[1] = w2[1];
    ctx->w2[2] = w2[2];
    ctx->w2[3] = w2[3];
    ctx->w3[0] = w3[0];
    ctx->w3[1] = w3[1];
    ctx->w3[2] = w3[2];
    ctx->w3[3] = w3[3];

    if (len == 64)
    {
      sm3_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = 0;
      ctx->w0[1] = 0;
      ctx->w0[2] = 0;
      ctx->w0[3] = 0;
      ctx->w1[0] = 0;
      ctx->w1[1] = 0;
      ctx->w1[2] = 0;
      ctx->w1[3] = 0;
      ctx->w2[0] = 0;
      ctx->w2[1] = 0;
      ctx->w2[2] = 0;
      ctx->w2[3] = 0;
      ctx->w3[0] = 0;
      ctx->w3[1] = 0;
      ctx->w3[2] = 0;
      ctx->w3[3] = 0;
    }
  }
  else
  {
    if ((pos + len) < 64)
    {
      switch_buffer_by_offset_be (w0, w1, w2, w3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];
    }
    else
    {
      u32x c0[4] = { 0 };
      u32x c1[4] = { 0 };
      u32x c2[4] = { 0 };
      u32x c3[4] = { 0 };

      switch_buffer_by_offset_carry_be (w0, w1, w2, w3, c0, c1, c2, c3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];

      sm3_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = c0[0];
      ctx->w0[1] = c0[1];
      ctx->w0[2] = c0[2];
      ctx->w0[3] = c0[3];
      ctx->w1[0] = c1[0];
      ctx->w1[1] = c1[1];
      ctx->w1[2] = c1[2];
      ctx->w1[3] = c1[3];
      ctx->w2[0] = c2[0];
      ctx->w2[1] = c2[1];
      ctx->w2[2] = c2[2];
      ctx->w2[3] = c2[3];
      ctx->w3[0] = c3[0];
      ctx->w3[1] = c3[1];
      ctx->w3[2] = c3[2];
      ctx->w3[3] = c3[3];
    }
  }
}

DECLSPEC void sm3_update_vector (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sm3_update_vector_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sm3_update_vector_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_vector_swap (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32 (w0[0]);
    w0[1] = hc_swap32 (w0[1]);
    w0[2] = hc_swap32 (w0[2]);
    w0[3] = hc_swap32 (w0[3]);
    w1[0] = hc_swap32 (w1[0]);
    w1[1] = hc_swap32 (w1[1]);
    w1[2] = hc_swap32 (w1[2]);
    w1[3] = hc_swap32 (w1[3]);
    w2[0] = hc_swap32 (w2[0]);
    w2[1] = hc_swap32 (w2[1]);
    w2[2] = hc_swap32 (w2[2]);
    w2[3] = hc_swap32 (w2[3]);
    w3[0] = hc_swap32 (w3[0]);
    w3[1] = hc_swap32 (w3[1]);
    w3[2] = hc_swap32 (w3[2]);
    w3[3] = hc_swap32 (w3[3]);

    sm3_update_vector_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32 (w0[0]);
  w0[1] = hc_swap32 (w0[1]);
  w0[2] = hc_swap32 (w0[2]);
  w0[3] = hc_swap32 (w0[3]);
  w1[0] = hc_swap32 (w1[0]);
  w1[1] = hc_swap32 (w1[1]);
  w1[2] = hc_swap32 (w1[2]);
  w1[3] = hc_swap32 (w1[3]);
  w2[0] = hc_swap32 (w2[0]);
  w2[1] = hc_swap32 (w2[1]);
  w2[2] = hc_swap32 (w2[2]);
  w2[3] = hc_swap32 (w2[3]);
  w3[0] = hc_swap32 (w3[0]);
  w3[1] = hc_swap32 (w3[1]);
  w3[2] = hc_swap32 (w3[2]);
  w3[3] = hc_swap32 (w3[3]);

  sm3_update_vector_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sm3_update_vector_utf16le (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    sm3_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le (w1, w2, w3);
  make_utf16le (w0, w0, w1);

  sm3_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_update_vector_utf16le_swap (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    w0[0] = hc_swap32 (w0[0]);
    w0[1] = hc_swap32 (w0[1]);
    w0[2] = hc_swap32 (w0[2]);
    w0[3] = hc_swap32 (w0[3]);
    w1[0] = hc_swap32 (w1[0]);
    w1[1] = hc_swap32 (w1[1]);
    w1[2] = hc_swap32 (w1[2]);
    w1[3] = hc_swap32 (w1[3]);
    w2[0] = hc_swap32 (w2[0]);
    w2[1] = hc_swap32 (w2[1]);
    w2[2] = hc_swap32 (w2[2]);
    w2[3] = hc_swap32 (w2[3]);
    w3[0] = hc_swap32 (w3[0]);
    w3[1] = hc_swap32 (w3[1]);
    w3[2] = hc_swap32 (w3[2]);
    w3[3] = hc_swap32 (w3[3]);

    sm3_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le (w1, w2, w3);
  make_utf16le (w0, w0, w1);

  w0[0] = hc_swap32 (w0[0]);
  w0[1] = hc_swap32 (w0[1]);
  w0[2] = hc_swap32 (w0[2]);
  w0[3] = hc_swap32 (w0[3]);
  w1[0] = hc_swap32 (w1[0]);
  w1[1] = hc_swap32 (w1[1]);
  w1[2] = hc_swap32 (w1[2]);
  w1[3] = hc_swap32 (w1[3]);
  w2[0] = hc_swap32 (w2[0]);
  w2[1] = hc_swap32 (w2[1]);
  w2[2] = hc_swap32 (w2[2]);
  w2[3] = hc_swap32 (w2[3]);
  w3[0] = hc_swap32 (w3[0]);
  w3[1] = hc_swap32 (w3[1]);
  w3[2] = hc_swap32 (w3[2]);
  w3[3] = hc_swap32 (w3[3]);

  sm3_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_update_vector_utf16beN (PRIVATE_AS sm3_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16beN (w1, w2, w3);
    make_utf16beN (w0, w0, w1);

    sm3_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16beN (w1, w2, w3);
  make_utf16beN (w0, w0, w1);

  sm3_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sm3_final_vector (PRIVATE_AS sm3_ctx_vector_t *ctx)
{
  const int pos = ctx->len & 63;

  append_0x80_4x4 (ctx->w0, ctx->w1, ctx->w2, ctx->w3, pos ^ 3);

  if (pos >= 56)
  {
    sm3_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

    ctx->w0[0] = 0;
    ctx->w0[1] = 0;
    ctx->w0[2] = 0;
    ctx->w0[3] = 0;
    ctx->w1[0] = 0;
    ctx->w1[1] = 0;
    ctx->w1[2] = 0;
    ctx->w1[3] = 0;
    ctx->w2[0] = 0;
    ctx->w2[1] = 0;
    ctx->w2[2] = 0;
    ctx->w2[3] = 0;
    ctx->w3[0] = 0;
    ctx->w3[1] = 0;
    ctx->w3[2] = 0;
    ctx->w3[3] = 0;
  }

  ctx->w3[2] = 0;
  ctx->w3[3] = ctx->len * 8;

  sm3_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);
}
