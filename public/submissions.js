$(function() {
    //hang on event of form with id=myform
    $("#tag-creation").submit(function(e) {

        //prevent Default functionality
        e.preventDefault();

        //do your own request an handle the results
        $.ajax({
                url: '/l',
                type: 'post',
                dataType: 'json',
                data: $("#tag-creation").serialize(),
                success: function(data) {
                    console.log(data);
                    $("#last-tag").html("<a href='" + data.link +"'>" + data.link + "</a>");
                }
        });

    });

});
