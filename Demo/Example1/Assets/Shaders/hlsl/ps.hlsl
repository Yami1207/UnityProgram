Shader hash ccb1ecd9 - 3712a5c2 - 11aed349 - dd44c18d

ps_5_0
dcl_globalFlags refactoringAllowed
dcl_immediateConstantBuffer{
	  { 1.0000, 0, 0, 0},
	  { 0, 1.0000, 0, 0},
	  { 0, 0, 1.0000, 0},
	  { 0, 0, 0, 1.0000} }
	  dcl_constantbuffer cb0[75], immediateIndexed
	dcl_constantbuffer cb1[8], immediateIndexed
	dcl_constantbuffer cb2[17], immediateIndexed
	dcl_sampler s0, mode_default
	dcl_sampler s1, mode_default
	dcl_sampler s2, mode_default
	dcl_sampler s3, mode_default
	dcl_sampler s4, mode_default
	dcl_sampler s5, mode_default
	dcl_resource_texture2d(float, float, float, float) t0
	dcl_resource_texture2d(float, float, float, float) t1
	dcl_resource_texture2d(float, float, float, float) t2
	dcl_resource_texture2d(float, float, float, float) t3
	dcl_resource_texture2d(float, float, float, float) t4
	dcl_resource_texture2d(float, float, float, float) t5
	dcl_input_ps linear v1.xw
	dcl_input_ps linear v2.xyzw
	dcl_input_ps linear v3.xyzw
	dcl_input_ps linear v4.xyw
	dcl_input_ps linear v5.xyz
	dcl_input_ps linear v5.w
	dcl_input_ps linear v7.xyz
	dcl_input_ps linear v8.xyz
	dcl_output o0.xyzw
	dcl_output o1.xyzw
	dcl_output o2.xyzw
	dcl_output o3.x
	dcl_temps 11
	0: ne r0.xy, l(0, 0, 0, 0), cb0[47].wxww
	1 : add r0.z, v1.w, l(-0.0100)
	2 : lt r0.z, r0.z, l(0)
	3 : and r0.x, r0.x, r0.z
	4 : discard_nz r0.x
	5 : if_nz r0.y
	6 : lt r0.x, cb0[47].y, l(0.9500)
	7 : if_nz r0.x
	8 : div r0.xy, v4.yxyy, v4.wwww
	9 : mul r0.xy, r0.xyxx, cb1[7].yxyy
	10 : mul r0.xy, r0.xyxx, l(0.2500, 0.2500, 0.0000, 0.0000)
	11 : ge r0.zw, r0.xxxy, -r0.xxxy
	12 : frc r0.xy, abs(r0.xyxx)
	13 : movc r0.xy, r0.zwzz, r0.xyxx, -r0.xyxx
	14 : mul r0.xy, r0.xyxx, l(4.0000, 4.0000, 0.0000, 0.0000)
	15 : ftou r0.xy, r0.xyxx
	16 : dp4 r1.x, cb0[3].xyzw, icb[r0.y + 0].xyzw
	17 : dp4 r1.y, cb0[4].xyzw, icb[r0.y + 0].xyzw
	18 : dp4 r1.z, cb0[5].xyzw, icb[r0.y + 0].xyzw
	19 : dp4 r1.w, cb0[6].xyzw, icb[r0.y + 0].xyzw
	20 : dp4 r0.x, r1.xyzw, icb[r0.x + 0].xyzw
	21 : mad r0.x, cb0[47].y, l(17.0000), -r0.x
	22 : add r0.x, r0.x, l(-0.0100)
	23 : lt r0.x, r0.x, l(0)
	24 : discard_nz r0.x
	25 : endif
	26 : endif
	27 : add r0.xyz, -v5.xyzx, cb1[5].xyzx
	28 : dp3 r0.w, r0.xyzx, r0.xyzx
	29 : rsq r0.w, r0.w
	30 : lt r1.x, l(0.5000), cb0[65].w
	31 : mov r2.x, cb0[65].x
	32 : mov r2.yz, -cb0[65].yyzy
	33 : movc r1.xyz, r1.xxxx, r2.xyzx, cb0[61].xyzx
	34 : mad r0.xyz, r0.xyzx, r0.wwww, r1.xyzx
	35 : dp3 r0.w, r0.xyzx, r0.xyzx
	36 : rsq r0.w, r0.w
	37 : mul r0.xyz, r0.wwww, r0.xyzx
	38 : add r0.w, cb0[47].z, l(-1.0000)
	39 : sample_b(texture2d)(float, float, float, float) r1.xyzw, v2.xyxx, t0.xyzw, s0, r0.w
	40 : eq r2.xyz, cb0[13].xxxx, l(3.0000, 1.0000, 2.0000, 0.0000)
	41 : mul r2.w, r1.w, cb0[21].y
	42 : add r3.xyz, -r1.xyzx, cb0[22].xyzx
	43 : mad r3.xyz, r2.wwww, r3.xyzx, r1.xyzx
	44 : movc r1.xyz, r2.xxxx, r3.xyzx, r1.xyzx
	45 : add r2.x, r1.w, -cb0[13].y
	46 : lt r2.x, r2.x, l(0)
	47 : and r2.x, r2.y, r2.x
	48 : discard_nz r2.x
	49 : sample_b(texture2d)(float, float, float, float) r3.xyzw, v2.xyxx, t1.xyzw, s1, r0.w
	50 : ne r2.xy, l(0, 0, 0, 0), cb0[16].xyxx
	51 : movc r0.w, r2.x, r3.y, l(0.5000)
	52 : ne r2.x, l(0, 0, 0, 0), cb0[31].x
	53 : ge r4.xyzw, r3.wwww, l(0.8000, 0.4000, 0.2000, 0.6000)
	54 : and r2.x, r2.x, r4.x
	55 : movc r2.x, r2.x, l(2.0000), l(1.0000)
	56 : ne r2.w, l(0, 0, 0, 0), cb0[34].w
	57 : and r2.w, r4.y, r2.w
	58 : lt r5.xyz, r3.wwww, l(0.6000, 0.4000, 0.8000, 0.0000)
	59 : and r2.w, r2.w, r5.x
	60 : movc r2.x, r2.w, l(3.0000), r2.x
	61 : ne r2.w, l(0, 0, 0, 0), cb0[38].w
	62 : and r2.w, r4.z, r2.w
	63 : and r2.w, r5.y, r2.w
	64 : movc r2.x, r2.w, l(4.0000), r2.x
	65 : ne r2.w, l(0, 0, 0, 0), cb0[42].w
	66 : and r2.w, r4.w, r2.w
	67 : and r2.w, r5.z, r2.w
	68 : movc r2.x, r2.w, l(5.0000), r2.x
	69 : eq r4.xyzw, r2.xxxx, l(2.0000, 3.0000, 4.0000, 5.0000)
	70 : movc r5.xyz, r4.xxxx, cb0[31].yzwy, cb0[10].xyzx
	71 : movc r5.xyz, r4.yyyy, cb0[35].xyzx, r5.xyzx
	72 : movc r5.xyz, r4.zzzz, cb0[39].xyzx, r5.xyzx
	73 : movc r5.xyz, r4.wwww, cb0[43].xyzx, r5.xyzx
	74 : mul r1.xyz, r1.xyzx, r5.xyzx
	75 : lt r2.w, l(0.0100), r1.w
	76 : and r2.z, r2.w, r2.z
	77 : and r1.w, r1.w, r2.z
	78 : mul r2.w, r0.w, v1.x
	79 : movc r0.w, r2.y, r2.w, r0.w
	80 : lt r2.y, r0.w, l(0.0500)
	81 : lt r2.w, l(0.9500), r0.w
	82 : add r0.w, r0.w, v3.w
	83 : mul r0.w, r0.w, l(0.5000)
	84 : movc r0.w, r2.w, l(1.0000), r0.w
	85 : movc r0.w, r2.y, l(0), r0.w
	86 : lt r2.y, r0.w, cb0[16].z
	87 : if_nz r2.y
	88 : ne r2.y, l(0, 0, 0, 0), cb0[19].y
	89 : movc r3.yw, r4.xxxx, cb0[34].yyyz, cb0[19].zzzw
	90 : movc r3.yw, r4.yyyy, cb0[38].yyyz, r3.yyyw
	91 : movc r3.yw, r4.zzzz, cb0[42].yyyz, r3.yyyw
	92 : movc r3.yw, r4.wwww, cb0[46].yyyz, r3.yyyw
	93 : add r0.w, -r0.w, cb0[16].z
	94 : div r0.w, r0.w, r3.y
	95 : ge r2.w, r0.w, l(1.0000)
	96 : add r0.w, r0.w, l(0.0100)
	97 : log r0.w, r0.w
	98 : mul r0.w, r0.w, r3.w
	99 : exp r0.w, r0.w
	100 : min r0.w, r0.w, l(1.0000)
	101 : movc r0.w, r2.w, l(1.0000), r0.w
	102 : movc r0.w, r2.y, r0.w, l(1.0000)
	103 : mov r2.y, l(0)
	104 : else
	105:   mov r0.w, l(0)
	106 : mov r2.y, l(1.0000)
	107 : endif
	108 : add r2.y, -r2.y, l(1.0000)
	109 : ne r2.w, l(0, 0, 0, 0), v5.w
	110 : movc r2.y, r2.w, l(1.0000), r2.y
	111 : lt r3.y, l(0.5000), cb0[61].w
	112 : add r3.w, cb0[60].w, cb0[60].w
	113 : min r3.w, r3.w, l(1.0000)
	114 : movc r3.y, r3.y, r3.w, l(1.0000)
	115 : lt r3.w, l(0.9000), r3.x
	116 : if_nz r3.w
	117 : mul r5.xy, v3.yyyy, cb2[15].xyxx
	118 : mad r5.xy, cb2[14].xyxx, v3.xxxx, r5.xyxx
	119 : mad r5.yz, cb2[16].xxyx, v3.zzzz, r5.xxyx
	120 : mul r5.x, r5.y, cb0[50].y
	121 : mad r5.xy, r5.xzxx, l(0.5000, 0.5000, 0.0000, 0.0000), l(0.5000, 0.5000, 0.0000, 0.0000)
	122 : sample_indexable(texture2d)(float, float, float, float) r3.w, r5.xyxx, t2.yzwx, s2
	123 : mul_sat r3.w, r3.w, cb0[50].x
	124 : add r5.xyz, cb0[51].xyzx, -cb0[52].xyzx
	125 : mad r5.xyz, r3.wwww, r5.xyzx, cb0[52].xyzx
	126 : mul r5.xyz, r1.xyzx, r5.xyzx
	127 : dp3 r3.w, v3.xyzx, r0.xyzx
	128 : max r3.w, r3.w, l(0.0010)
	129 : log r3.w, r3.w
	130 : mul r3.w, r3.w, cb0[53].w
	131 : exp r3.w, r3.w
	132 : mul_sat r3.w, r3.w, cb0[54].w
	133 : mul r6.xyz, r3.wwww, cb0[54].xyzx
	134 : mul r6.xyz, r3.zzzz, r6.xyzx
	135 : mul r7.xyz, r6.xyzx, cb0[55].xxxx
	136 : movc r6.xyz, r2.wwww, r7.xyzx, r6.xyzx
	137 : ne r3.w, l(0, 0, 0, 0), cb0[19].y
	138 : add r7.xyz, cb0[53].xyzx, l(-1.0000, -1.0000, -1.0000, 0.0000)
	139 : mad r7.xyz, r0.wwww, r7.xyzx, l(1.0000, 1.0000, 1.0000, 0.0000)
	140 : movc r7.xyz, r3.wwww, r7.xyzx, cb0[53].xyzx
	141 : ne r3.w, l(0, 0, 0, 0), r2.y
	142 : mul r8.xyz, r5.xyzx, r7.xyzx
	143 : mul r9.xyz, r5.xyzx, cb0[56].wwww
	144 : movc r9.xyz, r3.wwww, r8.xyzx, r9.xyzx
	145 : lt r3.w, r3.y, l(1.0000)
	146 : mad r5.xyz, -r5.xyzx, r7.xyzx, r9.xyzx
	147 : mad r5.xyz, r3.yyyy, r5.xyzx, r8.xyzx
	148 : movc r5.xyz, r3.wwww, r5.xyzx, r9.xyzx
	149 : mul r6.xyz, r6.xyzx, cb0[56].wwww
	150 : else
	151:   eq r2.x, r2.x, l(1.0000)
	152 : if_nz r2.x
	153 : ne r3.w, l(0, 0, 0, 0), cb0[17].w
	154 : add r7.xyz, cb0[17].xyzx, -cb0[18].xyzx
	155 : mad r7.xyz, cb0[58].yyyy, r7.xyzx, cb0[18].xyzx
	156 : movc r7.xyz, r3.wwww, r7.xyzx, cb0[17].xyzx
	157 : else
	158:     if_nz r4.x
	159 : ne r3.w, l(0, 0, 0, 0), cb0[17].w
	160 : add r8.xyz, cb0[32].xyzx, -cb0[33].xyzx
	161 : mad r8.xyz, cb0[58].yyyy, r8.xyzx, cb0[33].xyzx
	162 : movc r7.xyz, r3.wwww, r8.xyzx, cb0[32].xyzx
	163 : else
	164:       ne r3.w, l(0, 0, 0, 0), cb0[17].w
	165 : add r8.xyz, cb0[36].xyzx, -cb0[37].xyzx
	166 : mad r8.xyz, cb0[58].yyyy, r8.xyzx, cb0[37].xyzx
	167 : movc r8.xyz, r3.wwww, r8.xyzx, cb0[36].xyzx
	168 : add r9.xyz, cb0[40].xyzx, -cb0[41].xyzx
	169 : mad r9.xyz, cb0[58].yyyy, r9.xyzx, cb0[41].xyzx
	170 : movc r9.xyz, r3.wwww, r9.xyzx, cb0[40].xyzx
	171 : add r10.xyz, cb0[44].xyzx, -cb0[45].xyzx
	172 : mad r10.xyz, cb0[58].yyyy, r10.xyzx, cb0[45].xyzx
	173 : movc r10.xyz, r3.wwww, r10.xyzx, cb0[44].xyzx
	174 : movc r9.xyz, r4.zzzz, r9.xyzx, r10.xyzx
	175 : movc r7.xyz, r4.yyyy, r8.xyzx, r9.xyzx
	176 : endif
	177 : endif
	178 : lt r3.w, r3.y, l(1.0000)
	179 : and r8.xyz, r7.xyzx, r3.wwww
	180 : ne r4.w, l(0, 0, 0, 0), cb0[19].y
	181 : not r2.w, r2.w
	182 : and r2.w, r2.w, r4.w
	183 : add r9.xyz, r7.xyzx, l(-1.0000, -1.0000, -1.0000, 0.0000)
	184 : mad r9.xyz, r0.wwww, r9.xyzx, l(1.0000, 1.0000, 1.0000, 0.0000)
	185 : movc r7.xyz, r2.wwww, r9.xyzx, r7.xyzx
	186 : ne r0.w, l(0, 0, 0, 0), r2.y
	187 : mul r7.xyz, r1.xyzx, r7.xyzx
	188 : mul r9.xyz, r1.xyzx, cb0[56].wwww
	189 : movc r7.xyz, r0.wwww, r7.xyzx, r9.xyzx
	190 : mul r9.xyz, r1.xyzx, r8.xyzx
	191 : mad r8.xyz, -r1.xyzx, r8.xyzx, r7.xyzx
	192 : mad r8.xyz, r3.yyyy, r8.xyzx, r9.xyzx
	193 : movc r5.xyz, r3.wwww, r8.xyzx, r7.xyzx
	194 : movc r0.w, r4.z, cb0[41].w, cb0[45].w
	195 : movc r2.y, r4.z, cb0[42].x, cb0[46].x
	196 : movc r0.w, r4.y, cb0[37].w, r0.w
	197 : movc r2.y, r4.y, cb0[38].x, r2.y
	198 : movc r0.w, r4.x, cb0[33].w, r0.w
	199 : movc r2.y, r4.x, cb0[34].x, r2.y
	200 : movc r0.w, r2.x, cb0[20].w, r0.w
	201 : movc r2.x, r2.x, cb0[21].x, r2.y
	202 : dp3 r0.x, v3.xyzx, r0.xyzx
	203 : max r0.x, r0.x, l(0.0010)
	204 : log r0.x, r0.x
	205 : mul r0.x, r0.x, r0.w
	206 : exp r0.x, r0.x
	207 : add r0.y, -r3.z, l(1.0000)
	208 : lt r0.x, r0.y, r0.x
	209 : mul r0.yzw, r2.xxxx, cb0[20].xxyz
	210 : mul r0.yzw, r3.xxxx, r0.yyzw
	211 : and r0.yzw, r0.yyzw, r0.xxxx
	212 : mul r0.yzw, r0.yyzw, cb0[56].wwww
	213 : and r6.xyz, r0.yzwy, r0.xxxx
	214 : endif
	215 : mul r0.xyz, r1.xyzx, cb0[26].xyzx
	216 : lt r0.w, r3.y, l(1.0000)
	217 : mul r1.xyz, r3.yyyy, r6.xyzx
	218 : movc r1.xyz, r0.wwww, r1.xyzx, r6.xyzx
	219 : add r1.xyz, r1.xyzx, r5.xyzx
	220 : mad r0.xyz, r0.xyzx, cb0[25].zzzz, -r1.xyzx
	221 : mad r0.xyz, r1.wwww, r0.xyzx, r1.xyzx
	222 : movc r0.xyz, r2.zzzz, r0.xyzx, r1.xyzx
	223 : dp3 r0.w, v7.xyzx, v7.xyzx
	224 : rsq r0.w, r0.w
	225 : mul r1.xyz, r0.wwww, v7.xyzx
	226 : dp3 r0.w, v3.xyzx, v3.xyzx
	227 : rsq r0.w, r0.w
	228 : mul r2.xyz, r0.wwww, v3.xyzx
	229 : dp3 r0.w, r2.xyzx, r1.xyzx
	230 : add r0.w, -r0.w, l(1.0000)
	231 : max r0.w, r0.w, l(0.0001)
	232 : mul r1.x, r0.w, r0.w
	233 : mul r0.w, r0.w, r1.x
	234 : mad r1.xy, v2.zwzz, cb0[66].xyxx, cb0[66].zwzz
	235 : eq r1.z, cb0[67].z, l(1.0000)
	236 : add r2.w, -v2.w, l(1.0000)
	237 : movc r1.z, r1.z, r2.w, v2.w
	238 : mad r1.z, cb0[67].y, l(2.1000), r1.z
	239 : add r3.y, r1.z, l(-1.0000)
	240 : mov r3.x, v2.z
	241 : sample_indexable(texture2d)(float, float, float, float) r3.xy, r3.xyxx, t3.xyzw, s4
	242 : mad r1.xy, cb1[0].yyyy, cb0[67].xxxx, r1.xyxx
	243 : sample_indexable(texture2d)(float, float, float, float) r1.x, r1.xyxx, t4.xyzw, s3
	244 : mad r0.w, r0.w, l(1.1000), r1.x
	245 : add r1.x, cb0[67].y, l(-0.2500)
	246 : mul r1.x, r1.x, l(6.2800)
	247 : sincos r1.x, null, r1.x
	248 : add r1.x, r1.x, l(1.0000)
	249 : mul r0.w, r0.w, r1.x
	250 : mul r1.x, r3.y, l(3.0000)
	251 : mad r0.w, r0.w, l(0.5000), r1.x
	252 : add r1.xyz, -v8.xyzx, cb1[5].xyzx
	253 : dp3 r2.w, r1.xyzx, r1.xyzx
	254 : rsq r2.w, r2.w
	255 : mul r1.xyz, r1.xyzx, r2.wwww
	256 : dp3 r1.x, r1.xyzx, r2.xyzx
	257 : add r1.x, -r1.x, l(1.0000)
	258 : max r1.x, r1.x, l(0.0001)
	259 : log r1.x, r1.x
	260 : mul r1.x, r1.x, cb0[69].x
	261 : exp r1.x, r1.x
	262 : mul r1.xyz, r1.xxxx, cb0[70].xyzx
	263 : mad r2.xy, v2.zwzz, cb0[72].xyxx, cb0[72].zwzz
	264 : eq r2.w, cb0[73].x, l(1.0000)
	265 : add r3.y, -r2.y, l(1.0000)
	266 : movc r2.y, r2.w, r3.y, r2.y
	267 : mul r2.w, cb0[73].y, cb1[0].y
	268 : mad r2.z, r2.y, l(0.5000), r2.w
	269 : sample_indexable(texture2d)(float, float, float, float) r2.x, r2.xzxx, t5.xyzw, s5
	270 : mul r2.x, r2.x, cb0[73].z
	271 : add r1.w, r1.w, r0.w
	272 : mad r1.w, r1.x, cb0[71].x, r1.w
	273 : mad_sat o2.x, r2.x, cb0[74].x, r1.w
	274 : mad r0.xyz, r0.wwww, cb0[68].xyzx, r0.xyzx
	275 : mad r0.xyz, r1.xyzx, cb0[71].xxxx, r0.xyzx
	276 : mad r0.xyz, r2.xxxx, cb0[74].xyzx, r0.xyzx
	277 : lt r1.x, r3.x, l(0.9900)
	278 : add r1.y, r3.x, l(-0.0010)
	279 : lt r1.y, r1.y, l(0)
	280 : and r1.x, r1.x, r1.y
	281 : discard_nz r1.x
	282 : max r1.x, r0.z, r0.y
	283 : max r1.w, r0.x, r1.x
	284 : lt r2.x, l(1.0000), r1.w
	285 : div r1.xyz, r0.xyzx, r1.wwww
	286 : mov r0.w, l(1.0000)
	287 : movc r0.xyzw, r2.xxxx, r1.xyzw, r0.xyzw
	288 : lt r1.x, v3.z, l(0)
	289 : movc o0.w, r1.x, l(0), l(1.0000)
	290 : ne r1.x, l(0, 0, 0, 0), cb0[9].x
	291 : mul r1.y, cb0[9].y, l(0.0039)
	292 : and o2.z, r1.y, r1.x
	293 : mad o0.xy, v3.xyxx, l(0.5000, 0.5000, 0.0000, 0.0000), l(0.5000, 0.5000, 0.0000, 0.0000)
	294 : mov o0.z, v5.w
	295 : mul o1.xyzw, r0.xyzw, l(1.0000, 1.0000, 1.0000, 0.0500)
	296 : mov o2.y, l(0)
	297 : mov o2.w, v5.w
	298 : mov o3.x, l(0.0157)
	299 : ret
