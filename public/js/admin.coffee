$ ->
  $(".tableNav").on "click", ".button", (e) ->
    return if $(this).data("requesting")
    tableNav = $(this).closest(".tableNav")
    direction = if !$(this).prev(".button")[0] then -1 else 1
    offset = parseInt(tableNav.data("offset"), 10) + (direction * 5)
    return if offset < 0
    text = $(this).html()
    $(this).html("...").css("backgroundColor", "#ec008b").data("requesting", true)
    $.ajax
      type: "post"
      url: "/admin/get_articles"
      data:
        type: tableNav.data("type")
        offset: offset
      success: (data) =>
        data = JSON.parse(data)
        if data.length == 0
          $(this).html(text).removeAttr("style").removeData("requesting")
          return false
        newRows = $("<div class='tableContent'>" + $.map(data, (row, i) ->
          "<div class='row'>" +
            "<div class='rowImg'>#{ if row.public then "<img src='/icons/check_green.png' />" else "" }</div>" +
            "<a class='b' href='/admin/blog_post/#{ row.id }'>#{ if row.title != "" then row.title else "Untitled" }</a>" +
          "</div>"
        ).join("") + "</div>").css(
          position: "absolute"
          top: 0
          right: -980 * direction
          width: "100%"
        )
        container = tableNav.siblings(".tableContentContainer")
        container.find(".tableContent").css(
          position: "absolute"
          top: 0
          left: 0
          width: "100%"
        ).animate { left: -980 * direction }, 200, ->
          $(this).remove()
        container.append(newRows)
        newRows.animate { right: 0 }, 200, =>
          pageNumber = $(this).siblings(".currentPage")
          newRows.removeAttr("style")
          tableNav.data("offset", offset)
          pageNumber.html(parseInt(pageNumber.html(), 10) + direction)
          $(this).html(text).removeAttr("style").removeData("requesting")
      error: =>
        $(this).animateButton "!", "#cc0000", 200, text, 1000, ->
          $(this).removeData("requesting")