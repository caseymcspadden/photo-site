BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'submit form' : 'submitForm'

	initialize: (options) ->
		this.template = templates['contact-view']

	validateForm: (data)->
		this.$('.field-label').removeClass('error')
		this.$('.invalid').addClass('hide')
		errors = []
		errors.push 'name' if !data['name']
		errors.push 'message' if !data['message']
		errors.push 'email' if not /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(data['email'])

		for i in [0...errors.length]
			this.$('#form-'+errors[i] + ' .field-label').addClass('error')
			this.$('#form-'+errors[i] + ' .invalid').removeClass('hide')

		return errors.length==0

	submitForm: (e) ->
		e.preventDefault();
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		if this.validateForm(data)
			$.ajax(
				url: config.servicesBase + '/contact'
				type: 'POST'
				context: this
				data: data
				success: (json) ->
					document.location = config.urlBase 
				error: (json) ->
					console.log json
			)

	render: ->
		data = {}
		this.$el.html this.template(data)
