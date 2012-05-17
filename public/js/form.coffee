$ = jQuery
$.fn.washulolForm = ->
  sectionContainer = this;
  defaults =
    saving: false
    deleting: false
    previewing: false
  $.extend(sectionContainer, {
    init: ->
      this.on "click", "a.button.back", @back
      this.on "click", "a.button.togglePreview", @togglePreview
      this.on "click", "a.button.togglePublic", @togglePublic
      this.on "click", "a.button.save", @save
      this.on "click", "a.button.delete", @delete
      this.on "click", "a.button.addPhotos", @addPhotos
      this.on "click", "a.button.uploadPhotos", @uploadPhotos
    back: (e) ->
      location.href = "/admin"
    togglePreview: (e) ->
      return if sectionContainer.previewing
      section = sectionContainer.find(".section")
      article = section.siblings(".article")
      if article[0]
        $(this).html("PREVIEW")
        section.show()
        article.remove()
      else
        form = sectionContainer.find("form")
        sectionContainer.previewing = true
        $.ajax
          type: "post"
          url: form.data("previewAction")
          data: Utils.getFormData(form)
          success: (html) =>
            sectionContainer.previewing = false
            sectionContainer.prepend($(html).css("border", "none")).find(".section").hide()
            $(this).html("EDIT")
          error: =>
            $(this).animateButton "ERROR!", "#cc0000", 200, "PREVIEW", 1000, ->
              sectionContainer.previewing = false
    togglePublic: (e) ->
      $(this).toggleClass("red green")
      $(this).find("img").attr("src",
          if $(this).hasClass("red") then "/icons/pencil.png" else "/icons/check.png")
      $(this).find("span").html(if $(this).hasClass("red") then "DRAFT" else "PUBLIC")
      sectionContainer.find("input[name=public]").attr("checked", not $(this).hasClass("red"))
    save: (e) ->
      return false if sectionContainer.saving
      form = sectionContainer.find("form")
      $(this).html("SAVING...").css("backgroundColor", "#ec008b")
      sectionContainer.saving = true
      $.ajax
        type: "post"
        url: form.attr("action")
        data: Utils.getFormData(form)
        success: (data) =>
          data = JSON.parse(data)
          history.replaceState(null, null, data["url"])
          form.find("input[name=id]").val(data["id"])
          $(this).animateButton "SAVED!", "#008000", 200, "SAVE", 1000, ->
            sectionContainer.saving = false
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "SAVE", 1000, ->
            sectionContainer.saving = false
    delete: (e) ->
      return false if sectionContainer.deleting
      form = sectionContainer.find("form")
      return false if not form.find("input[name=id]").val()
      sectionContainer.deleting = true
      $.ajax
        type: "post"
        url: form.data("deleteAction")
        data: { id: parseInt(form.find("input[name=id]").val(), 10) }
        success: =>
          location.href = "/admin"
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "DELETE", 1000, ->
            sectionContainer.deleting = false
    addPhotos: (e) ->
      return
    uploadPhotos: (e) ->
      $(this).html("UPLOADING...").css("backgroundColor", "#ec008b")
      setTimeout(=>
        $(this).animateButton "UPLOADED!", "#008000", 200, "UPLOAD", 1000
      , 2000)
  }, defaults)
  sectionContainer.init()

$ ->
  $(".sectionContainer").washulolForm()
  Utils.preloadImages([
    "/icons/pencil.png",
    "/icons/check.png"
  ])