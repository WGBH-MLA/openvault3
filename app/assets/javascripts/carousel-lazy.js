$(function(){
    $('body').on('slide.bs.carousel', function(e) {
        var next_up = $(e.relatedTarget).find('img');
        next_up.attr('src', next_up.attr('lazy-src'));
    }); 
})
