
// example from SO
//	var create_form = $('form.create').clone();
//	2) Get the hidden input from the variable:
//	create_form.find(':hidden[name=form_id]').doSomething()...
// 	3) Place form after .edit link in the same row (I assume this is in an event handler):
//	$(this).closest('tr').find('a.edit').after( create_form );

//$('#test img').each(function(){
//   console.log($(this).attr('src'));
//});

function set_click_to_copy(obj) {
	obj.find(".click_to_copy").click(function () {
		parent = $(this).closest(".paradigm");
		parent.find("input.word[type='text']").each(function () {
			$(this).attr('value', $("#current_word").text());
		});
	});
};

function set_focus_to_editable_input(obj) {
	obj.find("input").filter(':visible').not("[disabled]").not("[readonly]").first().focus();
};

$(document).ready(function() {
//	alert('hello');

	$(".btn_pdg_creator").click(function () {
		var pdgid = $(this).attr('id'); // =>pdg_of_type_1
//		console.log(pdgid);

		// retrieve the stub for the current paradigm
		var pdg = $("#stub_for_"+pdgid).clone();

		// compute unique idx for pdg[idx][pdgid]... 
		var idx = $(".paradigms").children().length;

		// update the name/id attributes to reflect the above computed unique idx
		// pdg[0][pdgid][tagid]["tag"] -> pdg[idx][pdgid][tagid]["tag"]
		pdg.find("input").each(function () {
			// update NAME attribute
//			console.log($(this).attr('name')) // before
			newval = $(this).attr('name').replace(/pdg\[0\]/, "pdg["+idx+"]");
			$(this).attr('name', newval)
//			console.log($(this).attr('name')) // after

			// update ID attribute
//			console.log($(this).attr('id')) // before
			newval = $(this).attr('id').replace(/pdg_0_/, "pdg_"+idx+"_");
			$(this).attr('id', newval)
//			console.log($(this).attr('id')) // after
		});

		// update 'label for' similarly to input.NAME and input.ID 
		pdg.find("label").each(function () {
			// update label.FOR attribute
			newval = $(this).attr('for').replace(/pdg_0_/, "pdg_"+idx+"_");
			$(this).attr('for', newval);
		});

		pdg.attr('id', '') // otherwise it would be like: stub_for_pdg_of_type_3
//		console.log(pdg.attr(id)) // after

		//
//		if ( $(this).attr('id') == "pdg_of_type_other" ) {
//			// insert the current word into the text box for word
//			pdg.find("input.word[type='text']").each(function () {
//				$(this).attr('value', $("#current_word").text());
//			});
//		};

		// attach handlers of clicks to a.click_to_copy
		set_click_to_copy(pdg);

		// insert as the first item in the container for paradigms
		$(".paradigms").prepend(pdg);

		set_focus_to_editable_input(pdg);
	});

	// TODO: rewrite using set_click_to_copy.
	$(".click_to_copy").click(function () {
		parent = $(this).closest(".paradigm");
		parent.find("input.word[type='text']").each(function () {
			$(this).attr('value', $("#current_word").text());
		});
	});
});


/*
	$("#btn_create_other_pdg").click(function () {
		var pdg = $("#pdg_stub_for_other").clone();
		// compute unique idx for pdg[idx][pdgid]... 
		var idx = $(".paradigms").children().length;
		// update the name attribute to reflect the above computed unique idx
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
*/
