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
  @HSV_REGEX: /hsv\(\s*0*(?:360|3[0-5]\d|[12]?\d?\d)\s*(?:,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%?\s*){2}\)/
  @CMYK_REGEX: /cmyk\((?:\s*(0(\.\d+)?|1(\.0+)?)\s*(?:,?)){4}\)/
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
  ######################
  ## RGB to something ##
  ######################

  # Formats an RGB value as a string or as an object.
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
  # Converts an RGB object to a hex string.
  # @static
  # @param [RGB] rgb
  #
  @rgbToHex: (rgb)->
    {r, g, b}= @formatRgb rgb

    vals= [rgb.r, rgb.g, rgb.b].map (value)->
      ('0' + value.toString(16)).slice(-2)

    "##{vals[0]}#{vals[1]}#{vals[2]}"
  # Converts an RBG object to a HSL value.
  # @static
  # @param [RGB] rgb
  # @param [boolean] formatted
  #
  @rgbToHsl: (rgb, formatted)->
    {r, g, b}= @formatRgb rgb
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
  # Converts an RBG value to an HSL value.
  # @static
  # @param [RGB] rgb
  # @param [boolean] formatted
  #
  @rgbToHsv: (rgb, formatted)->
    {r, g, b}= @formatRgb rgb

    max = Math.max r, g, b
    dif = max - Math.min r, g, b
    s = if max is 0 then 0 else ( 100 * dif / max )
    h = switch
      when s is 0 then 0
      when r is max then 60 * ( g - b ) / dif
      when g is max then 120 + 60 * ( b -  r) / dif
      when b is max then 240 + 60 * ( r - g ) / dif

    if h < 0
      h = 360.0

    h = Math.round h
    s = Math.round s
    v = Math.round max * 100 / 255
    if formatted
      "hsv(#{h},#{s},#{v})"
    else
      new HSV h, s, v
  # Converts an RGB value to a CMYK value
  # @static
  # @param [string|object] rgb
  # @param formatted
  @rgbToCmyk: (rgb, formatted)->
    {r, g, b}= @formatRgb rgb

    r /= 255
    g /= 255
    b /= 255

    k= toPrecision (1 - Math.max r, g, b), 2
    c= toPrecision ((1 - r - k) / (1-k)), 2
    m= toPrecision ((1 - g - k) / (1-k)), 2
    y= toPrecision ((1 - b - k) / (1-k)), 2

    if formatted
      "cmyk(#{c},#{m},#{y},#{k})"
    else
      new CMYK c, m, y, k

  ######################
  ## Something to RGB ##
  ######################

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
    else if (isObject hsl) and (hasKeys hsl, ['h', 's', 'l'])
      {h, s, l} = hsl
      h= h / 100
      s= s / 100
      l= l / 100
    else
      return

    if s == 0
      r = g = b = l
    else
      q = if l < 0.5 then l * (1 + s) else l + s - l * s;
      p = 2 * l - q;
      r = Color.hueToRgb p, q, h + 1/3
      g = Color.hueToRgb p, q, h
      b = Color.hueToRgb p, q, h - 1/3

    getRgb Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), formatted

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

  # Converts an HSV value to an RGB object.
  # @static
  # @param [HSV] hsv
  # @param [boolean] formatted
  #
  @hsvToRgb: (hsv, formatted)->
    if isString hsv
      unless hsv.match Color.HSV_REGEX
        return

      [h, s, b]= hsl.match(/hsv\((.+?)\)/)[1].split(',').map (value)->
        value.trim()
        numeric= parseFloat(value)

        numeric =  if value.indexOf('%') >= 0 then numeric / 100 else numeric
    else if (isObject hsv) and (hasKeys hsv, ['h', 's', 'v'])
      {h, s, v} = hsv
    else return

    if s is 0
      r = g = b = Math.round v * 2.55
    else
      h /= 60
      s /= 100
      v /= 100
      i = Math.floor h
      f = h - i
      p = v * (1 - s)
      q = v * (1 - s * f)
      t = v * (1 - s * (1 - f))
      switch i
        when 0 then r = v; g = t; b = p
        when 1 then r = q; g = v; b = p
        when 2 then r = p; g = v; b = t
        when 3 then r = p; g = q; b = v
        when 4 then r = t; g = p; b = v
        else r = v; g = p; b = q
      r = Math.round r * 255
      g = Math.round g * 255
      b = Math.round b * 255

    getRgb r, g, b, formatted

  # Converts a CMYK value to a RGB value
  # @static
  # @param [string|object] cmyk
  # @param [boolean] formatted
  @cmykToRgb: (cmyk, formatted)->
    if isString cmyk
      unless cmyk.match @CMYK_REGEX
        return

      [c, m, y, k]= cmyk.match(/cmyk\((.+?)\)/)[1].split(',').map (value)->
        value.trim()
        parseFloat(value)
    else if (isObject cmyk) and (hasKeys cmyk, ['c', 'm', 'y', 'k'])
      {c, m, y, k} = cmyk

    r = Math.ceil 255 * (1-c) * (1-k)
    g = Math.ceil 255 * (1-m) * (1-k)
    b = Math.ceil 255 * (1-y) * (1-k)

    getRgb r, g, b, formatted
  ###########
  ## Other ##
  ###########

  # Generates a random color.
  # @static
  #
  @random: ()->
    new Color {r: randomBetween(0, 255), g: randomBetween(0, 255), b: randomBetween(0, 255)}

  ####################
  ## Color Palettes ##
  ####################

  # Returns a color, based on a given color and an angle offset.
  # @static
  # @param [object] color
  # @param [number] angle
  @angle: (color, angle)->
    {h, s, v} = Color.rgbToHsv color

    h += angle
    while h >= 360
      h -= 360
    while (h < 0)
      h += 360

    new Color Color.hsvToRgb(new HSV(h, s, v))

  # Returns the complementary, opposite color of a given color.
  # @static
  # @param [object] color
  #
  @complementary: (color)->
    @angle color, 180

  # Returns the two triadic counterparts of a color.
  # @static
  # @param [object] color
  #
  @triad: (color)->
    @balanced color, 3

  # Returns the two quadratic counterparts of a color.
  # @static
  # @param [object] color
  #
  @square: (color)->
    @balanced color, 4

  # Returns two analogous colors.
  # @static
  # @param [object] color
  #
  @analogous: (color)->
    [@angle(color, 30), @angle(color, -30)]

  # Returns to split complementary colors.
  # @static
  # @param [object] color
  #
  @splitComplementary: (color)->
    [@angle(color, 150), @angle(-150)]
  # Returns an array of a given amount of colors. Which are equally spaced.
  # @static
  # @param [object] color
  # @param [number] amount
  #
  @balanced: (color, amount = 3)->
    palette= []
    angle= 360/ amount

    for cIdx in [1..amount-1]
      palette.push @angle(color, angle * cIdx)
    palette

  # Sets the RGB of the object instance.
  # @private
  # @param [string] value
  #
  _setRgb: (value)->
    {@r, @g, @b} = switch Color.getFormat(value)
      when 'hex' then Color.hexToRgb value
      when 'rgb' then Color.formatRgb value
      when 'hsl' then Color.hslToRgb value
      when 'hsv' then Color.hsvToRgb value
      when 'cmyk' then Color.cmykToRgb value
      else new RGB 0, 0, 0

  constructor: (value= {r: 0, g: 0, b: 0})->
    @_setRgb(value)

  # Calls and retrieves the result from an appropriate function.
  # @param [string] property
  #
  to: (property, formatted=false)->
    switch property
      when 'hex' then Color.rgbToHex @
      when 'rgb' then Color.formatRgb @, formatted
      when 'hsl' then Color.rgbToHsl @, formatted
      when 'hsv' then Color.rgbToHsv @, formatted
      when 'cmyk' then Color.rgbToCmyk @, formatted

  # Used to change the value of the object, after it's instantiation.
  # @param [object|string] value
  set: (value)->
    @_setRgb(value)

  angle: (deg)->
    Color.angle @, deg

  complementary: ()->
    Color.complementary @

  balanced: ()->
    Color.balanced @

  triad: ()->
    Color.triad @

  square: ()->
    Color.square @

  analogous: ()->
    Color.analogous @

  splitComplementary: ()->
    Color.splitComplementary @


