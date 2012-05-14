window.Utils =
  getFormData: (form, filter = "") ->
    data = {}
    elements = form.find("input, textarea")
    elements.filter(filter) if filter
    for element in elements
      if element.name
        switch element.type
          when "checkbox"
            data[element.name] = $(element).is(":checked")
          when "radio"
            data[element.name] = $(element).val() if $(element).is(":checked")
          else
            data[element.name] = $(element).val()
    data

$ = jQuery
$.fn.animateButton = (animateText, animateColor, animateDuration, endText, endDuration, callback) ->
  this.html(animateText).animate { backgroundColor: animateColor }, animateDuration, =>
    setTimeout =>
      $(this).html(endText).removeAttr("style")
      callback()
    , endDuration