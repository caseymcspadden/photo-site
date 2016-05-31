Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		idphoto: 0
		idcontainer: 0
		idproduct: ''
		type: ''
		description: ''
		hsize: 0
		vsize: 0
		hsizeprod: 0
		vsizeprod: 0
		hres: 0
		vres: 0		
		shippingtype: ''
		attributes: ''
		price: 0
		quantity: 1
		cropx: 0
		cropy: 0
		cropwidth: 100
		cropheight: 100
		togglecrop: false
