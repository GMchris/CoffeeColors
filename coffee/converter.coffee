class window.RGB
  constructor: (@r=0, @g=0, @b=0) ->

class window.Color
  formats=
    hex: ''
    rgb: ''
    hsl: ''

  update= (value)->
    type = Color.getFormat(value);


  @HEX_REGEX: /#(?:[a-f\d]{3}){1,2}\b/
  @RGB_REGEX: /rgb\((?:(?:\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)\s*,){2}\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)|\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%(?:\s*,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%){2})\s*\)/
  @HSL_REGEX: /hsl\(\s*0*(?:360|3[0-5]\d|[12]?\d?\d)\s*(?:,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%\s*){2}\)/
  @getFormat: (value) ->
    type = switch
      when value.match Color.HSL_REGEX then 'hsl'
      when value.match Color.RGB_REGEX then 'rgb'
      when value.match Color.HEX_REGEX then 'hex'
      else 'none'

    type
  @hexToRGB: (hex) ->
    hex
  constructor: (value= '#000000', rest...) ->
    value= value.toString();

    Color.getFormat(value)


    @hex = value;

  get: (property) ->
    if property of formats
      formats[property]

  set: (property, value) ->
    if property of formats
      update(value)

console.log new Color '#555555'
console.log new Color 'rgb(12, 15, 55)'
console.log new Color 'hsl(15,55,12)'