
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
//	alert('document ready!');

	$("a").on('click', function (ev) {
		if ( $(this).attr('disabled') == 'disabled' ) {
			ev.preventDefault();
			return false;
		}
	});

	$(".btn_pdg_creator").click(function () {
		var pdgid = $(this).attr('id'); // =>pdg_of_type_1
//		console.log(pdgid);

		// retrieve the stub for the current paradigm
		var pdg = $("#stub_for_"+pdgid).clone(true);

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

		pdg.attr('id', ''); // otherwise it would be like: stub_for_pdg_of_type_3
//		console.log(pdg.attr(id)) // after

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

	// this works incorrectly for tables with dinamically disappearing rows
//	$(".table_of_tasks tbody tr:odd").css('background-color', 'beige');

	$(".btn_add_pdg_slot").click(function () {
		this_slot = $(this).closest(".pdg_slot"); 
		new_slot = this_slot.clone(true); // true tells to copy events as well

		c_slot = $(".paradigm .pdg_slot").length;

		// update id and name attributes:
		// replace stuff inside <NUMBER> with value of c_slot
		//   id="pdg_1_1_57_<1>_tag" name="pdg[1][1][57][<1>][tag]"
		//   id="pdg_1_1_57_<1>_100" name="pdg[1][1][57][<1>][100]"
		new_slot.find("input").each(function () {
			// name
//			console.log("NAME before: " + $(this).attr('name'));
			chunks = $(this).attr('name').split('][');
			chunks[chunks.length-2] = c_slot;
			if ( $(this).hasClass('word') ) {
				chunks[chunks.length-1] = 'word]'; // get rid of the old word id
			}
			$(this).attr('name', chunks.join(']['));
//			console.log("NAME after:  " + $(this).attr('name'));

			// id
//			console.log("ID before: " + $(this).attr('id'));
			chunks = $(this).attr('id').split('_');
			chunks[chunks.length-2] = c_slot;
			if ( $(this).hasClass('word') ) {
				chunks[chunks.length-1] = 'word'; // get rid of the old word id
			}
			$(this).attr('id', chunks.join('_'));
//			console.log("ID after:  " + $(this).attr('id'));
		});

		this_slot.after(new_slot);

		return false;
	});
});

