{ FLAG -O0 }  { just to speed things up }

program fjf664;

var
  cf: Integer = 0;
  vis1: ByteInt   = -1; vib1: ByteInt   = $7f;
  vis2: ShortInt  = -1; vib2: ShortInt  = $7fff;
  vis3: Integer   = -1; vib3: Integer   = $7fffffff;
  vis4: MedInt    = -1; vib4: MedInt    = $7fffffff;
  vis5: LongInt   = -1; vib5: LongInt   = $7fffffffffffffff;
  vcs1: ByteCard  = 42; vcb1: ByteCard  = $ff;
  vcs2: ShortCard = 42; vcb2: ShortCard = $ffff;
  vcs3: Cardinal  = 42; vcb3: Cardinal  = $ffffffff;
  vcs4: MedCard   = 42; vcb4: MedCard   = $ffffffff;
  vcs5: LongCard  = 42; vcb5: LongCard  = $ffffffffffffffff;

const
  cis1 = ByteInt   (-1); cib1 = ByteInt   ($7f);
  cis2 = ShortInt  (-1); cib2 = ShortInt  ($7fff);
  cis3 = Integer   (-1); cib3 = Integer   ($7fffffff);
  cis4 = MedInt    (-1); cib4 = MedInt    ($7fffffff);
  cis5 = LongInt   (-1); cib5 = LongInt   ($7fffffffffffffff);
  ccs1 = ByteCard  (42); ccb1 = ByteCard  ($ff);
  ccs2 = ShortCard (42); ccb2 = ShortCard ($ffff);
  ccs3 = Cardinal  (42); ccb3 = Cardinal  ($ffffffff);
  ccs4 = MedCard   (42); ccb4 = MedCard   ($ffffffff);
  ccs5 = LongCard  (42); ccb5 = LongCard  ($ffffffffffffffff);

procedure CEQ (a, b: CString; feq, fgt, fge, flt, fle, fne: Boolean);
begin
  if feq and not fgt and fge and not flt and fle and not fne then
    a := a { OK }
  else if not feq and fgt and fge and not flt and not fle and fne then
    begin
      Write (CString2String (a), '=', CString2String (b), ': >; ');
      Inc (cf)
    end
  else if not feq and not fgt and not fge and flt and fle and fne then
    begin
      Write (CString2String (a), '=', CString2String (b), ': <; ');
      Inc (cf)
    end
  else
    begin
      Write (CString2String (a), '=', CString2String (b), ' ???');
      if feq then Write (' =');
      if fgt then Write (' >');
      if fge then Write (' >=');
      if flt then Write (' <');
      if fle then Write (' <=');
      if fne then Write (' <>');
      Write ('; ');
      Inc (cf)
    end
end;

procedure CGT (a, b: CString; feq, fgt, fge, flt, fle, fne: Boolean);
begin
  if not feq and fgt and fge and not flt and not fle and fne then
    a := a { OK }
  else if feq and not fgt and fge and not flt and fle and not fne then
    begin
      Write (CString2String (a), '>', CString2String (b), ': =; ');
      Inc (cf)
    end
  else if not feq and not fgt and not fge and flt and fle and fne then
    begin
      Write (CString2String (a), '>', CString2String (b), ': <; ');
      Inc (cf)
    end
  else
    begin
      Write (CString2String (a), '>', CString2String (b), ' ???');
      if feq then Write (' =');
      if fgt then Write (' >');
      if fge then Write (' >=');
      if flt then Write (' <');
      if fle then Write (' <=');
      if fne then Write (' <>');
      Write ('; ');
      Inc (cf)
    end
end;

procedure CLT (a, b: CString; feq, fgt, fge, flt, fle, fne: Boolean);
begin
  if not feq and not fgt and not fge and flt and fle and fne then
    a := a { OK }
  else if feq and not fgt and fge and not flt and fle and not fne then
    begin
      Write (CString2String (a), '<', CString2String (b), ': =; ');
      Inc (cf)
    end
  else if not feq and fgt and fge and not flt and not fle and fne then
    begin
      Write (CString2String (a), '<', CString2String (b), ': >; ');
      Inc (cf)
    end
  else
    begin
      Write (CString2String (a), '<', CString2String (b), ' ???');
      if feq then Write (' =');
      if fgt then Write (' >');
      if fge then Write (' >=');
      if flt then Write (' <');
      if fle then Write (' <=');
      if fne then Write (' <>');
      Write ('; ');
      Inc (cf)
    end
end;

{$define EQ(a, b) CEQ(#a, #b, a=b, a>b, a>=b, a<b, a<=b, a<>b)}
{$define GT(a, b) CGT(#a, #b, a=b, a>b, a>=b, a<b, a<=b, a<>b)}
{$define LT(a, b) CLT(#a, #b, a=b, a>b, a>=b, a<b, a<=b, a<>b)}
{$define XO(a, b, N, M)
  if N = M then
    begin
      EQ (a, b)
    end
  else if N < M then
    begin
      LT (a, b)
    end
  else
    begin
      GT (a, b)
    end
}
{$define YO(a, b, N, M)
  if N <= M then
    begin
      LT (a, b)
    end
  else
    begin
      GT (a, b)
    end
}
{$define ZO(a, b, N, M)
  if N < M then
    begin
      LT (a, b)
    end
  else
    begin
      GT (a, b)
    end
}

{$define C(NK, N, NI, MK, M, MI)
  EQ (NK##is##N, MK##is##M); GT (NK##ib##N, MK##is##M);         GT (NK##cs##N, MK##is##M); GT (NK##cb##N, MK##is##M);
  LT (NK##is##N, MK##ib##M); XO (NK##ib##N, MK##ib##M, NI, MI); LT (NK##cs##N, MK##ib##M); ZO (NK##cb##N, MK##ib##M, NI, MI);
  LT (NK##is##N, MK##cs##M); GT (NK##ib##N, MK##cs##M);         EQ (NK##cs##N, MK##cs##M); GT (NK##cb##N, MK##cs##M);
  LT (NK##is##N, MK##cb##M); YO (NK##ib##N, MK##cb##M, NI, MI); LT (NK##cs##N, MK##cb##M); XO (NK##cb##N, MK##cb##M, NI, MI);
}

{$define CM(NK, MK, N, NI)
  C (NK, N, NI, MK, 1, 1);
  C (NK, N, NI, MK, 2, 2);
  C (NK, N, NI, MK, 3, 3);
  C (NK, N, NI, MK, 4, 3);
  C (NK, N, NI, MK, 5, 4)
}

{$define CN(I, NK, MK)
procedure t##I##1; begin CM (NK, MK, 1, 1) end;
procedure t##I##2; begin CM (NK, MK, 2, 2) end;
procedure t##I##3; begin CM (NK, MK, 3, 3) end;
procedure t##I##4; begin CM (NK, MK, 4, 3) end;
procedure t##I##5; begin CM (NK, MK, 5, 4) end;
}

CN (1, v, v)
{$W-}
CN (2, v, c)
CN (3, c, v)
{$W+}
CN (4, c, c)

begin
  t11; t12; t13; t14; t15;
  t21; t22; t23; t24; t25;
  t31; t32; t33; t34; t35;
  t41; t42; t43; t44; t45;
  if cf = 0 then WriteLn ('OK') else WriteLn ('-- ', cf, ' failures')
end.
