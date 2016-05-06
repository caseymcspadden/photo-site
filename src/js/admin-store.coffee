$ = require 'jquery'
foundation = require 'foundation'
Products = require('../../require/products')
AdminProductsView = require('../../require/admin-products-view')

products = new Products
adminProductsView = new AdminProductsView {el: '.admin-products-view', collection: products}

adminProductsView.render()

$ ->
	$(document).foundation()
	products.fetch {reset: true}