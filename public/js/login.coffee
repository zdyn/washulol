$ = jQuery
$.fn.login = ->
  login = this;
  defaults =
    loggingIn: false
  $.extend(login, {
    init: ->
      loginButton = this.find("a.button.login")
      this.on "click", "a.button.login", @authenticate
      this.on "keypress", "input", (e) =>
        @authenticate.call(loginButton) if e.which == 13
    authenticate: (e) ->
      return if login.loggingIn
      $(this).html("LOGGING IN...").css("backgroundColor", "#ec008b")
      login.loggingIn = true
      $.ajax
        type: "post"
        url: "/authenticate"
        data: Utils.getFormData(login)
        success: =>
          if login.data("url") and login.data("url").indexOf("/login") != 0
            location.href = login.data("url")
          else
            location.href = "/admin"
        error: =>
          $(this).animateButton "FAILED!", "#cc0000", 200, "LOG IN &raquo;", 1000, ->
            login.loggingIn = false
  }, defaults)
  login.init()

$ ->
  $("#login_container form").login()