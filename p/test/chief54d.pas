program delfp;

type pt = procedure ();
     ft = function () : integer;

var a : pt;
    b : procedure ();
    c : ft;
    d : function () : integer;

function fi : integer;
begin
   fi := 0
end;

function fid () : integer;
begin
   fid := 0
end;

procedure p ;
begin
end;

procedure pd ();
begin
end;

begin
  a := p;
  a := pd;
  b := p;
  b := pd;
  c := fi;
  c := fid;
  d := fi;
  d := fid;
  writeln ('OK')
end.
