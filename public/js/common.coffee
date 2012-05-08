$ ->
  init()

  # input element helper
  $("body").on
    focus: (e) ->
      $(this).siblings(".placeholder").addClass("focus")
    blur: (e) ->
      $(this).siblings(".placeholder").removeClass("focus")
    "propertychange keyup input paste": (e) ->
      sibling = $(this).siblings(".placeholder")
      sibling.val(if $(this).val() then "" else sibling.data("placeholder"))
  , "input:text, input:password, textarea"

init = ->
  $(i).val(if $(i).siblings().val() then "" else $(i).data("placeholder")) for i in $(".placeholder")