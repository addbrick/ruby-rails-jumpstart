$(document).ready(function(){
	$.ajaxSetup ({
		cache: false
	});

	var ajax_loading = "<img src='http://d2o0t5hpnwv4c1.cloudfront.net/412_ajaxCalls/DEMO/img/load.gif' alt='Loading....' />";

	// New Query
	$('a[data-remote], form[data-remote]').live("ajax:beforeSend", function(){
		//alert("Before");
	}).live('ajax:success', function(evt, data, status, xhr){
		$('.centerbox').html(data);
		//alert("Success!");
	}).live("ajax:complete", function(){
		//alert("Complete");
	}).live("ajax:error", function(xhr, status, error){
		alert("Error");
	});

	$('#showAlert').click(function() {
		alert("WTF!!!");
	});
});