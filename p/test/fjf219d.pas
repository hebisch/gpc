program fjf219d;

type
  f=array[1..sizeof(text)] of byte;
  t=record
    case boolean of
      false:(f1:f;
             t1:text);
      true :(t2:text;
             f2:f)
    end;

procedure p;
var v:t;
begin
  fillchar(v.f1,sizeof(v.f1),255)
end;

begin
  p;
  writeln('OK')
end.
