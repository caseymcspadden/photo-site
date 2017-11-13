Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlBase: config.servicesBase + '/photos'
	defaults :
		selected: false
		chosen: false
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
		exifLensModel: ""
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

