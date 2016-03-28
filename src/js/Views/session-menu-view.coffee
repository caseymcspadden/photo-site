require 'foundation'
Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:uid' , this.uidChanged
		this.render()

	uidChanged: (m) ->
		if m.get('uid')==0
			this.$('.top-menu-item').html('LOGIN').addClass('login-item')
			this.$('ul.submenu').html ''
		else
			this.$('.top-menu-item').html('USER').removeClass('login-item')
			this.$('ul.submenu').html '<li><a href="#">PROFILE</a></li><li><a href="#" class="logout-item">LOGOUT</a></li>'

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()

	render: ->
		html = '<a href="#" class="top-menu-item login-item">LOGIN</a>' +
			'<ul class="menu submenu vertical" data-submenu>' +
      		'</ul>'

		###
		if this.model.get('uid')==0
			html = '<a href="#" class="login-item">LOGIN</a>'
		else
			html = '<a href="#" class="login-item">USER</a>' +
				'<ul class="menu submenu vertical" data-submenu>' +
            	'<li><a href="#">PROFILE</a></li>' +
            	'<li><a href="#" class="logout-item">LOGOUT</a></li>' +
          		'</ul>'
		###
		this.$el.html html
		this