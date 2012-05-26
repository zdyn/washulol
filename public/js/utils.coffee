$ = jQuery

window.Utils =
  getFormData: (form, filter = "") ->
    data = {}
    elements = form.find("input, textarea")
    elements = elements.filter(filter) if filter
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
  preloadImages: (images) ->
    $("<img />")[0].src = src for src in images
  positionThumbnails: ->
    for thumbnail in $(".thumbnail")
      imgHolder = $(thumbnail).find(".img")
      width = imgHolder.width()
      height = imgHolder.height()
      img = imgHolder.find("img")
      if img.width() / width > img.height() / height
        img.css(
          width: height * img.width() / img.height()
          height: height
        )
      else
        img.css(
          height: width * img.height() / img.width()
          width: width
        )
      img.css(
        top: (height - img.height()) / 2
        left: (width - img.width()) / 2
      )
      $(thumbnail).animate({ opacity: 1 }, 100)

$.fn.animateButton = (animateText, animateColor, animateDuration, endText, endDuration, callback) ->
  this.html(animateText).animate { backgroundColor: animateColor }, animateDuration, =>
    setTimeout =>
      $(this).html(endText).removeAttr("style")
      callback() if callback
    , endDuration

Array.prototype.remove = (start, end) ->
  rest = this.slice((end || start) + 1 || this.length);
  this.length = start < 0 ? this.length + start : start;
  return this.push.apply(this, rest);

$(window).load ->
  Utils.positionThumbnails()