// Generated by CoffeeScript 1.7.1

/*
  @TODO have s and l be static
 */

(function() {
  var Jsrp_svg, format_jsrp, log, pulse_speed, retrieve_all_pulse_objects, total_active_gradients;

  pulse_speed = 50;


  /*
   INIT
   parses dom, and formats array of objects
   cycles through objects applying pulse effect
   */

  document.addEventListener("DOMContentLoaded", function() {
    var jsrp_objects;
    jsrp_objects = retrieve_all_pulse_objects();
    setInterval((function() {
      var jsrp_obj, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = jsrp_objects.length; _i < _len; _i++) {
        jsrp_obj = jsrp_objects[_i];
        _results.push(jsrp_obj.advance_color(void 0));
      }
      return _results;
    }), pulse_speed);
  });


  /*
   Retrieve and format all dom elements with .jsrp into jsrp_obj_array
   @RETURN an array of formatted object for specific tag types
   */

  retrieve_all_pulse_objects = function() {
    var all_jsrp, jsrp_dom, _i, _len, _results;
    all_jsrp = document.querySelectorAll(".jsrp");
    _results = [];
    for (_i = 0, _len = all_jsrp.length; _i < _len; _i++) {
      jsrp_dom = all_jsrp[_i];
      _results.push(format_jsrp(jsrp_dom));
    }
    return _results;
  };


  /*
   preps a dom object for object creation and passes to class/constructor
   @param {DOM object} _jsrp_dom
   @RETURN a formatted jsrp type object
   */

  format_jsrp = function(_jsrp_dom) {
    var parent_node, parent_tag;
    parent_tag = _jsrp_dom.parentNode.tagName;
    parent_node = _jsrp_dom.parentNode;
    if (parent_tag === "g") {
      parent_node = _jsrp_dom.parentNode.parentNode;
    }
    if (parent_node.tagName === "svg") {
      return new Jsrp_svg(_jsrp_dom, parent_node);
    } else {

    }
  };

  total_active_gradients = 0;


  /*
   class structure for jsrp object for an SVG element
   @method constructor - initialized object and gets relevent information
   @method parse_color - parses colors into local params
    @param {String} raw_color - attr from dom formatted as "h1,h2 s1,s2 b1,b2"
   @mathod advance_color - increments the color within its ranges
   @method hsl_split - splits an array of format ["h1,h2", "s1,s2", "b1,b2"]
    into and array with format hx,sx,bx
    @param {Array} _color_data - format ["h1,h2", "s1,s2", "b1,b2"]
    @param {int} _key -  index for sub array (x)
   @method set_updated_gradient - formats and sets the gradient stops into the DOM
   */

  Jsrp_svg = (function() {
    function Jsrp_svg(jsrp_dom, parent_node) {
      this.jsrp_dom = jsrp_dom;
      this.parent_node = parent_node;
      total_active_gradients++;
      this.format_gradient_def();
      this.parse_color(this.jsrp_dom.getAttribute("data-jsrp"));
    }

    Jsrp_svg.prototype.parse_color = function(raw_color) {
      var color_data;
      color_data = raw_color.split(" ");
      this.base_hsl_stop1 = this.hsl_split(color_data, 0);
      this.base_hsl_stop2 = this.hsl_split(color_data, 1);
      this.stops = [this.base_hsl_stop1, this.base_hsl_stop2];
      this.max_hsl = [306, 100, 100];
    };

    Jsrp_svg.prototype.advance_color = function() {
      var _i, _s;
      _s = 0;
      while (_s < this.stops.length) {
        _i = 0;
        while (_i < this.stops[_s].length) {
          if (this.stops[_s][_i] < this.max_hsl[_i]) {
            this.stops[_s][_i]++;
          } else {
            this.stops[_s][_i] = 0;
          }
          _i++;
        }
        _s++;
      }
      this.set_updated_gradient();
    };

    Jsrp_svg.prototype.format_gradient_def = function() {
      var _defs, _fillID;
      this.dom_id = "jsrp_grad_" + total_active_gradients;
      _fillID = "url(#jsrp_grad_" + total_active_gradients + ")";
      _defs = this.parent_node.getElementsByTagName("defs")[0];
      _defs.innerHTML = _defs.innerHTML + ("<radialGradient id=\"jsrp_grad_" + total_active_gradients + "\" cx=\"62.5\" cy=\"62.5\" r=\"87.0057\" gradientUnits=\"userSpaceOnUse\">\n</radialGradient>");
      return this.jsrp_dom.setAttribute("fill", _fillID);
    };

    Jsrp_svg.prototype.set_updated_gradient = function() {
      this.parent_node.getElementById(this.dom_id).innerHTML = "<stop  offset=\"0\" style=\"stop-color:hsl(" + this.stops[0][0] + "," + this.stops[0][1] + "%," + this.stops[0][2] + "%);\"/>\n<stop  offset=\"1\" style=\"stop-color:hsl(" + this.stops[1][0] + "," + this.stops[1][1] + "%," + this.stops[1][2] + "%);\"/>";
    };

    Jsrp_svg.prototype.hsl_split = function(_color_data, _key) {
      var hsl, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = _color_data.length; _i < _len; _i++) {
        hsl = _color_data[_i];
        _results.push(parseInt(hsl.split(",")[_key]));
      }
      return _results;
    };

    return Jsrp_svg;

  })();


  /*
  ////////////////////////////////////
  /// @DEV @ONLY @METHODS ////////////
  ////////////////////////////////////
   */


  /*
   Shorthand log to console
   @param {String} _statement - string to log
   */

  log = function(_statement) {
    return console.log(_statement);
  };

}).call(this);
