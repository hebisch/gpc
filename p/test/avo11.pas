program avo11;
type
         UInt16 = cardinal attribute( size = 16);
         StyleItemGPC =
(bold,italic,underline,outline,shadow,condense,extend);
         StyleParameter = UInt16;
procedure TextFace(face: StyleParameter); external name 'TextFace';
begin
         TextFace( StyleParameter( [bold, italic])); {internal compiler
error}  { WRONG }
end.
