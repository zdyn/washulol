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
  positionThumbnails: (thumbnails = null) ->
    for thumbnail in (thumbnails || $(".thumbnail"))
      imgHolder = $(thumbnail).find(".img")
      holderWidth = imgHolder.width()
      holderHeight = imgHolder.height()
      img = imgHolder.find("img")
      imgWidth = img.data("width") || img.width()
      imgHeight = img.data("height") || img.height()
      if imgWidth / imgHeight > holderWidth / holderHeight
        img.css(
          width: holderHeight * imgWidth / imgHeight
          height: holderHeight
        )
      else
        img.css(
          height: holderWidth * imgHeight / imgWidth
          width: holderWidth
        )
      img.css(
        top: (holderHeight - imgHeight) / 2
        left: (holderWidth - imgWidth) / 2
      )
      $(thumbnail).animate({ opacity: 1 }, 100)

$.fn.animateButton = (animateText, animateColor, animateDuration, endText, endDuration, callback) ->
  this.html(animateText).animate { backgroundColor: animateColor }, animateDuration, =>
    setTimeout =>
      $(this).html(endText).removeAttr("style")
      callback() if callback
    , endDuration

$.fn.showBrowserWarning = -> $(this).find("[class^='browserWarning']").show();

Array.prototype.remove = (start, end) ->
  rest = this.slice((end || start) + 1 || this.length);
  this.length = if start < 0 then this.length + start else start;
  return this.push.apply(this, rest);

$(window).load ->
  Utils.positionThumbnails()