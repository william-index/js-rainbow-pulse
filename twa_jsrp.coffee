###
  @TODO figure out seemsless loop for base point in gradient
    currently only the end point is accounted for
###

pulse_speed = 50

###
 INIT
 parses dom, and formats array of objects
 cycles through objects applying pulse effect
###
document.addEventListener "DOMContentLoaded", ->
  jsrp_objects = retrieve_all_pulse_objects()
  setInterval (->
    jsrp_obj.advance_color undefined for jsrp_obj in jsrp_objects
  ), pulse_speed
  return

###
 Retrieve and format all dom elements with .jsrp into jsrp_obj_array
 @RETURN an array of formatted object for specific tag types
###
retrieve_all_pulse_objects = ->
  all_jsrp = document.querySelectorAll(".jsrp")
  format_jsrp jsrp_dom for jsrp_dom in all_jsrp


###
 preps a dom object for object creation and passes to class/constructor
 @param {DOM object} _jsrp_dom
 @RETURN a formatted jsrp type object
###
format_jsrp = (_jsrp_dom) ->
  parent_tag = _jsrp_dom.parentNode.tagName
  parent_node = _jsrp_dom.parentNode

  if parent_tag == "g"
    parent_node = _jsrp_dom.parentNode.parentNode

  if parent_node.tagName == "svg"
    new Jsrp_svg _jsrp_dom,parent_node
  else

###
 class structure for jsrp object for an SVG element
 @method constructor - initialized object and gets relevent information
 @method parse_color - parses colors into local params
  @param {String} raw_color - attr from dom formatted as "h1,h2 s1,s2 b1,b2"
 @mathod advance_color - increments the color within its range
 @method hsb_split - splits an array of format ["h1,h2", "s1,s2", "b1,b2"]
  into and array with format hx,sx,bx
  @param {Array} _color_data - format ["h1,h2", "s1,s2", "b1,b2"]
  @param {int} _key -  index for sub array (x)
###
class Jsrp_svg

  constructor: (@jsrp_dom, @parent_node) ->
    @parse_color(@jsrp_dom.getAttribute("data-jsrp"))

  parse_color: (raw_color) ->
    color_data = raw_color.split(" ")
    @base_hsb = @hsb_split(color_data,0)
    @max_hsb = @hsb_split(color_data,1)
    @current_hsb = @hsb_split(color_data,0)
    return

  advance_color: () ->
    _i=0
    while _i < @base_hsb.length
      if @current_hsb[_i] < @max_hsb[_i]
        @current_hsb[_i]++
      else
        @current_hsb[_i] = parseInt @base_hsb[_i]
      _i++
    log @current_hsb
    return

  hsb_split: (_color_data,_key) ->
    hsb.split(",")[_key] for hsb in _color_data

###
////////////////////////////////////
/// @DEV @ONLY @METHODS ////////////
////////////////////////////////////
###

###
 Shorthand log to console
 @param {String} _statement - string to log
###
log = (_statement) ->
  console.log _statement
