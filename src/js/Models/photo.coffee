Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	url: '/'
	defaults :
		FileName: ""
		Title: ""
		Description: ""
		FileSize: ""
		Title: ""
		Width: ""
		Height: ""
		Extension: ""
		ExifImageDescription: ""
		ExifMake: ""
		ExifModel: ""
		ExifArtist: ""
		ExifCopyright: ""
		ExifExposureTime: ""
		ExifFNumber: ""
		ExifExposureProgram: ""
		ExifISOSpeedRatings: ""
		ExifDateTimeOriginal: ""
		ExifMeteringMode: ""
		ExifFlash: ""
		ExifFocalLength: ""