########################
## Color constructors ##
########################

# RBG has three properties, each corresponding to red, green or blue.
# The value of these properties is always a number in the [0-255] range.
class RGB
  constructor: (@r=0, @g=0, @b=0)->

# CMYK has four properties, corresponding to cyan, magenta, yellow and black.
class CMYK
  constructor: (@c=0, @m=0, @y=0, @k=0)->

# HSL has three properties. Hue, which is an angle between 0 and 360 degrees and
# corresponds to the official color wheel, saturation which determines the intensity
# of the color and is a percentage between 0 and 100, and a luminosity which determines
# the brightness of the color, and is also a percent between 0 and 100.
class HSL
  constructor: (@h=0, @s=0, @l=0)->

# HSL has three properties. Hue, which is an angle between 0 and 360 degrees and
# corresponds to the official color wheel, saturation which determines the intensity
# of the color and is a percentage between 0 and 100, and a value which determines
# the brightness of the color, and is also a percent between 0 and 100.
class HSV
  constructor: (@h=0, @s=0, @v=0)->

#######################
## Utility functions ##
#######################

# Sets a number to a certain precision, while keeping it a float.
# @param [number] number
# @param [precision] 2
#
toPrecision = (number, precision)->
  number = parseFloat number.toFixed(precision)
  if number < 0 then number *= -1
  number

# Checks if an object has all keys in a given array.
# @param [object] object
# @param [array] keys
#
hasKeys = (object, keys)->
  for key in keys
    if key not of object
      return false
  true

# Determines if a given parameter is a string.
# @param [Any] item
#
isString = (item) ->
  toString.call(item) == '[object String]'

# Determines if a given parameter is an object.
# @param [Any] item
#
isObject = (item) ->
  item != null && typeof item == 'object'

randomBetween = (min, max)->
  Math.floor Math.random() * ( max - min + 1) + min