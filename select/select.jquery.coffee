(($)->
  $.fn.selects = ((options) ->
    defaults = input: off
    options = $.extend defaults, options

    selected_item = if options.input is on then '<input type="text" />' else "<div class='s-select__item'></div>"
    tabindex = "tabindex='0'"
    template = "<div class='s-select' #{tabindex}>
                    <div class='s-select__current'>
                        #{selected_item}
                        <button class='s-select__toggler' tabindex='-1'>
                            <span class='s-select__icon'></span>
                        </button>
                    </div>
                    <ul class='s-select__submenu'>
                    </ul>
                </div>"

    item_tmpl = '<li class="s-select__item"></li>'
    group_tmpl = '<li class="s-select__group">Pacific American</li>'

    $(document).on('click', (event) ->
      $('.s-select.active').removeClass('active') unless $(event.target).closest('.s-select').length
    )

    @.each(->
      drawing = true
      $this = $ @
      $this.hide()
      @select = $ template
      $this.before @select
      @select.get(0).className = @.className

      $select_list = @select.find '.s-select__submenu'
      $selected = if options.input is on then @select.find 'input' else @select.find 'div.s-select__item'

      item_counter = 0

      $this.data 'custom_val', (value = null) ->
        ret = @__old_val.apply @, arguments
        if value?
          set_selected @find('option:selected'), false, true
        if options.input is on
          ret = $selected.val()
        return ret

      add_item = (item_el) ->
        $(item_tmpl)
          .appendTo($select_list)
          .addClass((if item_el.attr('data-placeholder') then 'placeholder hidden' else ''))
          .data('idx', item_counter++)
          .data('value', item_el.attr 'value')
          .html item_el.html()

      add_group = (group_el) ->
        $(group_tmpl)
          .appendTo($select_list)
          .html group_el.attr 'label'
        group_el.children().each(->
          add_item($ @)
        )

      set_selected = (item_el, silent = false, already_selected = false) =>
        if item_el.is 'li.s-select__item'
          selected_index = item_el.data 'idx'
        else
          selected_index = $this.find('option').index item_el
        @select.data 'selected', selected_index
        @select.find('.s-select__item.active').removeClass 'active'
        @select.find('li.s-select__item').eq(selected_index).addClass('active')
        if options.input is on
          $selected.val item_el.text()
        else
          $selected.html item_el.html()
        if item_el.hasClass('placeholder') or item_el.attr('data-placeholder')
          $selected.addClass('placeholder')
        else
          $selected.removeClass('placeholder')
        if not already_selected
          option = $this.find('option').eq selected_index|0
          $this.val option.val()
        if not silent and already_selected
          e = $.Event 'change'
          e.internal = true
          e.initial = drawing
          $this.trigger e
      next = (idx) ->
        items = $select_list.find 'li.s-select__item'
        _idx = Math.min idx + 1, items.length - 1
        $ items[_idx]

      prev = (idx) ->
        items = $select_list.find 'li.s-select__item'
        _idx = Math.max 0, idx - 1
        $ items[_idx]

      open_list = =>
        if not @.select.data 'disabled'
          if (@select.offset().top + $select_list.outerHeight()) > ($(document).height() - 40)
            $select_list.addClass 'topped'
          @select.addClass('active')
          shift_list()

      shift_list = =>
        $active_item = $select_list.find('.s-select__item.active');
        if $active_item.size() is 0
          return
        top = $active_item.position().top;
        scroll = $select_list.scrollTop();
        container_height = $select_list.outerHeight();
        item_height = $active_item.outerHeight();
        padding = 6;

        if top > container_height - item_height
          $select_list.animate {scrollTop: top + scroll - container_height + item_height + padding}, 'fast'
        if top < padding
          $select_list.animate {scrollTop: scroll + top - padding}, 'fast'


      fill_select = =>
        $select_list.empty()
        placeholder = $this.attr 'placeholder'
        if placeholder isnt '' and placeholder?
          if options.input is on
            @select.find('input').attr 'placeholder', placeholder
          else
            selected = if $this.find('option[selected]').size() then '' else "selected='selected'"
            new_option = $ "<option data-placeholder='true' #{selected} value=''>#{placeholder}</option>"
            if $this.find('option[data-placeholder]').size() is 0
              if $this.children().size() isnt 0
                $this.children().first().before new_option
              else
                $this.append new_option
        item_counter = 0
        $this.children().each ->
          nodename = $(@).prop('nodeName').toLowerCase()
          switch nodename
            when 'option' then add_item $ @
            when 'optgroup' then add_group $ @
            else break
        set_selected $this.find ':selected'

      fill_select()

      if $this.prop('disabled') is true
        @select.addClass 'disabled'

      @select.data 'disabled', $this.prop('disabled')

      $this.mutations
        children: on
        subtree: on
        attributes: on
        filter: ['disabled']

      $this.on 'attribute_changed', (event) =>
        disabled = !!$(event.target).attr(event.attribute)
        @select.data 'disabled', disabled
        if event.attribute is 'disabled'
          if disabled
            @select.addClass 'disabled'
          else
            @select.removeClass 'disabled'

      $this.on 'child_added', fill_select
      $this.on 'child_removed', fill_select

      $this.on 'change', (event) ->
        if not event.internal
          set_selected $(event.currentTarget).find('option:selected'), true

      @select.on 'click', '.s-select__current', (event) ->
        select = $(event.currentTarget).closest('.s-select')
        if select.hasClass 'active'
          select.removeClass 'active'
        else
          open_list()
        event.preventDefault()

      @select.on 'click', 'li.s-select__item', (event) ->
        event.preventDefault()
        if $(event.target).attr('data-selectible') is 'off'
          return true
        set_selected $(event.currentTarget)
        $(event.currentTarget).closest('.s-select').removeClass 'active'

      @select.on 'click', '.s-select__toggler', (event) -> event.preventDefault()

      @select.on 'blur', (event) ->
        $(event.currentTarget).removeClass 'active'

      keydown_handler = (event) ->
        select = $(event.currentTarget).closest('.s-select')
        select_list = select.find('.s-select__submenu')
        switch event.keyCode
          when $.constants.keyCodes.UP
            if select.hasClass 'active'
              active = select_list.find '.active'
              if active.length
                active.removeClass 'active'
                prev_item = prev active.data 'idx'
              else
                prev_item = select_list.find('.s-select__item').last()
              prev_item.addClass 'active'
              shift_list()
            else
              if not select.data 'disabled'
                set_selected prev select.data 'selected'
            event.preventDefault()
          when $.constants.keyCodes.DOWN
            if select.hasClass 'active'
              active = select_list.find '.active'
              if active.length
                active.removeClass 'active'
                next_item = next active.data 'idx'
              else
                next_item = select_list.find('.s-select__item').first()
              next_item.addClass 'active'
              shift_list()
            else
              if not select.data 'disabled'
                set_selected next select.data 'selected'
            event.preventDefault()
          when $.constants.keyCodes.SPACE
            open_list()
            select_list.find('.s-select__item.active').removeClass 'active'
            $(select_list.find('.s-select__item').get(select.data 'selected')).addClass 'active'
            if options.input isnt on
              event.preventDefault()
          when $.constants.keyCodes.ENTER
            if select.hasClass 'active'
              set_selected select_list.find '.s-select__item.active'
            $(event.target).closest('.s-select').removeClass 'active'
            event.preventDefault()
          when $.constants.keyCodes.ESC
            $(event.target).closest('.s-select').removeClass 'active'
            event.preventDefault()
          else break

      @select.on 'keydown', keydown_handler
      if options.input is on
        @select.on 'keydown', 'input', keydown_handler

      @.select.on 'mouseenter', 'li.s-select__item', (event) ->
        $select_list.find('.s-select__item.active').removeClass 'active'
        $(event.currentTarget).addClass 'active'
      drawing = false
    )
  )
)(jQuery)