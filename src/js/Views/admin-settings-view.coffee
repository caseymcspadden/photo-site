Backbone = require 'backbone'
BaseView = require './base-view'
Session = require './session'
Settings = require './settings'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'submit form' : 'saveSettings'
		'open.zf.reveal' : 'open'		

	initialize: (options) ->
		this.paths = new Backbone.Collection null , {comparator: 'path'}
		this.paths.url = config.servicesBase + '/containerpaths'
		this.template = templates['admin-settings-view']

	open: ->
		this.populateForm()

	populateForm: ->
		selectPortfolio = this.$('form select[name="portfoliofolder"]')
		selectGallery = this.$('form select[name="featuredgallery"]')

		selectPortfolio[0].options.length=0
		selectGallery[0].options.length=0

		self = this
		
		this.paths.fetch(
			success: (collection) ->
				idportfoliofolder = self.model.get('portfoliofolder')
				idfeaturedgallery = self.model.get('featuredgallery')
				collection.each( (container) ->
					$option = $("<option></option>").attr("value",container.id).text(container.get('path'))
					if container.get('type') == 'folder'
						$option.attr("selected","1") if container.id == idportfoliofolder
						selectPortfolio.append($option)
					else
						$option.attr("selected","1") if container.id == idfeaturedgallery
						selectGallery.append($option)
				)
		)

	saveSettings: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name] =  elem.value
		this.model.save data

	render: ->
		this.$el.html this.template()
		this
