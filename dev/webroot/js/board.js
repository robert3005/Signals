// Generated by CoffeeScript 1.3.1
var count, direction, drawHex, end, glow, height, hitOptions, horIncrement, margin, offset, onFrame, onMouseMove, oval, path, point, rectangle, size, start, verIncrement, width, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;

margin = 20;

size = 40;

count = 12;

height = Math.ceil(2 * margin + (3 * count + 1) / 2 * size);

width = 2 * margin + Math.ceil(Math.sqrt(3) * size / 2) * 25;

hitOptions = {
  segments: true,
  stroke: true,
  fill: true,
  tolerance: 2
};

view.viewSize = [width, height];

onMouseMove = function(event) {
  var hitResult;
  hitResult = project.hitTest(event.point, hitOptions);
  project.activeLayer.selected = false;
  if (hitResult && hitResult.item) {
    return hitResult.item.selected = true;
  }
};

drawHex = function(x, y, size) {
  var hex;
  hex = new Path.RegularPolygon(new Point(x, y), 6, size);
  return hex.style = {
    fillColor: new RgbColor(0, 0, 0, 0),
    strokeColor: 'yellow',
    strokeWidth: 3,
    selected: false
  };
};

glow = function(path, glow) {
  var c, i, newPath, out, s, _i, _ref;
  glow = glow || {};
  s = {
    strokeWidth: (glow.strokeWidth || 10) + path.strokeWidth,
    fillColor: glow.fillColor || new RgbColor(0, 0, 0, 0),
    opacity: glow.opacity || .5,
    translatePoint: glow.translatePoint || new Point(0, 0),
    strokeColor: glow.strokeColor || "#000"
  };
  c = s.strokeWidth / 2;
  out = [];
  for (i = _i = 1, _ref = c + 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
    newPath = path.clone();
    newPath.style = {
      strokeColor: s.strokeColor,
      fillColor: s.fillColor,
      strokeJoin: "round",
      strokeCap: "round",
      strokeWidth: +(s.strokeWidth / c * i).toFixed(3)
    };
    newPath.strokeColor.alpha = +(s.opacity / c).toFixed(3);
    newPath.moveBelow(path);
    out.push(newPath);
  }
  return out;
};

horIncrement = Math.ceil(Math.sqrt(3) * size);

verIncrement = Math.ceil(3 * size / 2);

offset = false;

for (y = _i = _ref = margin + size, _ref1 = height - margin - size; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; y = _i += verIncrement) {
  for (x = _j = _ref2 = margin + horIncrement / 2 + (offset ? horIncrement / 2 : 0), _ref3 = width - margin - (!offset ? horIncrement / 2 : 0); _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; x = _j += horIncrement) {
    drawHex(x, y, size);
  }
  offset = !offset;
}

path = new Path();

start = new Point(margin + size, size + margin);

end = new Point(margin + size + horIncrement, margin + size + 2 * verIncrement);

path.add(start);

path.lineTo(end);

path.strokeColor = '#0000ff';

path.strokeWidth = 2;

size = new Size(10, 8);

point = path.getPointAt(0);

rectangle = new Rectangle(point, size);

oval = new Path.Oval(rectangle);

oval.fillColor = '#0000ff';

oval.position += new Point(-5, -4);

direction = end - start;

onFrame = function(event) {
  if (oval.position.x > end.x && oval.position.y > end.y || oval.position.x < start.x && oval.position.y < start.y) {
    direction = -direction;
  }
  return oval.position += direction / 50;
};