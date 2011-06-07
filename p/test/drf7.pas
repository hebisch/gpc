program drf7 (input,output);

{ FLAG --extended-pascal }

type tstring = string (10);

{
This was in the original test program, as listed in
Scott A. Moore's Ansi-ISO-FAQ as EP syntax.

procedure foo(x : function (y : boolean) : tstring);

However, it isn't correct for EP or any other Pascal standard
or dialect I know. Instead, the correct EP syntax is the
following, and GPC supports it.
}
procedure foo(function x (y : Boolean) : tstring);
begin
  writeln (x(true))
end;

function bar (x : Boolean) : tstring;
begin
  if x then bar := 'OK' else bar := 'failed'
end;

begin
  foo (bar)
end.
