(function() {

  (function($) {
    return $.fn.datepicker = function(options) {
      var day_tmpl, days_of_week, defaults, monthes, other_month_class, template, week_tmpl;
      defaults = {
        week_starts: 1,
        _default: null
      };
      options = $.extend(defaults, options);
      template = '<div class="s-calendar" tabindex="0">\
                        <div class="s-calendar__container">\
                            <div class="s-calendar__header">\
                                <span class="month"></span>\
                                <span class="year"></span>\
                                <button class="s-calendar__btn prev" tabindex="-1"></button>\
                                <button class="s-calendar__btn next" tabindex="-1"></button>\
                            </div>\
                            <table class="s-calendar__table">\
                                <thead><tr></tr></thead>\
                                <tbody></tbody>\
                            </table>\
                        </div>\
                    </div>';
      week_tmpl = '<th></th>';
      other_month_class = 'other-month';
      day_tmpl = '<td></td>';
      days_of_week = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
      monthes = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      this.each(function() {
        var $this, current_date, disable, enable, fill_caption, fill_head, fill_month, first_month_day, format_date, format_number, get_selected, last_month_day, mark_date, navigate_month, parse_date, redraw, select_date, start_date;
        $this = $(this);
        $this.hide();
        this.datepicker = $(template);
        $this.before(this.datepicker);
        $this.data('custom_val', function(value) {
          var ret;
          if (value == null) {
            value = null;
          }
          ret = this.__old_val.apply(this, arguments);
          if (value != null) {
            redraw(parse_date(value));
          }
          return ret;
        });
        parse_date = function(str) {
          var splitted;
          if (!/^\d{4}\-\d{2}-\d{2}$/.test(str)) {
            return new Date;
          }
          splitted = str.split('-');
          return new Date(parseInt(splitted[0], 10), parseInt(splitted[1], 10) - 1, parseInt(splitted[2], 10));
        };
        format_date = function(timestamp) {
          var d;
          d = new Date(timestamp);
          return "" + (d.getFullYear()) + "-" + (format_number(d.getMonth() + 1)) + "-" + (format_number(d.getDate()));
        };
        format_number = function(number) {
          return ('00' + number.toString()).substr(-2);
        };
        first_month_day = function(month, year) {
          var d;
          d = new Date(year, month, 1);
          return d.getDay();
        };
        last_month_day = function(month, year) {
          var d;
          d = new Date(year, month + 1, -1);
          return d.getDay();
        };
        start_date = function(month, year) {
          var days_in_previous, first_day;
          first_day = first_month_day(month, year);
          days_in_previous = first_day - options.week_starts;
          days_in_previous = days_in_previous < 0 ? 7 + days_in_previous : days_in_previous;
          return new Date(year, month, 1 - days_in_previous);
        };
        fill_head = $.proxy(function(start_day) {
          var add_day, head, i, _i, _j, _ref, _results;
          head = this.datepicker.find('.s-calendar__table thead tr');
          head.empty();
          add_day = function(day) {
            return $(week_tmpl).appendTo(head).text(days_of_week[day]);
          };
          for (i = _i = start_day; start_day <= 6 ? _i <= 6 : _i >= 6; i = start_day <= 6 ? ++_i : --_i) {
            add_day(i);
          }
          _results = [];
          for (i = _j = 0, _ref = start_day - 1; 0 <= _ref ? _j <= _ref : _j >= _ref; i = 0 <= _ref ? ++_j : --_j) {
            _results.push(add_day(i));
          }
          return _results;
        }, this);
        fill_month = $.proxy(function(current) {
          var $day, current_week, d, day, i, month, start_day, table, year, _i, _results;
          start_day = start_date(current.getMonth(), current.getFullYear());
          day = start_day.getDate();
          month = start_day.getMonth();
          year = start_day.getFullYear();
          table = this.datepicker.find('.s-calendar__table tbody');
          table.empty();
          current_week = null;
          _results = [];
          for (i = _i = 0; _i <= 41; i = ++_i) {
            d = new Date(year, month, parseInt(day) + i);
            if (d.getDay() === options.week_starts) {
              current_week = $('<tr></tr>').appendTo(table);
            }
            $day = $(day_tmpl).appendTo(current_week).text(d.getDate());
            if (d.getMonth() !== current.getMonth()) {
              $day.addClass(other_month_class);
            }
            $day.data('date', d);
            if (d.getDate() === current.getDate() && d.getMonth() === current.getMonth()) {
              _results.push($day.addClass('current'));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }, this);
        fill_caption = $.proxy(function(date) {
          var month, year;
          month = monthes[date.getMonth()];
          year = date.getFullYear();
          this.datepicker.find('.s-calendar__header .year').text(year);
          return this.datepicker.find('.s-calendar__header .month').text(month);
        }, this);
        select_date = $.proxy(function(date) {
          this.datepicker.data('selected', date);
          this.value = format_date(date);
          return $(this).trigger('change');
        }, this);
        get_selected = $.proxy(function() {
          return this.datepicker.data('selected');
        }, this);
        redraw = function(date) {
          fill_month(date);
          fill_caption(date);
          return select_date(date);
        };
        navigate_month = function(new_month_func) {
          return function(event) {
            var cur, d;
            if ($(event.target).closest('.s-calendar').data('disabled')) {
              return;
            }
            cur = get_selected();
            d = new Date(cur.getFullYear(), new_month_func(cur.getMonth()), cur.getDate());
            return redraw(d);
          };
        };
        mark_date = function(element) {
          var date;
          if (element.closest('.s-calendar').data('disabled')) {
            return;
          }
          date = element.data('date');
          if (element.hasClass('other-month')) {
            return redraw(date);
          } else {
            element.removeClass('active');
            element.closest('tbody').find('td').removeClass('current');
            element.addClass('current');
            return select_date(date);
          }
        };
        disable = $.proxy(function() {
          this.datepicker.addClass('disabled');
          this.datepicker.find('.s-calendar__header .prev, .s-calendar__header .next, .s-calendar__table td').css('cursor', 'default');
          this.datepicker.data('disabled', true);
          return this.datepicker.attr('tabindex', -1);
        }, this);
        enable = $.proxy(function() {
          this.datepicker.removeClass('disabled');
          this.datepicker.find('.s-calendar__header .prev, .s-calendar__header .next, .s-calendar__table td').css('cursor', 'pointer');
          this.datepicker.data('disabled', false);
          return this.datepicker.attr('tabindex', 0);
        }, this);
        if (options._default != null) {
          current_date = parse_date(options._default);
        } else if ($this.val() !== '') {
          current_date = parse_date($this.val());
        } else {
          current_date = new Date;
        }
        fill_head(options.week_starts);
        redraw(current_date);
        if ($this.is(':disabled')) {
          disable();
        }
        $this.mutations({
          attributes: true,
          filter: ['disabled']
        });
        $this.on('attribute_changed', function(event) {
          if (!!$(event.target).prop('disabled') === true) {
            return disable();
          } else {
            return enable();
          }
        });
        this.datepicker.on('mouseenter', '.s-calendar__table tbody td', function(event) {
          var $target;
          $target = $(event.target);
          $target.closest('tbody').find('td').removeClass('active');
          return $target.addClass('active');
        });
        this.datepicker.on('mouseleave', '.s-calendar__table tbody td', function(event) {
          return $(event.target).removeClass('active');
        });
        this.datepicker.on('click', '.s-calendar__table tbody td', function(event) {
          var $target;
          $target = $(event.target);
          return mark_date($target);
        });
        this.datepicker.on('click', '.s-calendar__header .prev', navigate_month(function(m) {
          return m - 1;
        }));
        this.datepicker.on('click', '.s-calendar__header .next', navigate_month(function(m) {
          return m + 1;
        }));
        return this.datepicker.on('keydown', function(event) {
          var $target, cur_tr, d, difference, el, idx, last_day, next_td, next_tr, prev_td, prev_tr, selected_cell;
          $target = $(event.target);
          switch (event.keyCode) {
            case $.constants.keyCodes.UP:
              selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current');
              cur_tr = selected_cell.closest('tr');
              idx = cur_tr.find('td').index(selected_cell);
              prev_tr = cur_tr.prev();
              if (prev_tr.size() && prev_tr.prop('nodeName').toLowerCase() === 'tr') {
                el = prev_tr.find('td').eq(idx);
                mark_date(el);
              } else {
                d = selected_cell.data('date');
                last_day = new Date(d.getFullYear(), d.getMonth(), 0);
                difference = 7 - Math.abs(d.getDay() - last_day.getDay());
                difference = difference === 7 ? 0 : difference;
                redraw(new Date(last_day.getFullYear(), last_day.getMonth(), last_day.getDate() - difference));
              }
              return event.preventDefault();
            case $.constants.keyCodes.DOWN:
              selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current');
              cur_tr = selected_cell.closest('tr');
              idx = cur_tr.find('td').index(selected_cell);
              next_tr = cur_tr.next();
              if (next_tr.size() && next_tr.prop('nodeName').toLowerCase() === 'tr') {
                el = next_tr.find('td').eq(idx);
                mark_date(el);
              }
              return event.preventDefault();
            case $.constants.keyCodes.LEFT:
              selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current');
              prev_td = selected_cell.prev();
              if (prev_td.size() && prev_td.prop('nodeName').toLowerCase() === 'td') {
                mark_date(prev_td);
              } else {
                cur_tr = selected_cell.closest('tr');
                prev_tr = cur_tr.prev();
                if (prev_tr.size() && prev_tr.prop('nodeName').toLowerCase() === 'tr') {
                  el = prev_tr.find('td:last');
                  mark_date(el);
                } else {
                  d = selected_cell.data('date');
                  redraw(new Date(d.getFullYear(), d.getMonth(), 0));
                }
              }
              return event.preventDefault();
            case $.constants.keyCodes.RIGHT:
              selected_cell = $target.closest('.s-calendar').find('.s-calendar__table tbody td.current');
              next_td = selected_cell.next();
              if (next_td.size() && next_td.prop('nodeName').toLowerCase() === 'td') {
                mark_date(next_td);
              } else {
                cur_tr = selected_cell.closest('tr');
                next_tr = cur_tr.next();
                if (next_tr.size() && next_tr.prop('nodeName').toLowerCase() === 'tr') {
                  el = next_tr.find('td:first');
                  mark_date(el);
                }
              }
              return event.preventDefault();
            case $.constants.keyCodes.PAGEUP:
              navigate_month(function(m) {
                return m - 1;
              })(event);
              return event.preventDefault();
            case $.constants.keyCodes.PAGEDOWN:
              navigate_month(function(m) {
                return m + 1;
              })(event);
              return event.preventDefault();
          }
        });
      });
      return this;
    };
  })(jQuery);
}).call(this);
