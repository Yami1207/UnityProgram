Shader hash 160286ba-15d84d5e-562a1b33-b7594879

vs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer cb0[66], immediateIndexed
      dcl_constantbuffer cb1[7], immediateIndexed
      dcl_constantbuffer cb2[8], immediateIndexed
      dcl_constantbuffer cb3[25], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_input v0.xyzw
      dcl_input v1.xyz
      dcl_input v2.xy
      dcl_input v3.xy
      dcl_input v4.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_output o2.xyzw
      dcl_output o3.xyzw
      dcl_output o4.xyzw
      dcl_output o5.xyz
      dcl_output o5.w
      dcl_output o6.xyz
      dcl_output o7.xyzw
      dcl_output o8.xyzw
      dcl_temps 5
   0 mul r0.xyz, v0.yyyy, cb2[1].xyzx
   1 mad r0.xyz, cb2[0].xyzx, v0.xxxx, r0.xyzx
   2 mad r0.xyz, cb2[2].xyzx, v0.zzzz, r0.xyzx
   3 mad r0.xyz, cb2[3].xyzx, v0.wwww, r0.xyzx
   4 add r1.xyz, -r0.xyzx, cb1[5].xyzx
   5 dp3 r0.w, r1.xyzx, r1.xyzx
   6 rsq r0.w, r0.w
   7 mul o7.xyz, r0.wwww, r1.xyzx
   8 ne r0.w, l(0, 0, 0, 0), cb0[47].w
   9 ne r1.x, l(0, 0, 0, 0), cb0[48].x
  10 lt r1.y, abs(cb0[49].w), l(0.0010)
  11 mul r2.xyz, cb0[49].wwww, cb0[49].xyzx
  12 movc r1.yzw, r1.yyyy, l(0, 0, 0, 0), r2.xxyz
  13 mul r2.xyzw, r1.zzzz, cb2[5].xyzw
  14 mad r2.xyzw, cb2[4].xyzw, r1.yyyy, r2.xyzw
  15 mad r2.xyzw, cb2[6].xyzw, r1.wwww, r2.xyzw
  16 add r2.xyzw, r2.xyzw, cb2[7].xyzw
  17 div r1.yzw, r2.xxyz, r2.wwww
  18 mul r2.xyz, cb0[49].yyyy, cb2[5].xyzx
  19 mad r2.xyz, cb2[4].xyzx, cb0[49].xxxx, r2.xyzx
  20 mad r2.xyz, cb2[6].xyzx, cb0[49].zzzz, r2.xyzx
  21 dp3 r1.y, r1.yzwy, r2.xyzx
  22 dp3 r1.z, v0.xyzx, r2.xyzx
  23 lt r1.w, r1.z, r1.y
  24 add r1.y, -r1.y, r1.z
  25 mad r2.xyz, -r1.yyyy, r2.xyzx, v0.xyzx
  26 mov r2.w, l(0)
  27 mov r3.xyz, v0.xyzx
  28 mov r3.w, v4.w
  29 movc r2.xyzw, r1.wwww, r2.xyzw, r3.xyzw
  30 dp3 r1.y, v0.xyzx, cb0[49].xyzx
  31 add r1.z, cb0[49].w, l(-0.0100)
  32 lt r1.z, r1.y, r1.z
  33 add r1.y, r1.y, -cb0[49].w
  34 mad r4.xyz, -r1.yyyy, cb0[49].xyzx, v0.xyzx
  35 mov r4.w, l(0)
  36 movc r4.xyzw, r1.zzzz, r4.xyzw, r3.xyzw
  37 movc r1.xyzw, r1.xxxx, r2.xyzw, r4.xyzw
  38 movc r1.xyzw, r0.wwww, r1.xyzw, r3.xyzw
  39 add r2.xyw, -cb1[5].xyxz, cb2[3].xyxz
  40 mov r3.x, cb2[0].x
  41 mov r3.y, cb2[1].x
  42 mov r3.z, cb2[2].x
  43 mov r3.w, r2.x
  44 mov r4.xyz, r1.xyzx
  45 mov r4.w, l(1.0000)
  46 dp4 r0.w, r3.xyzw, r4.xyzw
  47 mov r3.x, cb2[0].y
  48 mov r3.y, cb2[1].y
  49 mov r3.z, cb2[2].y
  50 mov r3.w, r2.y
  51 dp4 r1.x, r3.xyzw, r4.xyzw
  52 mov r2.x, cb2[0].z
  53 mov r2.y, cb2[1].z
  54 mov r2.z, cb2[2].z
  55 dp4 r1.y, r2.xyzw, r4.xyzw
  56 mov r2.x, cb2[0].w
  57 mov r2.y, cb2[1].w
  58 mov r2.z, cb2[2].w
  59 mov r2.w, cb2[3].w
  60 dp4 r1.z, r2.xyzw, r4.xyzw
  61 mul r2.xyzw, r1.xxxx, cb3[22].xyzw
  62 mad r2.xyzw, cb3[21].xyzw, r0.wwww, r2.xyzw
  63 mad r2.xyzw, cb3[23].xyzw, r1.yyyy, r2.xyzw
  64 mad r2.xyzw, cb3[24].xyzw, r1.zzzz, r2.xyzw
  65 mul r3.xyzw, r4.yyyy, cb2[1].xyzw
  66 mad r3.xyzw, cb2[0].xyzw, r4.xxxx, r3.xyzw
  67 mad r3.xyzw, cb2[2].xyzw, r4.zzzz, r3.xyzw
  68 mad r3.xyzw, cb2[3].xyzw, v0.wwww, r3.xyzw
  69 div o5.xyz, r3.xyzx, r3.wwww
  70 mad o2.xy, v2.xyxx, cb0[11].xyxx, cb0[11].zwzz
  71 mad o2.zw, v3.xxxy, cb0[11].xxxy, cb0[11].zzzw
  72 mul r3.xz, r2.xxwx, l(0.5000, 0.0000, 0.5000, 0.0000)
  73 mul r0.w, r2.y, cb1[6].x
  74 mul r3.w, r0.w, l(0.5000)
  75 add o4.xy, r3.zzzz, r3.xwxx
  76 dp3 r1.x, v1.xyzx, cb2[4].xyzx
  77 dp3 r1.y, v1.xyzx, cb2[5].xyzx
  78 dp3 r1.z, v1.xyzx, cb2[6].xyzx
  79 dp3 r0.w, r1.xyzx, r1.xyzx
  80 rsq r0.w, r0.w
  81 mul r1.xyz, r0.wwww, r1.xyzx
  82 lt r0.w, l(0.5000), cb0[65].w
  83 mov r3.x, cb0[65].x
  84 mov r3.yz, -cb0[65].yyzy
  85 movc r3.xyz, r0.wwww, r3.xyzx, cb0[61].xyzx
  86 dp3 r0.w, r1.xyzx, r3.xyzx
  87 mad o3.w, r0.w, l(0.4975), l(0.5000)
  88 ne r0.w, l(0, 0, 0, 0), cb0[26].w
  89 if_nz r0.w
  90   sample_l(texture2d)(float,float,float,float) r0.w, cb0[28].xyxx, t0.yzwx, s0, l(0)
  91   lt r0.w, l(0.5000), r0.w
  92   and o5.w, r0.w, l(1.0000)
  93 else
  94   mov o5.w, l(0)
  95 endif
  96 mov o0.xyzw, r2.xyzw
  97 mov o1.xyz, v4.xyzx
  98 mov o1.w, r1.w
  99 mov o3.xyz, r1.xyzx
 100 mov o4.zw, r2.zzzw
 101 mov o7.w, l(0)
 102 mov o8.xyz, r0.xyzx
 103 mov o8.w, l(0)
 104 mov o6.xyz, l(0, 0, 0, 0)
 105 ret
