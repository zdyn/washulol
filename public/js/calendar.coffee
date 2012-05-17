do ->
  $ = jQuery
  current_date = new Date()
  defaults =
    year: current_date.getFullYear()
    month: current_date.getMonth()
    date: current_date.getDate()
    selectedDate: null

  $.fn.calendar = (options) ->
    if(this.length > 1)
      return ($(element).calendar(options) for element in this)
    $.extend(this, {
      init: ->
        return
    }, defaults, options)
    this.init()