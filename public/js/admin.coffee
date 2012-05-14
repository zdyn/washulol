$ ->
  $(".table_nav").on "click", ".button", (e) ->
    return if $(this).data("requesting")
    table_nav = $(this).closest(".table_nav")
    offset = parseInt(table_nav.data("offset"), 10) + (if !$(this).prev(".button")[0] then -5 else 5)
    return if offset < 0
    text = $(this).html()
    $(this).html("...").css("backgroundColor", "#ec008b").data("requesting", true)
    $.ajax
      type: "post"
      url: "/admin/get_articles"
      data:
        type: table_nav.data("type")
        offset: offset
      success: (data) =>
        table_nav.siblings(".table_content").animate(
          left: "-=980"
        , 500, =>
          $(this).html(text).removeAttr("style").removeData("requesting")
        )
      error: =>
        $(this).animateButton "!", "#cc0000", 200, text, 1000, ->
          $(this).removeData("requesting")