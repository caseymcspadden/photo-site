Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	url: '/'
	defaults :
		selected: false
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

