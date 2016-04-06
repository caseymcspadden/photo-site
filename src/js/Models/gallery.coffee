Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend

	defaults :
		name: ''
		featuredPhoto: 0
		url: ''

