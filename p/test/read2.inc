{ Note: `not ... =' is not the same as `<>' because of the
  overloaded operators in read1.inc }
{$define TO0I(typ,vr,vl) if TO1(typ) and not (vr=vl) then ErrI (typ, vr, vl)}
{$define TO0U(typ,vr,vl) if TO1(typ) and not (vr=vl) then ErrU (typ, vr, vl)}
{$define TO0R(typ,vr,vl) if TO1(typ) and not (vr=vl) then ErrR (typ, vr, vl)}
{$define TO0C(typ,vr,vl) if TO1(typ) and not (vr=vl) then ErrC (typ, vr, vl)}
{$define TO0S(typ,vr,vl) if TO1(typ) and not (vr=vl) then ErrS (typ, vr, vl)}

{$define GO1(typ,vr)    begin get(vr);Dummy:=TO1(typ) end}
{$define GOI(typ,vr,vl) begin get(vr);TO0I(typ,vr,vl) end}
{$define GOU(typ,vr,vl) begin get(vr);TO0U(typ,vr,vl) end}
{$define GOR(typ,vr,vl) begin get(vr);TO0R(typ,vr,vl) end}
{$define GOC(typ,vr,vl) begin get(vr);TO0C(typ,vr,vl) end}
{$define GOS(typ,vr,vl) begin get(vr);TO0S(typ,vr,vl) end}
{$define GW(typ,vr)     begin get(vr);TW(typ)         end}

{$define TestInt(typ,tvar)
  GOI(typ,tvar,42);
  if Hex  then GOI(StrConcat(typ,' (Hex)'),tvar,62) else GW(StrConcat(typ,' (Hex)'),tvar);
  if Base then GOI(StrConcat(typ,' (Base)'),tvar,93) else if valf then GW(StrConcat(typ,' (Base)'),tvar) else GOI(StrConcat(typ,' (Base)'),tvar,19);
  if not (White or valf) then GOI(StrConcat(typ,' (White)'),tvar,24) else GW(StrConcat(typ,' (White)'),tvar);
  if not (White or valf) and Hex then GOI(StrConcat(typ,' (White, Hex)'),tvar,17) else GW(StrConcat(typ,' (White, Hex)'),tvar);
  if White or valf then GW(StrConcat(typ,' (White, Base)'),tvar) else if Base then GOI(StrConcat(typ,' (White, Base)'),tvar,116) else GOI(StrConcat(typ,' (White, Base)'),tvar,11);
  GW(StrConcat(typ,' (Invalid)'),tvar);
  if not RangeCheck then GO1(StrConcat(typ,' (Range)'),tvar) else GW(StrConcat(typ,' (Range)'),tvar)
}

{$define TestUInt(typ,tvar)
  GOU(typ,tvar,42);
  if Hex  then GOU(StrConcat(typ,' (Hex)'),tvar,62) else GW(StrConcat(typ,' (Hex)'),tvar);
  if Base then GOU(StrConcat(typ,' (Base)'),tvar,93) else if valf then GW(StrConcat(typ,' (Base)'),tvar) else GOU(StrConcat(typ,' (Base)'),tvar,19);
  if not (White or valf) then GOU(StrConcat(typ,' (White)'),tvar,24) else GW(StrConcat(typ,' (White)'),tvar);
  if not (White or valf) and Hex then GOU(StrConcat(typ,' (White, Hex)'),tvar,17) else GW(StrConcat(typ,' (White, Hex)'),tvar);
  if White or valf then GW(StrConcat(typ,' (White, Base)'),tvar) else if Base then GOU(StrConcat(typ,' (White, Base)'),tvar,116) else GOU(StrConcat(typ,' (White, Base)'),tvar,11);
  GW(StrConcat(typ,' (Invalid)'),tvar);
  if not RangeCheck then GO1(StrConcat(typ,' (Range)'),tvar) else GW(StrConcat(typ,' (Range)'),tvar)
}

{$define TestReal(typ,tvar)
  GOR(StrConcat(typ,' (1)'),tvar,173.25);
  GOR(StrConcat(typ,' (2)'),tvar,-17326000.0);
  GW(StrConcat(typ,' (Invalid)'),tvar);
  GOR(StrConcat(typ,' (3)'),tvar,-0.125);
  if not RealISO7185 then GOR(StrConcat(typ,' (EP, 1)'),tvar,0.5) else GW(StrConcat(typ,' (EP, 1)'),tvar);
  if not RealISO7185 then GOR(StrConcat(typ,' (EP, 2)'),tvar,-0.25) else GW(StrConcat(typ,' (EP, 2)'),tvar);
  if not (White or valf) then GOR(StrConcat(typ,' (White)'),tvar,-2.3e16) else GW(StrConcat(typ,' (White)'),tvar);
  if not (White or valf) and not RealISO7185 then GOR(StrConcat(typ,' (White, EP)'),tvar,2e-14) else GW(StrConcat(typ,' (White, EP)'),tvar);
}

{ We split these tests into separate files, because some systems have
  problems compiling the otherwise quite large (preprocessed) test
  program (e.g., virtual memory exceeded under DJGPP). However, even
  the large test in a single file has worked fine, e.g., on a Linux
  system with enough RAM and temp space. }

{$define TestNum1  TestInt('ByteInt',bi);}
{$define TestNum2  TestInt('ShortInt',si);}
{$define TestNum3  TestInt('Integer',ni);}
{$define TestNum4  TestInt('MedInt',mi);}
{$define TestNum5  TestInt('LongInt',li);}
{$define TestNum6  TestUInt('Byte',bc);}
{$define TestNum7  TestUInt('ShortCard',sc);}
{$define TestNum8  TestUInt('Cardinal',nc);}
{$define TestNum9  TestUInt('MedCard',mc);}
{$define TestNum10 TestUInt('LongCard',lc);}
{$define TestNum11 TestReal('ShortReal',sr);}
{$define TestNum12 TestReal('Real',nr);}
{$define TestNum13 TestReal('LongReal',lr);}

