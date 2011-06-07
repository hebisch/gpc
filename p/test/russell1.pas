PROGRAM Bad1;

type
  DAFile = File [0..5] of Integer;
var
  MyFile : bindable DAFile;

procedure Assign_File;
var
  b : BindingType;
begin
  unbind(MyFile);
  b := binding(MyFile);
  b.name := 'test.dat';
  bind(MyFile,b);
end;

procedure CreateFile;
var
  i : Integer;
begin
  Assign_File;
  Rewrite(MyFile);
  for i := 0 to 5 do
    Write(MyFile,i);
  Close(MyFile);
end;


procedure ModifyFile(Index : Integer; val : Integer);
var
  pos : Integer;
begin
  Assign_File;
  SeekWrite(MyFile,Index);
  pos := Position(MyFile);
  Write(MyFile,val);
  Close(MyFile);
end;

procedure CheckFile;
var
  result: array[0..5] of Integer = (0:55, 1:1, 2:66, 3:3, 4:4, 5:5);
  i,val,pos : Integer;
begin
  Assign_File;
  for i := 0 to 5 do
  begin
    SeekRead(MyFile,i);
    pos := Position(MyFile);
    Read(MyFile,val);
    if (pos <> i) or (val <> result[i]) then
      begin
        WriteLn('Failed ',i,' : ',pos,', ',val);
        Halt
      end
  end;
  Close(MyFile);
end;

begin
  CreateFile;
  ModifyFile(0,55);
  ModifyFile(2,66);
  ModifyFile(6,77);
  CheckFile;
  WriteLn('OK')
end.
