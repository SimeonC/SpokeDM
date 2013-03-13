<!---
	This file is part of SpokeDM.

    SpokeDM is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SpokeDM is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SpokeDM.  If not, see <http://www.gnu.org/licenses/>.
--->
<!DOCTYPE html>
<!--- Place HTML here that should be used as the default layout of your application --->
<html lang="en">
	<head>
		<!--- make sure these tags stay in the header if you modify this page - they are needed for the spoke UI --->
		<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
		<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.0.4/angular.min.js"></script>
	    <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.0.4/angular-resource.min.js"></script>
	    <!--- bootstrap cdns hosted on MaxCDN - see http://www.bootstrapcdn.com/ --->
	    <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.0/js/bootstrap.min.js"></script>
		<link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.0/css/bootstrap.no-icons.min.css" rel="stylesheet">
		<link href="http://netdna.bootstrapcdn.com/font-awesome/3.0/css/font-awesome.css" rel="stylesheet">
		<link href="http://netdna.bootstrapcdn.com/font-awesome/3.0/css/font-awesome-ie7.css" rel="stylesheet">
	    <cfoutput>
			<script type="text/javascript">
				spokesBaseDataUrl = '#urlFor(route="spokeDataBase")#';
				spokesLinkDataUrl = '#urlFor(route="spokeLinkBase")#';
				spokesSearchDataUrl = '#urlFor(route="spokeSearchBase")#';
				spokesBaseViewUrl = '#urlFor(route="spokes")#';
				
				function LoginCtrl($scope){
					$scope.$on("SpokeUserLoggedOut", function(json){
						alert(json.loginerror);
						window.location.href = 'this-should-be-the-url-of-your-login-page';
					});
				}
			</script>
	    	#javascriptIncludeTag("spokes,angular.spokes,logic.spokes,data.spokes,bootstrap-datetimepicker.min,angular-strap.min,jquery.sticky,custom.spokes")#
	    	#styleSheetLinkTag("spokes,bootstrap-datetimepicker.min")#
	    </cfoutput>
	</head>
	<body ng-app="spokes">
		<cfoutput>#includeContent()#</cfoutput>
		<!---
		
		Uncomment this and complete the LoginCtrl Controller in the script block above if you wish to use a dynamic login popup
		Else a simple redirect will be used
		
		<div ng-controller="LoginCtrl">
		</div>
		--->
	</body>
</html>
