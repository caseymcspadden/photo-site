BaseView = require './base-view'
templates = require './jst'
config = require './config'
Products = require('./products')
Orders = require('./orders')
Downloads = require('./downloads')
AdminCatalogView = require ('./admin-catalog-view')
AdminOrdersView = require ('./admin-orders-view')
AdminDownloadsView = require ('./admin-downloads-view')

module.exports = BaseView.extend
	events:
		'click .catalog-menu' : 'openCatalog'
		'click .orders-menu' : 'openOrders'
		'click .downloads-menu' : 'openDownloads'

	fetched:
		catalog: false
		orders: false
		downloads: false

	initialize: (options) ->
		this.template = templates['admin-store-view']
		this.products = new Products
		this.orders = new Orders
		this.downloads = new Downloads
		this.adminCatalogView = new AdminCatalogView {collection: this.products}
		this.adminOrdersView = new AdminOrdersView {collection: this.orders}
		this.adminDownloadsView = new AdminDownloadsView {collection: this.downloads}

	render: ->
		this.$el.html this.template()
		this.assign this.adminCatalogView, '.admin-catalog-view'
		this.assign this.adminOrdersView, '.admin-orders-view'
		this.assign this.adminDownloadsView, '.admin-downloads-view'
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

	openDownloads: (e) ->
		e.preventDefault() if e
		if !this.fetched.downloads
			this.downloads.fetch {reset: true}
			this.fetched.downloads = true
		this.$('.store-view').addClass 'hide'
		this.$('.admin-downloads-view').removeClass 'hide'
