program Test (output);

type
        colour = (red, yellow, green, blue);
        colour_yellow = colour value yellow;
        { from ISO 10206, 6.4.10 }
        colour_map =
                record
                case selector: colour_yellow of
                  red:    (red_field:    integer value 6);
                  yellow: (yellow_field: integer value 3);
                  green:  (green_field:  integer value 2);
                  blue:   (blue_field:   integer value 7);
                end;

var
        c: colour_map value [case selector: blue of [blue_field: 5]];

begin
  if (c.selector = blue) and (c.blue_field = 5) then WriteLn ('OK') else WriteLn ('failed ', Ord (c.selector), ' ', c.blue_field)
end.
