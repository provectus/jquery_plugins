(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    return $.fn.tags = (function(options) {
      var defaults, tag_tmpl, template;
      defaults = {
        tags: [],
        tips: [],
        callback: function() {
          return [];
        }
      };
      options = $.extend(defaults, options);
      template = '<div class="s-tags" tabindex="0">\
                        <div class="s-tags__container">\
                            <ul class="s-tags__current">\
                                <li class="s-tags__input-container"><input class="s-tags__input" type="text"></li>\
                            </ul>\
                            <div class="placeholder hidden"></div>\
                         </div>\
                        <div class="s-tags__dropdown">\
                            <ul class="s-tags__list">\
                                <li class="s-tags__item s-tags__new">\
                                    <span class="text"></span>\
                                    <span class="js-tags-new-tag-text">(New tag)</span>\
                                    <button class="close"></button>\
                                </li>\
                            </ul>\
                        </div>\
                        <div class="s-tags__toggler"></div>\
                    </div>';
      tag_tmpl = '<li class="s-tags__item"><span class="text"></span><button class="close"></button></li>';
      return this.each(function() {
        var $this, add_tag, add_tip, disable, enable, remove_tag, set_input_size, showPlaceholder, show_tips, tag, _i, _len, _ref;
        $this = $(this);
        $this.hide();
        this.tags = $(template);
        this.tags.data('values', []);
        this.tags.data('tips', options.tips);
        $this.before(this.tags);
        $this.data('custom_val', $.proxy(function(value) {
          var val, _i, _len;
          if (value == null) {
            value = null;
          }
          if (value != null) {
            if (Array.isArray(value)) {
              this.tags.find('.s-tags__current .s-tags__item').each(function() {
                return remove_tag($(this));
              });
              for (_i = 0, _len = value.length; _i < _len; _i++) {
                val = value[_i];
                add_tag(val);
              }
            }
            return $this;
          } else {
            return this.tags.data('values');
          }
        }, this));
        show_tips = $.proxy(function(text) {
          var tip, tips, _i, _len, _ref, _results;
          this.tags.find('.s-tags__dropdown .s-tags__list .s-tags__item:not(.s-tags__new)').remove();
          tips = $.isFunction(options.callback) ? options.callback(text) : [];
          this.tags.data('tips', tips);
          _results = [];
          for (_i = 0, _len = tips.length; _i < _len; _i++) {
            tip = tips[_i];
            if (_ref = tip.toString(), __indexOf.call(this.tags.data('values'), _ref) < 0) {
              _results.push(add_tip(tip));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }, this);
        add_tip = $.proxy(function(text) {
          var list, tip;
          list = this.tags.find('.s-tags__dropdown .s-tags__list');
          tip = $(tag_tmpl);
          tip.find('.text').text(text);
          return list.find('.s-tags__new').before(tip);
        }, this);
        add_tag = $.proxy(function(text) {
          var $tag, e, values;
          values = this.tags.data('values');
          if (__indexOf.call(values, text) >= 0) {
            return;
          }
          values.push(text);
          this.tags.data('values', values);
          $tag = $(tag_tmpl);
          $tag.find('.text').text(text);
          this.tags.find('.s-tags__current .s-tags__input-container').before($tag);
          e = $.Event('tag_added');
          e.tag = text;
          return $this.trigger(e);
        }, this);
        remove_tag = $.proxy(function(element) {
          var e, idx, text, values, _ref;
          values = this.tags.data('values');
          text = element.find('.text').text();
          idx = values.indexOf(text);
          if (idx > -1) {
            [].splice.apply(values, [idx, idx - idx + 1].concat(_ref = [])), _ref;
          }
          this.tags.data('values', values);
          element.remove();
          e = $.Event('tag_removed');
          e.tag === text;
          return $this.trigger(e);
        }, this);
        set_input_size = $.proxy(function(text) {
          var input, prop, test_div, _i, _len, _ref;
          input = this.tags.find('.s-tags__input');
          test_div = $('.js-tags-plugin-size');
          if (!test_div.size()) {
            test_div = $('<div class="js-tags-plugin-size"></div>').css({
              position: 'absolute',
              left: -1000,
              top: -1000,
              visibility: 'hidden'
            });
            _ref = ['font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing'];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              prop = _ref[_i];
              test_div.css(prop, input.css(prop));
            }
            $('body').append(test_div);
          }
          test_div.text(text);
          return input.css('width', test_div.width() + 10);
        }, this);
        disable = $.proxy(function() {
          this.tags.addClass('disabled');
          this.tags.find('.s-tags__input').prop('disabled', true);
          return this.tags.find('.s-tags__current, .close').css('cursor', 'default');
        }, this);
        enable = $.proxy(function() {
          this.tags.removeClass('disabled');
          this.tags.find('.s-tags__input').prop('disabled', false);
          this.tags.find('.s-tags__current').css('cursor', 'text');
          return this.tags.find('.close').css('cursor', 'pointer');
        }, this);
        _ref = options.tags;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tag = _ref[_i];
          add_tag(tag);
        }
        if ($this.is(':disabled')) {
          disable();
        }
        if ($this.attr('placeholder')) {
          this.tags.find('.placeholder').removeClass('hidden').text($this.attr('placeholder'));
        }
        (showPlaceholder = $.proxy(function() {
          var text;
          text = $.trim(this.tags.find('.s-tags__input').val());
          if (text === '' && this.tags.data('values').length === 0) {
            return this.tags.find('.placeholder').removeClass('hidden');
          } else {
            return this.tags.find('.placeholder').addClass('hidden');
          }
        }, this))();
        $this.mutations({
          attributes: true,
          filter: ['disabled']
        });
        $this.on('attribute_changed', function(event) {
          if ($(event.target).prop('disabled')) {
            return disable();
          } else {
            return enable();
          }
        });
        this.tags.on('mouseenter', '.s-tags__dropdown .s-tags__item', function(event) {
          $(event.target).closest('.s-tags__list').find('.s-tags__item').removeClass('active');
          return $(event.target).addClass('active');
        });
        this.tags.on('mouseleave', '.s-tags__dropdown .s-tags__item', function(event) {
          return $(event.target).closest('.s-tags__list').find('.s-tags__item').removeClass('active');
        });
        this.tags.on('mousedown', '.s-tags__dropdown .s-tags__item', function(event) {
          var $target, tags;
          event.preventDefault();
          $target = $(event.target).closest('.s-tags__item');
          add_tag($target.find('.text').text());
          tags = $(event.target).closest('.s-tags');
          tags.find('.s-tags__input').focus().val('');
          tags.find('.s-tags__list').removeClass('active');
          return $target.removeClass('active');
        });
        this.tags.on('click', '.s-tags__current', function(event) {
          var tags;
          tags = $(event.target).closest('.s-tags');
          return tags.find('.s-tags__input').show().focus();
        });
        this.tags.on('focus', '.s-tags__input', function(event) {
          var tags;
          $(event.target).show();
          tags = $(event.target).closest('.s-tags');
          return tags.addClass('active');
        });
        this.tags.on('blur', '.s-tags__input', function(event) {
          var input, tags;
          tags = $(event.target).closest('.s-tags');
          if (tags.find('.s-tags__current').children().size() > 1) {
            tags.find('.s-tags__input').hide();
          }
          tags.removeClass('active');
          tags.find('.s-tags__list').removeClass('active');
          tags.find('.s-tags__dropdown .s-tags__item').removeClass('active');
          input = $.trim($(event.target).val());
          if (input !== '') {
            add_tag(input);
            return $(event.target).val('');
          }
        });
        this.tags.on('keydown', '.s-tags__input', function(event) {
          var active, add_new_tag, dropdown, items, prev, tags, text;
          showPlaceholder();
          tags = $(event.target).closest('.s-tags');
          text = $.trim($(event.target).val());
          dropdown = tags.find('.s-tags__list');
          if (text !== '') {
            dropdown.addClass('active');
          }
          add_new_tag = function(txt) {
            if (txt !== '') {
              add_tag(txt);
              dropdown.find('.s-tags__new .text').text(txt);
              tags.find('.s-tags__list').removeClass('active');
            }
            $(event.target).val('');
            return event.preventDefault();
          };
          switch (event.keyCode) {
            case $.constants.keyCodes.ENTER:
              active = tags.find('.s-tags__list .s-tags__item.active');
              tag = active.size() ? active.find('.text').text() : text;
              add_new_tag(tag);
              break;
            case $.constants.keyCodes.SPACE:
              add_new_tag(text);
              break;
            case $.constants.keyCodes.BACKSPACE:
              if (text === '') {
                remove_tag(tags.find('.s-tags__current .s-tags__item:last'));
              }
              break;
            case $.constants.keyCodes.UP:
              if (text === '') {
                return true;
              }
              items = tags.find('.s-tags__list .s-tags__item');
              active = items.filter('.active');
              prev = active.size() ? active.prev() : items.last();
              prev = prev.size() ? prev : items.last();
              items.removeClass('active');
              prev.addClass('active');
              false;
              break;
            case $.constants.keyCodes.DOWN:
              if (text === '') {
                return true;
              }
              items = tags.find('.s-tags__list .s-tags__item');
              active = items.filter('.active');
              prev = active.size() ? active.next() : items.first();
              prev = prev.size() ? prev : items.first();
              items.removeClass('active');
              prev.addClass('active');
              return false;
          }
          return set_input_size(text);
        });
        this.tags.on('keyup', '.s-tags__input', $.proxy(function(event) {
          var dropdown, new_tag, tags, text, _ref1;
          showPlaceholder();
          tags = $(event.target).closest('.s-tags');
          dropdown = tags.find('.s-tags__list');
          text = $.trim($(event.target).val());
          new_tag = dropdown.find('.s-tags__new');
          if (__indexOf.call(this.tags.data('tips'), text) >= 0 || __indexOf.call(this.tags.data('values'), text) >= 0) {
            new_tag.hide();
          } else {
            new_tag.show().find('.text').text(text);
          }
          set_input_size(text);
          if (text !== '') {
            if ((_ref1 = event.keyCode) !== $.constants.keyCodes.UP && _ref1 !== $.constants.keyCodes.DOWN) {
              show_tips(text);
            }
            dropdown = tags.find('.s-tags__list').addClass('active');
            return dropdown.find('.s-tags__new .js-tags-new-tag-text').show();
          } else {
            tags.find('.s-tags__list').removeClass('active');
            return dropdown.find('.s-tags__new .js-tags-new-tag-text').hide();
          }
        }, this));
        return this.tags.on('click', '.s-tags__item .close', function(event) {
          if ($this.is(':disabled')) {
            return false;
          }
          $(event.target).closest('.s-tags').find('.s-tags__input').show().focus();
          return remove_tag($(event.target).closest('.s-tags__item'));
        });
      });
    });
  })(jQuery);
}).call(this);
