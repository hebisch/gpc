program vol1;
{ Just naive test that volatile is accepted }
type
    VolatileChar = char attribute (volatile);
    VideoMemory = ^VolatileChar;

procedure p(v : VideoMemory);
begin
    write(v^)
end;

var VideoMemoryVar : VideoMemory;

begin
  new(VideoMemoryVar);
  VideoMemoryVar^ := 'O';
  p(VideoMemoryVar);
  VideoMemoryVar^ := 'K';
  p(VideoMemoryVar);
  writeln
end
.
