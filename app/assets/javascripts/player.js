$(function(){
    function parse_timecode(hms) {
        var arr = hms.split(':');
        return arr[2] + 60*arr[1] + 60*60*arr[0];
    }
    
    // TODO: offsets need to be recalculated when width changes.
    var $transcript = $('#transcript');
    $transcript.on('load', function(){
        var offset = {};
        $transcript.contents().find('[data-timecodebegin]').each(function(i,el){
            var $el = $(el);
            offset[parse_timecode($el.data('timecodebegin'))] = $el.position().top;
        });
        //offset[0].delete();
        var sorted = Object.keys(offset).sort();
        function greatest_less_than(t) {
            var last = 0;
            for (var i=0; i < sorted.length; i++) {
                if (sorted[i] < t) {
                    last = sorted[i];
                } else {
                    return last;
                }
            }
        };

        $('#player-media').on('timeupdate', function(){
            var current = $('#player-media')[0].currentTime;
            var offset_key = greatest_less_than(current);
            $('iframe').contents().scrollTop(offset[offset_key]);
        });

    });
});
