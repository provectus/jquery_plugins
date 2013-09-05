(($) ->
  $.fn.datepicker = (options) ->
    defaults =
      week_starts: 0
      access_past: true
      _default: null
    options = $.extend defaults, options

    template = '<div class="s-calendar" tabindex="0">
                            <div class="s-calendar__container">
                                <div class="s-calendar__header">
                                    <span class="month"></span>
                                    <span class="year"></span>
                                    <button class="s-calendar__btn prev" tabindex="-1"></button>
                                    <button class="s-calendar__btn next" tabindex="-1"></button>
                                </div>
                                <table class="s-calendar__table">
                                    <thead><tr></tr></thead>
                                    <tbody></tbody>
                                </table>
                            </div>
                        </div>'

    week_tmpl = '<th></th>'
    other_month_class = 'other-month'
    day_tmpl = '<td></td>'
    days_of_week = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
    monthes = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
               'November', 'December']

    @.each(() ->
      $this = $ @
      $this.hide()

      @.datepicker = $ template
      $this.before @.datepicker

      $this.data 'custom_val', (value = null) ->
        ret = @__old_val.apply @, arguments
        if value?
          redraw parse_date value
        ret

      parse_date = (str) ->
        if not /^\d{4}\-\d{2}-\d{2}$/.test str
          return new Date
        splitted = str.split '-'
        new Date parseInt(splitted[0], 10), parseInt(splitted[1], 10) - 1, parseInt(splitted[2], 10)

      format_date = (timestamp) ->
        d = new Date timestamp
        "#{d.getFullYear()}-#{format_number d.getMonth() + 1}-#{format_number d.getDate()}"

      format_number = (number) ->
        ('00' + number.toString()).substr -2

      first_month_day = (month, year) ->
        d = new Date year, month, 1
        d.getDay()

      start_date = (month, year) ->
        first_day = first_month_day month, year
        days_in_previous = first_day - options.week_starts
        days_in_previous = if days_in_previous < 0 then 7 + days_in_previous else days_in_previous
        new Date year, month, 1 - days_in_previous

      fill_head = (start_day) =>
        head = @datepicker.find '.s-calendar__table thead tr'
        head.empty()
        add_day = (day) ->
          $(week_tmpl).appendTo(head).text days_of_week[day]
        for i in [start_day..6]
          add_day i
        if start_day isnt 0
          for i in [0..start_day - 1]
            add_day i

      fill_month = (current) =>
        start_day = start_date current.getMonth(), current.getFullYear()
        day = start_day.getDate()
        month = start_day.getMonth()
        year = start_day.getFullYear()
        table = @datepicker.find '.s-calendar__table tbody'
        table.empty()
        current_week = null
        today = new Date().getTime() - 3600 * 24 * 1000
        for i in [0..41] # six weeks
          d = new Date year, month, parseInt(day) + i
          if d.getDay() is options.week_starts
            current_week = $('<tr></tr>').appendTo(table)
          $day = $(day_tmpl).appendTo(current_week).text d.getDate()
          if d.getMonth() isnt current.getMonth()
            $day.addClass other_month_class
          if today > d.getTime() and not options.access_past
            $day.addClass other_month_class + ' disabled'
          $day.data 'date', d
          if d.getDate() is current.getDate() and d.getMonth() is current.getMonth()
            $day.addClass 'current'

      fill_caption = (date) =>
        month = monthes[date.getMonth()]
        year = date.getFullYear()
        @datepicker.find('.s-calendar__header .year').text year
        @datepicker.find('.s-calendar__header .month').text month

      select_date = (date, silent = false) =>
        @datepicker.data 'selected', date
        @value = format_date date
        if silent is off
          $this.trigger 'change'

      get_selected = =>
        @datepicker.data 'selected'

      redraw = (date, silent = false) ->
        fill_month date
        fill_caption date
        select_date date, silent

      navigate_month = (new_month_func) ->
        (event) ->
          if $(event.target).closest('.s-calendar').data 'disabled'
            return false
          cur = get_selected()
          d = new Date cur.getFullYear(), new_month_func(cur.getMonth()), cur.getDate()
          redraw d, true
          false

      mark_date = (element) ->
        if element.closest('.s-calendar').data 'disabled'
          return
        date = element.data 'date'
        if element.hasClass 'other-month'
          redraw date
        else
          element.removeClass 'active'
          element.closest('tbody').find('td').removeClass 'current'
          element.addClass 'current'
          select_date date

      disable = =>
        @datepicker.addClass 'disabled'
        @datepicker.find('.s-calendar__header .prev, .s-calendar__header .next, .s-calendar__table td').css('cursor', 'default')
        @datepicker.data 'disabled', on
        @datepicker.attr 'tabindex', -1

      enable = =>
        @datepicker.removeClass 'disabled'
        @datepicker.find('.s-calendar__header .prev, .s-calendar__header .next, .s-calendar__table td').css('cursor', 'pointer')
        @datepicker.data 'disabled', off
        @datepicker.attr 'tabindex', 0

      if options._default?
        current_date = parse_date options._default
      else if $this.val() isnt ''
        current_date = parse_date $this.val()
      else
        current_date = new Date

      fill_head options.week_starts
      redraw current_date

      if $this.is ':disabled'
        disable()

      $this.mutations
        attributes: on
        filter: ['disabled']

      $this.on 'attribute_changed', (event) ->
        if !!$(event.target).prop('disabled') is on
          disable()
        else
          enable()

      @datepicker.on 'mouseenter', '.s-calendar__table tbody td', (event) ->
        $target = $ event.target
        $target.closest('tbody').find('td').removeClass 'active'
        unless $target.hasClass 'disabled'
          $target.addClass 'active'

      @datepicker.on 'mouseleave', '.s-calendar__table tbody td', (event) ->
        $(event.target).removeClass 'active'

      @datepicker.on 'click', '.s-calendar__table tbody td', (event) ->
        $target = $(event.target)
        unless $target.hasClass 'disabled'
          mark_date $target

      @datepicker.on 'click', '.s-calendar__header .prev', navigate_month((m) -> m - 1)

      @datepicker.on 'click', '.s-calendar__header .next', navigate_month((m) -> m + 1)

      @datepicker.on('keydown', (event) ->
        $target = $ event.target
        switch event.keyCode
          when $.constants.keyCodes.UP
            selected_cell = $target.closest('.s-calendar').find '.s-calendar__table tbody td.current'
            cur_tr = selected_cell.closest 'tr'
            idx = cur_tr.find('td').index selected_cell
            prev_tr = cur_tr.prev()
            if prev_tr.size() and prev_tr.prop('nodeName').toLowerCase() is 'tr'
              el = prev_tr.find('td').eq idx
              mark_date el
            else
              d = selected_cell.data 'date'
              last_day = new Date d.getFullYear(), d.getMonth(), 0
              difference = 7 - Math.abs(d.getDay() - last_day.getDay())
              difference = if difference is 7 then 0 else difference
              redraw(new Date last_day.getFullYear(), last_day.getMonth(), last_day.getDate() - difference)
            event.preventDefault()
          when $.constants.keyCodes.DOWN
            selected_cell = $target.closest('.s-calendar').find '.s-calendar__table tbody td.current'
            cur_tr = selected_cell.closest('tr')
            idx = cur_tr.find('td').index selected_cell
            next_tr = cur_tr.next()
            if next_tr.size() and next_tr.prop('nodeName').toLowerCase() is 'tr'
              el = next_tr.find('td').eq idx
              mark_date el
            event.preventDefault()
          when $.constants.keyCodes.LEFT
            selected_cell = $target.closest('.s-calendar').find '.s-calendar__table tbody td.current'
            prev_td = selected_cell.prev()
            if prev_td.size() and prev_td.prop('nodeName').toLowerCase() is 'td'
              mark_date prev_td
            else
              cur_tr = selected_cell.closest 'tr'
              prev_tr = cur_tr.prev()
              if prev_tr.size() and prev_tr.prop('nodeName').toLowerCase() is 'tr'
                el = prev_tr.find 'td:last'
                mark_date el
              else
                d = selected_cell.data 'date'
                redraw new Date d.getFullYear(), d.getMonth(), 0
            event.preventDefault()
          when $.constants.keyCodes.RIGHT
            selected_cell = $target.closest('.s-calendar').find '.s-calendar__table tbody td.current'
            next_td = selected_cell.next()
            if next_td.size() and next_td.prop('nodeName').toLowerCase() is 'td'
              mark_date next_td
            else
              cur_tr = selected_cell.closest 'tr'
              next_tr = cur_tr.next()
              if next_tr.size() and next_tr.prop('nodeName').toLowerCase() is 'tr'
                el = next_tr.find('td:first')
                mark_date el
            event.preventDefault()
          when $.constants.keyCodes.PAGEUP
            navigate_month((m) -> m - 1) event
            event.preventDefault()
          when $.constants.keyCodes.PAGEDOWN
            navigate_month((m) -> m + 1) event
            event.preventDefault()
          else
            true
      )
    )
    @)(jQuery)