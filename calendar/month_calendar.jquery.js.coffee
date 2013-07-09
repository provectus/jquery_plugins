(($) ->

   $.fn.newCalendarMonth = (method) ->
    template = '<div class="b-calendar-month">
                  <table class="b-calendar-month__header">
                    <thead>
                      <tr class="b-calendar-month__week"></tr>
                    </thead>
                  </table>
                  <div class="b-calendar-month__container">
                    <table class="b-calendar-month__month">
                      <tbody></tbody>
                    </table>
                  </div>
                </div>'
    templateHeader = '<th class="b-calendar-month__th"></th>'
    templateWeek = '<tr class="b-calendar-month__week"></tr>'
    templateDay = '<td class="b-calendar-month__day">
                    <div class="b-calendar-month__day-container">
                      <div class="b-calendar-month__day-content">
                        <div class="label"></div>
                        <ul class="b-calendar-month__events"></ul>
                      </div>
                    </div>
                   </td>'
    templateItem = '<li class="b-calendar-month__event"></li>'

    methods =
      addItem: (date, object, identifier = null)->
        if not identifier?
          identifier = (new Date().getTime()).toString() + Math.round(Math.random() * 1000).toString()
        options = @data 'options'
        $day = @find(".b-calendar-month__day[data-day='#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}']")
        if $day.size() is 0
          return
        $item = $(templateItem).appendTo $day.find '.b-calendar-month__events'
        tmpl = ''
        if options.itemTemplate?
          if $.isFunction options.itemTemplate
            tmpl = options.itemTemplate.call object
          else if $.type(options.itemTemplate) is 'string'
            tmpl = options.itemTemplate
        $item.empty().append $ tmpl
        $item.data 'id', identifier
        identifier
      removeItem: (date, identifier) ->
        $day = @find(".b-calendar-month__day[data-day='#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}']")
        $day.find('li.b-calendar-month__event').each ->
          $this = $ @
          if $this.data('id') is identifier
            $this.remove()
      clearItems: (date) ->
        $day = @find(".b-calendar-month__day[data-day='#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}']")
        $day.find('.b-calendar-month__event').empty()

    defaults =
      weekStarts: 0
      startDay: new Date()
      itemTemplate: '<b class="time"></b><div class="text"><span></span</div>'
      items: []

    params = Array.prototype.slice.call arguments, 1

    @each ->
      $this = $ @

      if method of methods
        methods[method].apply $this, params
        return @
      else if $.type(method) is 'object' or not method
        options = $.extend defaults, method
      else
        return $.error "Method #{method} does not exist on jQuery"

      $this.empty().append $ template

      $this.data 'options', options

      parse_date = (str) ->
        if not /^\d{4}\-\d{1,2}-\d{2}$/.test str
          return new Date
        splitted = str.split '-'
        new Date parseInt(splitted[0], 10), parseInt(splitted[1], 10), parseInt(splitted[2], 10)

      first_month_day = (month, year) ->
        d = new Date year, month, 1
        d.getDay()

      start_date = (month, year) ->
        first_day = first_month_day month, year
        days_in_previous = first_day - options.weekStarts
        days_in_previous = if days_in_previous < 0 then 7 + days_in_previous else days_in_previous
        new Date year, month, 1 - days_in_previous

      ((start_day)->
        start_day = start_day|0
        $head = $this.find('thead .b-calendar-month__week').empty()
        add_day = (day)->
          $(templateHeader).appendTo($head).text $.constants.daysOfWeek.full[day]
        for i in [start_day..6]
          add_day i
        if start_day isnt 0
          for i in [0..start_day-1]
            add_day i
      )(options.weekStarts)

      ((current) ->
        start_day = start_date current.getMonth(), current.getFullYear()
        day = start_day.getDate()
        month = start_day.getMonth()
        year = start_day.getFullYear()
        $table = $this.find('.b-calendar-month__month tbody').empty()
        currentWeek = null
        for i in [0..41] # six weeks
          d = new Date year, month, ~~day + i
          if d.getDay() is options.weekStarts
            currentWeek = $(templateWeek).appendTo $table
          $day = $(templateDay).appendTo currentWeek
          $day.find('.label').text d.getDate()
          if d.getMonth() isnt current.getMonth()
            $day.addClass 'other'
          $day.data 'date', d
          $day.attr 'data-day', "#{d.getFullYear()}-#{d.getMonth()}-#{d.getDate()}"
          today = new Date()
          if d.getDate() is today.getDate() and d.getMonth() is today.getMonth()
            $day.addClass 'current'
      )(options.startDay)

      $this.on 'click', '.b-calendar-month__event', (event) ->
        $target = $ event.currentTarget
        id = $target.data 'id'
        date = parse_date $target.closest('.b-calendar-month__day').attr 'data-day'
        ev = $.Event 'calendar_item_click'
        ev.targetId = id
        ev.targetDate = date
        $this.trigger ev
        false

      $this.on 'click', '.b-calendar-month__day', (event) ->
        $target = $ event.currentTarget
        date = parse_date $target.attr 'data-day'
        ev = $.Event 'calendar_day_click'
        ev.targetDate = date
        $this.trigger ev
        false

    @
)(jQuery)
