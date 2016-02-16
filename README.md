# CoffeeColors
Coffee colors is a simple and light class that lets you manipulate colors,convert them between
the most widely spread formats and even generate color palettes.

###Color

The Color constructor is at the core of this mini-library, being the only globally scoped variable
to come out of it. To start things off, you can create a new color like so:

```javascript
var color= new Color({r: 161, g: 234, b: 0});
```

This instantiates a new Color object, which, in addition to all it's methods, will also have
r, g and b properties. To change the current color of the object, you can use the `set` method.

```javascript
color.set('#45A5F5');
```

Note that we use a hex string, instead of an RBG object this time. The color detects the format
of the passed item, and sets itself accordingly. Despite setting a hex value this time, you'll
find that the object has simply changed it's r, g and b properties. Colors are always kept stored
as RGB, for clarity's sake.

It's not advised to retrieve properties directly by calling them like so:

```javascript
var red= color.r;
```

To get a color, call the `to` method. It takes two parameters, the second of which is optional.
Firstly you need to pass it a format in which you expect your color. You can also specify if said
data should be returned as an object, or as a formatted string, by passing a second boolean parameter.
The only exception is 'hex', which cannot be an object and will also be returned as a string.

```javascript
var rgb= color.to('rgb') // { r: 69, g: 165, b: 245 }
var hex= color.to('hex') // '#45A5F5'
var rgb= color.to('hsl', true) // 'hsl(0.58,0.9,0.62)'
```

Once a color is instantiated, you can check it's brightness:

```javascript
color.brightness(); //=> 0.92
```

Get or set it's alpha:

```javascript
color.alpha(); // => 1
color.alpha(0.6); // => 0.6
color.to('rgb', true); // => 'rgba(69, 165, 245, 0.6)'
```

Or get it's temperature. Temperature means whether the color is cold or warm.

```javascript
color.temperature(); // => 'cold'
```

###Supported

The following formats and ways of declaring and requesting methods exist.

Format | Unformatted | Formatted
--- | --- | ---
RGB | { r:255, g:255, b:255 } | 'rgb(255, 255, 255)'
hex | '#ffffff' | '#ffffff'
HSL | { h:360, s:100, l:100 } | 'hsl(360, 100, 100)'
HSV | { h:360, s:100, v:100 } | 'hsv(360, 100, 100)'
CMYK| { c:1, m:1, y:1, k:1 } | 'cmyk(1, 1, 1, 1)'

###Static

The Color constructor has several static method, some of which are used
to execute conversions. The choice to keep them static, and not members of
Color instances was to save memory as most of the methods need a color to be
passed to them anyway. In fact the `to` method of Color instances simply calls
one of the conversion functions, and passes the this as the first argument.

The conversion methods are split into two types. Conversions from RGB to another format, and from another format to RGB. The only exception being `formatRgb`, which can be used to convert formatted values to unformatted ones and vice versa. The way to use these conversion methods is pretty straightforward.

```javascript
var color= new Color('#4fa2cc');
Color.rgbToHsl(color, true); // => "hsl(200,55%,55%)"
Color.hexToRgb(color.to('hex')); // => {r: 79, g: 162, b: 204}
```
While it's not wrong to use the static method, especially when you don't want to create new Color objects, it's generally tidier to use instances and `to`.

###Color theory

There are a few methods that serve a more artistic purpose. What's unique about them, other than their intended use, is the fact that they're featured both as static methods on the Color constructor, as well as
methods on Color instances. The currently available ones are:

*angle(color, deg)* - Adds a given amount of degrees to a color. Rotating it's hue on the color wheel. This method is actually used to implement all color theory methods, and heavily relies on the HSV color format.

*analogous(color)* - Returns the analogous or adjacent colors (30deg, -30deg) of a given color.

*complementary(color)* - Applies the `angle` method, using exactly 180 degrees. Meaning that the exact opposite hue on the color wheel is chosen.

*triad(color)* - Applies the `angle` method once with 120 degrees and again with -120, to get three equally spaced colors on the wheel.

*splitComplementary(color)* - Applies the `angle` method once with 150 and again with -150 degrees.

*square(color)* - Applies the `angle` method three times, forming a square with the initial color.

*balanced(color, segments)* - Splits the color wheel into equal segments, and returns an array of all the split point colors.


```javascript
var color= new Color('#2251a8');
color.complementary(); // => {r: 168, g: 121, b: 34}
Color.complementary(color); // => {r: 168, g: 121, b: 34} as well
```
