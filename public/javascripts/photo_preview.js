function updatePreview(user_id, album_id, photo_id, dom_id) {
    var sepia_threshold;
    var solarize_threshold;
    var quantize_colors;
    var quantize_colorspace;
    var posterize_levels;
    var charcoal_radius;
    var charcoal_sigma;
    var despeckle;
    var enhance;
    var modulate_brightness;
    var modulate_saturation;
    var modulate_hue;
    var oil_paint_radius;
    var negate;

    sepia_threshold = $('sepia_threshold').value;
    solarize_threshold = $('solarize_threshold').value;
    if($('quantize_colors')) {
    	quantize_colors = $('quantize_colors').value;
    }
    if($('quantize_colorspace')) {
    	quantize_colorspace = $('quantize_colorspace').value;
    }
    posterize_levels = $('posterize_levels').value;
    charcoal_radius = $('charcoal_radius').value;
    charcoal_sigma = $('charcoal_sigma').value;
    despeckle = $('despeckle').value;
    enhance = $('enhance').value;
    modulate_brightness = $('modulate_brightness').value;
    modulate_saturation = $('modulate_saturation').value;
    modulate_hue = $('modulate_hue').value;
    oil_paint_radius = $('oil_paint_radius').value;
    negate = $('negate').value;

    // Build the query string
    var query_string = "";
    //query_string += "sepia%5bthreshold="+sepia_threshold+"%5d";
    query_string += "size=preview&";
    if(sepia_threshold != "") {
        query_string += "sepia%5Bthreshold%5D="+sepia_threshold+"&";
    }
    if(solarize_threshold != "") {
        query_string += "solarize%5Bthreshold%5D="+solarize_threshold+"&";
    }
    if(quantize_colors != "" && quantize_colorspace != "") {
        query_string += "quantize%5Bcolors%5D="+quantize_colors +
        "&quantize%5Bcolorspace%5D="+quantize_colorspace+"&";
    }
    if(posterize_levels != "") {
        query_string += "posterize%5Blevels%5D="+posterize_levels+"&";
    }
    if(charcoal_radius != "" && charcoal_sigma != "") {
        query_string += "charcoal%5Bradius%5D="+charcoal_radius+"&charcoal%5Bsigma%5D="+charcoal_sigma+"&";
    }
    if(despeckle == 1) {
        query_string += "despeckle=1&";
    }
    if(enhance == 1) {
        query_string += "enhance=1&";
    }
    if(modulate_brightness != "") {
        query_string += "modulate%5Bbrightness%5D="+modulate_brightness+"&";
    }
    if(modulate_saturation != "") {
        query_string += "modulate%5Bsaturation%5D="+modulate_saturation+"&";
    }
    if(modulate_hue != "") {
        query_string += "modulate%5Bhue%5D="+modulate_hue+"&";
    }
    if(oil_paint_radius != "") {
        query_string += "oil_paint%5Bradius%5D="+oil_paint_radius+"&";
    }
    if(negate == 1) {
        query_string += "negate=1&";
    }
    query_string += "dom_id="+dom_id;
    new Ajax.Request('/users/'+user_id+'/albums/'+album_id+'/photos/'+photo_id+'/edit?'+query_string,
        {asynchronous:true, evalScripts:true, method:'get'});
}
