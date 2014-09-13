# @TODO use speed from DOM object for each jsrp objects rate

# User Param -  mdofiy these to changes speed/etc
pulse_speed = 10

###
 INIT
 parses dom, and formats array of objects
 cycles through objects applying pulse effect
 #
 @since v0.1
###
document.addEventListener "DOMContentLoaded", ->
  jsrp_objects = retrieve_all_pulse_objects()
  setInterval (->
    jsrp_obj.advance_color undefined for jsrp_obj in jsrp_objects
  ), pulse_speed
  return

###
 Retrieve and format all dom elements with .jsrp into jsrp_obj_array
 #
 @RETURN an array of formatted object for specific tag types
 #
 @since v0.1
###
retrieve_all_pulse_objects = ->
  all_jsrp = document.querySelectorAll(".jsrp")
  format_jsrp jsrp_dom for jsrp_dom in all_jsrp


###
 preps a dom object for object creation and passes to class/constructor
 #
 @param {DOM object} _jsrp_dom
 @RETURN a formatted jsrp type object
 #
 @since v0.1
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
  #
  @param {String} _dom_string - string retrieved by the dom
  @RETURN {array} - an array of mixed types and values
    @val {array} _h - hue movement range
    @val {int} _s - satruation percent as int
    @val {int} _l - lightness percent as int
    @val {int} _speed - speed for each step of the cycles
  #
  @since v0.1
###
parse_jsrp_attr = (_dom_string) ->
  _split_dom = _dom_string.split(" ")
  _i = 0
  while _i < _split_dom.length
    switch _split_dom[_i].charAt(0)
      when "H" then _h = _split_dom[_i].substring(2, _split_dom[_i].length)
      when "S" then _s = parseInt _split_dom[_i].substring(2, _split_dom[_i].length-1)
      when "L" then _l = parseInt _split_dom[_i].substring(2, _split_dom[_i].length-1)
    if _split_dom[_i].charAt( _split_dom[_i].length - 1 ) is "s"
      _steps = _split_dom[_i].substring(0,_split_dom[_i].length-1)
      _steps = parseInt( (parseFloat _steps)*1000  / 360 )
    _i++
  _h = _h.split("->")
  return [_h, _s, _l, _steps]


total_active_gradients = 0 #tracks total number of active gradients for svg naming
###
  Jsrp_svg
  Object for JSRP made for an svg child node
  Controls parse of information and aniamtion of pulse
  #
  @jsrp_dom
  @parent_node  - svg parent container
  @dom_id       - id of gradient element in dom
  #
  @since v0.1
###
class Jsrp_svg

  ###
    initialized object and gets relevent information
    @param {DOM object} jsrp_dom - @see parent
    @param {DOM object} parent_node - @see parent
  ###
  constructor: (@jsrp_dom, @parent_node) ->
    total_active_gradients++
    @parse_jsrp_params(@jsrp_dom.getAttribute("data-jsrp"))
    @format_gradient_def()

  ###
    parses parameters for jsrp object
    or sets default values
    #
    @param {String} raw_jsrp_data - raw data input from string value
  ###
  parse_jsrp_params: (raw_jsrp_data) ->
    color_data = parse_jsrp_attr raw_jsrp_data
    @stops = color_data[0]
    @s     = color_data[1]
    @l     = color_data[2]
    @steps = color_data[3]
    @base_color = @stops[0]
    return

  ###
    increments the cbase color value
  ###
  advance_color: () ->
    @base_color--
    @set_updated_gradient()
    return

  ###
    Formats and inserts the radial gradeint elemtnt into the dom
  ###
  # @TODO check for <defs> and create if it doesnt exist
  # @TODO calculate cx, cy and r
  format_gradient_def: () ->
    @dom_id = "jsrp_grad_"+total_active_gradients
    _fillID = "url(#jsrp_grad_"+total_active_gradients+")"


    _cx = @jsrp_dom.getBoundingClientRect().width / 2
    _cy = @jsrp_dom.getBoundingClientRect().height / 2
    log _cx

    _defs = @parent_node.getElementsByTagName("defs")[0]
    _defs.innerHTML = _defs.innerHTML +
      """
      <radialGradient id="jsrp_grad_#{total_active_gradients}" cx="#{_cx}" cy="#{_cy}" r="#{_cx}" gradientUnits="userSpaceOnUse">
      </radialGradient>
      """
    @jsrp_dom.setAttribute "fill",_fillID
    @set_gradient_steps()

  ###
  * Sets up the initial stops for the radial gradients
  * Fixes steps range for pulsing
  ###
  set_gradient_steps: () ->
    @steps = @steps-1
    _gradient_steps = ""
    _inc = 0; while _inc < @steps+1
      _on_step = (_inc)*(1/@steps)
      _gradient_steps +=
        """
        <stop offset="#{Math.floor(_on_step*100)}%" style=""/>
        """
      _inc++
    @parent_node.getElementById(@dom_id).innerHTML = _gradient_steps
    return


  ###
    * Updates the hsb values for radial gradient stops
    * adds range variation to base color for each step/stop node
  ###
  set_updated_gradient: () ->
    stop_nodes = @parent_node.getElementById(@dom_id).querySelectorAll("stop")
    @range_stops = (@stops[1]-@stops[0])/(@steps);

    _inc=0
    for node in stop_nodes
      @pulse node, _inc
      _inc++

    return

  ###
  * Performs the actual calculatioon of step values
  * and their attachment to htm/svg node
  * @param {DOM element} node - <stop> node
  * @param {int} _in - node item to mofidy in order
  ###
  pulse: (node, _inc) ->
    _color = @base_color + @range_stops*_inc
    _new_color = "stop-color:hsl(#{_color},#{@s}%,#{@l}%);"
    node.setAttribute("style",_new_color)


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
