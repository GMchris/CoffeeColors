// Generated by CoffeeScript 1.10.0
(function() {
  var CMYK, HSL, HSV, RGB, color, hasKeys, hsv, isObject, isString, max3, min3, toPrecision, triad;

  window.Color = (function() {
    var getRgb;

    getRgb = function(r, g, b, formatted) {
      if (formatted) {
        return "rgb(" + r + "," + g + "," + b + ")";
      } else {
        return new RGB(r, g, b);
      }
    };

    Color.HEX_REGEX = /#(?:[a-f\d]{3}){1,2}\b/;

    Color.RGB_REGEX = /rgb\((?:(?:\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)\s*,){2}\s*0*(?:25[0-5]|2[0-4]\d|1?\d?\d)|\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%(?:\s*,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%){2})\s*\)/;

    Color.HSL_REGEX = /hsl\(\s*0*(?:360|3[0-5]\d|[12]?\d?\d)\s*(?:,\s*0*(?:100(?:\.0+)?|\d?\d(?:\.\d+)?)%?\s*){2}\)/;

    Color.getFormat = function(value) {
      if (value != null) {
        if (isString(value)) {
          switch (false) {
            case !value.match(Color.HSL_REGEX):
              return 'hsl';
            case !value.match(Color.RGB_REGEX):
              return 'rgb';
            case !value.match(Color.HEX_REGEX):
              return 'hex';
          }
        } else if (isObject(value)) {
          switch (false) {
            case !hasKeys(value, ['r', 'g', 'b']):
              return 'rgb';
            case !hasKeys(value, ['h', 's', 'l']):
              return 'hsl';
          }
        }
      }
    };

    Color.formatRgb = function(rgb, formatted) {
      var b, g, r, ref;
      if (isString(rgb)) {
        if (!rgb.match(Color.RGB_REGEX)) {
          return;
        }
        ref = rgb.match(/rgb\((.+?)\)/)[1].split(',').map(function(value) {
          value.trim();
          return parseInt(value);
        }), r = ref[0], g = ref[1], b = ref[2];
      } else if (isObject(rgb)) {
        r = rgb.r, g = rgb.g, b = rgb.b;
      }
      return getRgb(r, g, b, formatted);
    };

    Color.rgbToHex = function(rgb) {
      var b, g, r, ref, vals;
      ref = this.formatRgb(rgb), r = ref.r, g = ref.g, b = ref.b;
      vals = [rgb.r, rgb.g, rgb.b].map(function(value) {
        return ('0' + value.toString(16)).slice(-2);
      });
      return "#" + vals[0] + vals[1] + vals[2];
    };

    Color.rgbToHsl = function(rgb, formatted) {
      var b, d, g, h, l, max, min, r, ref, s;
      ref = this.formatRgb(rgb), r = ref.r, g = ref.g, b = ref.b;
      r /= 255;
      g /= 255;
      b /= 255;
      max = Math.max(r, g, b);
      min = Math.min(r, g, b);
      l = (max + min) / 2;
      if (max === min) {
        h = s = 0;
      } else {
        d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch (max) {
          case r:
            h = (g - b) / d + (g < b ? 6 : 0);
            break;
          case g:
            h = (b - r) / d + 2;
            break;
          case b:
            h = (r - g) / d + 4;
        }
        h = Math.round((h / 6) * 360);
        s = Math.round(s * 100);
        l = Math.round(l * 100);
      }
      if (formatted) {
        return "hsl(" + h + "," + s + "%," + l + "%)";
      } else {
        return new HSL(h, s, l);
      }
    };

    Color.rgbToHsv = function(rgb, formatted) {
      var b, dif, g, h, max, r, ref, s, v;
      ref = this.formatRgb(rgb), r = ref.r, g = ref.g, b = ref.b;
      max = max3(r, g, b);
      dif = max - min3(r, g, b);
      s = max === 0 ? 0 : 100 * dif / max;
      h = (function() {
        switch (false) {
          case s !== 0:
            return 0;
          case r !== max:
            return 60 * (g - b) / dif;
          case g !== max:
            return 120 + 60 * (b - r) / dif;
          case b !== max:
            return 240 + 60 * (r - g) / dif;
        }
      })();
      if (h < 0) {
        h = 360.0;
      }
      h = Math.round(h);
      s = Math.round(s);
      v = Math.round(max * 100 / 255);
      return new HSV(h, s, v);
    };

    Color.hexToRgb = function(hex, formatted) {
      var rgb;
      if (!hex.match(Color.HEX_REGEX)) {
        return;
      }
      hex = hex.replace('#', '');
      if (hex.length === 3) {
        hex += hex;
      }
      rgb = hex.match(/.{1,2}/g).map(function(val) {
        return parseInt(val, 16);
      });
      return getRgb(rgb[0], rgb[1], rgb[2], formatted);
    };

    Color.hslToRgb = function(hsl, formatted) {
      var b, g, h, l, p, q, r, ref, s;
      if (isString(hsl)) {
        if (!hsl.match(Color.HSL_REGEX)) {
          return;
        }
        ref = hsl.match(/hsl\((.+?)\)/)[1].split(',').map(function(value) {
          var numeric;
          value.trim();
          numeric = parseFloat(value);
          return numeric = value.indexOf('%') >= 0 ? numeric / 100 : numeric;
        }), h = ref[0], s = ref[1], l = ref[2];
      } else if (isObject(hsl)) {
        h = hsl.h, s = hsl.s, l = hsl.l;
        h = h / 100;
        s = s / 100;
        l = l / 100;
      }
      if (s === 0) {
        r = g = b = l;
      } else {
        q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        p = 2 * l - q;
        r = Color.hueToRgb(p, q, h + 1 / 3);
        g = Color.hueToRgb(p, q, h);
        b = Color.hueToRgb(p, q, h - 1 / 3);
      }
      return getRgb(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), formatted);
    };

    Color.hueToRgb = function(p, q, t) {
      if (t < 0) {
        t += 1;
      }
      if (t > 1) {
        t -= 1;
      }
      if (t < 1 / 6) {
        return p + (q - p) * 6 * t;
      }
      if (t < 1 / 2) {
        return q;
      }
      if (t < 2 / 3) {
        return p + (q - p) * (2 / 3 - t) * 6;
      }
      return p;
    };

    Color.hsvToRgb = function(hsv, formatted) {
      var b, f, g, h, i, p, q, r, s, t, v;
      h = hsv.h, s = hsv.s, v = hsv.v;
      if (s === 0) {
        r = g = b = Math.round(v * 2.55);
      } else {
        h /= 60;
        s /= 100;
        v /= 100;
        i = Math.floor(h);
        f = h - i;
        p = v * (1 - s);
        q = v * (1 - s * f);
        t = v * (1 - s * (1 - f));
        switch (i) {
          case 0:
            r = v;
            g = t;
            b = p;
            break;
          case 1:
            r = q;
            g = v;
            b = p;
            break;
          case 2:
            r = p;
            g = v;
            b = t;
            break;
          case 3:
            r = p;
            g = q;
            b = v;
            break;
          case 4:
            r = t;
            g = p;
            b = v;
            break;
          default:
            r = v;
            g = p;
            b = q;
        }
        r = Math.round(r * 255);
        g = Math.round(g * 255);
        b = Math.round(b * 255);
      }
      return getRgb(r, g, b, formatted);
    };

    Color.angle = function(color, angle) {
      var h, ref, s, v;
      ref = Color.rgbToHsv(color), h = ref.h, s = ref.s, v = ref.v;
      h += angle;
      while (h >= 360) {
        h -= 360;
      }
      while (h < 0) {
        h += 360;
      }
      return new Color(Color.hsvToRgb(new HSV(h, s, v)));
    };

    Color.complementary = function(color) {
      return this.angle(color, 180);
    };

    Color.triad = function(color) {
      return [this.angle(color, 120), this.angle(color, -120)];
    };

    Color.prototype._setRgb = function(value) {
      var ref;
      return ref = (function() {
        switch (Color.getFormat(value)) {
          case 'hex':
            return Color.hexToRgb(value);
          case 'rgb':
            return Color.formatRgb(value);
          case 'hsl':
            return Color.hslToRgb(value);
          default:
            return new RGB(0, 0, 0);
        }
      })(), this.r = ref.r, this.g = ref.g, this.b = ref.b, ref;
    };

    function Color(value) {
      if (value == null) {
        value = {
          r: 0,
          g: 0,
          b: 0
        };
      }
      this._setRgb(value);
    }

    Color.prototype.to = function(property, formatted) {
      if (formatted == null) {
        formatted = false;
      }
      switch (property) {
        case 'hex':
          return Color.rgbToHex(this);
        case 'rgb':
          return Color.formatRgb(this, formatted);
        case 'hsl':
          return Color.rgbToHsl(this, formatted);
        case 'hsv':
          return Color.rgbToHsv(this, formatted);
      }
    };

    Color.prototype.set = function(value) {
      return this._setRgb(value);
    };

    Color.prototype.complementary = function() {
      return Color.complementary(this);
    };

    Color.prototype.triad = function() {
      return Color.triad(this);
    };

    return Color;

  })();

  RGB = (function() {
    function RGB(r1, g1, b1) {
      this.r = r1 != null ? r1 : 0;
      this.g = g1 != null ? g1 : 0;
      this.b = b1 != null ? b1 : 0;
    }

    return RGB;

  })();

  CMYK = (function() {
    function CMYK(c1, m, y, k) {
      this.c = c1 != null ? c1 : 0;
      this.m = m != null ? m : 0;
      this.y = y != null ? y : 0;
      this.k = k != null ? k : 0;
    }

    return CMYK;

  })();

  HSL = (function() {
    function HSL(h1, s1, l1) {
      this.h = h1 != null ? h1 : 0;
      this.s = s1 != null ? s1 : 0;
      this.l = l1 != null ? l1 : 0;
    }

    return HSL;

  })();

  HSV = (function() {
    function HSV(h1, s1, v1) {
      this.h = h1 != null ? h1 : 0;
      this.s = s1 != null ? s1 : 0;
      this.v = v1 != null ? v1 : 0;
    }

    return HSV;

  })();

  toPrecision = function(number, precision) {
    return parseFloat(number.toPrecision(precision));
  };

  hasKeys = function(object, keys) {
    var j, key, len;
    for (j = 0, len = keys.length; j < len; j++) {
      key = keys[j];
      if (!(key in object)) {
        return false;
      }
    }
    return true;
  };

  isString = function(item) {
    return toString.call(item) === '[object String]';
  };

  isObject = function(item) {
    return item !== null && typeof item === 'object';
  };

  min3 = function(a, b, c) {
    if (a < b) {
      if (a < c) {
        return a;
      } else {
        return c;
      }
    } else {
      if (b < c) {
        return b;
      } else {
        return c;
      }
    }
  };

  max3 = function(a, b, c) {
    if (a > b) {
      if (a > c) {
        return a;
      } else {
        return c;
      }
    } else {
      if (b > c) {
        return b;
      } else {
        return c;
      }
    }
  };

  color = new Color({
    r: 69,
    g: 165,
    b: 245
  });

  hsv = color.to('hsv');

  triad = color.triad();

  window.onload = function() {
    document.getElementById('a').style.backgroundColor = color.to('rgb', true);
    document.getElementById('b').style.backgroundColor = triad[0].to('rgb', true);
    return document.getElementById('c').style.backgroundColor = triad[1].to('rgb', true);
  };

}).call(this);