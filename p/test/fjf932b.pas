program fjf932b;

uses fjf932u;

begin
  if    (v.a <> 11)
     or (v.b <> 24)
     or (v.c <> 22)
     or (v.d <> 13)
     or (v.e <> 3)
     or (v.f <> 14)
     or (v.g <> 15)
     or (v.h <> 16)
     or (v.i <> 8)
     or (v.j <> 17)
     or (v.k <> 18)
     or (v.l <> 19)
     or (v.m <> 26)
     or (v.n <> 25)
     or (v.o <> 9)
     or (v.p <> 10)
     or (v.q <> 1)
     or (v.r <> 4)
     or (v.s <> 12)
     or (v.t <> 5)
     or (v.u <> 7)
     or (v.v <> 23)
     or (v.w <> 2)
     or (v.x <> 21)
     or (v.y <> 20)
     or (v.z <> 6)
     or (v.ba <> 26 + 11)
     or (v.bb <> 26 + 24)
     or (v.bc <> 26 + 22)
     or (v.bd <> 26 + 13)
     or (v.be <> 26 + 3)
     or (v.bf <> 26 + 14)
     or (v.bg <> 26 + 15)
     or (v.bh <> 26 + 16)
     or (v.bi <> 26 + 8)
     or (v.bj <> 26 + 17)
     or (v.bk <> 26 + 18)
     or (v.bl <> 26 + 19)
     or (v.bm <> 26 + 26)
     or (v.bn <> 26 + 25)
     or (v.bo <> 26 + 9)
     or (v.bp <> 26 + 10)
     or (v.bq <> 26 + 1)
     or (v.br <> 26 + 4)
     or (v.bs <> 26 + 12)
     or (v.bt <> 26 + 5)
     or (v.bu <> 26 + 7)
     or (v.bv <> 26 + 23)
     or (v.bw <> 26 + 2)
     or (v.bx <> 26 + 21)
     or (v.by <> 26 + 20)
     or (v.bz <> 26 + 6) then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  with v do
    if    (a <> 11)
       or (b <> 24)
       or (c <> 22)
       or (d <> 13)
       or (e <> 3)
       or (f <> 14)
       or (g <> 15)
       or (h <> 16)
       or (i <> 8)
       or (j <> 17)
       or (k <> 18)
       or (l <> 19)
       or (m <> 26)
       or (n <> 25)
       or (o <> 9)
       or (p <> 10)
       or (q <> 1)
       or (r <> 4)
       or (s <> 12)
       or (t <> 5)
       or (u <> 7)
       or (v <> 23)
       or (w <> 2)
       or (x <> 21)
       or (y <> 20)
       or (z <> 6)
       or (ba <> 26 + 11)
       or (bb <> 26 + 24)
       or (bc <> 26 + 22)
       or (bd <> 26 + 13)
       or (be <> 26 + 3)
       or (bf <> 26 + 14)
       or (bg <> 26 + 15)
       or (bh <> 26 + 16)
       or (bi <> 26 + 8)
       or (bj <> 26 + 17)
       or (bk <> 26 + 18)
       or (bl <> 26 + 19)
       or (bm <> 26 + 26)
       or (bn <> 26 + 25)
       or (bo <> 26 + 9)
       or (bp <> 26 + 10)
       or (bq <> 26 + 1)
       or (br <> 26 + 4)
       or (bs <> 26 + 12)
       or (bt <> 26 + 5)
       or (bu <> 26 + 7)
       or (bv <> 26 + 23)
       or (bw <> 26 + 2)
       or (bx <> 26 + 21)
       or (by <> 26 + 20)
       or (bz <> 26 + 6) then WriteLn ('failed 2') else WriteLn ('OK')
end.
