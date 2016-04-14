Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.urlBase + '/services/session'

	defaults :
		isadmin: 0		
		errorMessage: ''
		loggingIn: false
		email: ''
		name: ''
		company: ''

	initialize: (attributes, options) ->
		self = this
		$.get(this.urlRoot, (result) ->
			json = $.parseJSON(result)
			self.set json
		)

		
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
					expires = new Date(json.expiredate)
					#document.cookie = 'session=' + json.hash + ';path=/; expires=' + expires.toString()
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
				#document.cookie = "session=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
		)



