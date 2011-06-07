program Test (output);

type
        colour = (red, yellow, green, blue);
        colour_green = colour value green;
        { from ISO 10206, 6.4.10 }
        colour_map =
                record
                case colour_green of
                  red:    (red_field:    integer value ord (red));
                  yellow: (yellow_field: integer value ord (yellow));
                  green:  (green_field:  integer value ord (green));
                  blue:   (blue_field:   integer value ord (blue));
                end;

procedure p;
const green_field = 5;
var
  a: colour_map;
begin
  if a.green_field = 2 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p
end.
