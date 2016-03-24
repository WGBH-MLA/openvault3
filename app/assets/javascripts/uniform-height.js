$(function(){
    var $infos = $('.blacklight-collections .info, .blacklight-exhibits .info');
    var heights = $.map(
            $infos,
            function (el) {
                return $(el).height();
            }
        );
    $infos.height(Math.max.apply(null, heights));
});
