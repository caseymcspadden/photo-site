BaseView = require './base-view'
templates = require './jst'
config = require './config'
Products = require('./products')
Orders = require('./orders')
Archives = require('./archives')
AdminCatalogView = require ('./admin-catalog-view')
AdminOrdersView = require ('./admin-orders-view')
AdminArchivesView = require ('./admin-archives-view')

module.exports = BaseView.extend
	events:
		'click .catalog-menu' : 'openCatalog'
		'click .orders-menu' : 'openOrders'
		'click .archives-menu' : 'openArchives'

	fetched:
		catalog: false
		orders: false
		archives: false

	initialize: (options) ->
		this.template = templates['admin-store-view']
		this.products = new Products
		this.orders = new Orders
		this.archives = new Archives
		this.adminCatalogView = new AdminCatalogView {collection: this.products}
		this.adminOrdersView = new AdminOrdersView {collection: this.orders}
		this.adminArchivesView = new AdminArchivesView {collection: this.archives}

	render: ->
		this.$el.html this.template()
		this.assign this.adminCatalogView, '.admin-catalog-view'
		this.assign this.adminOrdersView, '.admin-orders-view'
		this.assign this.adminArchivesView, '.admin-archives-view'
		this.openCatalog()

	openCatalog: (e) ->
		e.preventDefault() if e
		if !this.fetched.catalog
			this.products.fetch {reset: true}
			this.fetched.catalog = true
		this.$('.store-view').addClass 'hide'
		this.$('.admin-catalog-view').removeClass 'hide'

	openOrders: (e) ->
		e.preventDefault() if e
		if !this.fetched.orders
			this.orders.fetch {reset: true}
			this.fetched.orders = true
		this.$('.store-view').addClass 'hide'
		this.$('.admin-orders-view').removeClass 'hide'

	openArchives: (e) ->
		e.preventDefault() if e
		if !this.fetched.archives
			this.archives.fetch {reset: true}
			this.fetched.archives = true
		this.$('.store-view').addClass 'hide'
		this.$('.admin-archives-view').removeClass 'hide'
