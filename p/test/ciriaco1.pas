program Ciriaco1;

{$W-}

PROCEDURE readdata;
VAR
   f : bindable text;
   c : BindingType;
   i : integer;
BEGIN
   c:= binding(f);
   c.name:=ParamStr (1);
   bind(f,c);
   SeekRead(f,0);
END;

PROCEDURE printdata;
VAR
   f : bindable text;
   c : BindingType;
   i : integer;
BEGIN
   c:= binding(f);
   c.name:='tmp.dat';
   bind(f,c);
   SeekWrite(f,0);
END;

begin
 readdata;
 printdata;
 writeln('OK')
end.
