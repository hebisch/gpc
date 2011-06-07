{$field-widths,extended-pascal}

program fjf1071a (Output);

type
  i1 = Integer value 1;
  i2 = Integer value 2;
  i3 = Integer value 3;
  i4 = Integer value 4;

var
  n: Integer value 0;

procedure Check1 (a, b: Integer);
begin
  n := n + 1;
  if a <> b then
    WriteLn ('failed #', n : 0, a, b)
end;

{procedure Check2 (a, b, c, d: Integer);
begin
  n := n + 1;
  if (a <> b) or (c <> d) then
    WriteLn ('failed #', n : 0, a, b, c, d)
end;}

procedure Check3 (a, b, c, d, e, f: Integer);
begin
  n := n + 1;
  if (a <> b) or (c <> d) or (e <> f) then
    WriteLn ('failed #', n : 0, a, b, c, d, e, f)
end;

procedure Test1;
type
  r0 = record
         a: Integer;
       case b: Integer of
         2, 12: (c: Integer)
         otherwise (d: Integer)
       end;
  r1 = r0 value [a: 5; case b: 2 of [c: 6]];
  r2 = r0 value [a: 7; case b: 8 of [d: 9]];
var
  v1: r1;
  v2: r2;
  v3: r2 value [a: 10; case b: 11 of [d: 12]];
  p0: ^r0;
  p1: ^r1;
  p2: ^r2;
begin
  with v1 do Check3 (a, 5, b, 2, c, 6);
  with v2 do Check3 (a, 7, b, 8, d, 9);
  with v3 do Check3 (a, 10, b, 11, d, 12);
  New (p1); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 2); with p0^ do Check1 (b, 2);
  New (p0, 3); with p0^ do Check1 (b, 3);
  New (p1, 2); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2, 8); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 12); with p0^ do Check1 (b, 12);
  New (p1, 12); with p1^ do Check3 (a, 5, b, 12, c, 6);
  New (p2, 18); with p2^ do Check3 (a, 7, b, 18, d, 9);
end;

procedure Test2;
type
  r0 = record
         a: i1;
       case b: Integer of
         2, 12: (c: i3)
         otherwise (d: i4)
       end;
  r1 = r0 value [a: 5; case b: 2 of [c: 6]];
  r2 = r0 value [a: 7; case b: 8 of [d: 9]];
var
  v1: r1;
  v2: r2;
  v3: r2 value [a: 10; case b: 11 of [d: 12]];
  p0: ^r0;
  p1: ^r1;
  p2: ^r2;
begin
  with v1 do Check3 (a, 5, b, 2, c, 6);
  with v2 do Check3 (a, 7, b, 8, d, 9);
  with v3 do Check3 (a, 10, b, 11, d, 12);
  New (p1); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 2); with p0^ do Check3 (a, 1, b, 2, c, 3);
  New (p0, 3); with p0^ do Check3 (a, 1, b, 3, d, 4);
  New (p1, 2); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2, 8); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 12); with p0^ do Check3 (a, 1, b, 12, c, 3);
  New (p1, 12); with p1^ do Check3 (a, 5, b, 12, c, 6);
  New (p2, 18); with p2^ do Check3 (a, 7, b, 18, d, 9);
end;

procedure Test3;
type
  r0 = record
         a: i1;
       case b: i2 of
         2, 12: (c: i3)
         otherwise (d: i4)
       end;
  r1 = r0 value [a: 5; case b: 2 of [c: 6]];
  r2 = r0 value [a: 7; case b: 8 of [d: 9]];
var
  v0: r0;
  v1: r1;
  v2: r2;
  v3: r2 value [a: 10; case b: 11 of [d: 12]];
  p0: ^r0;
  p1: ^r1;
  p2: ^r2;
begin
  with v0 do Check3 (a, 1, b, 2, c, 3);
  with v1 do Check3 (a, 5, b, 2, c, 6);
  with v2 do Check3 (a, 7, b, 8, d, 9);
  with v3 do Check3 (a, 10, b, 11, d, 12);
  New (p0); with p0^ do Check3 (a, 1, b, 2, c, 3);
  New (p1); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 2); with p0^ do Check3 (a, 1, b, 2, c, 3);
  New (p0, 3); with p0^ do Check3 (a, 1, b, 3, d, 4);
  New (p1, 2); with p1^ do Check3 (a, 5, b, 2, c, 6);
  New (p2, 8); with p2^ do Check3 (a, 7, b, 8, d, 9);
  New (p0, 12); with p0^ do Check3 (a, 1, b, 12, c, 3);
  New (p1, 12); with p1^ do Check3 (a, 5, b, 12, c, 6);
  New (p2, 18); with p2^ do Check3 (a, 7, b, 18, d, 9);
end;

procedure Test4;
type
  r1 = record
         a: i1;
       case b: i2 of
         1: (c: i3);
         otherwise (d: i4)
       end;
  r2 = record
         a: Integer;
       case b: Integer of
         1: (c: i3);
         otherwise (d: Integer)
       end value [a: 1; case b: 2 of [d: 4]];
var
  v1: r1;
  v2: r2;
  p1: ^r1;
  p2: ^r2;
begin
  with v1 do Check3 (a, 1, b, 2, d, 4);
  with v2 do Check3 (a, 1, b, 2, d, 4);
  New (p1); with p1^ do Check3 (a, 1, b, 2, d, 4);
  New (p2); with p2^ do Check3 (a, 1, b, 2, d, 4);
  New (p1, 2); with p1^ do Check3 (a, 1, b, 2, d, 4);
  New (p2, 2); with p2^ do Check3 (a, 1, b, 2, d, 4);
  New (p1, 3); with p1^ do Check3 (a, 1, b, 3, d, 4);
  New (p2, 3); with p2^ do Check3 (a, 1, b, 3, d, 4);
  New (p1, 1); with p1^ do Check3 (a, 1, b, 1, c, 3);
{  New (p2, 1);}
end;

begin
  Test1;
  Test2;
  Test3;
  Test4;
  WriteLn ('OK')
end.
