// http://test.pusher.com/1.9.4

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
		
var maxMessages = 20; // The maximum number of messages you want to be displayed on the screen at once

;$(function(){
  
  $('.sizeAdjuster input').change(function(){
    var val = this.value;
    $(this).parents('.app').find('.chat-list img:not(.sound)').each(function(i, ment){
      ment = $(ment);
      ment.height(val);
      ment.width(val);
    });
  });
  
  $('.debugMessages').click(function(){
    $(this).children('.infoDisplay').toggle();
  });
  
  // $('.sizeAdjuster a').first().click(function(){
  //   $('.chat-list img').each(function(i, ment){
  //     ment = $(ment);
  //     ment.height(ment.height() - 1);
  //     ment.width(ment.width() - 1);
  //   });
  // });
  // $('.sizeAdjuster a').last().click(function(){
  //   $('.chat-list img').each(function(i, ment){
  //     ment = $(ment);
  //     ment.height(ment.height() + 1);
  //     ment.width(ment.width() + 1);
  //   });
  // });
  
  // Must supply a room, so it knows which infoDisplay to add to
  function addToInfoDisplay(infoToDisplay, room) {
    $('#' + room).find('.infoDisplay').children().first().after('<br><span>' + infoToDisplay + '</span>');
  }
  
  var resizeChatList = function resizeChatList() {
    $('body').height($(window).height());
    $('.chat-list').height($(window).height() - $('.chat-list').position().top);
    $('.infoDisplay').height($(window).height() - 10);
  }

  $(window).resize(resizeChatList);
  
  window.app = window.app || {};
  var appName = "Chat";
  $("#the_url").click(function(){this.select()});

  $.fn.exists = function () {
      return this.length !== 0;
  }

  app.Chat = Backbone.Model.extend({
    EMPTY: '[nil]',

    initialize: function() {
      console.log('initialize');
      if (!this.get('message') && !this.get('clear')) {
        this.set({'message': this.EMPTY});
      }
    }
  });

  app.ChatList = Backbone.Collection.extend({
    model: app.Chat,
    url: function() {
      console.log(app.chat_path);
      return app.chat_path + '/items.json';
    },
    comparator: function(item) {
      return item.get('id');
    },
    // This method is overridden to save us messing around
    // with socket_id filtering.
    add: function(models, options) {
      if (_.isArray(models)) {
        for (var i = 0, l = models.length; i < l; i++) {
          if (models[i].id && !app.Chats.get(models[i].id)) {
            this._add(models[i], options);
          }
        }
      } else {
        if (models.id && !app.Chats.get(models.id)) {
          this._add(models, options);
        }
      }
      return this;
    }
  });

  app.Chats = new app.ChatList;

  app.ChatView = Backbone.View.extend({
    tagName: 'div',
    template: _.template($('#chat-item-template').html()),

    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('change', this.render);
      this.model.view = this;
    },

    render: function() {
      var model = this.model.toJSON();
      
      var addSoundP = false;
      if (model.message.indexOf("@" + me) > -1) addSoundP = true;
      
      model.message = twttr.txt.autoLink(model.message, {room: model.room});
      $(this.el).html(this.template(model));
      this.el.id = "chat-item-" + this.model.get("id");
      $(this.el).addClass('item');
      addToInfoDisplay(model.message, model.room);
      //$(this.el.firstChild).html(this.model.get('message'));
      if (addSoundP) {
        $(this.el).append('<a class="playSound" href="#" onclick="$(\'#bell\')[0].play();" ><img class="sound" src="images/sound.png" /></a>');
        $('#bell')[0].play();
      }
      return this;
    }
  });

  app.AppView = Backbone.View.extend({
    //el: $('.app'),

    events: {
      'keypress #new-chat': 'createOnEnter',
      'focus #new-chat':    'showTooltip',
      'blur #new-chat':     'hideTooltip',
      'click #clear-chat':   'clearChat',
    },

    initialize: function() {
      _.bindAll(this, 'addOne', 'removeOne', 'render', 'showTooltip', 'hideTooltip');
      this.input = this.$('#new-chat');
      this.$('.ui-tooltip-top').hide();
      app.Chats.bind('add', this.addOne);
      app.Chats.bind('remove', this.removeOne);
      app.Chats.fetch({'add':true});
    },

    addOne: function(item) {
      if (item.attributes.room != this.el[0].id) {
        return;
      }
      if (item.attributes.clear) {
        this.el.find('.chat-list').html('');
        return;
      }
      var view = new app.ChatView({model: item});
      var chat_list = this.$('.chat-list');
      if (chat_list.children().length >= maxMessages) {
        chat_list.children().last().remove();
        $(this.el).find('.infoDisplay').children().last().remove();
      }
      chat_list.prepend(view.render().el);
      $(this.el).find('#num_messages').text(chat_list.children().length);
    },

    removeOne: function(item) {
      this.$("#chat-item-" + item.id).parent('li').remove();
    },

    newAttributes: function() {
      console.log(this);
      return {
        message:this.input.val(),
        when:new Date().toString(),
        author:me,
        room: this.el[0].id
      };
    },
    
    newClearAttributes: function() {
      console.log('newClearAttributes');
      return {
        when:new Date().toString(),
        room:this.el[0].id,
        clear:true
      };
    },

    createOnEnter: function(e) {
      if (e.keyCode != 13) return;
      if (this.input.val() == '') return;

      app.Chats.create(this.newAttributes());
      var input = this.input;
      input.blur();
      input.val('Sending...').addClass('working');
      _.delay(function(el) {
        if (el.val() == 'Sending...') {
          el.val('').blur().removeClass('working');
          input.focus();
        }
      }, 500, this.input);
    },
    
    clearChat: function(e) {
      console.log("Time to clear");
      app.Chats.create(this.newClearAttributes());
      $(e.target).parents('.app').find('.chat-list').html('');
    },

    showTooltip: function(e) {
      document.title = appName;
      var tooltip = this.$('.ui-tooltip-top');
      var self = this;
      if (this.tooltipTimeout) clearTimeout(this.tooltipTimeout);

      this.tooltipTimeout = _.delay(function() {
        tooltip.fadeIn(300);
        self.tooltipTimeout = _.delay(self.hideTooltip, 2400);
      }, 400);
    },

    hideTooltip: function() {
      var tooltip = this.$('.ui-tooltip-top');
      if (this.tooltipTimeout) clearTimeout(this.tooltipTimeout);
      tooltip.fadeOut(300);
    }
  });

  window.AppInstance = $('.app').each(function(i, a) {
    new app.AppView({el: $(a)});
  });

  Pusher.log = function() {
    if (window.console) window.console.log.apply(window.console, arguments);
  };

  var presenceItemTemplate = _.template($('#presence-item-template').html());
  var presenceStatsTemplate = _.template($('#presence-stats-template').html());
  
  // FIXME: turn this into a backbone model someday
  var update_members = function() {
    $('.presence-all').html("");
    pchannel.members.each(add_member);
  
    $('.presence-stats').html(presenceStatsTemplate({
        size : _(pchannel.members._members_map).keys().length
    }));
  }
  
  function add_member(member) {
    if ($("#presence-item-" + member.id).exists()) return;
    $('.presence-all').prepend(presenceItemTemplate({
      id : member.id,
      name : member.info.nick,
      you : (member.id == me)
    }));
  }

  var loggit = function() {
    console.log(arguments);
  };

  Pusher.channel_auth_endpoint = window.app.chat_path + '/pusher/auth';
  var pusher = new Pusher('3e9e069d8b9f2750062c');

  //
  // WARNING: presence events are *very* flaky! we should
  // probably avoid them and prefer server-side (redis)
  // maintenance of this instead...
  //
  var pchannel = pusher.subscribe('presence-' + window.app.chat_channel);
  pchannel.bind('pusher:subscription_succeeded', update_members);
  pchannel.bind('pusher:member_added', update_members);
  pchannel.bind('pusher:member_removed', update_members);

  var channel = pusher.subscribe(window.app.chat_channel);
  app.ChatsBackpusher = new Backpusher(channel, app.Chats);
});