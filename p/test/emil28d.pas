program Test (output);

type
        colour = (red, yellow, green, blue);
        colour_blue = colour value blue;
        { from ISO 10206, 6.4.10 }
        colour_map =
                record
                case selector: colour_blue of
                  red:    (red_field:    integer value ord (red));
                  yellow: (yellow_field: integer value ord (yellow));
                  green:  (green_field:  integer value ord (green));
                  blue:   (blue_field:   integer value ord (blue));
                end;

var
  a: colour_map;

begin
  if (a.selector = blue) and (a.blue_field = 3) then WriteLn ('OK') else WriteLn ('failed')
end.
