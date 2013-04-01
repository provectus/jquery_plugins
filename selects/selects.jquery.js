(function() {

  (function($) {
    return $.fn.selects = (function(options) {
      var defaults, group_tmpl, item_tmpl, selected_item, tabindex, template;
      defaults = {
        input: false
      };
      options = $.extend(defaults, options);
      selected_item = options.input === true ? '<input type="text" />' : "<div class='s-select__item'></div>";
      tabindex = "tabindex='0'";
      template = "<div class='s-select' " + tabindex + ">                    <div class='s-select__current'>                        " + selected_item + "                        <button class='s-select__toggler' tabindex='-1'>                            <span class='s-select__icon'></span>                        </button>                    </div>                    <ul class='s-select__submenu'>                    </ul>                </div>";
      item_tmpl = '<li class="s-select__item"></li>';
      group_tmpl = '<li class="s-select__group">Pacific American</li>';
      $(document).on('click', function(event) {
        if (!$(event.target).closest('.s-select').length) {
          return $('.s-select.active').removeClass('active');
        }
      });
      return this.each(function() {
        var $select_list, $selected, $this, add_group, add_item, fill_select, item_counter, keydown_handler, next, open_list, prev, set_selected, shift_list;
        $this = $(this);
        $this.hide();
        this.select = $(template);
        $this.before(this.select);
        this.select.get(0).className = this.className;
        $select_list = this.select.find('.s-select__submenu');
        $selected = options.input === true ? this.select.find('input') : this.select.find('div.s-select__item');
        item_counter = 0;
        $this.data('custom_val', function(value) {
          var ret;
          if (value == null) {
            value = null;
          }
          ret = this.__old_val.apply(this, arguments);
          if (value != null) {
            set_selected(this.find('option:selected'), false, true);
          }
          if (options.input === true) {
            ret = $selected.val();
          }
          return ret;
        });
        add_item = function(item_el) {
          return $(item_tmpl).appendTo($select_list).addClass((item_el.attr('data-placeholder') ? 'placeholder hidden' : '')).data('idx', item_counter++).data('value', item_el.attr('value')).html(item_el.html());
        };
        add_group = function(group_el) {
          $(group_tmpl).appendTo($select_list).html(group_el.attr('label'));
          return group_el.children().each(function() {
            return add_item($(this));
          });
        };
        set_selected = $.proxy(function(item_el, silent, already_selected) {
          var e, option, selected_index;
          if (silent == null) {
            silent = false;
          }
          if (already_selected == null) {
            already_selected = false;
          }
          if (item_el.is('li.s-select__item')) {
            selected_index = item_el.data('idx');
          } else {
            selected_index = $this.find('option').index(item_el);
          }
          this.select.data('selected', selected_index);
          this.select.find('.s-select__item.active').removeClass('active');
          this.select.find('li.s-select__item').eq(selected_index).addClass('active');
          if (options.input === true) {
            $selected.val(item_el.text());
          } else {
            $selected.html(item_el.html());
          }
          if (item_el.hasClass('placeholder') || item_el.attr('data-placeholder')) {
            $selected.addClass('placeholder');
          } else {
            $selected.removeClass('placeholder');
          }
          if (!already_selected) {
            option = $this.find('option').eq(selected_index | 0);
            $this.val(option.val());
          }
          if (!silent) {
            e = $.Event('change');
            e.internal = true;
            return $this.trigger(e);
          }
        }, this);
        next = function(idx) {
          var items, _idx;
          items = $select_list.find('li.s-select__item');
          _idx = Math.min(idx + 1, items.length - 1);
          return $(items[_idx]);
        };
        prev = function(idx) {
          var items, _idx;
          items = $select_list.find('li.s-select__item');
          _idx = Math.max(0, idx - 1);
          return $(items[_idx]);
        };
        open_list = $.proxy(function() {
          if (!this.select.data('disabled')) {
            this.select.addClass('active');
            return shift_list();
          }
        }, this);
        shift_list = function(direction) {
          var $active_item, top;
          $active_item = $select_list.find('.s-select__item.active');
          top = $active_item.position().top;
          if (top > ($select_list.height() - $active_item.height()) || top < 0) {
            if (direction === 'down') {
              top = $active_item.height() - $select_list.height() + $select_list.scrollTop() + $active_item.position().top;
            } else if (direction === 'up') {
              top = $select_list.scrollTop() + $active_item.position().top;
            }
            return $select_list.animate({
              scrollTop: top
            }, 'fast');
          }
        };
        fill_select = $.proxy(function() {
          var placeholder, selected;
          $select_list.empty();
          placeholder = $this.attr('placeholder');
          if (placeholder != undefined && placeholder != null && placeholder !== '') {
            if (options.input === true) {
              this.select.find('input').attr('placeholder', placeholder);
            } else {
              selected = $this.find('option[selected]').size() ? '' : "selected='selected'";
              $this.children().first().before($("<option data-placeholder='true' " + selected + " value=''>" + placeholder + "</option>"));
            }
          }
          $this.children().each(function() {
            var nodename;
            nodename = $(this).prop('nodeName').toLowerCase();
            switch (nodename) {
              case 'option':
                return add_item($(this));
              case 'optgroup':
                return add_group($(this));
            }
          });
          return set_selected($this.find(':selected'));
        }, this);
        fill_select();
        if ($this.prop('disabled') === true) {
          this.select.addClass('disabled');
        }
        this.select.data('disabled', $this.prop('disabled'));
        $this.mutations({
          children: true,
          subtree: true,
          attributes: true,
          filter: ['disabled']
        });
        $this.on('attribute_changed', $.proxy(function(event) {
          var disabled;
          disabled = !!$(event.target).attr(event.attribute);
          this.select.data('disabled', disabled);
          if (event.attribute === 'disabled') {
            if (disabled) {
              return this.select.addClass('disabled');
            } else {
              return this.select.removeClass('disabled', this);
            }
          }
        }));
        $this.on('child_added', $.proxy(fill_select, this));
        $this.on('child_removed', $.proxy(fill_select, this));
        $this.on('change', function(event) {
          if (!event.internal) {
            return set_selected($(event.target).find('option:selected'), true);
          }
        });
        this.select.on('click', '.s-select__current', function(event) {
          var select;
          select = $(event.target).closest('.s-select');
          if (select.hasClass('active')) {
            select.removeClass('active');
          } else {
            open_list();
          }
          return event.preventDefault();
        });
        this.select.on('click', 'li.s-select__item', function(event) {
          event.preventDefault();
          set_selected($(event.target), true);
          return $(event.target).closest('.s-select').removeClass('active');
        });
        this.select.on('click', '.s-select__toggler', function(event) {
          return event.preventDefault();
        });
        this.select.on('blur', function(event) {
          return $(event.target).removeClass('active');
        });
        keydown_handler = function(event) {
          var active, next_item, prev_item, select, select_list;
          select = $(event.target).closest('.s-select');
          select_list = select.find('.s-select__submenu');
          switch (event.keyCode) {
            case $.constants.keyCodes.UP:
              if (select.hasClass('active')) {
                active = select_list.find('.active');
                if (active.length) {
                  active.removeClass('active');
                  prev_item = prev(active.data('idx'));
                } else {
                  prev_item = select_list.find('.s-select__item').last();
                }
                prev_item.addClass('active');
                shift_list('up');
              } else {
                if (!select.data('disabled')) {
                  set_selected(prev(select.data('selected')));
                }
              }
              return event.preventDefault();
            case $.constants.keyCodes.DOWN:
              if (select.hasClass('active')) {
                active = select_list.find('.active');
                if (active.length) {
                  active.removeClass('active');
                  next_item = next(active.data('idx'));
                } else {
                  next_item = select_list.find('.s-select__item').first();
                }
                next_item.addClass('active');
                shift_list('down');
              } else {
                if (!select.data('disabled')) {
                  set_selected(next(select.data('selected')));
                }
              }
              return event.preventDefault();
            case $.constants.keyCodes.SPACE:
              open_list();
              select_list.find('.s-select__item.active').removeClass('active');
              $(select_list.find('.s-select__item').get(select.data('selected'))).addClass('active');
              if (options.input !== true) {
                return event.preventDefault();
              }
              break;
            case $.constants.keyCodes.ENTER:
              if (select.hasClass('active')) {
                set_selected(select_list.find('.s-select__item.active'));
              }
              $(event.target).closest('.s-select').removeClass('active');
              return event.preventDefault();
            case $.constants.keyCodes.ESC:
              $(event.target).closest('.s-select').removeClass('active');
              return event.preventDefault();
          }
        };
        if (options.input === true) {
          this.select.on('keydown', 'input', keydown_handler);
        } else {
          this.select.on('keydown', keydown_handler);
        }
        return this.select.on('mouseenter', 'li.s-select__item', function(event) {
          $select_list.find('.s-select__item.active').removeClass('active');
          return $(event.target).addClass('active');
        });
      });
    });
  })(jQuery);
}).call(this);
