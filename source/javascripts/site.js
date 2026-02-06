document.addEventListener("DOMContentLoaded", function () {
  var canvas = document.getElementById("starfield");
  if (!canvas) return;
  var ctx = canvas.getContext("2d");

  var NUM_STARS = 256;
  var SPEED = 0.15;
  var stars = [];

  function getScale() {
    return window.innerWidth < 600 ? 2 : 4;
  }

  function resize() {
    var scale = getScale();
    canvas.width = Math.ceil(window.innerWidth / scale);
    canvas.height = Math.ceil(window.innerHeight / scale);
  }

  function initStar(s) {
    var angle = Math.random() * Math.PI * 2;
    var dist = Math.random() * 0.3 + 0.01;
    s.x = Math.cos(angle) * dist;
    s.y = Math.sin(angle) * dist;
    s.z = Math.random() * 1.0 + 0.01;
    s.pz = s.z;
  }

  function init() {
    resize();
    for (var i = 0; i < NUM_STARS; i++) {
      var s = {};
      initStar(s);
      s.z = Math.random();
      s.pz = s.z;
      stars.push(s);
    }
  }

  function draw() {
    var w = canvas.width;
    var h = canvas.height;
    var cx = w * 0.5;
    var cy = h * 0.5;

    ctx.fillStyle = "rgba(0,0,0,0.65)";
    ctx.fillRect(0, 0, w, h);

    for (var i = 0; i < NUM_STARS; i++) {
      var s = stars[i];
      s.pz = s.z;
      s.z -= 0.008 * SPEED;

      if (s.z <= 0.001) {
        initStar(s);
        s.pz = s.z;
        continue;
      }

      var sx = (s.x / s.z) * w * 0.5 + cx;
      var sy = (s.y / s.z) * h * 0.5 + cy;

      if (sx < -1 || sx > w + 1 || sy < -1 || sy > h + 1) {
        initStar(s);
        s.pz = s.z;
        continue;
      }

      var px = (s.x / s.pz) * w * 0.5 + cx;
      var py = (s.y / s.pz) * h * 0.5 + cy;

      var depth = 1.0 - s.z;
      var bright = Math.floor(depth * depth * 255);
      if (bright > 255) bright = 255;
      if (bright < 40) bright = 40;

      var size = depth > 0.7 ? 2 : 1;

      ctx.fillStyle = "rgb(" + bright + "," + bright + "," + bright + ")";

      var dx = sx - px;
      var dy = sy - py;
      var len = Math.sqrt(dx * dx + dy * dy);

      if (len > 1.5) {
        var steps = Math.ceil(len);
        if (steps > 6) steps = 6;
        for (var j = 0; j <= steps; j++) {
          var t = j / steps;
          var lx = Math.floor(px + dx * t);
          var ly = Math.floor(py + dy * t);
          ctx.fillRect(lx, ly, size, size);
        }
      } else {
        ctx.fillRect(Math.floor(sx), Math.floor(sy), size, size);
      }
    }

    requestAnimationFrame(draw);
  }

  window.addEventListener("resize", resize);
  init();
  draw();
});
