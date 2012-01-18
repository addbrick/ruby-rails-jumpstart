function runQuery() {
  var queryUrl = "http://search.twitter.com/search.json?q=" + $('#query').text().trim().replace(/\s/g,"%20") + '&callback=?';
  $.getJSON(queryUrl, function(json){
    $('img').remove();
    $.each(json.results, function(i, tweet){
      tweet.text = twttr.txt.autoLink(tweet.text);
      $('.centerbox').append('<h2>' + tweet.from_user_name + '</h2><h3>@' + tweet.from_user + '</h3><p>' + tweet.text + '</p><p>' + tweet.created_at + '</p><hr size="1" width="300">');
    });
    $('.centerbox').append('<p>End</p>');
  });
}

$(document).ready(function(){
	$.ajaxSetup ({
		cache: false
	});

	// New Query
	$('a[data-remote], form[data-remote]').live("ajax:beforeSend", function(){
		//alert("Before");
	}).live('ajax:success', function(evt, data, status, xhr){
		$('.centerbox').html(data);
		if ($('#query').length > 0){
		  runQuery();
		}
		//alert("Success!");
	}).live("ajax:complete", function(){
		//alert("Complete");
	}).live("ajax:error", function(xhr, status, error){
		alert("Error");
	});
});