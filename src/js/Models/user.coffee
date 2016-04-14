Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	defaults :
		name: ''
		email: ''
		company: ''	
		isadmin: 0
		isactive: 1
		dt: ''
		idcontainer: 0