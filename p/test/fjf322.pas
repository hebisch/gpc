program fjf322;

uses fjf322u;

function o (a : Integer)  : TString;
var i : Integer = 1; attribute (static);
begin
  if i = 2 then Exit;
  inc (i);
  o := ''
end;

var
  t : TString;

function d2 : TString;
var r, f: TString;

  procedure n;
  begin
    if r <> '' then r := '';
  end;

begin
  r := '';
  n;
  r := o (0);
  d2 := ''
end;

begin
  t := d2;
  t := d2;
  writeln ('OK')
end.
