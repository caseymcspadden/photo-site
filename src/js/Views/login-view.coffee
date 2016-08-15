Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	className: 'reveal form login-view'

	attributes:
		'data-reveal': ''

	events:
		'submit form' : 'login'
		'click .forgot-password' : 'forgotPassword'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.template = templates['login-view']
		this.listenTo this.model, 'change:loggingIn' , this.openClose
		this.listenTo this.model, 'change:message' , this.loginError
		this.listenTo this.model, 'change:success' , this.loginSuccess

	loginError: (m) ->
		msg = m.get 'message'
		if msg.length==0
			this.$('.error-message').addClass 'hide'
		else
			this.$('.error-message').html(msg).removeClass 'hide'

	loginSuccess: (m) ->
		if m.get 'success'
			this.$el.foundation 'close'
			document.location = config.urlBase + '/galleries/' + m.get('homepath') if m.get('id')!=0

	forgotPassword: (e) ->
		e.preventDefault()
		this.$('.enter-container').addClass 'hide'
		this.$('.forgot-container').removeClass 'hide'
		this.$('input[name="forgot"]').val '1'

	openClose: (m) ->
		this.model.set 'message' , ''
		this.model.set 'success' , false
		this.$('.enter-container').removeClass 'hide'
		this.$('.forgot-container').addClass 'hide'
		this.$('input[name="forgot"]').val '0'
		if m.get 'loggingIn'
			this.$('input[name="email"]').val ''
			this.$('input[name="password"]').val ''
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
