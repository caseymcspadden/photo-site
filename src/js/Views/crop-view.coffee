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
				data = {}
				data.width = item.cropwidth * canvas.width / 100 
				data.height = item.cropheight * canvas.height / 100 
				data.left = canvas.left + item.cropx * canvas.width / 100 
				data.top = canvas.top + item.cropy * canvas.height / 100 
				$image.cropper('setCropBoxData' , data)
		})

	saveCrop: (e) ->
		e.preventDefault()
		$image = this.$('.crop-photo')
		img = $image.cropper('getImageData')
		canvas = $image.cropper('getCanvasData')
		crop = $image.cropper('getCropBoxData')

		this.cartitem.set 'cropwidth' , 100*(crop.width/canvas.width)
		this.cartitem.set 'cropx' , 100*((crop.left-canvas.left)/canvas.width)
		this.cartitem.set 'cropheight' , 100*(crop.height/canvas.height)
		this.cartitem.set 'cropy' , 100*((crop.top-canvas.top)/canvas.height)
		this.cartitem.set 'togglecrop' , !this.cartitem.get('togglecrop')
		this.cartitem.save()

		this.$el.foundation 'close'

	closed: ->
		this.$('.crop-photo').cropper('destroy')