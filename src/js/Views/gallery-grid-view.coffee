BaseView = require './base-view'
templates = require './jst'
PageView = require './gallery-grid-page'

module.exports = BaseView.extend
	events:
		'change .pager select' : 'changePage'
		'click .prev' : 'scrollLeft'
		'click .next' : 'scrollRight'

	initialize: (options) ->
		this.template = templates['gallery-grid-view']
		this.gridPages = []
		this.currentPage = -1
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

	scrollLeft: ->
		val = parseInt this.$('.pager select').val()
		if val > 0
			this.$('.pager select').val(val-1)
			this.showPage(val-1)
		
	scrollRight: ->
		val = parseInt this.$('.pager select').val()
		if val < this.gridPages.length-1
			this.$('.pager select').val(val+1)
			this.showPage(val+1)

	changePage: (e) ->
		this.showPage e.target.value

	showPage: (n) ->
		this.$('.content').html ''
		this.gridPages[this.currentPage].undelegateEvents() if this.currentPage>=0
		this.currentPage=n
		this.assign this.gridPages[n] , '.content'
		this.model.photos.at(n*12).set 'selected' , true
