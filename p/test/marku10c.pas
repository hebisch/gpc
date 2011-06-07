program Markus10c;

Function Bar = result: integer; forward;

Function Bar: integer;  { WRONG }
begin (* Bar *)
  result:= 2;
end (* Bar *);

begin
end.
