$(function(){
    $('body').on('slide.bs.carousel', function(e) {
        var $next_next_img = $(e.relatedTarget).next().find('img');
        $next_next_img.attr('src', $next_next_img.attr('lazy-src'));
        // No harm done if src is already set, or if we're at the end of the list.
        // (If we only do the immediate "next", it hasn't actually loaded when the swap happens.) 
    }); 
});
