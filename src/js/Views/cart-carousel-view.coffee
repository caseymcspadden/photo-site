BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		"click .prev" : "previousItem"
		"click .next" : "nextItem"

	initialize: (options) ->
		this.template = templates['cart-carousel-view']
		this.itemIndex = 0

	showItem: ->
		return if this.collection.length==0
		item = this.collection.at(this.itemIndex).toJSON()
		price = item.quantity * item.price
		this.$('.preview img').removeClass('show')
		this.$('#item-'+this.itemIndex+' img').addClass('show')
		this.$('.item-description').html(item.quantity + ' ' + item.description + ' $' + (price/100).toFixed(2))
		###
		img = this.$('#item-'+this.itemIndex+' img')[0]
		left = img.offsetLeft + (img.width * item.cropx)/100
		top = img.offsetTop + (img.height * item.cropy)/100
		width = (img.width * item.cropwidth)/100
		height = (img.height * item.cropheight)/100
		this.$('.crop-rect').css {left: left+'px', top: top+'px', height: height+'px', width: width+'px'}
		###

	previousItem: (e) ->
		this.itemIndex -= 1
		this.itemIndex = this.collection.length-1 if this.itemIndex < 0
		this.showItem()

	nextItem: (e) ->
		this.itemIndex += 1
		this.itemIndex = 0 if this.itemIndex == this.collection.length
		this.showItem()

	render: ->
		this.$el.html this.template {urlBase: config.urlBase, collection: this.collection}
		return if this.collection.length==0
		item = this.collection.at this.itemIndex
		self = this
		image = new Image()
		image.onload = ->
			self.showItem()
		image.src = config.urlBase + '/downloads/cartphoto/' + item.get('idcart') + '/' + item.id + '.jpg'		
		this