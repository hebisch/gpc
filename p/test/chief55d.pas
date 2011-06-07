program two;
type
THandle = integer;

function f: integer;
begin
  f := 99
end;

function LoadLibrary (const s: String): THandle;
begin
  Writeln (s);
  LoadLibrary := 42
end;

function GetProcAddress (h: THandle; const s: String): Pointer;
begin
  Writeln (h, ' ', s);
  GetProcAddress := @f
end;

function FreeLibrary (h: THandle): Boolean;
begin
  Writeln (h);
  FreeLibrary := h > 0
end;

type
pf = function : integer;

var
h : THandle = LoadLibrary ('winstl32.dll');
v : pf = pf (GetProcAddress (h, 'Chief32DllVersion'));

begin
  Writeln ('begin');
  Writeln ('Handle=', h);
  Writeln ('V is assigned=', Assigned (v)); { TRUE }
  Writeln ('Version=', v); { wrong result }
  Writeln ('DLL Unloaded=',FreeLibrary (h)); { TRUE }
end.
