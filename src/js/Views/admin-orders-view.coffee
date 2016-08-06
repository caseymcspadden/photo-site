BaseView = require './base-view'
templates = require './jst'
AdminOrdersRowView = require './admin-orders-row-view'
JsonView = require './json-view'
OrderView = require './order-view'
Order = require './order'
config = require './config'

module.exports = BaseView.extend
	###
	events:
		'click .add-user' : 'addUser'
	###
	
	initialize: (options) ->
		this.template = templates['admin-orders-view']
		this.order = new Order
		this.orderView = new OrderView {model: this.order}
		this.jsonView = new JsonView
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
	
	render: ->
		this.$el.html this.template()
		this.assign this.orderView, '.order-view'
		this.assign this.jsonView, '.json-view'
  		
	addOne: (order) ->
		adminOrdersRowView = new AdminOrdersRowView {model: order, orderView: this.orderView, jsonView: this.jsonView}
		this.$('.orders').append adminOrdersRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this
