require 'foundation'
Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.listenTo this.model, 'change:id' , this.setUser
		this.setUser(this.model)

	setUser: (m) ->
		if m.get('id')==0
			this.$('ul.submenu').html ''
			this.$('.top-item').html 'LOGIN'
			this.$('.top-item').addClass('login-item')
		else
			html = 	'<li><a href="#">PROFILE</a></li><li><a href="#">MY GALLERIES</a></li>'
			html += '<li><a href="' + config.urlBase + '/admin">ADMIN</a></li>' if this.model.get('isadmin')
			html += '<li><a href="#" class="logout-item">LOGOUT</a></li>'
			this.$('ul.submenu').html html
			this.$('.top-item').html 'CLIENT'
			this.$('.top-item').removeClass('login-item')

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()
		document.location = config.urlBase

	render: ->
		this