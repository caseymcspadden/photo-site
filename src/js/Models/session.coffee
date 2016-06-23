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
			contentType: "application/json; charset=utf-8"
			data: data
			success: (json) ->
				if json.hasOwnProperty 'error'
					this.set 'errorMessage' , json.message
				else
					location.reload();
		)

	logout: ->
		$.ajax(
			url: this.urlRoot
			type: 'PUT'
			context: this
			success: (json) ->
				#location.reload();
				this.set 'uid', 0
		)



