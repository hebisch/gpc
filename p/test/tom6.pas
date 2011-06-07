program tom6;

type
  Rec = record i: integer; r: real; end;

var
  c, d, e: char;
  a: array [ char, char ] of Rec;

begin
  c := 'a';
  d := 'm';
  e := 'z';
  a ['A', 'm'].i := 42;
  a ['n', 'z'].r := 0;
; with a [ UpCase(c), d ] : x, a [ succ(d), e ] : y do begin
  ; y.r := sqrt ( x.i )
  end;
  if Abs (Sqr (a ['n', 'z'].r) - 42) < 1e6 then WriteLn ('OK') else WriteLn ('failed')
end.
