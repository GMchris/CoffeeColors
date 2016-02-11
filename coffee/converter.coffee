#
# Color: A global class, which contains static methods for converting different color formats.
# Instances of the Color class offer a cleaner API for the conversions.
#
class window.Color
  getRgb= (r, g, b, formatted)->
    if formatted
      "rgb(#{r},#{g},#{b})"
    else
      new RGB r, g, b
  # Regular expressions used to match various color formats.
  #
  @HEX_REGEX: /#(?:[a-f\d]{3}){1,2}\b/
  @RGB_REGEX: /rgb\((?:(?:\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)\s*,){2}\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)|\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%(?:\s*,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%){2})\s*\)/
  @HSL_REGEX: /hsl\(\s*0*(?:360|3[0-5]\d|[12]?\d?\d)\s*(?:,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%?\s*){2}\)/
  # Determines the format of the given color string.
  # @static
  # @param [string] value
  #
  @getFormat: (value)->
    if value?
      if isString value
        switch
          when value.match Color.HSL_REGEX then 'hsl'
          when value.match Color.RGB_REGEX then 'rgb'
          when value.match Color.HEX_REGEX then 'hex'
      else if isObject value
        switch
          when hasKeys value, ['r','g','b'] then 'rgb'
          when hasKeys value, ['h','s','l'] then 'hsl'
  # Converts an RGB object to an  rgb(*, *, *) string.
  # @static
  # @param [RGB] rgb
  #
  @formatRgb: (rgb, formatted)->
    if isString rgb
      unless rgb.match Color.RGB_REGEX
        return
      # Extract the values if it's a string
      [r, g, b]= rgb.match(/rgb\((.+?)\)/)[1].split(',').map (value)->
        value.trim()
        parseInt(value)

    else if isObject rgb
      # Unwrap it if it's an object.
      {r, g, b}= rgb

    getRgb r, g, b, formatted
  # Converts a hex string to an RGB object.
  # @static
  # @param [hex] string
  #
  @hexToRgb: (hex, formatted)->
    unless hex.match Color.HEX_REGEX
      return

    hex= hex.replace '#', ''
    if hex.length is 3
      hex += hex

    rgb= hex.match(/.{1,2}/g).map (val)-> parseInt val, 16

    getRgb rgb[0], rgb[1], rgb[2], formatted
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
  @hueToRgb: (p, q, t)->
    if (t < 0)
      t += 1
    if (t > 1)
      t -= 1
    if (t < 1/6)
      return p + (q - p) * 6 * t
    if (t < 1/2)
      return q
    if (t < 2/3)
      return p + (q - p) * (2/3 - t) * 6
    p
  # Converts an hsl(*, *, *) string to an RGB object.
  # @static
  # @param [RGB] rgb
  #
  @hslToRgb: (hsl, formatted)->
    if isString hsl
      unless hsl.match Color.HSL_REGEX
        return

      [h, s, l]= hsl.match(/hsl\((.+?)\)/)[1].split(',').map (value)->
        value.trim()
        numeric= parseFloat(value)

        numeric =  if value.indexOf('%') >= 0 then numeric / 100 else numeric
    else if isObject hsl
      {h, s, l} = hsl
      h= h / 100
      s= s / 100
      l= l / 100

    if s == 0
      r = g = b = l
    else
      q = if l < 0.5 then l * (1 + s) else l + s - l * s;
      p = 2 * l - q;
      r = Color.hueToRgb p, q, h + 1/3
      g = Color.hueToRgb p, q, h
      b = Color.hueToRgb p, q, h - 1/3

    getRgb Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), formatted
  # Converts an RBG object to a HSL value.
  # @static
  # @param [RGB] rgb
  # @param [boolean] formatted
  #
  @rgbToHsl: (rgb, formatted)->
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

      h = Math.round (h / 6) * 360
      s = Math.round s * 100
      l = Math.round l * 100

    if formatted
      "hsl(#{h},#{s}%,#{l}%)"
    else
      new HSL h, s, l
  # Object containing the red, green and blue value of the the color.
  rgb: null
  # Sets the RGB of the object instance.
  # @private
  # @param [string] value
  #
  _setRgb: (value)->
    @rgb = switch Color.getFormat(value)
      when 'hex' then Color.hexToRgb value
      when 'rgb' then Color.formatRgb value
      when 'hsl' then Color.hslToRgb value
      else new RGB 0, 0, 0

  constructor: (value= {r: 0, g: 0, b: 0})->
    @_setRgb(value)
  # Calls and retrieves the result from an appropriate function.
  # @param [string] property
  #
  to: (property, formatted=false)->
    switch property
      when 'hex' then return Color.rgbToHex @rgb
      when 'rgb' then return Color.formatRgb @rgb, formatted
      when 'hsl' then return Color.rgbToHsl @rgb, formatted
  # Used to change the value of the object, after it's instantiation.
  # @param [object|string] value
  set: (value)->
    @_setRgb(value)
  # Finds and returns the objects complementary color
  complementary: ()->
    hsl= Color.rgbToHsl @rgb
    if hsl.h >= 180
      console.log hsl.h
      newH= hsl.h - 100
    else
      newH= hsl.h + 180
    console.log newH
    Color.hslToRgb new HSL(newH, hsl.s, hsl.l)

# RBG has three properties, each corresponding to red, green or blue.
# The value of these properties is always a number in the [0-255] range.
class RGB
  constructor: (@r=0, @g=0, @b=0)->

class CMYK
  constructor: (@c=0, @m=0, @y=0, @k=0)->
# HSL has three properties. Hue, which is an angle between 0 and 360 degrees and
# corresponds to the official color wheel, saturation which determines the intensity
# of the color and is a percentage between 0 and 100, and a luminosity which determines
# the brightness of the color, and is also a percent between 0 and 100.
class HSL
  constructor: (@h=0, @s=0, @l=0)->

toPrecision = (number, precision)->
  parseFloat number.toPrecision(precision)

hasKeys = (object, keys)->
  for key in keys
    if key not of object
      return false
  true

isString = (item) ->
  toString.call(item) == '[object String]'

isObject = (item) ->
  item != null && typeof item == 'object'

color= new Color {r: 69, g: 165, b: 245}
complementary= new Color(color.complementary())

window.onload= ()->
  document.getElementById('a').style.backgroundColor = color.to('rgb', true)
  document.getElementById('b').style.backgroundColor = complementary.to('rgb', true)