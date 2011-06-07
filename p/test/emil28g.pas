program Test (output);

type
        colour = (red, yellow, green, blue);
        { from ISO 10206, 6.4.10 }
        colour_map =
                record
                case selector: colour of
                  red:    (red_field:    integer value ord (red));
                  yellow: (yellow_field: integer value ord (yellow));
                  green:  (green_field:  integer value ord (green));
                  blue:   (blue_field:   integer value ord (blue));
                end;

var
        ca, cb: ^colour_map;

begin
  New (ca, yellow);
  New (cb, green);
  if (ca^.selector = yellow) and (ca^.yellow_field = 1) and
     (cb^.selector = green) and (cb^.green_field = 2) then writeln ('OK')
  else writeln ('failed')
end.
