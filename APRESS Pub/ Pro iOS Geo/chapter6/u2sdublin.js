//Declare some global variables for use in various functions
var layer = null;
var positionCoordinates = null; 
var map = null; 
var marker = null; 
var statusButton = 0;
var initialCenter = null; 
var watchId = null; 


function initialize() {
   
    //Define a custom style and create a styled map type
   var customStyle = [ {
      "elementType" : "geometry", 
      "stylers" : [ {
         "visibility" : "simplified" }
      ] }
   , {
      "stylers" : [ {
         "invert_lightness" : true }
      , {
         "hue" : "#00bbff" }
      ] }
   , {
      "featureType" : "landscape.man_made", 
      "elementType" : "labels", 
      "stylers" : [ {
         "visibility" : "simplified" }
      ] }
   , {
      "featureType" : "water", 
      "stylers" : [ {
         "invert_lightness" : true }
      ] }
   ]
    
    var styledMap = new google.maps.StyledMapType(customStyle,
   {
      name : "Map" }
   ); 
   
    // Set initial center for the map
   initialCenter = new google.maps.LatLng(53.344104, 
   - 6.267494); 
   var myOptions = {
      center : initialCenter, zoom : 12,
      //Include the new MapTypeId for custom style to add to the map type control.
      mapTypeControlOptions : {
         mapTypeIds : ['map_style', 
         google.maps.MapTypeId.HYBRID] }
      }
   map = new google.maps.Map(document.getElementById("map_canvas"), 
   myOptions); 
   
    //Link the MapTypeId with the styled map type created
   map.mapTypes.set('map_style', styledMap); 
   
    //Set the new map type ID so that is shown as default map type
   map.setMapTypeId('map_style'); 
   
    //Show a splash screen until map tiles are loaded
   google.maps.event.addListener(map, 'tilesloaded', function () {
      document.getElementById("tilesSplashScreen").style.display = 'none'; }
   ); 
   
    //Launch a Fusion Tables query that shows all POIs on the map
   layer = new google.maps.FusionTablesLayer( {
      query : {
         select : 'geometry', 
         from : '1jNiw87Mm_r6wWvmirKgq2AqCh9cqxokJ5frDW_s' }
      , map : map }
   ); 
   }

//Launch a Fusion Tables query to show a POI according to the user's selection
function selectPlace() {
   var optionsList = document.getElementById("select-choice-min"); 
   var requestedPlace = optionsList.options[optionsList.selectedIndex].value; 
   var where = "name CONTAINS IGNORING CASE '" + requestedPlace + "'"; 
   layer.setOptions( {
      query : {
         select : 'geometry', 
         from : '1jNiw87Mm_r6wWvmirKgq2AqCh9cqxokJ5frDW_s', 
         where : where }
      }
   ); 
   map.setZoom(12); 
   map.setCenter(initialCenter); 
   }

//Show all POIs on the map and set the map to the initial zoom level and centering
function showAll() {
   layer.setOptions( {
      query : {
         select : 'geometry', 
         from : '1jNiw87Mm_r6wWvmirKgq2AqCh9cqxokJ5frDW_s' }
      }
   ); 
   map.setZoom(12); 
   map.setCenter(initialCenter); 
   }

//Show the two POis nearest to the user's current position
function nearestSpots() {
   if (statusButton == 0) {
      watchId = navigator.geolocation.watchPosition(function (position) {
         if (positionCoordinates == null) {
            positionCoordinates = new google.maps.LatLng(position.coords.latitude, 
            position.coords.longitude); 
            marker = new google.maps.Marker( {
               position : positionCoordinates, 
               icon : "blue_dot_circle.png", 
               map : map }
            ); 
            map.setCenter(positionCoordinates); 
            map.setZoom(13);
            layer.setOptions( {
               query : {
                  select : 'geometry', 
                  from : '1jNiw87Mm_r6wWvmirKgq2AqCh9cqxokJ5frDW_s', 
                  orderBy : "ST_DISTANCE('geometry', LATLNG(" + position.coords.latitude + ',' + position.coords.longitude + "))", 
                  limit : 2 }
               }
            ); 
            document.getElementById('nearestSpotsText').style.color = "yellow";
            statusButton = 1;
            }
         else {
            positionCoordinates = new google.maps.LatLng(position.coords.latitude, 
            position.coords.longitude); 
            layer.setOptions( {
               query : {
                  select : 'geometry', 
                  from : '1jNiw87Mm_r6wWvmirKgq2AqCh9cqxokJ5frDW_s', 
                  orderBy : "ST_DISTANCE('geometry', LATLNG(" + position.coords.latitude + ',' + position.coords.longitude + "))", 
                  limit : 2 }
               }
            ); 
            map.setCenter(positionCoordinates); 
            marker.setPosition(positionCoordinates); 
            }
         }
      , 
      function (error) {
         var typeOfError = error.code; 
         switch (typeOfError) {
            case (1) : alert("No geolocation activated. If you want to use this function, please activate Location Services for this app, then close and restart the app."); 
            break; 
            case (2) : alert("Position unavailable"); 
            break; 
            case (3) : alert("Timeout error"); 
            break; 
            }
         document.getElementById('nearestSpotsText').style.color = "white";
         statusButton = 0;
         }
      , 
      {
         enableHighAccuracy : true }
      );
       
      }
   else //Stop the gelocation process and reset the map to the initial view
   {
      alert("Geolocation stopped"); 
      navigator.geolocation.clearWatch(watchId); 
      positionCoordinates = null; 
      marker.setMap(null); 
      marker = null; 
      showAll(); 
      document.getElementById('nearestSpotsText').style.color = "white"; 
      statusButton = 0; 
      }
   }