"use strict"

$ = @jQuery

$.fn.addFloatGhost = ->
  original = $ @
  $ """<div class="fop-ghost"></div>"""
    .insertAfter original
    .hide()
    .css
      "width": original.get(0).offsetWidth
      "height": original.get(0).offsetHeight
  original.addClass "fop-active"

$.fn.removeFloatGhost = ->
  original = $ @
  original.next(".fop-ghost").remove()
  original.removeClass "fop-active"

$.fn.floatOnPage = (config) ->
  $(@).each ->
    eltConfig = $(@).data("float-config") or config
    stopAt = eltConfig.stopAt;
    minSize = eltConfig.minSize or 0;
    floatElt = $ @
    originTop = floatElt.get(0).getBoundingClientRect().top + window.scrollY
    originLeft = floatElt.get(0).getBoundingClientRect().left + window.scrollX
    eltHeight = floatElt.height()
    eltWidth = floatElt.width()

    applyPageFloat = ->
      collisionPoint = $(stopAt).get(0).getBoundingClientRect().top + window.scrollY
      docTop = window.scrollY

      shouldFloat = docTop >= originTop
      eltTop = if shouldFloat then docTop + originTop else originTop
      willCollide = docTop + eltHeight >= collisionPoint
      floating = floatElt.hasClass "fop-afloat"
      pinnedToPage = floatElt.hasClass "fop-pinned"

      if shouldFloat and !willCollide
        floatElt
          .removeClass "fop-pinned"
          .addClass "fop-afloat"
          .css
            "left": originLeft
            "top": 0
            "position": "fixed"
            "width": eltWidth
          .next(".fop-ghost").show()
      else if shouldFloat
        leftFromParent = originLeft - floatElt.offsetParent().get(0).getBoundingClientRect().left + window.scrollX
        floatElt
          .addClass "fop-pinned"
          .css
            "left": leftFromParent
            "position": "absolute"
            "top": collisionPoint - eltHeight - floatElt.offsetParent().get(0).getBoundingClientRect().top - window.scrollY
            "width": eltWidth
          .next(".fop-ghost").show()
      else if !shouldFloat and floating
        resetPageFloat()
      return

    startPageFloat = ->
      floatElt.addFloatGhost()
      originTop = floatElt.get(0).getBoundingClientRect().top + window.scrollY
      originLeft = floatElt.get(0).getBoundingClientRect().left + window.scrollX
      $(window).on "scroll", applyPageFloat
      $(window).trigger "scroll"
      return

    stopPageFloat = ->
      $(window).off "scroll", applyPageFloat
      floatElt.removeFloatGhost()
      return

    resetPageFloat = ->
      floatElt
        .removeClass "fop-afloat fop-pinned"
        .css
          "left": "auto"
          "position": "static"
          "top": "auto"
          "width": "auto"
        .next(".fop-ghost").hide()
      originTop = floatElt.get(0).getBoundingClientRect().top + window.scrollY
      originLeft = floatElt.get(0).getBoundingClientRect().left + window.scrollX
      return

    $(window).on "resize", () ->
      clearTimeout debounceResize
      debounceResize = setTimeout(( ->
        wouldFloat = $(window).width() >= minSize
        if wouldFloat and !floatElt.hasClass("fop-active")
          startPageFloat()
        else if !wouldFloat and floatElt.hasClass("fop-active")
          stopPageFloat()
        else
          resetPageFloat()
      ), 320)
      return

    $(window).trigger "resize"
    return
  return @
