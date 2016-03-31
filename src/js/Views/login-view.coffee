Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	className: 'reveal form'

	attributes:
		'data-reveal': ''

	events:
		'submit form' : 'login'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.template = templates['login-view']
		this.listenTo this.model, 'change:loggingIn' , this.openClose
		this.listenTo this.model, 'change:errorMessage' , this.loginError
		this.listenTo this.model, 'change:id' , this.loginSuccess

	loginError: (m) ->
		msg = m.get 'errorMessage'
		if msg.length==0
			this.$('.error-message').addClass 'hidden'
		else
			this.$('.error-message').html(msg).removeClass 'hidden'

	loginSuccess: (m) ->
		this.$('error-message').addClass 'hidden'
		this.$el.foundation 'close'

	openClose: (m) ->
		this.model.set 'errorMessage', ''
		if m.get 'loggingIn'
			this.$el.foundation 'open'
			m.set 'loggingIn', false

	login: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {remember: 0}
		for elem in arr
			data[elem.name] = if elem.name=='remember' then 1 else elem.value
		this.model.login data

	render: ->
		this.$el.html this.template()
		this
