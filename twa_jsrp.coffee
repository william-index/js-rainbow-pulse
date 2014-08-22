# stores all formatted jsrp objects
jsrp_objects = []

# init
document.addEventListener "DOMContentLoaded", ->
  jsrp_objects = retrieve_all_pulse_objects()
  return

# Retrieve and format all dom elements with .jsrp into jsrp_obj_array
# RETURNs an array of formatted object for specific tag types
retrieve_all_pulse_objects = ->
  all_jsrp = document.querySelectorAll(".jsrp")
  format_jsrp jsrp_dom for jsrp_dom in all_jsrp


# preps a dom object for object creation and passes to class/constructor
# @param {DOM object} _jsrp_dom
# RETURNs a formatted jsrp type object
format_jsrp = (_jsrp_dom) ->
  parent_tag = _jsrp_dom.parentNode.tagName
  parent_node = _jsrp_dom.parentNode

  if parent_tag == "g"
    parent_node = _jsrp_dom.parentNode.parentNode

  if parent_node.tagName == "svg"
    new jsrp_svg _jsrp_dom,parent_node
  else

# @TODO main loop for rainbow pulsing

# class structure for jsrp object for an SVG element
# @TODO constructor
# @TODO object type
# @TODO color range type
# @TODO update color method
class jsrp_svg
  constructor: (@jsrp_dom, @parent_node) ->
    @parse_color()
  advance_color: () ->
    log "increment"
    return
  parse_color: () ->
    log "parse call"
    return



# Shorthand log to console
# @param {String} _statement - string to log
log = (_statement) ->
  console.log _statement
