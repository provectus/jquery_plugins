(($)->
  $.fn.tags = ((options) ->
    defaults =
      tags: []
      tips: []
      withId: off
      withDropdown: off
      withNew: off
      async: off
      callback: null

    options = $.extend defaults, options

    template = '<div class="s-tags" tabindex="0">
                  <div class="s-tags__container">
                    <ul class="s-tags__current">
                      <li class="s-tags__input-container"><input class="s-tags__input" type="text"></li>
                    </ul>
                    <div class="placeholder hidden"></div>
                   </div>
                  <div class="s-tags__dropdown">
                    <ul class="s-tags__list">
                      <li class="s-tags__item s-tags__new hidden">
                        <span class="text"></span>
                        <span class="js-tags-new-tag-text">(New tag)</span>
                        <button class="close"></button>
                      </li>
                    </ul>
                  </div>
                  <div class="s-tags__toggler hidden"></div>
                </div>'

    tag_tmpl = '<li class="s-tags__item"><span class="text"></span><button class="close"></button></li>'

    @.each(()->
      $this = $ @
      $this.hide()
      @tags = $ template
      @tags.data 'values', []
      @tags.data 'ids', []
      @tags.data 'tips', options.tips
      $this.before @tags

      in_tips = (txt, tips) ->
        for tip in tips
          if txt.toLowerCase() == tip.name.toLowerCase()
            return tip
        off

      $this.data 'custom_val', (value) =>
        if value?
          if Array.isArray(value)
            @tags.find('.s-tags__current .s-tags__item').each ()->
              remove_tag $ @
            for val in value
              add_tag val
          return $this
        else
         return if options.withId then @tags.data 'ids' else @tags.data('values').map((v) -> if v? and v.name? then v.name else v)

      show_tips = (text) =>
        @tags.find('.s-tags__dropdown .s-tags__list .s-tags__item:not(.s-tags__new)').remove()
        deferred = $.Deferred()
        if $.isFunction options.callback
          if options.async is on
            options.callback(text).done (result) ->
              deferred.resolve result
          else
            deferred.resolve if $.isFunction(options.callback) then options.callback(text) else []
        else if options.tips?
          deferred.resolve options.tips.map((tip) -> tip if tip.toLowerCase().trim().indexOf(text.toLowerCase().trim()) is 0).filter (tip) -> tip
        else
          deferred.resolve []
        deferred.done (tips) =>
          tips = tips.map((tip) -> if $.type(tip) is 'string' then name: tip else tip)
          @tags.data 'tips', tips
          values = @tags.data('values').map (value) -> if $.type(value) is 'string' then value else value.name
          for tip in tips
            unless typeof tip is "object"
              tip = { name: tip }
            if tip.name.toString() not in values
              add_tip(tip)
          show_dropdown()

      add_tip = (item) =>
        list = @tags.find('.s-tags__dropdown .s-tags__list')
        tip = $(tag_tmpl)
        tip.find('.text').text item.name
        if item.id?
          tip.attr 'data-id', item.id
        list.find('.s-tags__new').before tip

      add_tag = (text, id = undefined, withCheck = on) =>
        if withCheck is on and options.withNew is off
          text = in_tips(text, @tags.data('tips'))
          return if text is false
        values = @tags.data 'values'
        if text in values
          return
        values.push text
        @tags.data 'values', values

        if id?
          ids = @.tags.data 'ids'
          unless id in ids
            ids.push id
            @tags.data 'ids', ids
          else
            return

        $tag = $ tag_tmpl
        $tag.attr 'data-id', id
        $tag.find('.text').text if $.type(text) is 'string' then text else text.name
        @tags.find('.s-tags__current .s-tags__input-container').before($tag)

        e = $.Event 'tag_added'
        e.tag = text
        $this.trigger e

      remove_tag = (element) =>
        values = @tags.data 'values'
        text = element.find('.text').text()
        idx = values.map((value) -> if $.type(value) is 'string' then value else value.name ).indexOf(text)
        values[idx..idx] = [] if idx > -1
        @tags.data 'values', values

        if options.withId
          ids = @tags.data 'ids'
          ids[idx..idx] = [] if idx > -1
          @tags.data 'ids', ids

        element.remove()

        e = $.Event 'tag_removed'
        e.tag == text
        $this.trigger e

      set_input_size = (text) =>
        input = @tags.find('.s-tags__input')
        test_div = $('.js-tags-plugin-size')
        if not test_div.size()
          test_div = $('<div class="js-tags-plugin-size"></div>').css
            position: 'absolute'
            left: -1000
            top: -1000
            visibility: 'hidden'
          for prop in ['font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing']
            test_div.css prop, input.css(prop)
          $('body').append test_div
        test_div.text text
        input.css 'width', test_div.width() + 10

      shift_list = =>
        list = @tags.find('.s-tags__dropdown .s-tags__list')
        $active_item = list.find('.s-tags__item.active');
        if $active_item.size() is 0
          return
        top = $active_item.position().top;
        scroll = list.scrollTop();
        container_height = list.outerHeight();
        item_height = $active_item.outerHeight();
        padding = 6;

        if top > container_height - item_height
          list.animate {scrollTop: top + scroll - container_height + item_height + padding}, 'fast'
        if top < padding
          list.animate {scrollTop: scroll + top - padding}, 'fast'

      show_dropdown = =>
        $list = @tags.find('.s-tags__dropdown .s-tags__list')
        if ($list.height() + @tags.offset().top + @tags.height() + 20) > $(document).height()
          $list.addClass 'topped'
        else
          $list.removeClass 'topped'
        toggle = off
        if options.withNew and $list.children().length > 0
          toggle = on
        else if $list.children().length > 1
          toggle = on
        if toggle
          $list.addClass 'active'
          $('.s-tags__toggler').addClass 'active'
        $list

      hide_dropdown = =>
        @tags.find('.s-tags__dropdown .s-tags__list').removeClass 'active'
        @tags.find('.s-tags__toggler').removeClass 'active'

      disable = =>
        @tags.addClass 'disabled'
        @tags.find('.s-tags__input').prop('disabled', on)
        @tags.find('.s-tags__current, .close').css('cursor', 'default')

      enable = =>
        @tags.removeClass 'disabled'
        @tags.find('.s-tags__input').prop('disabled', off)
        @tags.find('.s-tags__current').css('cursor', 'text')
        @tags.find('.close').css('cursor', 'pointer')

      for tag in options.tags
        if tag? and $.type(tag) is "object"
          add_tip tag.name
          add_tag tag.name, tag.id, off
        else
          add_tag tag, undefined, off

      if $this.is ':disabled'
        disable()

      if $this.attr('placeholder')
        @tags.find('.placeholder').removeClass('hidden').text($this.attr('placeholder'))

      if options['withDropdown']
        @tags.find('.s-tags__toggler').removeClass 'hidden'

      (showPlaceholder = =>
        text = $.trim(@tags.find('.s-tags__input').val())
        if text is '' and @tags.data('values').length is 0
          @tags.find('.placeholder').removeClass 'hidden'
        else
          @tags.find('.placeholder').addClass 'hidden'
      )()

      $this.mutations
        attributes: on
        filter: ['disabled']

      $this.on 'attribute_changed', (event) ->
        if $(event.target).prop('disabled')
          disable()
        else
          enable()

      @tags.on 'mousedown', '.s-tags__toggler', =>
        $list = @tags.find('.s-tags__dropdown .s-tags__list')
        if $list.hasClass 'active'
          hide_dropdown()
        else
          show_tips ''
          show_dropdown()

      @tags.on 'mousedown', '.s-tags__list', -> off

      @tags.on 'mouseenter', '.s-tags__dropdown .s-tags__item', (event) ->
        $target = $ event.target
        $target.closest('.s-tags__list').find('.s-tags__item').removeClass 'active'
        $target.addClass 'active'

      @tags.on 'mouseleave', '.s-tags__dropdown .s-tags__item', (event) ->
        $(event.target).closest('.s-tags__list').find('.s-tags__item').removeClass 'active'

      @tags.on 'mousedown', '.s-tags__dropdown .s-tags__item', (event) ->
        event.preventDefault()

        $target = $(event.target).closest('.s-tags__item')
        add_tag $target.find('.text').text(), $target.attr "data-id"

        tags = $(event.target).closest('.s-tags')
        tags.find('.s-tags__input').focus().val('')
        hide_dropdown()

        $target.removeClass 'active'

      @tags.on 'click', '.s-tags__container', (event) ->
        tags = $(event.target).closest('.s-tags')
        tags.find('.s-tags__input').show().focus()

      @tags.on 'focus', '.s-tags__input', (event) ->
        $(event.target).show()
        tags = $(event.target).closest('.s-tags')
        tags.addClass('active')
        e = $.Event 'tags_size_changed'
        $this.trigger e

      @tags.on 'blur', '.s-tags__input', (event) ->
        tags = $(event.target).closest('.s-tags')
        if tags.find('.s-tags__current').children().size() > 1
          tags.find('.s-tags__input').hide()
        tags.removeClass 'active'
        e = $.Event 'tags_size_changed'
        $this.trigger e
        hide_dropdown()
        tags.find('.s-tags__dropdown .s-tags__item').removeClass 'active'
        input = $.trim $(event.target).val()
        if input isnt ''
          add_tag input unless options.withNew
          $(event.target).val ''

      @tags.on 'keydown', '.s-tags__input', (event) ->
        showPlaceholder()
        tags = $(event.target).closest('.s-tags')
        text = $.trim($(event.target).val())
        dropdown = tags.find('.s-tags__list')
        if text isnt ''
          show_dropdown()

        add_new_tag = (txt) ->
          tip = in_tips(txt, tags.data('tips'))
          return if tip is false
          txt = tip.name
          id = tip.id
          if txt isnt ''
            add_tag txt, id
            dropdown.find('.s-tags__new .text').text txt
            hide_dropdown()
          $(event.target).val ''
          event.preventDefault()

        switch event.keyCode
          when $.constants.keyCodes.ENTER
            active = tags.find('.s-tags__list .s-tags__item.active')
            tag = if active.size() then active.find('.text').text() else text
            add_new_tag(tag)
            return false
          when $.constants.keyCodes.BACKSPACE
            if text is ''
              remove_tag tags.find('.s-tags__current .s-tags__item:last')
          when $.constants.keyCodes.UP
            if text is ''
              return true
            items = tags.find('.s-tags__list .s-tags__item')
            active = items.filter('.active')
            prev = if active.size() then active.prev() else items.last()
            prev = if prev.size() then prev else items.last()
            items.removeClass 'active'
            prev.addClass 'active'
            shift_list()
            return false
          when $.constants.keyCodes.DOWN
            if text is ''
              return true
            items = tags.find('.s-tags__list .s-tags__item')
            active = items.filter('.active')
            prev = if active.size() then active.next() else items.first()
            prev = if prev.size() then prev else items.first()
            items.removeClass 'active'
            prev.addClass 'active'
            shift_list()
            return false
          else
            break
        set_input_size text

      @tags.on 'keyup', '.s-tags__input', (event) =>
        showPlaceholder()
        tags = $(event.target).closest('.s-tags')
        dropdown = tags.find('.s-tags__list')
        text = $.trim($(event.target).val())
        new_tag = dropdown.find('.s-tags__new')
        if text in @tags.data('tips') or text in @tags.data('values')
          new_tag.hide()
        else
          if options.withNew
            new_tag.show().removeClass('hidden').find('.text').text text
        set_input_size text
        if text isnt ''
          if event.keyCode not in [$.constants.keyCodes.UP, $.constants.keyCodes.DOWN]
            show_tips text
          dropdown = show_dropdown()
          if options.withNew
            dropdown.find('.s-tags__new .js-tags-new-tag-text').show()
        else
          hide_dropdown()
          dropdown.find('.s-tags__new .js-tags-new-tag-text').hide()

      @tags.on 'click', '.s-tags__item .close', (event) ->
        if $this.is ':disabled'
          return false
        $(event.target).closest('.s-tags').find('.s-tags__input').show().focus()
        remove_tag $(event.target).closest('.s-tags__item')

      $this.on 'add_tag', (event, params)->
        add_tag params.name, params.id, off
    )
  )
)(jQuery)