{$define CONCAT1(A,B) A##B}
{$define CONCAT(A,B) CONCAT1(A,B)}

{$if DoTestNum > 13}
{$define TestNum}
{$else}
{$define TestNum
  CONCAT(TestNum,DoTestNum);
}
{$endif}

{$if DoTestNum <> 14}
{$define TestChar}
{$define TestNoChar}
{$else}
{$define TestChar
  GOC('Char',c,'a');
  GOC('Char',c,chr(0));
  get2(c,c2);
  TO0C('Char (1)',c,'f');
  TO0C('Char (2)',c2,'o');
  GOC('Char (R)',cr,'M');
  if not RangeCheck then GO1('Char (Range)',cr) else GW('Char (Range)',cr);
}
{$define TestNoChar
  ReadLn(infile);
  ReadLn(infile);
  ReadLn(infile);
  ReadLn(infile);
  ReadLn(infile);
}
{$endif}

{$if defined(Classic) or (DoTestNum <> 15)}
{$define TestString}
{$define TestNoString}
{$else}
{$define TestString
  if run2=3 then GOS('String',nst,StrConcat(StrConcat(StrConcat('foo',Chr(0)),'b ar '),StringOfChar(' ',GetStringCapacity(nst)-9))) else GOS('String',nst,StrConcat(StrConcat('foo',Chr(0)),'b ar '));
  if run2=3 then GOS('ShortString',sst,StrConcat(StrConcat(StrConcat('oof',Chr(0)),'ra b '),StringOfChar(' ',GetStringCapacity(sst)-9))) else GOS('ShortString',sst,StrConcat(StrConcat('oof',Chr(0)),'ra b '));
  GOS('FixedString',fst,StrConcat(StrConcat(StrConcat('ofo',Chr(0)),'ba r'),StringOfChar(' ',fstsize-8)));
}
{$define TestNoString
  ReadLn(infile);
  ReadLn(infile);
  ReadLn(infile);
}
{$endif}

{$if defined(Standard) or (DoTestNum <> 16)}
{$define TestCString}
{$define TestNoCString}
{$else}
{$define TestCString
  get(cst);if TO1('CString') and (strcmp(cst,'fof')<>0) then begin Err(StrConcat(StrConcat('value of CString variable is `',GetCString2String(cst)),''', but should be `fof''')) end
}
{$define TestNoCString
  ReadLn(infile);
}
{$endif}

{$define TestStart
  run2:=run2+1;
  reset(infile);
  if GetIOResult<>0 then begin WriteLn('Could not open input file.'); Halt1 end;
}

{$define TestAll
  TestStart
  TestNum
  TestChar
  TestString
  TestCString
}

{$define TestOnlyNum
  TestStart
  TestNum
  TestNoChar
  TestNoString
  TestNoCString
}

procedure r;
begin
  {$i-}
  run1:=0;
  {$i readsub.inc}
  {$no-read-base-specifier}
  {$no-read-hex}
  {$no-read-white-space}
  {$R+}
  { longest types can't have range errors }
  RangeCheck:= (DoTestNum > 10) or 
                  (TypeSizes[(DoTestNum - 1) mod 5 + 1] < LongestSize) ; 
  Base      :=False;
  Hex       :=False;
  whitespace:=False;
  {$i readsub.inc}
  {$read-base-specifier}
  {$read-hex}
  {$read-white-space}
  {$R-}
  RangeCheck:=False;
  Base      :=True;
  Hex       :=True;
  whitespace:=True;
  {$i readsub.inc}
  {$i+}
end;

{$gnu-pascal}

procedure test;
begin
  OK:=True;
  Rewrite(infile);
  {$if DoTestNum <= 10}
  WriteLn(infile,'42');
  WriteLn(infile,'$3e');
  WriteLn(infile,'19#4h');
  WriteLn(infile,'24:');
  WriteLn(infile,'$000000011,x');
  WriteLn(infile,'  '#9#9'  11#A6~');
  WriteLn(infile,'foo');
  if DoTestNum > 5 then WriteLn(infile,High(LongestCard)) else WriteLn(infile,High(LongestInt));
  {$elif DoTestNum <= 13}
  WriteLn(infile,'17.325e1');
  WriteLn(infile,'-17.326E6');
  WriteLn(infile,'one point two');
  WriteLn(infile,'-125e-3');
  WriteLn(infile,'.5');
  WriteLn(infile,'-.25');
  WriteLn(infile,'-23e15$');
  WriteLn(infile,'.2e-13%');
  {$elif DoTestNum = 14}
  WriteLn(infile,'a');
  WriteLn(infile,#0);
  WriteLn(infile,'fo');
  WriteLn(infile,'M');
  WriteLn(infile,'m');
  {$elif DoTestNum = 15}
    {$ifndef Classic}
    WriteLn(infile,'foo'#0'b ar ');
    WriteLn(infile,'oof'#0'ra b ');
    WriteLn(infile,'ofo'#0'ba r ');
    {$endif}
  {$elif DoTestNum = 16}
    {$ifndef Standard}
    WriteLn(infile,'fof'#0'r ab ');
    {$endif}
  {$else}
  {$error Invalid TestNum}
  {$endif}
  r;
  if not EOF (infile) then Err('missing EOF');
  if OK then WriteLn('OK')
end;
