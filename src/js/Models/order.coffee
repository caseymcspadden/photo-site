Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend

	urlRoot: config.servicesBase + '/orders'