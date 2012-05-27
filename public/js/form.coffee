$ = jQuery
$.fn.washulolForm = ->
  sectionContainer = this;
  defaults =
    saving: false
    deleting: false
    previewing: false
    uploading: false
    files: []
  $.extend(sectionContainer, {
    init: ->
      this.on "click", "a.button.back", @back
      this.on "click", "a.button.togglePreview", @togglePreview
      this.on "click", "a.button.togglePublic", @togglePublic
      this.on "click", "a.button.save", @save
      this.on "click", "a.button.delete", @delete
      this.on "click", "a.button.uploadFiles", @uploadFiles
      this.on "change", "input:file", @uploadChange
      this.on "click", "a.removeFile", @removeFile
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
          data: Utils.getFormData(form, ":not(.files)")
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
        data: Utils.getFormData(form, ":not(.files)")
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
    uploadFiles: (e) ->
      return false if sectionContainer.uploading
      $(this).html("UPLOADING...").css("backgroundColor", "#ec008b")
      form = sectionContainer.find("form")
      sectionContainer.uploading = true
      $.ajax
        xhr: ->
          xhr = $.ajaxSettings.xhr()
          if xhr instanceof XMLHttpRequest and xhr.upload
            xhr.upload.addEventListener("progress", (e) ->
              console.log(e.loaded + " " + e.total)
            , false)
          return xhr
        type: "post"
        url: form.data("uploadAction")
        data: sectionContainer.formData || Utils.getFormData(form, ".files")
        processData: false
        contentType: false
        success: (data) =>
          $(this).animateButton "UPLOADED!", "#008000", 200, "UPLOAD", 1000, ->
            sectionContainer.uploading = false
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "UPLOAD", 1000, ->
            sectionContainer.uploading = false
    uploadChange: (e) ->
      for file in this.files
        sectionContainer.files.push(file)
      sectionContainer.updateFileList()
      $(this).val("")
    removeFile: (e) ->
      index = $(this).parent().index(".row")
      sectionContainer.files.remove(index)
      sectionContainer.updateFileList()
    updateFileList: ->
      fileList = sectionContainer.find(".fileList")
      fileList.html(if sectionContainer.files.length == 0 then "<div class='nothingHere'>Nothing here.</div>" else "")
      for file in sectionContainer.files
        fileList.append("<div class='row'><div class='rowImg'><a class='removeFile'></a></div>#{ file.name }</div>")
  }, defaults)
  sectionContainer.init()

$ ->
  $(".sectionContainer").washulolForm()
  Utils.preloadImages([
    "/icons/pencil.png",
    "/icons/check.png"
  ])