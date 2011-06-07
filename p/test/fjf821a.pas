program fjf821a;

type
  a = AnyFile;
  p = ^a;

procedure Test2 (var f: AnyFile; const s: String; Size: Integer);
begin
  if FileSize (f) <> Size then
    begin
      WriteLn ('failed FileSize ', s, ' ', FileSize (f), ' ', Size);
      Halt
    end
end;

procedure Test (var f: a; const s: String; Size: Integer);
var v: p;
begin
  Test2 (f, s, Size);
  Reset (f);
  v := @f;
  if EOF (v^) then
    begin
      WriteLn ('failed EOF ', s);
      Halt
    end
end;

var
  t: Text;
  f: file;
  g: file of Integer;
  s: String (10);
  i, j, k: Integer = 99;

begin
  Rewrite (t);
  Write (t, 'foo');
  Rewrite (f, 1);
  BlockWrite (f, i, SizeOf (i));
  Rewrite (g);
  Write (g, 42, 17);
  Test (t, 't', 3);
  Test (f, 'f', SizeOf (i));
  Test (g, 'g', 2);
  Read (t, s);
  i := 0;
  BlockRead (f, i, SizeOf (i));
  Read (g, j, k);
  if (s = 'foo') and (i = 99) and (j = 42) and (k = 17) then WriteLn ('OK') else WriteLn ('failed')
end.
