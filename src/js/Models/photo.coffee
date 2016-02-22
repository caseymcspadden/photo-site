Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	url: '/'
	defaults :
		FileName: ""
		FileSize: ""
		Title: ""
		Width: ""
		Height: ""
		Make: ""
		Model: ""
		Orientation: ""
		ImageDescription: ""
		DateTimeOriginal: ""
		Artist: ""
		Copyright: ""
		ExposureTime: ""
		FNumber: ""
		ExposureProgram: ""
		ISOSpeedRatings: ""
		ExifVersion: ""
		MeteringMode: ""
		Flash: ""
		FocalLength: ""

