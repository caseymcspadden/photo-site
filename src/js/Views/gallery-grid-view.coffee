BaseView = require './base-view'
templates = require './jst'
PageView = require './gallery-grid-page'

module.exports = BaseView.extend
	events:
		'change .pager select' : 'changePage'

	initialize: (options) ->
		this.template = templates['gallery-grid-view']
		this.gridPages = []
		this.listenTo this.model.photos, 'reset', this.addAll

	render: ->
		this.$el.html this.template()
		this

	addAll: (collection) ->
		for i in [0...collection.length]
			if i%12 == 0
				pageView = new PageView {model: this.model, id: 'grid-' + this.gridPages.length}
				this.gridPages.push pageView
			this.gridPages[this.gridPages.length-1].addPhoto collection.at(i)

		for i in [0...this.gridPages.length]
			this.$('.pager select').append $("<option></option>").attr("value",i).text('' + (i+1) + ' of ' + this.gridPages.length)

		this.showPage 0
		
	changePage: (e) ->
		this.showPage e.target.value

	showPage: (n)->
		this.$('.content').html ''
		this.assign this.gridPages[n] , '.content'
