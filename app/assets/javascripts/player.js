$(function(){
    function parse_timecode(hms) {
        var arr = hms.split(':');
        return parseFloat(arr[2]) + 
               60 * parseFloat(arr[1]) + 
               60*60 * parseFloat(arr[0]);
    }
    
    // TODO: offsets need to be recalculated when width changes.
    var $transcript = $('#transcript');
    $transcript.on('load', function(){
        var offset = {};
        $transcript.contents().find('[data-timecodebegin]').each(function(i,el){
            var $el = $(el);
            offset[parse_timecode($el.data('timecodebegin'))] = $el.position().top;
        });
        var sorted = Object.keys(offset).sort(function(a,b){return a - b;});
        // Browser seems to preserve key order, but don't rely on that.
        // JS default sort is lexicographic.
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
        
        var $player = $('#player-media');

        $player.on('timeupdate', function(){
            var current = $player[0].currentTime;
            var offset_key = greatest_less_than(current);
            var target = offset[offset_key];
            if (!$player.data('user-scroll')) {
                $('iframe').contents().scrollTop(target-30);
                // "-30" to get the speaker's name at the top;
                // TODO: tweak xslt to move time attributes
                // up to the containing element.
            }
        });
        
        $player.on('play', function(){
            $player.data('user-scroll', false);
        });
        
        $transcript.contents().find('.play-from-here').click(function(){
            $player[0].currentTime = parse_timecode($(this).data('timecode'));
            $player[0].play();
            $player.data('user-scroll', false);
        });
        
        $transcript.contents().scroll(function(){
            $player.data('user-scroll', true);
        });

    });
});
