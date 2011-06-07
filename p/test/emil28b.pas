program Test (output);

type
        colour = (red, yellow, green, blue);
        colour_red = colour value red;
        { from ISO 10206, 6.4.10 }
        colour_map =
                record
                case colour_red of
                  red:    (red_field:    integer value ord (red));
                  yellow: (yellow_field: integer value ord (yellow));
                  green:  (green_field:  integer value ord (green));
                  blue:   (blue_field:   integer value ord (blue));
                end;

var
  a: colour_map;

begin
  if a.red_field = 0 then WriteLn ('OK') else WriteLn ('failed')
end.
