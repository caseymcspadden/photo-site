Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlBase: config.urlBase + '/services/photos'
	defaults :
		selected: false
		fileName: ""
		title: ""
		description: ""
		keywords: ""
		fileSize: ""
		width: ""
		height: ""
		extension: ""
		exifImageDescription: ""
		exifMake: ""
		exifModel: ""
		exifArtist: ""
		exifCopyright: ""
		exifExposureTime: ""
		exifFNumber: ""
		exifExposureProgram: ""
		exifISOSpeedRatings: ""
		exifDateTimeOriginal: ""
		exifMeteringMode: ""
		exifFlash: ""
		exifFocalLength: ""

