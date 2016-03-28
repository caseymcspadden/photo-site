Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.urlBase + '/services/session'

	defaults :
		uid: 0
		errorMessage: ''
		loggingIn: false

	initialize: (attributes, options) ->
		hash = this.getSessionHash()
		return if hash==''
		self = this
		$.get(this.urlRoot+'/'+hash, (result) ->
			json = $.parseJSON(result)
			self.set 'uid', json.uid
		)

	getSessionHash: ->
		arr = document.cookie.split ';'
		return '' if arr.length==0
		hash = ''
		for cookie in arr
			index = cookie.indexOf 'session='
			return cookie.substring(index+8) if index>=0
		return ''

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
					console.log expires.toString()
					document.cookie = 'session=' + json.hash + '; expires=' + expires.toString()
					this.set json
		)

	logout: ->
		$.ajax(
			url: this.urlRoot + '/' + this.getSessionHash()
			type: 'POST'
			context: this
			success: (result) ->
				json = $.parseJSON(result)
				console.log json
				this.set 'uid', 0
				document.cookie = "session=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
		)



