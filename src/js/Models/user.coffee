Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	defaults :
		email: ''	
		password: ''
		isactive: 0
		dt: 0