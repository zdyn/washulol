$ ->
  $(".table_nav").on "click", ".button", (e) ->
    $(this).html("...").css("backgroundColor", "#ec008b")
    $.ajax
      type: "post"
      url: "/admin/get_articles"
      data: { get_events: false, offset: 0 }
      success: (data) =>

      error: =>
        text = $(this).html()
        $(this).animateButton "!", "#cc0000", 200, text, 1000, ->
            sectionContainer.saving = false