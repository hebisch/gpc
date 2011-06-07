{ This program is not the test program itself. It outputs a randomized test program. }

{ COMPILE-CMD: fjf1000.cmp }

program fjf1000;

uses GPC;

{$setlimit 20001}

const
  NMin = -10000;
  NMax = 10000;
  EMax = 10;
  CMax = 10;
  TMax = 25;

var
  k: RandomSeedType;
  c, e, m, n, n1, n2, i, j: Integer;
  Op: String (4);
  cs, ce: String (30 * CMax * EMax);
  s: array [1 .. TMax] of String (30 * CMax * EMax);
  Used: set of NMin .. NMax;
  Comp: array [1 .. 6] of String (2) = ('=', '<>', '>', '>=', '<', '<=');

begin
  if ParamCount <> 0 then
    ReadStr (ParamStr (1), k)
  else
    k := Random (High (k));
  SeedRandom (k);
  WriteLn ('program SetTest_', k, ';');
  WriteLn;
  WriteLn ('{$W-,setlimit ', NMax - NMin + 1, '}');
  WriteLn;
  WriteLn ('type');
  WriteLn ('  Range = ', NMin, ' .. ', NMax, ';');
  WriteLn;
  WriteLn ('const');
  Used := [];
  for n := 1 to TMax do
    begin
      e := Random (EMax) + 1;
      ce := '';
      for j := 1 to e do
        begin
          c := Random (CMax + 1);
          cs := '(.';  { '[', but do not remove below unlike array indices }
          n1 := 0;
          n2 := 0;
          for i := 1 to c do
            begin
              if i > 1 then cs := cs + ', ';
              case Random (15) of
                0:        n1 := Max (NMin, n1 - 1);
                1:        n1 := n1;
                2:        n1 := Min (NMax, n1 + 1);
                3:        n1 := Max (NMin, n2 - 1);
                4:        n1 := n2;
                6:        n1 := Min (NMax, n2 + 1);
                otherwise n1 := NMin + Random (NMax - NMin + 1)
              end;
              n2 := n1;
              Include (Used, n1);
              case Random (5) of
                0:        WriteStr (cs, cs, 'v[', n1, ']');
                1:        WriteStr (cs, cs, 'v[', n1, '] .. v[', n1, ']');
                otherwise m := NMax - n1;
                          n2 := n1 + m - Trunc (SqRt (Random (Sqr (m + 1))));
                          Include (Used, n2);
                          WriteStr (cs, cs, 'v[', n1, '] .. v[', n2, ']')
              end
            end;
          cs := cs + '.)';
          if j = 1 then
            ce := cs
          else
            begin
              case Random (4) of
                0: Op := ' + ';
                1: Op := ' - ';
                2: Op := ' * ';
                3: Op := ' >< ';
              end;
              if Random (2) = 0 then
                ce := '(' + ce + Op + cs + ')'
              else
                ce := '(' + cs + Op + ce + ')'
            end
        end;
      s[n] := ce;
      for i := Length (ce) downto 1 do
        if ce[i] in ['v', '[', ']'] then Delete (ce, i, 1);
      WriteLn ('  c', n, ' = ', ce, ';');
      if n > 1 then
        for i := 1 to 6 do
          WriteLn ('  c', n, '_', i, ' = c', n, ' ', Comp[i], ' c', n - 1, ';')
    end;
  WriteLn;
  WriteLn ('var');
  WriteLn ('  r: Integer value 0;');
  WriteLn ('  i: Range;');
  WriteLn ('  v: array [Range] of Range;');
  WriteLn ('  s, o: set of Range;');
  WriteLn;
  WriteLn ('procedure p;');
  WriteLn ('begin');
  WriteLn ('  s := [];');
  for n := 1 to TMax do
    begin
      WriteLn ('  o := s;');
      WriteLn ('  s := ', s[n], ';');
      WriteLn ('  if c', n, ' <> s then begin WriteLn (''failed: ', n, '''); r := 1 end;');
      if n > 1 then
        for i := 1 to 6 do
          WriteLn ('  if c', n, '_', i, ' <> (s ', Comp[i], ' o) then begin WriteLn (''failed: ', Comp[i], ' ', n, '''); r := 1 end;')
    end;
  WriteLn ('end;');
  WriteLn;
  WriteLn ('begin');
  WriteLn ('  for i := ', NMin, ' to ', NMax, ' do v[i] := i;');
  WriteLn ('  p;');
  WriteLn ('  if r = 0 then WriteLn (''OK'');');
  WriteLn ('  Halt (r)');
  WriteLn ('end.')
end.
