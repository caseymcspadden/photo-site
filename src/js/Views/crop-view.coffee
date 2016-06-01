BaseView = require './base-view'
templates = require './jst'
config = require './config'
require 'cropper'

module.exports = BaseView.extend
	events:
		'closed.zf.reveal' : 'closed'
		'click .save-crop' : 'saveCrop'

	initialize: (options) ->
		this.template = templates['crop-view']
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		this.$el.html this.template {urlBase: config.urlBase}

	open: (cartitem)->
		this.cartitem = cartitem
		item = cartitem.toJSON()
		this.$el.foundation 'open'
		$image = this.$('.crop-photo')
		$image.attr 'src' , config.urlBase + '/photos/M/' + cartitem.get('idphoto') + '.jpg'
		aspect = item.vsize / item.hsize
		aspect = 1/aspect if item.height > item.width

		this.$('.crop-photo').cropper({
			viewMode: 2
			aspectRatio: aspect
			autoCropArea: 0
			scalable: false
			rotatable: false
			zoomable: false
			background: false
			minCropBoxHeight: 300 
			###
			crop: (e) ->
				console.log(e.x);
				console.log(e.y);
				console.log(e.width);	
				console.log(e.height);
			###
			built: (e) ->
				img = $image.cropper('getImageData')
				canvas = $image.cropper('getCanvasData')
				console.log item
				console.log img
				console.log canvas
				data = {}
				data.width = Math.round(item.cropwidth * img.width / 100)
				data.height = Math.round(item.cropheight * img.height / 100)
				data.left = Math.round(canvas.left + item.cropx * img.width / 100)
				data.top = Math.round(canvas.top + item.cropy * img.height / 100)
				###
				data.width = 449
				data.height = 337
				data.left = 0 
				data.top = 0
				###
				console.log data
				$image.cropper('setCropBoxData' , data)
		})

	saveCrop: (e) ->
		e.preventDefault()
		$image = this.$('.crop-photo')
		img = $image.cropper('getImageData')
		canvas = $image.cropper('getCanvasData')
		crop = $image.cropper('getCropBoxData')

		this.cartitem.set 'cropwidth' , 100*(crop.width/img.width)
		this.cartitem.set 'cropx' , 100*((crop.left-canvas.left)/img.width)
		this.cartitem.set 'cropheight' , 100*(crop.height/img.height)
		this.cartitem.set 'cropy' , 100*((crop.top-canvas.top)/img.height)
		this.cartitem.set 'togglecrop' , !this.cartitem.get('togglecrop')
		this.cartitem.save()

		this.$el.foundation 'close'

	closed: ->
		this.$('.crop-photo').cropper('destroy')