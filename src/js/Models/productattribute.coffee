Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		idproduct: 0
		idattribute: 0
		name: ''
		title: ''
		validvalues: ''
		defaultvalue: ''