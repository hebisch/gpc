{ Crashes gpc -g, but not with -O3, 19990711 }
{ FLAG -O0 }

program fjf358;

uses GPC;

type
  l = record
        s : PString
      end;

function f1 : TString;
var p : l;
begin
  f1 := p.s^
end;

function f2 : TString;
begin
  f2 := 'OK'
end;

type t = PString;

begin
  writeln (f2)
end.
