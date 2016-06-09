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
		this.$('.cropper-face').removeClass 'warning'
		this.$('.error-message').addClass 'hide'
		this.$('.save-crop').removeClass 'disabled'

		this.$el.foundation 'open'
		$image = this.$('.crop-photo')
		$image.attr 'src' , config.urlBase + '/photos/M/' + cartitem.get('idphoto') + '.jpg'
		aspect = item.vsize / item.hsize
		aspect = 1/aspect if item.height > item.width
		minheight = 0
		minwidth = 0
		self = this

		this.$('.dimensions').html('' + item.hsize + ' x ' + item.vsize)

		this.$('.crop-photo').cropper({
			viewMode: 2
			aspectRatio: aspect
			autoCropArea: 0
			scalable: false
			rotatable: false
			zoomable: false
			background: false
			crop: (e) ->
				if (e.width<minwidth or e.height<minheight)
					self.$('.cropper-face').addClass 'warning'
					self.$('.error-message').removeClass 'hide'
					self.$('.save-crop').addClass 'disabled'
				else
					self.$('.cropper-face').removeClass 'warning'
					self.$('.error-message').addClass 'hide'
					self.$('.save-crop').removeClass 'disabled'
			built: (e) ->
				imageData = $image.cropper('getImageData')
				canvas = $image.cropper('getCanvasData')
				minheight = if item.width > item.height then imageData.naturalHeight*item.hres/item.height else imageData.naturalHeight*item.vres/item.height
				minwidth = if item.width > item.height then imageData.naturalWidth*item.vres/item.width else imageData.naturalWidth*item.hres/item.width
				minheight *= 1.05
				minwidth *= 1.05
				data = {}
				data.width = Math.round(item.cropwidth * imageData.width / 100)
				data.height = Math.round(item.cropheight * imageData.height / 100)
				data.left = Math.round(canvas.left + item.cropx * imageData.width / 100)
				data.top = Math.round(canvas.top + item.cropy * imageData.height / 100)
				$image.cropper 'setCropBoxData' , data
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