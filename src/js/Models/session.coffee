Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.servicesBase + '/session'

	defaults :
		isadmin: 0
		success: false	
		message: ''
		loggingIn: false
		email: ''
		name: ''
		company: ''
		idcontainer: 0

	#initialize: (attributes, options) ->
		
	login: (data) ->
		$.ajax(
			url: this.urlRoot
			type: 'POST'
			context: this
			data: data
			success: (json) ->
				this.set json
				this.set 'success' , true
			error: (json) ->
				this.set 'message' , json.responseJSON.message
		)

	logout: (successUrl) ->
		$.ajax(
			url: this.urlRoot
			type: 'PUT'
			context: this
			success: (json) ->
				this.set 'uid', 0
				document.location = successUrl
		)



