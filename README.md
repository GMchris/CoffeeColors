# CoffeeColors
Coffee colors is a simple and light class that lets you manipulate colors,convert them between
the most widely spread formats and even generate color palettes.

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

The currently supported color formats are RGB, hex, CMYK, HSV, HSL.