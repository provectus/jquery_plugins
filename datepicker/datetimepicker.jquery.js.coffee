(($) ->
    $.fn.datetimepicker = (options) ->
        defaults =
            week_starts: 1
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
                        <div class="s-calendar__time">
                            <div class="s-calendar__title">HOURS</div>
                            <div class="s-calendar__hours s-calendar__group">
                                <div class="s-calendar__row">
                                    <button>1</button>
                                    <button>2</button>
                                    <button>3</button>
                                    <button>4</button>
                                </div>
                                <div class="s-calendar__row">
                                    <button>5</button>
                                    <button>6</button>
                                    <button>7</button>
                                    <button>8</button>
                                </div>
                                <div class="s-calendar__row">
                                    <button>9</button>
                                    <button>10</button>
                                    <button>11</button>
                                    <button>12</button>
                                </div>
                            </div>

                            <hr class="s-calendar__hr"/>
                            <div class="s-calendar__title">AM/PM</div>
                            <div class="s-calendar__row s-calendar__ampm s-calendar__group">
                                <button>AM</button>
                                <button>PM</button>
                            </div>

                            <hr class="s-calendar__hr"/>
                            <div class="s-calendar__title">MINUTES</div>
                            <div class="s-calendar__row s-calendar__min s-calendar__group">
                                <button>0</button>
                                <button>15</button>
                                <button>30</button>
                                <button>45</button>
                            </div>
                            <hr class="s-calendar__hr"/>
                            <div class="s-calendar__row">
                                <button class="s-calendar__close">Set</button>
                            </div>
                        </div>
                    </div>'

        week_tmpl = '<th></th>'
        other_month_class = 'other-month'
        day_tmpl = '<td></td>'
        days_of_week = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
        monthes = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

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
                if not /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$/.test str
                    return new Date
                splitted = str.split ' '

                date = splitted[0].split '-'
                time = splitted[1].split ':'
                time[0] = parseInt(time[0])

                new Date parseInt(date[0], 10), parseInt(date[1], 10) - 1, parseInt(date[2], 10), parseInt(time[0], 10), parseInt(time[1], 10)

            format_date = (timestamp) ->
                d = new Date timestamp
                t = formatAMPM d
                "#{d.getFullYear()}-#{format_number d.getMonth() + 1}-#{format_number d.getDate()} #{t.hours24}:#{t.minutes}"

            format_number = (number) ->
                ('00' + number.toString()).substr -2

            formatAMPM = (date) ->
                hours = date.getHours()
                ampm = if hours >= 12 then 'pm' else 'am'
                hours = hours % 12
                hours = 12 unless hours

                hours: format_number hours
                hours24: format_number date.getHours()
                minutes: format_number date.getMinutes()
                ampm: ampm

            first_month_day = (month, year) ->
                d = new Date year, month, 1
                d.getDay()

            start_date = (month, year) ->
                first_day = first_month_day month, year
                days_in_previous = first_day - options.week_starts
                days_in_previous = if days_in_previous < 0 then 7 + days_in_previous else days_in_previous
                new Date year, month, 1 - days_in_previous

            fill_head = (start_day) =>
                head = @datepicker.find('.s-calendar__table thead tr')
                head.empty()
                add_day = (day) ->
                    $(week_tmpl).appendTo(head).text days_of_week[day]
                for i in [start_day..6]
                    add_day i
                for i in [0..start_day-1]
                    add_day i

            fill_month = (current) =>
                start_day = start_date current.getMonth(), current.getFullYear()
                day = start_day.getDate()
                month = start_day.getMonth()
                year = start_day.getFullYear()
                table = @datepicker.find('.s-calendar__table tbody')
                table.empty()
                current_week = null
                for i in [0..41] # six weeks
                    d = new Date year, month, parseInt(day) + i
                    if d.getDay() is options.week_starts
                        current_week = $('<tr></tr>').appendTo(table)
                    $day = $(day_tmpl).appendTo(current_week).text(d.getDate())
                    if d.getMonth() isnt current.getMonth()
                        $day.addClass other_month_class
                    $day.data 'date', d
                    if d.getDate() is current.getDate() and d.getMonth() is current.getMonth()
                        $day.addClass 'current'

            fill_time = (current) =>
                t = formatAMPM current
                hours_index = parseInt(t.hours) - 1
                minutes_index = Math.round(parseInt(t.minutes)/15)
                if minutes_index is 4
                    hours_index += 1
                    minutes_index = 3
                @datepicker.find(".s-calendar__time button").removeClass 'active'
                @datepicker.find(".s-calendar__hours button:eq(#{hours_index})").addClass 'active'
                @datepicker.find(".s-calendar__min button:eq(#{minutes_index})").addClass 'active'
                @datepicker.find(".s-calendar__ampm button:contains('#{t.ampm.toUpperCase()}')").addClass 'active'

            fill_caption = (date) =>
                month = monthes[date.getMonth()]
                year = date.getFullYear()
                @datepicker.find('.s-calendar__header .year').text year
                @datepicker.find('.s-calendar__header .month').text month

            select_date = (date, silent = false) =>
                minutes = parseInt @datepicker.find(".s-calendar__min .active").text()
                hours = parseInt @datepicker.find(".s-calendar__hours .active").text()
                ampm = @datepicker.find(".s-calendar__ampm .active").text()

                hours += 12 if ampm is "PM"
                hours = 0 if hours is 24

                date.setMinutes(minutes)
                date.setHours(hours)
                @datepicker.data 'selected', date
                console.log date, format_date date
                @value = format_date date
                console.log @value, $(@).val()
                if silent is off
                  $this.trigger('change')

            get_selected = =>
                @datepicker.data 'selected'

            redraw = (date, silent = false) ->
                fill_month date
                fill_caption date
                fill_time date
                select_date date, silent

            navigate_month = (new_month_func) ->
                (event) ->
                    if $(event.target).closest('.s-calendar').data 'disabled'
                        return false
                    cur = get_selected()
                    d = new Date cur.getFullYear(), new_month_func(cur.getMonth()), cur.getDate()
                    redraw d, true
                    false

            mark_date = (element) =>
                if element.closest('.s-calendar').data 'disabled'
                    return
                date = element.data 'date'

                if element.hasClass 'other-month'
                    redraw date
                else
                    element.removeClass 'active'
                    element.closest('tbody').find('td').removeClass 'current'
                    element.addClass 'current'
                    select_date date, on

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

            if options.hide_date
              @datepicker.find(".s-calendar__container").hide()

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
                $target = $(event.target)
                $target.closest('tbody').find('td').removeClass 'active'
                $target.addClass 'active'

            @datepicker.on 'mouseleave', '.s-calendar__table tbody td', (event) ->
                $(event.target).removeClass 'active'

            @datepicker.on 'click', '.s-calendar__table tbody td', (event) ->
                $target = $(event.target)
                mark_date $target

            @datepicker.on 'click', '.s-calendar__header .prev', navigate_month((m) -> m - 1)

            @datepicker.on 'click', '.s-calendar__header .next', navigate_month((m) -> m + 1)

            @datepicker.on 'click', '.s-calendar__time button:not(.s-calendar__close)', (event) =>
                $target = $ event.target
                if $(event.target).closest('.s-calendar').data 'disabled'
                    return false
                $target.closest('.s-calendar__group').find('button').removeClass 'active'
                $target.addClass 'active'
                select_date @datepicker.data('selected'), on

            @datepicker.on 'click', '.s-calendar__close', =>
                select_date @datepicker.data('selected')

            @datepicker.on('keydown', (event) ->
                $target = $(event.target)
                switch event.keyCode
                    when $.constants.keyCodes.UP
                        selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current')
                        cur_tr = selected_cell.closest('tr')
                        idx = cur_tr.find('td').index selected_cell
                        prev_tr = cur_tr.prev()
                        if prev_tr.size() and prev_tr.prop('nodeName').toLowerCase() is 'tr'
                            el = prev_tr.find('td').eq(idx)
                            mark_date el
                        else
                            d = selected_cell.data 'date'
                            last_day = new Date d.getFullYear(), d.getMonth(), 0
                            difference = 7 - Math.abs(d.getDay() - last_day.getDay())
                            difference = if difference is 7 then 0 else difference
                            redraw(new Date last_day.getFullYear(), last_day.getMonth(), last_day.getDate() - difference)
                        event.preventDefault()
                    when $.constants.keyCodes.DOWN
                        selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current')
                        cur_tr = selected_cell.closest('tr')
                        idx = cur_tr.find('td').index selected_cell
                        next_tr = cur_tr.next()
                        if next_tr.size() and next_tr.prop('nodeName').toLowerCase() is 'tr'
                            el = next_tr.find('td').eq(idx)
                            mark_date el
                        event.preventDefault()
                    when $.constants.keyCodes.LEFT
                        selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current')
                        prev_td = selected_cell.prev()
                        if prev_td.size() and prev_td.prop('nodeName').toLowerCase() is 'td'
                            mark_date prev_td
                        else
                            cur_tr = selected_cell.closest('tr')
                            prev_tr = cur_tr.prev()
                            if prev_tr.size() and prev_tr.prop('nodeName').toLowerCase() is 'tr'
                                el = prev_tr.find('td:last')
                                mark_date el
                            else
                                d = selected_cell.data 'date'
                                redraw new Date d.getFullYear(), d.getMonth(), 0
                        event.preventDefault()
                    when $.constants.keyCodes.RIGHT
                        selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current')
                        next_td = selected_cell.next()
                        if next_td.size() and next_td.prop('nodeName').toLowerCase() is 'td'
                            mark_date next_td
                        else
                            cur_tr = selected_cell.closest('tr')
                            next_tr = cur_tr.next()
                            if next_tr.size() and next_tr.prop('nodeName').toLowerCase() is 'tr'
                                el = next_tr.find('td:first')
                                mark_date el
                        event.preventDefault()
                    when $.constants.keyCodes.PAGEUP
                        navigate_month((m) -> m - 1)(event)
                        event.preventDefault()
                    when $.constants.keyCodes.PAGEDOWN
                        navigate_month((m) -> m + 1)(event)
                        event.preventDefault()
                    else
                      true
            )
        )
        @
)(jQuery)