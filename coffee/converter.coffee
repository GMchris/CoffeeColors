#
# Color: A global class, which contains static methods for converting different color formats.
# Instances of the Color class offer a cleaner API for the conversions.
#
class window.Color
  # Regular expressions used to match various color formats.
  #
  @HEX_REGEX: /#(?:[a-f\d]{3}){1,2}\b/
  @RGB_REGEX: /rgb\((?:(?:\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)\s*,){2}\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)|\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%(?:\s*,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%){2})\s*\)/
  @HSL_REGEX: /hsl\(\s*0*(?:360|3[0-5]\d|[12]?\d?\d)\s*(?:,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%?\s*){2}\)/
  # Determines the format of the given color string.
  #
  # @param [string] value
  #
  @getFormat: (value)->
    if value?
      switch
        when value.match Color.HSL_REGEX then 'hsl'
        when value.match Color.RGB_REGEX then 'rgb'
        when value.match Color.HEX_REGEX then 'hex'
  # Converts an rgb(*, *, *) string to an RGB object.
  # @static
  # @param [string] rgb
  #
  @stringToRGB: (rgb)->
    unless rgb.match Color.RGB_REGEX
      return

    [r, g, b]= rgb.match(/rgb\((.+?)\)/)[1].split(',').map (value)->
      value.trim()
      parseInt(value)

    new RGB r, g, b
  # Converts an RGB object to an  rgb(*, *, *) string.
  # @static
  # @param [RGB] rgb
  #
  @rgbToString: (rgb)->
    {r, g, b}= rgb

    "rgb(#{r},#{g},#{b})"
  # Converts a hex string to an RGB object.
  # @static
  # @param [hex] string
  #
  @hexToRGB: (hex)->
    unless hex.match Color.HEX_REGEX
      return

    hex= hex.replace '#', ''
    if hex.length is 3
      hex += hex

    rgb= hex.match(/.{1,2}/g).map (val)-> parseInt val, 16

    new RGB rgb[0], rgb[1], rgb[2]
  # Converts an RGB object to a hex string.
  # @static
  # @param [RGB] rgb
  #
  @rgbToHex: (rgb)->
    {r, g, b}= rgb

    vals= [rgb.r, rgb.g, rgb.b].map (value)->
      ('0' + value.toString(16)).slice(-2)

    "##{vals[0]}#{vals[1]}#{vals[2]}"
  # Converts a hue to an RGB value.
  # @static
  # @param [number] p
  # @param [number] q
  # @param [number] t
  #
  @hueToRGB: (p, q, t)->
    if (t < 0)
      t += 1
    if (t > 1)
      t -= 1
    if (t < 1/6)
      return p + (q - p) * 6 * t
    if (t < 1/2)
      return q
    if (t < 2/3)
      return p + (q -p) * (2/3 - t) * 6
    p
  # Converts an hsl(*, *, *) string to an RGB object.
  # @static
  # @param [RGB] rgb
  #
  @hslToRGB: (hsl)->
    unless hsl.match Color.HSL_REGEX
      return

    [h, s, l]= hsl.match(/hsl\((.+?)\)/)[1].split(',').map (value)->
      value.trim()
      numeric= parseFloat(value)

      numeric =  if value.indexOf('%') >= 0 then numeric / 100 else numeric

    if s == 0
      r = g = b = l
    else
      q = if l < 0.5 then l * (1 + s) else l + s - l * s;
      p = 2 * l - q;
      r = Color.hueToRGB p, q, h + 1/3
      g = Color.hueToRGB p, q, h
      b = Color.hueToRGB p, q, h - 1/3

    return new RGB Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)
  # Converts a hue to an RGB value.
  # @static
  # @param [number] p
  # @param [number] q
  # @param [number] t
  #
  @rgbToHsl: (rgb)->
    {r,g,b}= rgb;
    r /= 255
    g /= 255
    b /= 255;
    max = Math.max r, g, b
    min = Math.min r, g, b
    l = (max + min) / 2

    if max is min
      h = s = 0
    else
      d = max - min;
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch(max)
        when r then h = (g - b) / d + (if g < b then 6 else 0)
        when g then h = (b - r) / d + 2
        when b then h = (r - g) / d + 4

      h /= 6

    "hsl(#{toPrecision(h, 2)},#{Math.round(s * 100)}%,#{Math.round(s * 100)}%)";
  # Converts
  rgb: null

  _setRGB: (value)->
    @rgb = switch Color.getFormat(value)
      when 'hex' then Color.hexToRGB value
      when 'rgb' then Color.stringToRGB value
      when 'hsl' then Color.hslToRGB value
      else new RGB 0, 0, 0

  constructor: (value= '#000000', rest...)->
    value= value.toString();
    @_setRGB(value)
    console.log(rest);

  get: (property)->
    switch property
      when 'hex' then return Color.rgbToHex @rgb
      when 'rgb' then return Color.rgbToString @rgb
      when 'hsl' then return Color.rgbToHsl @rgb

  set: (value, rest...)->
    @_setRGB(value)

class RGB
  constructor: (@r=0, @g=0, @b=0)->

toPrecision= (number, precision)->
  parseFloat number.toPrecision(precision)

color= new Color '#45a5f5'

window.onload= ()->
  console.log(color.get('hsl'));
  document.getElementsByTagName('body')[0].style.backgroundColor = color.get('hsl');