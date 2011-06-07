program bug;

type r = packed record
           a : char;
           b : array [1..4] of char
         end;

var v : r;
    i : integer = 2;
    c : char;

begin
  c := v.a;      { line 13: succeeds }
  c := v.b [1];  { line 14: succeeds }
  c := v.b [i];  { line 15: fails }
  WriteLn ('OK')
end.
