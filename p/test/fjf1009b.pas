{$B+} { don't waste time with fjf226 kludges which are irrelevant here }

{$W-} { don't warn about trivial string comparisons }

program fjf1009b;

const
  E = '';
  C = Chr (1);
  D = ' ';
  A = 'a';
  B = 'b';
  CC = C + C;
  CD = C + D;
  CA = C + A;
  CB = C + B;
  DC = D + C;
  DD = D + D;
  DA = D + A;
  DB = D + B;
  AC = A + C;
  AD = A + D;
  AA = A + A;
  AB = A + B;
  BC = B + C;
  BD = B + D;
  BA = B + A;
  BB = B + B;

{$define CHECKS
  CEQ (E, E)

  O4 (C, D, A, B)

  CGTPL (C, E)
  CGTPE (D, E)
  CGT (A, E)
  CGT (B, E)

  CGTPL (CC, E)
  CGTPL (CD, E)
  CGTPL (CA, E)
  CGTPL (CB, E)
  CGTPL (CC, C)
  CGTPE (CD, C)
  CGT (CA, C)
  CGT (CB, C)
  LT4 (CC, CD, CA, CB, D)
  LT4 (CC, CD, CA, CB, A)
  LT4 (CC, CD, CA, CB, B)

  CGTPL (DC, E)
  CGTPE (DD, E)
  CGT (DA, E)
  CGT (DB, E)
  GT4 (DC, DD, DA, DB, C)
  CGTPL (DC, D)
  CGTPE (DD, D)
  CGT (DA, D)
  CGT (DB, D)
  LT4 (DC, DD, DA, DB, A)
  LT4 (DC, DD, DA, DB, B)

  GT4 (AC, AD, AA, AB, E)
  GT4 (AC, AD, AA, AB, C)
  GT4 (AC, AD, AA, AB, D)
  CGTPL (AC, A)
  CGTPE (AD, A)
  CGT (AA, A)
  CGT (AB, A)
  LT4 (AC, AD, AA, AB, B)

  GT4 (BC, BD, BA, BB, E)
  GT4 (BC, BD, BA, BB, C)
  GT4 (BC, BD, BA, BB, D)
  GT4 (BC, BD, BA, BB, A)
  CGTPL (BC, B)
  CGTPE (BD, B)
  CGT (BA, B)
  CGT (BB, B)

  O4 (CC, CD, CA, CB)
  O4 (DC, DD, DA, DB)
  O4 (AC, AD, AA, AB)
  O4 (BC, BD, BA, BB)
  GT44 (DC, DD, DA, DB, CC, CD, CA, CB)
  GT44 (AC, AD, AA, AB, CC, CD, CA, CB)
  GT44 (BC, BD, BA, BB, CC, CD, CA, CB)
  GT44 (AC, AD, AA, AB, DC, DD, DA, DB)
  GT44 (BC, BD, BA, BB, DC, DD, DA, DB)
  GT44 (BC, BD, BA, BB, AC, AD, AA, AB)}

{$define GT44(a, b, c, d, e, f, g, h)
  GT4 (a, b, c, d, e)
  GT4 (a, b, c, d, f)
  GT4 (a, b, c, d, g)
  GT4 (a, b, c, d, h)}

{$define GT4(a, b, c, d, e)
  CGT (a, e)
  CGT (b, e)
  CGT (c, e)
  CGT (d, e)}

{$define LT4(a, b, c, d, e)
  CGT (e, a)
  CGT (e, b)
  CGT (e, c)
  CGT (e, d)}

{$define O4(a, b, c, d)
  CEQ (a, a)
  CEQ (b, b)
  CEQ (c, c)
  CEQ (d, d)
  CGT (b, a)
  CGT (c, a)
  CGT (d, a)
  CGT (c, b)
  CGT (d, b)
  CGT (d, c)}

{$define EQ1(a,b) (FEQ (a, b) and not FGT (a, b) and FGE (a, b) and not FLT (a, b) and FLE (a, b) and not FNE (a, b) and
                   FEQ (b, a) and not FGT (b, a) and FGE (b, a) and not FLT (b, a) and FLE (b, a) and not FNE (b, a))}

{$define GT1(a,b) (not FEQ (a, b) and FGT (a, b) and FGE (a, b) and not FLT (a, b) and not FLE (a, b) and FNE (a, b) and
                   not FEQ (b, a) and not FGT (b, a) and not FGE (b, a) and FLT (b, a) and FLE (b, a) and FNE (b, a))}

var
  n: Integer = 0;

procedure T (Cond: Boolean);
begin
  Inc (n);
  if not Cond then WriteLn ('failed ', n)
end;

procedure PEQ (const s1, s2: String);
begin
  {$define FEQ(a, b) (a = b)}
  {$define FNE(a, b) (a <> b)}
  {$define FLT(a, b) (a < b)}
  {$define FLE(a, b) (a <= b)}
  {$define FGT(a, b) (a > b)}
  {$define FGE(a, b) (a >= b)}
  T (EQ1 (s1, s2));
  {$define FEQ EQ}
  {$define FNE NE}
  {$define FLT LT}
  {$define FLE LE}
  {$define FGT GT}
  {$define FGE GE}
  T (EQ1 (s1, s2));
  {$define FEQ EQPad}
  {$define FNE NEPad}
  {$define FLT LTPad}
  {$define FLE LEPad}
  {$define FGT GTPad}
  {$define FGE GEPad}
  T (EQ1 (s1, s2));
end;

procedure PGT (const s1, s2: String);
begin
  {$define FEQ(a, b) (a = b)}
  {$define FNE(a, b) (a <> b)}
  {$define FLT(a, b) (a < b)}
  {$define FLE(a, b) (a <= b)}
  {$define FGT(a, b) (a > b)}
  {$define FGE(a, b) (a >= b)}
  T (GT1 (s1, s2));
  {$define FEQ EQ}
  {$define FNE NE}
  {$define FLT LT}
  {$define FLE LE}
  {$define FGT GT}
  {$define FGE GE}
  T (GT1 (s1, s2));
  {$define FEQ EQPad}
  {$define FNE NEPad}
  {$define FLT LTPad}
  {$define FLE LEPad}
  {$define FGT GTPad}
  {$define FGE GEPad}
  T (GT1 (s1, s2));
end;

procedure PGTPE (const s1, s2: String);
begin
  {$define FEQ(a, b) (a = b)}
  {$define FNE(a, b) (a <> b)}
  {$define FLT(a, b) (a < b)}
  {$define FLE(a, b) (a <= b)}
  {$define FGT(a, b) (a > b)}
  {$define FGE(a, b) (a >= b)}
  T (GT1 (s1, s2));
  {$define FEQ EQ}
  {$define FNE NE}
  {$define FLT LT}
  {$define FLE LE}
  {$define FGT GT}
  {$define FGE GE}
  T (GT1 (s1, s2));
  {$define FEQ EQPad}
  {$define FNE NEPad}
  {$define FLT LTPad}
  {$define FLE LEPad}
  {$define FGT GTPad}
  {$define FGE GEPad}
  T (EQ1 (s1, s2));
end;

procedure PGTPL (const s1, s2: String);
begin
  {$define FEQ(a, b) (a = b)}
  {$define FNE(a, b) (a <> b)}
  {$define FLT(a, b) (a < b)}
  {$define FLE(a, b) (a <= b)}
  {$define FGT(a, b) (a > b)}
  {$define FGE(a, b) (a >= b)}
  T (GT1 (s1, s2));
  {$define FEQ EQPad}
  {$define FNE NEPad}
  {$define FLT LTPad}
  {$define FLE LEPad}
  {$define FGT GTPad}
  {$define FGE GEPad}
  T (GT1 (s2, s1));
  {$define FEQ EQ}
  {$define FNE NE}
  {$define FLT LT}
  {$define FLE LE}
  {$define FGT GT}
  {$define FGE GE}
  T (GT1 (s1, s2))
end;

begin
  {$define CEQ(a, b) PEQ (a, b);}
  {$define CGT(a, b) PGT (a, b);}
  {$define CGTPE(a, b) PGTPE (a, b);}
  {$define CGTPL(a, b) PGTPL (a, b);}
  CHECKS;

  {$define CEQ(a, b) CompilerAssert (EQ1 (a, b));}
  {$define CGT(a, b) CompilerAssert (GT1 (a, b));}
  {$define CGTPE(a, b) CompilerAssert (GT1 (a, b));}
  {$define CGTPL(a, b) CompilerAssert (GT1 (a, b));}

  {$define FEQ(a, b) (a = b)}
  {$define FNE(a, b) (a <> b)}
  {$define FLT(a, b) (a < b)}
  {$define FLE(a, b) (a <= b)}
  {$define FGT(a, b) (a > b)}
  {$define FGE(a, b) (a >= b)}
  CHECKS;

  {$define FEQ EQ}
  {$define FNE NE}
  {$define FLT LT}
  {$define FLE LE}
  {$define FGT GT}
  {$define FGE GE}
  CHECKS;

  {$define CGTPE(a, b) CompilerAssert (EQ1 (a, b));}
  {$define CGTPL(a, b) CompilerAssert (GT1 (b, a));}

  {$define FEQ EQPad}
  {$define FNE NEPad}
  {$define FLT LTPad}
  {$define FLE LEPad}
  {$define FGT GTPad}
  {$define FGE GEPad}
  CHECKS;

  WriteLn ('OK')
end.
