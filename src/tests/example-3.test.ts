import { parseGerber } from "../parse-gerber"
import test from "ava"

export const SMD_prim_20 = `G04 Generated by UcamX v2017.04-170404 on 2017.4.7*
G04 Ucamco copyright*


%TF.GenerationSoftware,Ucamco,UcamX,v2017.04-170404*%
%TF.CreationDate,2017-04-18T10:09:12+00:00*%
%TF.FileFunction,Other,SMD prim20*%
%TF.FilePolarity,Positive*%



%FSLAX46Y46*%
%MOMM*%
G01*

G04 Create aperture macro*


%AMRECTROUNDCORNERS*
0 Rectangle with rounded corners*
0 $1 width *
0 $2 height *
0 $3 corner radius *
0 $4 flash origin X offset *
0 $5 flash origin Y offset *
0 $6 rotation angle *
0 Create two overlapping rectangles that omit the rounded corner areas*
20,1,$2-2x$3,$4-$1/2,$5,$4+$1/2,$5,$6*
20,1,$2,$4,$5-$2/2,$4,$5+$2/2,$6*
0 Add circles at the corners. *
1,1,2x$3,$4+$1/2-$3,$5+$2/2-$3,$6*
1,1,2x$3,$4-$1/2+$3,$5+$2/2-$3,$6*
1,1,2x$3,$4-$1/2+$3,$5-$2/2+$3,$6*
1,1,2x$3,$4+$1/2-$3,$5-$2/2+$3,$6*%

G04 Create aperture*
%ADD10RECTROUNDCORNERS,4X3X0.5X0X0X0*%
%ADD11RECTROUNDCORNERS,4X3X0.5X0X0X10*%
%ADD12RECTROUNDCORNERS,4X3X0.5X0X0X30*%
%ADD13RECTROUNDCORNERS,4X3X0.5X0X0X45*%
%ADD20RECTROUNDCORNERS,4X3X0.5X1.0X2.0X0*%
%ADD21RECTROUNDCORNERS,4X3X0.5X1.0X2.0X10*%
%ADD22RECTROUNDCORNERS,4X3X0.5X1.0X2.0X30*%
%ADD23RECTROUNDCORNERS,4X3X0.5X1.0X2.0X45*%
G04 Select aperture*
D10*
G04 Flash aperture*
X0Y0D03*
D11*
X6000000D03*
D12*
X12000000D03*
D13*
X18000000D03*
D20*
X0Y5000000D03*
D21*
X6000000Y5000000D03*
D22*
X12000000D03*
D23*
X18000000D03*
%TF.MD5,2A4CB336BBB01B553283D651B0C6E89A*%
M02*`

test("SMD_prim_20", (t) => {
  t.snapshot(parseGerber(SMD_prim_20))
})
