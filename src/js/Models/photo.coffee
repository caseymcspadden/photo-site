Backbone = require 'backbone'
require 'backbone-relational'

module.exports = Backbone.RelationalModel.extend
	url: '/'
	defaults :
		fileName: ""
		title: ""
		description: ""
		fileSize: ""
		title: ""
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

