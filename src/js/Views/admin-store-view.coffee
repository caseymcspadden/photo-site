BaseView = require './base-view'
templates = require './jst'
config = require './config'
Products = require('./products')
AdminCatalogView = require ('./admin-catalog-view')

module.exports = BaseView.extend
	events:
		'click .catalog-menu' : 'openCatalog'
		'click .orders-menu' : 'openOrders'
		'click .payments-menu' : 'openPayments'

	fetched:
		catalog: false
		orders: false
		payments: false

	initialize: (options) ->
		this.template = templates['admin-store-view']
		this.products = new Products
		this.adminCatalogView = new AdminCatalogView {collection: this.products}

	render: ->
		this.$el.html this.template()
		this.assign this.adminCatalogView, '.admin-catalog-view'
		this.openCatalog()

	openCatalog: ->
		if !this.fetched.catalog
			this.products.fetch {reset: true}
			this.fetched.catalog = true
		this.$('.store-view').addClass 'hide'
		this.$('.admin-catalog-view').removeClass 'hide'

	openOrders: ->
		this.$('.store-view').addClass 'hide'
		this.$('.admin-orders-view').removeClass 'hide'

	openPayments: ->
		this.$('.store-view').addClass 'hide'
		this.$('.admin-payments-view').removeClass 'hide'
