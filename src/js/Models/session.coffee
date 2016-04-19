Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.servicesBase + '/session'

	defaults :
		isadmin: 0		
		errorMessage: ''
		loggingIn: false
		email: ''
		name: ''
		company: ''
		idcontainer: 0

	initialize: (attributes, options) ->
		console.log 'initializing session'
		self = this
		###
		$.get(this.urlRoot, (result) ->
			json = $.parseJSON(result)
			self.set json
		)
		###
		
	login: (data) ->
		$.ajax(
			url: this.urlRoot
			type: 'POST'
			context: this
			data: data
			success: (result) ->
				json = $.parseJSON(result)
				if json.hasOwnProperty 'error'
					this.set 'errorMessage' , json.message
				else
					this.set json
		)

	logout: ->
		$.ajax(
			url: this.urlRoot
			type: 'PUT'
			context: this
			success: (result) ->
				json = $.parseJSON(result)
				this.set 'uid', 0
		)



