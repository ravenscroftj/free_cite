$.ajaxSetup ({
	cache: false
});


$(".citationEditor").ready(function(e){
	$("div.citationEditor").each(function(){
		var citeId = $(this).parent().attr('id').split("_")[1];
		$("#updateContainer_"+citeId).show();
	});
});

function enableEditor() {

	$('span.editField').editable(function(value, settings) { 
	    return(value);
	 }, { 
		event	: 'dblclick',
		tooltip	: 'Double click to edit text',
		placeholder	: "",
		style   : 'display: inline'
	});
}


$(function() {
	$(document).bind('textselect', function(e) {
		if(e.nodeId) {	
			var fieldTmp = e.nodeId.split("_");
			var oldField = fieldTmp[0], citeId = fieldTmp[1];
			$('#cite_'+citeId).data('editor', {'field': e.nodeId, 'value': e.text});			

		}
	});
	$(document).bind('textunselect', function(e) {
		if(e.nodeId) {	
			var fieldTmp = e.nodeId.split("_");
			var oldField = fieldTmp[0], citeId = fieldTmp[1];			
			$('#cite_'+citeId).removeData('editor');
		}
	});       
});

function fillPlaceHolder(txt, nodeId) {
	$("#placeHolder").val(txt);
	$("#idHolder").val(nodeId);
}

function updateField(fld, id) {
	var data = $('#cite_'+id).data('editor');

	if(!data.field.match(/^original_/)) {	
		$("#"+data.field).html($("#"+data.field).html().replace(data.value, ""));
	}
	
	
	if($("#textAction_"+id).val() == "replace") {
		$("#"+fld+"_"+id).html(data.value);
	} else if($("#textAction_"+id).val() == "append") {
		$("#"+fld+"_"+id).html($("#"+fld+"_"+id).html() + " " + data.value);
	} else if($("#textAction_"+id).val() == "prepend") {
		$("#"+fld+"_"+id).html(data.value + " " +  $("#"+fld+"_"+id).html());		
	} else if($("#textAction_"+id).val() == "remove") {
		$("#"+fld+"_"+id).html("");
	}
	$('#cite_'+id).removeData('editor');
	return false;
}

function replacePath(path) {
	p = window.location.pathname.split("/");
	p.pop();
	p.push(path);
	return p.join("/");
}

$(function() {
  $(".updateButton").click(function(event) {
	var buttonId = event.target.id;
	var citeId = buttonId.split("_")[1];
	//var formId = "form_"+citeId;
	var dataValues = {"id": citeId};

	$("#cite_"+citeId).children("span.editField").each(function(index) {
		var classes = $(this).attr("class").split(" ");		
		for(var i = 0; i < classes.length; i++) {
			if (classes[i] != "editField") {
				dataValues[classes[i]] = $(this).text();				
			}
		}
	});
	var dataString = $.param(dataValues);
	console.log(dataString);
	 //dataString=decodeURIComponent(dataString);
//	console.log(dataString);
// 
	$.ajax({
	  type: "POST",
	  url: replacePath("update"),
	  data: dataString,
	  success: function(html) {
		//var data = $.parseJSON(jsonData);
		//$("#updateContainer_"+citeId).hide();
		//displayAppropriateDiv(data, citeId);
		$("div#citation_"+citeId).html(html);		
	  }
	});
	return false;
  });
  $(".editButton").click(function(event) {
	var buttonId = event.target.id;
	var citeId = buttonId.split("_")[1];
	$("div#citation_"+citeId).load(replacePath("")+"edit/"+citeId);
	$("#editContainer_"+citeId).hide();
	$("#updateContainer_"+citeId).show();
	$("#floatMenu").show();
	return false;
  });
});
