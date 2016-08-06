$ = require 'jquery'
require 'foundation'
#Products = require('../../require/products')
#AdminProductsView = require('../../require/admin-products-view')
AdminStoreView = require('../../require/admin-store-view')

#products = new Products
#adminProductsView = new AdminProductsView {el: '.admin-products-view', collection: products}

#adminProductsView.render()

adminStoreView = new AdminStoreView {el: '.admin-store-view'}

adminStoreView.render()

$ ->
	$(document).foundation()
	#products.fetch {reset: true}