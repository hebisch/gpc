{ Common declarations for crt.pas and crtc.c

  This file is included into crt.pas. crtc.h which is included into
  crtc.c can be generated from this file (cf. Make-lang.in in the
  main GPC source directory).

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{ Key codes not used yet: #204, #205, #244, #245, #248, #249 }

const
  ksUnknown    = #255;     kbUnknown    = $100 * Ord (ksUnknown);
  ksLeft       = #75;      kbLeft       = $100 * Ord (ksLeft);
  ksRight      = #77;      kbRight      = $100 * Ord (ksRight);
  ksUp         = #72;      kbUp         = $100 * Ord (ksUp);
  ksDown       = #80;      kbDown       = $100 * Ord (ksDown);
  ksPgUp       = #73;      kbPgUp       = $100 * Ord (ksPgUp);
  ksPgDn       = #81;      kbPgDn       = $100 * Ord (ksPgDn);
  ksHome       = #71;      kbHome       = $100 * Ord (ksHome);
  ksEnd        = #79;      kbEnd        = $100 * Ord (ksEnd);
  ksIns        = #82;      kbIns        = $100 * Ord (ksIns);
  ksDel        = #83;      kbDel        = $100 * Ord (ksDel);
  ksCenter     = #76;      kbCenter     = $100 * Ord (ksCenter);
  ksShTab      = #15;      kbShTab      = $100 * Ord (ksShTab);
  ksShIns      = #246;     kbShIns      = $100 * Ord (ksShIns);
  ksShDel      = #247;     kbShDel      = $100 * Ord (ksShDel);
  ksCtrlTab    = #148;     kbCtrlTab    = $100 * Ord (ksCtrlTab);
  ksCtrlLeft   = #115;     kbCtrlLeft   = $100 * Ord (ksCtrlLeft);
  ksCtrlRight  = #116;     kbCtrlRight  = $100 * Ord (ksCtrlRight);
  ksCtrlUp     = #141;     kbCtrlUp     = $100 * Ord (ksCtrlUp);
  ksCtrlDown   = #145;     kbCtrlDown   = $100 * Ord (ksCtrlDown);
  ksCtrlPgUp   = #132;     kbCtrlPgUp   = $100 * Ord (ksCtrlPgUp);
  ksCtrlPgDn   = #118;     kbCtrlPgDn   = $100 * Ord (ksCtrlPgDn);
  ksCtrlHome   = #119;     kbCtrlHome   = $100 * Ord (ksCtrlHome);
  ksCtrlEnd    = #117;     kbCtrlEnd    = $100 * Ord (ksCtrlEnd);
  ksCtrlIns    = #146;     kbCtrlIns    = $100 * Ord (ksCtrlIns);
  ksCtrlDel    = #147;     kbCtrlDel    = $100 * Ord (ksCtrlDel);
  ksCtrlBkSp   = #167;     kbCtrlBkSp   = $100 * Ord (ksCtrlBkSp);
  ksCtrlCentr  = #143;     kbCtrlCentr  = $100 * Ord (ksCtrlCentr);
  ksShCtrlIns  = #206;     kbShCtrlIns  = $100 * Ord (ksShCtrlIns);
  ksShCtrlDel  = #207;     kbShCtrlDel  = $100 * Ord (ksShCtrlDel);
  ksAltTab     = #165;     kbAltTab     = $100 * Ord (ksAltTab);
  ksAltLeft    = #155;     kbAltLeft    = $100 * Ord (ksAltLeft);
  ksAltRight   = #157;     kbAltRight   = $100 * Ord (ksAltRight);
  ksAltUp      = #152;     kbAltUp      = $100 * Ord (ksAltUp);
  ksAltDown    = #160;     kbAltDown    = $100 * Ord (ksAltDown);
  ksAltPgUp    = #153;     kbAltPgUp    = $100 * Ord (ksAltPgUp);
  ksAltPgDn    = #161;     kbAltPgDn    = $100 * Ord (ksAltPgDn);
  ksAltHome    = #151;     kbAltHome    = $100 * Ord (ksAltHome);
  ksAltEnd     = #159;     kbAltEnd     = $100 * Ord (ksAltEnd);
  ksAltIns     = #162;     kbAltIns     = $100 * Ord (ksAltIns);
  ksAltDel     = #163;     kbAltDel     = $100 * Ord (ksAltDel);
  ksAltEnter   = #166;     kbAltEnter   = $100 * Ord (ksAltEnter);
  ksAltPStar   = #55;      kbAltPStar   = $100 * Ord (ksAltPStar);
  ksAltPMinus  = #74;      kbAltPMinus  = $100 * Ord (ksAltPMinus);
  ksAltPPlus   = #78;      kbAltPPlus   = $100 * Ord (ksAltPPlus);
  ksAltEsc     = #1;       kbAltEsc     = $100 * Ord (ksAltEsc);
  ksAltSpace   = #2;       kbAltSpace   = $100 * Ord (ksAltSpace);
  ksAltBkSp    = #14;      kbAltBkSp    = $100 * Ord (ksAltBkSp);
  ksAltMinus   = #130;     kbAltMinus   = $100 * Ord (ksAltMinus);
  ksAltEqual   = #131;     kbAltEqual   = $100 * Ord (ksAltEqual);
  ksAltLBrack  = #26;      kbAltLBrack  = $100 * Ord (ksAltLBrack);
  ksAltRBrack  = #27;      kbAltRBrack  = $100 * Ord (ksAltRBrack);
  ksAltSemic   = #39;      kbAltSemic   = $100 * Ord (ksAltSemic);
  ksAltFQuote  = #40;      kbAltFQuote  = $100 * Ord (ksAltFQuote);
  ksAltBQuote  = #41;      kbAltBQuote  = $100 * Ord (ksAltBQuote);
  ksAltComma   = #51;      kbAltComma   = $100 * Ord (ksAltComma);
  ksAltStop    = #52;      kbAltStop    = $100 * Ord (ksAltStop);
  ksAltFSlash  = #53;      kbAltFSlash  = $100 * Ord (ksAltFSlash);
  ksAltBSlash  = #43;      kbAltBSlash  = $100 * Ord (ksAltBSlash);
  ksAlt0       = #129;     kbAlt0       = $100 * Ord (ksAlt0);
  ksAlt1       = #120;     kbAlt1       = $100 * Ord (ksAlt1);
  ksAlt2       = #121;     kbAlt2       = $100 * Ord (ksAlt2);
  ksAlt3       = #122;     kbAlt3       = $100 * Ord (ksAlt3);
  ksAlt4       = #123;     kbAlt4       = $100 * Ord (ksAlt4);
  ksAlt5       = #124;     kbAlt5       = $100 * Ord (ksAlt5);
  ksAlt6       = #125;     kbAlt6       = $100 * Ord (ksAlt6);
  ksAlt7       = #126;     kbAlt7       = $100 * Ord (ksAlt7);
  ksAlt8       = #127;     kbAlt8       = $100 * Ord (ksAlt8);
  ksAlt9       = #128;     kbAlt9       = $100 * Ord (ksAlt9);
  ksAltA       = #30;      kbAltA       = $100 * Ord (ksAltA);
  ksAltB       = #48;      kbAltB       = $100 * Ord (ksAltB);
  ksAltC       = #46;      kbAltC       = $100 * Ord (ksAltC);
  ksAltD       = #32;      kbAltD       = $100 * Ord (ksAltD);
  ksAltE       = #18;      kbAltE       = $100 * Ord (ksAltE);
  ksAltF       = #33;      kbAltF       = $100 * Ord (ksAltF);
  ksAltG       = #34;      kbAltG       = $100 * Ord (ksAltG);
  ksAltH       = #35;      kbAltH       = $100 * Ord (ksAltH);
  ksAltI       = #23;      kbAltI       = $100 * Ord (ksAltI);
  ksAltJ       = #36;      kbAltJ       = $100 * Ord (ksAltJ);
  ksAltK       = #37;      kbAltK       = $100 * Ord (ksAltK);
  ksAltL       = #38;      kbAltL       = $100 * Ord (ksAltL);
  ksAltM       = #50;      kbAltM       = $100 * Ord (ksAltM);
  ksAltN       = #49;      kbAltN       = $100 * Ord (ksAltN);
  ksAltO       = #24;      kbAltO       = $100 * Ord (ksAltO);
  ksAltP       = #25;      kbAltP       = $100 * Ord (ksAltP);
  ksAltQ       = #16;      kbAltQ       = $100 * Ord (ksAltQ);
  ksAltR       = #19;      kbAltR       = $100 * Ord (ksAltR);
  ksAltS       = #31;      kbAltS       = $100 * Ord (ksAltS);
  ksAltT       = #20;      kbAltT       = $100 * Ord (ksAltT);
  ksAltU       = #22;      kbAltU       = $100 * Ord (ksAltU);
  ksAltV       = #47;      kbAltV       = $100 * Ord (ksAltV);
  ksAltW       = #17;      kbAltW       = $100 * Ord (ksAltW);
  ksAltX       = #45;      kbAltX       = $100 * Ord (ksAltX);
  ksAltY       = #21;      kbAltY       = $100 * Ord (ksAltY);
  ksAltZ       = #44;      kbAltZ       = $100 * Ord (ksAltZ);
  ksAltGr0     = #168;     kbAltGr0     = $100 * Ord (ksAltGr0);
  ksAltGr1     = #169;     kbAltGr1     = $100 * Ord (ksAltGr1);
  ksAltGr2     = #170;     kbAltGr2     = $100 * Ord (ksAltGr2);
  ksAltGr3     = #171;     kbAltGr3     = $100 * Ord (ksAltGr3);
  ksAltGr4     = #172;     kbAltGr4     = $100 * Ord (ksAltGr4);
  ksAltGr5     = #173;     kbAltGr5     = $100 * Ord (ksAltGr5);
  ksAltGr6     = #174;     kbAltGr6     = $100 * Ord (ksAltGr6);
  ksAltGr7     = #175;     kbAltGr7     = $100 * Ord (ksAltGr7);
  ksAltGr8     = #176;     kbAltGr8     = $100 * Ord (ksAltGr8);
  ksAltGr9     = #177;     kbAltGr9     = $100 * Ord (ksAltGr9);
  ksAltGrA     = #178;     kbAltGrA     = $100 * Ord (ksAltGrA);
  ksAltGrB     = #179;     kbAltGrB     = $100 * Ord (ksAltGrB);
  ksAltGrC     = #180;     kbAltGrC     = $100 * Ord (ksAltGrC);
  ksAltGrD     = #181;     kbAltGrD     = $100 * Ord (ksAltGrD);
  ksAltGrE     = #182;     kbAltGrE     = $100 * Ord (ksAltGrE);
  ksAltGrF     = #183;     kbAltGrF     = $100 * Ord (ksAltGrF);
  ksAltGrG     = #184;     kbAltGrG     = $100 * Ord (ksAltGrG);
  ksAltGrH     = #185;     kbAltGrH     = $100 * Ord (ksAltGrH);
  ksAltGrI     = #186;     kbAltGrI     = $100 * Ord (ksAltGrI);
  ksAltGrJ     = #187;     kbAltGrJ     = $100 * Ord (ksAltGrJ);
  ksAltGrK     = #188;     kbAltGrK     = $100 * Ord (ksAltGrK);
  ksAltGrL     = #189;     kbAltGrL     = $100 * Ord (ksAltGrL);
  ksAltGrM     = #190;     kbAltGrM     = $100 * Ord (ksAltGrM);
  ksAltGrN     = #191;     kbAltGrN     = $100 * Ord (ksAltGrN);
  ksAltGrO     = #192;     kbAltGrO     = $100 * Ord (ksAltGrO);
  ksAltGrP     = #193;     kbAltGrP     = $100 * Ord (ksAltGrP);
  ksAltGrQ     = #194;     kbAltGrQ     = $100 * Ord (ksAltGrQ);
  ksAltGrR     = #195;     kbAltGrR     = $100 * Ord (ksAltGrR);
  ksAltGrS     = #196;     kbAltGrS     = $100 * Ord (ksAltGrS);
  ksAltGrT     = #197;     kbAltGrT     = $100 * Ord (ksAltGrT);
  ksAltGrU     = #198;     kbAltGrU     = $100 * Ord (ksAltGrU);
  ksAltGrV     = #199;     kbAltGrV     = $100 * Ord (ksAltGrV);
  ksAltGrW     = #200;     kbAltGrW     = $100 * Ord (ksAltGrW);
  ksAltGrX     = #201;     kbAltGrX     = $100 * Ord (ksAltGrX);
  ksAltGrY     = #202;     kbAltGrY     = $100 * Ord (ksAltGrY);
  ksAltGrZ     = #203;     kbAltGrZ     = $100 * Ord (ksAltGrZ);
  ksExtra0     = #208;     kbExtra0     = $100 * Ord (ksExtra0);
  ksExtra1     = #209;     kbExtra1     = $100 * Ord (ksExtra1);
  ksExtra2     = #210;     kbExtra2     = $100 * Ord (ksExtra2);
  ksExtra3     = #211;     kbExtra3     = $100 * Ord (ksExtra3);
  ksExtra4     = #212;     kbExtra4     = $100 * Ord (ksExtra4);
  ksExtra5     = #213;     kbExtra5     = $100 * Ord (ksExtra5);
  ksExtra6     = #214;     kbExtra6     = $100 * Ord (ksExtra6);
  ksExtra7     = #215;     kbExtra7     = $100 * Ord (ksExtra7);
  ksExtra8     = #216;     kbExtra8     = $100 * Ord (ksExtra8);
  ksExtra9     = #217;     kbExtra9     = $100 * Ord (ksExtra9);
  ksExtraA     = #218;     kbExtraA     = $100 * Ord (ksExtraA);
  ksExtraB     = #219;     kbExtraB     = $100 * Ord (ksExtraB);
  ksExtraC     = #220;     kbExtraC     = $100 * Ord (ksExtraC);
  ksExtraD     = #221;     kbExtraD     = $100 * Ord (ksExtraD);
  ksExtraE     = #222;     kbExtraE     = $100 * Ord (ksExtraE);
  ksExtraF     = #223;     kbExtraF     = $100 * Ord (ksExtraF);
  ksExtraG     = #224;     kbExtraG     = $100 * Ord (ksExtraG);
  ksExtraH     = #225;     kbExtraH     = $100 * Ord (ksExtraH);
  ksExtraI     = #226;     kbExtraI     = $100 * Ord (ksExtraI);
  ksExtraJ     = #227;     kbExtraJ     = $100 * Ord (ksExtraJ);
  ksExtraK     = #228;     kbExtraK     = $100 * Ord (ksExtraK);
  ksExtraL     = #229;     kbExtraL     = $100 * Ord (ksExtraL);
  ksExtraM     = #230;     kbExtraM     = $100 * Ord (ksExtraM);
  ksExtraN     = #231;     kbExtraN     = $100 * Ord (ksExtraN);
  ksExtraO     = #232;     kbExtraO     = $100 * Ord (ksExtraO);
  ksExtraP     = #233;     kbExtraP     = $100 * Ord (ksExtraP);
  ksExtraQ     = #234;     kbExtraQ     = $100 * Ord (ksExtraQ);
  ksExtraR     = #235;     kbExtraR     = $100 * Ord (ksExtraR);
  ksExtraS     = #236;     kbExtraS     = $100 * Ord (ksExtraS);
  ksExtraT     = #237;     kbExtraT     = $100 * Ord (ksExtraT);
  ksExtraU     = #238;     kbExtraU     = $100 * Ord (ksExtraU);
  ksExtraV     = #239;     kbExtraV     = $100 * Ord (ksExtraV);
  ksExtraW     = #240;     kbExtraW     = $100 * Ord (ksExtraW);
  ksExtraX     = #241;     kbExtraX     = $100 * Ord (ksExtraX);
  ksExtraY     = #242;     kbExtraY     = $100 * Ord (ksExtraY);
  ksExtraZ     = #243;     kbExtraZ     = $100 * Ord (ksExtraZ);
  ksF1         = #59;      kbF1         = $100 * Ord (ksF1);
  ksF2         = #60;      kbF2         = $100 * Ord (ksF2);
  ksF3         = #61;      kbF3         = $100 * Ord (ksF3);
  ksF4         = #62;      kbF4         = $100 * Ord (ksF4);
  ksF5         = #63;      kbF5         = $100 * Ord (ksF5);
  ksF6         = #64;      kbF6         = $100 * Ord (ksF6);
  ksF7         = #65;      kbF7         = $100 * Ord (ksF7);
  ksF8         = #66;      kbF8         = $100 * Ord (ksF8);
  ksF9         = #67;      kbF9         = $100 * Ord (ksF9);
  ksF10        = #68;      kbF10        = $100 * Ord (ksF10);
  ksF11        = #133;     kbF11        = $100 * Ord (ksF11);
  ksF12        = #134;     kbF12        = $100 * Ord (ksF12);
  ksShF1       = #84;      kbShF1       = $100 * Ord (ksShF1);
  ksShF2       = #85;      kbShF2       = $100 * Ord (ksShF2);
  ksShF3       = #86;      kbShF3       = $100 * Ord (ksShF3);
  ksShF4       = #87;      kbShF4       = $100 * Ord (ksShF4);
  ksShF5       = #88;      kbShF5       = $100 * Ord (ksShF5);
  ksShF6       = #89;      kbShF6       = $100 * Ord (ksShF6);
  ksShF7       = #90;      kbShF7       = $100 * Ord (ksShF7);
  ksShF8       = #91;      kbShF8       = $100 * Ord (ksShF8);
  ksShF9       = #92;      kbShF9       = $100 * Ord (ksShF9);
  ksShF10      = #93;      kbShF10      = $100 * Ord (ksShF10);
  ksShF11      = #135;     kbShF11      = $100 * Ord (ksShF11);
  ksShF12      = #136;     kbShF12      = $100 * Ord (ksShF12);
  ksCtrlF1     = #94;      kbCtrlF1     = $100 * Ord (ksCtrlF1);
  ksCtrlF2     = #95;      kbCtrlF2     = $100 * Ord (ksCtrlF2);
  ksCtrlF3     = #96;      kbCtrlF3     = $100 * Ord (ksCtrlF3);
  ksCtrlF4     = #97;      kbCtrlF4     = $100 * Ord (ksCtrlF4);
  ksCtrlF5     = #98;      kbCtrlF5     = $100 * Ord (ksCtrlF5);
  ksCtrlF6     = #99;      kbCtrlF6     = $100 * Ord (ksCtrlF6);
  ksCtrlF7     = #100;     kbCtrlF7     = $100 * Ord (ksCtrlF7);
  ksCtrlF8     = #101;     kbCtrlF8     = $100 * Ord (ksCtrlF8);
  ksCtrlF9     = #102;     kbCtrlF9     = $100 * Ord (ksCtrlF9);
  ksCtrlF10    = #103;     kbCtrlF10    = $100 * Ord (ksCtrlF10);
  ksCtrlF11    = #137;     kbCtrlF11    = $100 * Ord (ksCtrlF11);
  ksCtrlF12    = #138;     kbCtrlF12    = $100 * Ord (ksCtrlF12);
  ksAltF1      = #104;     kbAltF1      = $100 * Ord (ksAltF1);
  ksAltF2      = #105;     kbAltF2      = $100 * Ord (ksAltF2);
  ksAltF3      = #106;     kbAltF3      = $100 * Ord (ksAltF3);
  ksAltF4      = #107;     kbAltF4      = $100 * Ord (ksAltF4);
  ksAltF5      = #108;     kbAltF5      = $100 * Ord (ksAltF5);
  ksAltF6      = #109;     kbAltF6      = $100 * Ord (ksAltF6);
  ksAltF7      = #110;     kbAltF7      = $100 * Ord (ksAltF7);
  ksAltF8      = #111;     kbAltF8      = $100 * Ord (ksAltF8);
  ksAltF9      = #112;     kbAltF9      = $100 * Ord (ksAltF9);
  ksAltF10     = #113;     kbAltF10     = $100 * Ord (ksAltF10);
  ksAltF11     = #139;     kbAltF11     = $100 * Ord (ksAltF11);
  ksAltF12     = #140;     kbAltF12     = $100 * Ord (ksAltF12);
  ksCancel     = #3;       kbCancel     = $100 * Ord (ksCancel);
  ksCopy       = #4;       kbCopy       = $100 * Ord (ksCopy);
  ksUndo       = #5;       kbUndo       = $100 * Ord (ksUndo);
  ksRedo       = #6;       kbRedo       = $100 * Ord (ksRedo);
  ksOpen       = #7;       kbOpen       = $100 * Ord (ksOpen);
  ksClose      = #8;       kbClose      = $100 * Ord (ksClose);
  ksCommand    = #9;       kbCommand    = $100 * Ord (ksCommand);
  ksCreate     = #10;      kbCreate     = $100 * Ord (ksCreate);
  ksExit       = #11;      kbExit       = $100 * Ord (ksExit);
  ksFind       = #12;      kbFind       = $100 * Ord (ksFind);
  ksHelp       = #13;      kbHelp       = $100 * Ord (ksHelp);
  ksMark       = #28;      kbMark       = $100 * Ord (ksMark);
  ksMessage    = #29;      kbMessage    = $100 * Ord (ksMessage);
  ksMove       = #42;      kbMove       = $100 * Ord (ksMove);
  ksNext       = #54;      kbNext       = $100 * Ord (ksNext);
  ksPrevious   = #56;      kbPrevious   = $100 * Ord (ksPrevious);
  ksOptions    = #57;      kbOptions    = $100 * Ord (ksOptions);
  ksReference  = #58;      kbReference  = $100 * Ord (ksReference);
  ksRefresh    = #69;      kbRefresh    = $100 * Ord (ksRefresh);
  ksReplace    = #70;      kbReplace    = $100 * Ord (ksReplace);
  ksResize     = #114;     kbResize     = $100 * Ord (ksResize);
  ksRestart    = #142;     kbRestart    = $100 * Ord (ksRestart);
  ksSuspend    = #144;     kbSuspend    = $100 * Ord (ksSuspend);
  ksResume     = #149;     kbResume     = $100 * Ord (ksResume);
  ksSave       = #150;     kbSave       = $100 * Ord (ksSave);
  ksMenu       = #154;     kbMenu       = $100 * Ord (ksMenu);
  ksClear      = #156;     kbClear      = $100 * Ord (ksClear);
  ksSelect     = #158;     kbSelect     = $100 * Ord (ksSelect);
  ksStop       = #164;     kbStop       = $100 * Ord (ksStop);

  ksInt               = #250; kbInt               = $100 * Ord (ksInt);
  ksTerm              = #251; kbTerm              = $100 * Ord (ksTerm);
  ksHUp               = #252; kbHUp               = $100 * Ord (ksHUp);
  ksError             = #253; kbError             = $100 * Ord (ksError);
  ksScreenSizeChanged = #254; kbScreenSizeChanged = $100 * Ord (ksScreenSizeChanged);

  chBell       = #7;       kbBell       = Ord (chBell);
  chBkSp       = #8;       kbBkSp       = Ord (chBkSp);
  chTab        = #9;       kbTab        = Ord (chTab);
  chLF         = #10;      kbLF         = Ord (chLF);
  chFF         = #12;      kbFF         = Ord (chFF);
  chCR         = #13;      kbCR         = Ord (chCR);
  chEnter      = chCR;     kbEnter      = Ord (chEnter);
  chEsc        = #27;      kbEsc        = Ord (chEsc);
  chSpace      = ' ';      kbSpace      = Ord (chSpace);
  chNBSp       = #160;     kbNBSp       = Ord (chNBSp);

  chCtrlA      = #1;       kbCtrlA      = Ord (chCtrlA);
  chCtrlB      = #2;       kbCtrlB      = Ord (chCtrlB);
  chCtrlC      = #3;       kbCtrlC      = Ord (chCtrlC);
  chCtrlD      = #4;       kbCtrlD      = Ord (chCtrlD);
  chCtrlE      = #5;       kbCtrlE      = Ord (chCtrlE);
  chCtrlF      = #6;       kbCtrlF      = Ord (chCtrlF);
  chCtrlG      = #7;       kbCtrlG      = Ord (chCtrlG);
  chCtrlH      = #8;       kbCtrlH      = Ord (chCtrlH);
  chCtrlI      = #9;       kbCtrlI      = Ord (chCtrlI);
  chCtrlJ      = #10;      kbCtrlJ      = Ord (chCtrlJ);
  chCtrlK      = #11;      kbCtrlK      = Ord (chCtrlK);
  chCtrlL      = #12;      kbCtrlL      = Ord (chCtrlL);
  chCtrlM      = #13;      kbCtrlM      = Ord (chCtrlM);
  chCtrlN      = #14;      kbCtrlN      = Ord (chCtrlN);
  chCtrlO      = #15;      kbCtrlO      = Ord (chCtrlO);
  chCtrlP      = #16;      kbCtrlP      = Ord (chCtrlP);
  chCtrlQ      = #17;      kbCtrlQ      = Ord (chCtrlQ);
  chCtrlR      = #18;      kbCtrlR      = Ord (chCtrlR);
  chCtrlS      = #19;      kbCtrlS      = Ord (chCtrlS);
  chCtrlT      = #20;      kbCtrlT      = Ord (chCtrlT);
  chCtrlU      = #21;      kbCtrlU      = Ord (chCtrlU);
  chCtrlV      = #22;      kbCtrlV      = Ord (chCtrlV);
  chCtrlW      = #23;      kbCtrlW      = Ord (chCtrlW);
  chCtrlX      = #24;      kbCtrlX      = Ord (chCtrlX);
  chCtrlY      = #25;      kbCtrlY      = Ord (chCtrlY);
  chCtrlZ      = #26;      kbCtrlZ      = Ord (chCtrlZ);

  chLineHS     = #196;
  chLineVS     = #179;
  chLineHD     = #205;
  chLineVD     = #186;
  chLineHSS    = chLineHS;
  chLineVSS    = chLineVS;
  chLineHDS    = chLineHD;
  chLineVDS    = chLineVS;
  chLineHSD    = chLineHS;
  chLineVSD    = chLineVD;
  chLineHDD    = chLineHD;
  chLineVDD    = chLineVD;
  chCornerTLS  = #218;
  chCornerTRS  = #191;
  chCornerBLS  = #192;
  chCornerBRS  = #217;
  chCornerTLD  = #201;
  chCornerTRD  = #187;
  chCornerBLD  = #200;
  chCornerBRD  = #188;
  chCornerTLSS = chCornerTLS;
  chCornerTRSS = chCornerTRS;
  chCornerBLSS = chCornerBLS;
  chCornerBRSS = chCornerBRS;
  chCornerTLDS = #213;
  chCornerTRDS = #184;
  chCornerBLDS = #212;
  chCornerBRDS = #190;
  chCornerTLSD = #214;
  chCornerTRSD = #183;
  chCornerBLSD = #211;
  chCornerBRSD = #189;
  chCornerTLDD = chCornerTLD;
  chCornerTRDD = chCornerTRD;
  chCornerBLDD = chCornerBLD;
  chCornerBRDD = chCornerBRD;
  chTeeTS      = #194;
  chTeeBS      = #193;
  chTeeLS      = #195;
  chTeeRS      = #180;
  chTeeTD      = #203;
  chTeeBD      = #202;
  chTeeLD      = #204;
  chTeeRD      = #185;
  chTeeTSS     = chTeeTS;
  chTeeBSS     = chTeeBS;
  chTeeLSS     = chTeeLS;
  chTeeRSS     = chTeeRS;
  chTeeTDS     = #209;
  chTeeBDS     = #207;
  chTeeLDS     = #198;
  chTeeRDS     = #181;
  chTeeTSD     = #210;
  chTeeBSD     = #208;
  chTeeLSD     = #199;
  chTeeRSD     = #182;
  chTeeTDD     = chTeeTD;
  chTeeBDD     = chTeeBD;
  chTeeLDD     = chTeeLD;
  chTeeRDD     = chTeeRD;
  chCenterS    = #197;
  chCenterD    = #206;
  chCenterSS   = chCenterS;
  chCenterDS   = #216;
  chCenterSD   = #215;
  chCenterDD   = chCenterD;

  chArrowU     = #24;
  chArrowD     = #25;
  chArrowL     = #27;
  chArrowR     = #26;
  chArrowUD    = #18;
  chArrowLR    = #29;
  chTriangleU  = #30;
  chTriangleD  = #31;
  chTriangleL  = #17;
  chTriangleR  = #16;
  chBlock      = #219;
  chBlockT     = #223;
  chBlockB     = #220;
  chBlockL     = #221;
  chBlockR     = #222;

  chClubs      = #5;
  chSpades     = #6;
  chHearts     = #3;
  chDiamonds   = #4;
  chChkBoard1  = #176;
  chChkBoard2  = #177;
  chChkBoard3  = #178;
  chDegree     = #248;
  chPlusMinus  = #241;
  chBullet     = #254;
  chLEqual     = #243;
  chGEqual     = #242;
  chPi         = #227;
  chSmilie1    = #1;
  chSmilie2    = #2;
  chParagraph  = #21;

  shLeftShift  = 1;
  shRightShift = 2;
  shShift      = (shRightShift + shLeftShift);
  shLeftCtrl   = 4;
  shRightCtrl  = 8;
  shCtrl       = (shRightCtrl + shLeftCtrl);
  shLeftAlt    = 16;
  shAlt        = shLeftAlt;
  shRightAlt   = 32;
  shAltGr      = shRightAlt;
  shAnyAlt     = (shLeftAlt + shRightAlt);
  shExtra      = 64;

{$if defined (X11) and not defined (XCURSES)}
{$define XCURSES}
{$endif}
{$if defined (XCURSES) and not defined (X11)}
{$define X11}
{$endif}
{$if not defined (USE_PDCURSES) and not defined (USE_NCURSES)}
{$if defined (MSDOS) or defined (__MINGW32__) or defined (__CYGWIN__) or defined (__EMX__) or defined (XCURSES)}
{$define USE_PDCURSES}
{$else}
{$define USE_NCURSES}
{$endif}
{$endif}
