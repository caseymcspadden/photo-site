require 'foundation'
Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:id' , this.setUser
		this.render()
		this.setUser(this.model)

	setUser: (m) ->
		if m.get('id')==0
			#this.$('ul.submenu').html '<li><a href="#" class="login-item">LOGIN</a></li>'
			this.$('ul.submenu').html ''
			this.$('.top-item').addClass('login-item')
		else
			html = 	'<li><a href="#">PROFILE</a></li><li><a href="#">GALLERIES</a></li>'
			html += '<li><a href="' + config.urlBase + '/admin">ADMIN</a></li>' if this.model.get('isadmin')
			html += '<li><a href="#" class="logout-item">LOGOUT</a></li>'
			this.$('ul.submenu').html html
			this.$('.top-item').removeClass('login-item')

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()
		document.location = config.urlBase

	render: ->
		this.$el.html this.template()
		this