
// example from SO
//	var create_form = $('form.create').clone();
//	2) Get the hidden input from the variable:
//	create_form.find(':hidden[name=form_id]').doSomething()...
// 	3) Place form after .edit link in the same row (I assume this is in an event handler):
//	$(this).closest('tr').find('a.edit').after( create_form );

//$('#test img').each(function(){
//   console.log($(this).attr('src'));
//});

$(document).ready(function() {
//	alert('hello');
	$("#btn_create_other_pdg").click(function () {
		var pdg = $("#pdg_stub_for_other").clone();
		// compute unique idx for pdg[idx][pdgid]... 
		var idx = $(".paradigms").children().length;
		// update the name attribute to have the above computer unique idx
		// pdg[0][other][notag][tag] -> pdg[idx][other][notag][tag]
		pdg.find("input").each(function () {
			// update NAME attribute
//			console.log($(this).attr('name')) // before
			newval = $(this).attr('name').replace(/pdg\[0\]/, "pdg["+idx+"]");
			$(this).attr('name', newval)
//			console.log($(this).attr('name')) // after

			// update ID attribute
//			console.log($(this).attr('id')) // before
			newval = $(this).attr('id').replace(/pdg\[0\]/, "pdg["+idx+"]");
			$(this).attr('id', newval)
//			console.log($(this).attr('id')) // after
		});
		// insert the current word into the text box for word
		pdg.find("input.word[type='text']").each(function () {
			$(this).attr('value', $("#current_word").text());
		})
		// insert as the first item in the container for paradigms
		$(".paradigms").prepend(pdg);
	});

	$(".click_to_copy").click(function () {
		parent = $(this).closest(".paradigm");
		parent.find("input.word[type='text']").each(function () {
			$(this).attr('value', $("#current_word").text());
		});
	});
});

