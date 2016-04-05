Backbone = require 'backbone'
Session = require './session'
Settings = require './settings'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit form' : 'saveSettings'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.viewModel = options.viewModel
		this.template = templates['admin-settings-view']
		this.listenTo this.model, 'change', this.settingsChanged
		this.listenTo this.viewModel.containers, 'change', this.populateForm

	settingsChanged: (settings) ->
		console.log "Settings Changed"
		console.log this.model
		this.populateForm()

	populateForm: ->
		selectPortfolio = this.$('select[name="portfoliofolder"]')
		selectGallery = this.$('select[name="featuredgallery"]')

		selectPortfolio.html ''
		selectGallery.html ''

		this.viewModel.containers.each( (container) ->
			$option = $("<option></option>").attr("value",container.id).text(container.get('name'))
			if container.get('type') == 'folder'
				$option.attr("selected","1") if container.id == this.model.get('portfoliofolder')
				selectPortfolio.append($option)
			else
				$option.attr("selected","1") if container.id == this.model.get('featuredgallery')
				selectGallery.append($option)
		, this)

	saveSettings: (e) ->
		e.preventDefault()
		console.log this.model
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name] =  elem.value
		this.model.save data

	render: ->
		this.$el.html this.template()
		this
