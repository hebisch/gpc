program two;
type
THandle = integer;

function f: integer;
begin
  f := 99
end;

function LoadLibrary (const s: String): THandle;
begin
  LoadLibrary := 42
end;

function GetProcAddress (h: THandle; const s: String): Pointer;
begin
  GetProcAddress := @f
end;

function FreeLibrary (h: THandle): integer;
begin
  FreeLibrary := h
end;

var
h : THandle = LoadLibrary ('winstl32.dll');
v : function : integer = GetProcAddress (h, 'Chief32DllVersion');  { WRONG }

begin
  Writeln ('begin');
  Writeln ('Handle=', h);
  Writeln ('V is assigned=', Assigned (v)); { TRUE }
  Writeln ('Version=', v); { wrong result }
  Writeln ('DLL Unloaded=',FreeLibrary (h)); { TRUE }
end.
