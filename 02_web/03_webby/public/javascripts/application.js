
// for locations
var initialize_map = function(lat, lon) {
  var myOptions = {
    zoom: 9,
    center: new google.maps.LatLng(lat, lon),
    mapTypeId: google.maps.MapTypeId.SATELLITE
  };
  return new google.maps.Map(document.getElementById('map_canvas'), myOptions);
}

//
//  TODO : add more javascript here to support features
//