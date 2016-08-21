$(function() {
    //hang on event of form with id=myform
    $("#link-submit").on('click', function(e) {
        e.preventDefault();

        var target = $("#url").val();

        $.ajax({
                url: '/l',
                type: 'post',
                dataType: 'json',
                data: { url: target },
                success: function(data) {
                    var link = [
                      '<div>',
                      '<span class="link-metric-url"><a href="/s/', data.tag, '"><span class="glyphicon glyphicon-signal"></span></a></span>',
                      '<span class="link-target-url"><a href="/l/', data.tag ,'"><span class="glyphicon glyphicon-tag"></span>', data.link,'</a></span>',
                      '</div>'
                    ];

                    $("#url").val("");
                    $("#add-failed").hide(100);
                    $("#link-panel").show(300, 'swing');
                    $("#links").append(link.join(""));
                },
                error: function() {
                    $("#add-failed").show(300, 'swing');
                }
        });

    });

});
