###
  @TODO have s and l be static
###

# User Param -  mdofiy these to changes speed/etc
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
    color_data = raw_color.split(" ")
    @base_hsl_stop1 = @hsl_split(color_data,0)
    @base_hsl_stop2 = @hsl_split(color_data,1)
    @stops = [@base_hsl_stop1, @base_hsl_stop2]
    @max_hsl = [306,100,100]
    return

  advance_color: () ->
    _s=0
    while _s < @stops.length
      _i=0
      while _i < @stops[_s].length
        if @stops[_s][_i] < @max_hsl[_i]
          @stops[_s][_i]++
        else
          @stops[_s][_i] = 0
        _i++
      _s++
    @set_updated_gradient()
    return

  # @TODO check for defs and create if it doesnt exist
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
      <stop  offset="0" style="stop-color:hsl(#{@stops[0][0]},#{@stops[0][1]}%,#{@stops[0][2]}%);"/>
      <stop  offset="1" style="stop-color:hsl(#{@stops[1][0]},#{@stops[1][1]}%,#{@stops[1][2]}%);"/>
      """
    return

  hsl_split: (_color_data,_key) ->
    parseInt hsl.split(",")[_key] for hsl in _color_data

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
