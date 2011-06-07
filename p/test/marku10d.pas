{$object-pascal}

program Markus10d;

Function Bar: integer; forward;

Function Bar = result: integer;  { WRONG }
begin (* Bar *)
  result:= 2;
end (* Bar *);

begin
end.
