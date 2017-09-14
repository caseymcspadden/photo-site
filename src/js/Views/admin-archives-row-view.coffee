BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	tagName: 'tr'

	events:
		'click .show-payment' : 'showPayment'

	initialize: (options) ->
		this.template = templates['admin-archives-row-view']
		this.jsonView = options.jsonView

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		this.$el.html this.template(data)
		this

	showPayment: (e) ->
		e.preventDefault()
		this.jsonView.fetchJSON(config.servicesBase + '/payments/' + this.model.get('idpaypal'))
		this.jsonView.$el.foundation 'open'
