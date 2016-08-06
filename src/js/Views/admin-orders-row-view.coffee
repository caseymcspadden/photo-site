BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	tagName: 'tr'

	events:
		'click .show-order' : 'showOrder'
		'click .show-pwinty' : 'showPwinty'
		'click .show-payment' : 'showPayment'

	initialize: (options) ->
		this.template = templates['admin-orders-row-view']
		this.orderView = options.orderView
		this.jsonView = options.jsonView
		this.listenTo this.model, 'change', this.render
		this.listenTo this.containers, 'reset', this.render

	render: ->
		data = this.model.toJSON()
		this.$el.html this.template(data)
		this

	showOrder: (e) ->
		e.preventDefault()
		this.orderView.model.retrieve this.model.get('orderid')
		this.orderView.$el.foundation 'open'
	
	showPwinty: (e) ->
		e.preventDefault()
		this.jsonView.fetchJSON(config.servicesBase + '/orderdetails/' + this.model.get('idpwinty'))
		this.jsonView.$el.foundation 'open'

	showPayment: (e) ->
		e.preventDefault()
		this.jsonView.fetchJSON(config.servicesBase + '/payments/' + this.model.get('idpaypal'))
		this.jsonView.$el.foundation 'open'
