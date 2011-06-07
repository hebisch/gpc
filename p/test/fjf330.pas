program fjf330;

uses fjf330u;

type
  t = record
    s : tstring
  end;

var
  v : t;
  c : CString;

procedure bar (x : CString);
begin
  c := x;
end;

begin
  v.s := 'failed';
  bar (v.s);
  v.s := 'OK'#0;
  writeln (cstring2string (c))
end.
