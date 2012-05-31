$ = jQuery
$.fn.washulolForm = (options) ->
  formContainer = this;
  defaults =
    saving: false
    deleting: false
    previewing: false
    uploading: false
    files: []
  $.extend(formContainer, {
    init: ->
      # main form buttons
      this.on "click", "a.button.back", (e) -> location.href = "/admin"
      this.on "click", "a.button.togglePreview", @togglePreview
      this.on "click", "a.button.togglePublic", @togglePublic
      this.on "click", "a.button.save", @save
      this.on "click", "a.button.delete", @delete
      # upload form buttons
      if this.uploadForm[0]
        this.on "click", "a.button.uploadFiles", @uploadFiles
        this.on "change", "input:file", @uploadChange
        this.on "click", "a.removeFile", @removeFile
        this.find(".uploadList").showBrowserWarning() unless window.FormData
      # file order form buttons
    togglePreview: (e) ->
      return if formContainer.previewing
      formSections = formContainer.find(".formSection")
      articleSection = formContainer.find(".articleSection")
      if articleSection[0]
        $(this).html("PREVIEW")
        formSections.show()
        articleSection.remove()
      else
        $(this).html("LOADING...").css("backgroundColor", "#ec008b")
        formContainer.previewing = true
        $.ajax
          type: "post"
          url: formContainer.form.data("previewAction")
          data: Utils.getFormData(formContainer.form, ":not(.files)")
          success: (html) =>
            html = $("<div class='sectionContainer articleSection'>#{ html }</div>")
            formContainer.previewing = false
            formContainer.prepend(html)
            formSections.hide()
            $(this).html("EDIT").removeAttr("style")
          error: =>
            $(this).animateButton "ERROR!", "#cc0000", 200, "PREVIEW", 1000, ->
              formContainer.previewing = false
    togglePublic: (e) ->
      $(this).toggleClass("red green")
      $(this).find("img").attr("src",
          if $(this).hasClass("red") then "/icons/pencil.png" else "/icons/check.png")
      $(this).find("span").html(if $(this).hasClass("red") then "DRAFT" else "PUBLIC")
      formContainer.find("input[name=public]").attr("checked", not $(this).hasClass("red"))
    save: (e) ->
      return false if formContainer.saving
      $(this).html("SAVING...").css("backgroundColor", "#ec008b")
      formContainer.saving = true
      $.ajax
        type: "post"
        url: formContainer.form.attr("action")
        data: Utils.getFormData(formContainer.form, ":not(.files)")
        success: (data) =>
          data = JSON.parse(data)
          history.replaceState(null, null, data["url"])
          formContainer.form.find("input[name=id]").val(data["id"])
          $(this).animateButton "SAVED!", "#008000", 200, "SAVE", 1000, ->
            formContainer.saving = false
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "SAVE", 1000, ->
            formContainer.saving = false
    delete: (e) ->
      return false if formContainer.deleting
      return false if not formContainer.form.find("input[name=id]").val()
      formContainer.deleting = true
      $.ajax
        type: "post"
        url: formContainer.form.data("deleteAction")
        data: { id: parseInt(formContainer.form.find("input[name=id]").val(), 10) }
        success: =>
          location.href = "/admin"
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "DELETE", 1000, ->
            formContainer.deleting = false
    uploadFiles: (e) ->
      return false if formContainer.uploading || !formContainer.files.length
      $(this).html("UPLOADING...").css("backgroundColor", "#ec008b")
      formContainer.uploading = true
      formData = new FormData()
      formData.append("files[]", file) for file in formContainer.files
      formData.append("id", formContainer.form.find("input[name=id]").val())
      $.ajax
        xhr: ->
          xhr = $.ajaxSettings.xhr()
          if xhr instanceof XMLHttpRequest and xhr.upload
            xhr.upload.addEventListener("progress", (e) ->
              console.log(e.loaded + " " + e.total)
              # add upload progress here
            , false)
          return xhr
        type: "post"
        url: formContainer.uploadForm.attr("action")
        data: formData
        processData: false
        contentType: false
        success: (data) =>
          data = JSON.parse(data)
          html = []
          for thumb in data
            html = html.concat(["<div class='imgBorder thumbnail'>",
                                  "<div class='img'>",
                                    "<img data-width='#{ thumb.width }' data-height='#{ thumb.height }' src='/albums/#{ thumb.filename }' />",
                                  "</div>",
                                "</div>"])
          html = $(html.join(""))
          formContainer.find(".photosPreview .content").html("").append(html)
          Utils.positionThumbnails(html)
          $(this).animateButton "UPLOADED!", "#008000", 200, "UPLOAD", 1000, ->
            formContainer.uploading = false
        error: =>
          $(this).animateButton "ERROR!", "#cc0000", 200, "UPLOAD", 1000, ->
            formContainer.uploading = false
    uploadChange: (e) ->
      for file in this.files
        formContainer.files.push(file)
      formContainer.updateFileList()
      $(this).val("")
    removeFile: (e) ->
      index = $(this).closest(".row").index(".row")
      formContainer.files.remove(index)
      formContainer.updateFileList()
    updateFileList: ->
      fileList = formContainer.find(".fileList")
      if !formContainer.files.length
        fileList.html("<div class='nothingHere'>Nothing here.</div>")
        formContainer.find("a.button.addFiles span").html("SELECT")
      else
        fileList.html("")
        formContainer.find("a.button.addFiles span").html("ADD MORE")
      for file in formContainer.files
        fileList.append("<div class='row'><div class='rowImg'><a class='removeFile'></a></div>#{ file.name }</div>")
  }, defaults, options)
  formContainer.init()

$ ->
  $("#form").washulolForm({
    form: $("#main"),
    uploadForm: $("#upload"),
    fileOrder: $("#fileOrder")
  })
  Utils.preloadImages([
    "/icons/pencil.png",
    "/icons/check.png"
  ])