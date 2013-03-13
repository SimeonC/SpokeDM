<!--- when including this on other pages, ensure you create your own implementation of the search.select function (passed into the SPSearchLogic factory) --->
<!--- If search settings aren't set, don't show this at all! --->
<cfif StructKeyExists(APPLICATION, "spokesearch") && ArrayLen(APPLICATION.spokesearch)><div class="row-fluid spoke-header">
	<div class="span3"><!--- you could put a dropdown menu here ---></div>
	<div class="span6">
		<div class="spoke-search span6" ng-mouseenter="search.mouseover = true" ng-mouseleave="search.mouseover = false" ng-class="{'searching': search.mouseover || search.focussed}" sp-sticky top-spacing="0">
			<div class="search-bar pull-left navbar-search">
				<input name="MainSearchbox" type="text" class="search-query" ng-model="search.searchstring.$" ng-hasfocus="search.focussed" placeholder="Start Typing to Search...">
			</div>
			<div class="results">
				<p ng-show="search.searchstring.$ == ''">Click on the following to select <i class="icon-circle active"></i> or deselect Spokes to search within.
					<button class="btn btn-link pull-right" ng-click="search.deselectAll()">Deselect All</button><button class="btn btn-link pull-right" ng-click="search.selectAll()">Select All</button></p>
				<div class="navbar">
					<div class="navbar-inner">
						<a class="brand">Search {{search.title()}}</a>
						<a class="scroll-nav" ng-show="search.scrollnav()"><i ng-click="search.scrollright()" class="icon-chevron-left grey"></i></a>
						<div class="scroller" ng-class="{'scroll-nav': search.scrollnav()}">
							<ul class="nav">
								<li ng-repeat="axle in search.results" ng-class="{'active': axle.active()}" ng-show="axle.show()"><a ng-click="axle.click()">
									{{axle.title}}&nbsp;{{axle._querying}}
									<i ng-class="{'icon-circle': !axle.loading(), 'icon-spinner icon-spin': axle.loading()}" ng-show="search.searchstring.$ == '' || axle.loading()"></i>
									<span class="badge" ng-class="{'badge-success': axle.active()}" ng-hide="search.searchstring.$ == '' || axle.loading()">{{axle.count()}}</span>
								</a></li>
							</ul>
						</div>
						<a class="scroll-nav pull-right" ng-show="search.scrollnav()"><i class="icon-chevron-right grey" ng-click="search.scrollleft()"></i></a>
					</div>
				</div>
				<div class="display navbar-inner" ng-show="search.searchstring.$ != ''">
					<div class="loading" ng-show="!search.current || search.totalcount() <= 0">
						<h2 ng-show="search.isquerying()">Querying... <i class="icon-spinner icon-spin"></i></h3>
						<h2 ng-hide="search.isquerying()">No Results</h2>
					</div>
					<div class="table-scroller-wrapper" ng-show="search.current && search.totalcount() > 0">
						<div class="table-scroller-inner">
							<table class="table table-striped table-hover table-condensed">
								<thead>
									<tr>
										<th style="width: 180px;" ng-show="search.totalcount() < 10">Spoke</th>
										<th style="width: 180px;">Name</th>
										<th>Description</th>
									</tr>
								</thead>
								<tbody ng-repeat="axle in search.results" ng-show="search.totalcount() < 10 || axle == search.current">
									<tr ng-repeat="row in axle.rows | limitTo: 10" ng-click="search.select(axle, row)">
										<td style="width: 180px;" ng-show="search.totalcount() < 10">{{axle.title}}</td>
										<td style="width: 180px;">{{row.name}}</td>
										<td ng-bind-html-unsafe="row.description">&nbsp;</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="span3"><!--- or maybe a logout button here---></div>
</div></cfif>
