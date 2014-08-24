# @TODO use speed from DOM object for each jsrp objects rate

# User Param -  mdofiy these to changes speed/etc
pulse_speed = 15

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
  Parses the values from the DOM Attr and returns them as
  an appropriately formatted array. This is done by retrieving
  the core hsl values as well as the speed in seconds @TODO stroke/fill

  @param {String} _dom_string - string retrieved by the dom
  @RETURN {array} - an array of mixed types and values
    @val {array} _h - hue movement range
    @val {int} _s - satruation percent as int
    @val {int} _l - lightness percent as int
    @val {int} _speed - speed for each step of the cycles
###
parse_jsrp_attr = (_dom_string) ->
  _split_dom = _dom_string.split(" ")
  _i = 0
  while _i < _split_dom.length
    switch _split_dom[_i].charAt(0)
      when "H" then _h = _split_dom[_i].substring(2, _split_dom[_i].length-1)
      when "S" then _s = parseInt _split_dom[_i].substring(2, _split_dom[_i].length-1)
      when "L" then _l = parseInt _split_dom[_i].substring(2, _split_dom[_i].length-1)
    if _split_dom[_i].charAt( _split_dom[_i].length - 1 ) is "s"
      _speed = _split_dom[_i].substring(0,_split_dom[_i].length-1)
      _speed = parseInt( (parseFloat _speed)*1000  / 360 )
    _i++
  _h = _h.split("->")
  return [_h, _s, _l, _speed]


total_active_gradients = 0 #tracks total number of active gradients for svg naming
###
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
###
class Jsrp_svg

  constructor: (@jsrp_dom, @parent_node) ->
    total_active_gradients++
    @format_gradient_def()
    @parse_color(@jsrp_dom.getAttribute("data-jsrp"))

  parse_color: (raw_color) ->
    color_data = parse_jsrp_attr raw_color
    @stops = color_data[0]
    @s     = color_data[1]
    @l     = color_data[2]
    @speed = color_data[3]
    return

  advance_color: () ->
    _i=0
    while _i < @stops.length
      if @stops[_i] < 360
        @stops[_i]++
      else
        @stops[_i] = 0
      _i++
    @set_updated_gradient()
    return

  # @TODO check for <defs> and create if it doesnt exist
  # @TODO calculate cx, cy and r
  format_gradient_def: () ->
    @dom_id = "jsrp_grad_"+total_active_gradients
    _fillID = "url(#jsrp_grad_"+total_active_gradients+")"

    _defs = @parent_node.getElementsByTagName("defs")[0]
    _defs.innerHTML = _defs.innerHTML +
      """
      <radialGradient id="jsrp_grad_#{total_active_gradients}" cx="62.5" cy="62.5" r="87.0057" gradientUnits="userSpaceOnUse">
      </radialGradient>
      """
    @jsrp_dom.setAttribute "fill",_fillID

  set_updated_gradient: () ->
    @parent_node.getElementById(@dom_id).innerHTML =
      """
      <stop  offset="0" style="stop-color:hsl(#{@stops[1]},#{@s}%,#{@l}%);"/>
      <stop  offset="1" style="stop-color:hsl(#{@stops[0]},#{@s}%,#{@l}%);"/>
      """
    return


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
