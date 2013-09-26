
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
			if ( ! $(this).val() ) {
				$(this).attr('value', $("#current_word").text());
			}
		});
	});
};

function set_focus_to_editable_input(obj) {
	obj.find("input").filter(':visible').not("[disabled]").not("[readonly]").first().focus();
};

function do_on_document_ready() {

//	alert('document ready!');

	$("a").on('click', function (ev) {
		if ( $(this).attr('disabled') == 'disabled' ) {
			ev.preventDefault();
			return false;
		}
	});

	$(".btn_dismiss").on("click", function () {
		var section = $(this).attr("data-page-section-id");
		$("#" + section).remove();
		return false;
	});

	$(".btn_pdg_creator").on("click", function () {
		// keep the orignal value of href in old-href
		if (! $(this).attr("old-href")) {
			$(this).attr("old-href", $(this).attr("href"))
		}

		// build a new value of href based on old-href appending to it
		// a new parameter ?page_section_id=NUMBER
		$(this).attr("href", function () {
			var sep = "&";
			if ($(this).attr('old-href').indexOf('?') == -1) {
				sep = "?"
			}
			var num = $(".paradigms").children().length;
			var newhref = $(this).attr('old-href') + sep + "page_section_id=paradigm_data_" + num;
//			console.log("new href: " + newhref);
			return(newhref);
		});
	});

	// TODO: rewrite using set_click_to_copy.
	$(".click_to_copy").on("click", function () {
		parent = $(this).closest(".paradigm");
		parent.find("input.word[type='text']").each(function () {
			if ( ! $(this).val() ) {
				$(this).attr('value', $("#current_word").text());
			}
		});
	});

	// this works incorrectly for tables with dinamically disappearing rows
//	$(".table_of_tasks tbody tr:odd").css('background-color', 'beige');

	$(".btn_add_pdg_slot").on("click", function () {
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

			$(this).addClass('changed');
			$(this).addClass('new');
		});

		this_slot.after(new_slot);

		return false;
	});

	$(".btn_convert").on("click", function () {
		var action = $(this).attr("href");
		$(this).closest("form").attr("action", action).submit();
		return false;
	});

/*
	$("form").on("submit", function () {
		console.log("Form " + $(this).attr("id") + " submitted to action " + $(this).attr('action'));
	});
*/

	$(".btn_delete_pdg_slot").on("click", function () {
		// grey out the row
		this_slot = $(this).closest(".pdg_slot"); 
		this_slot.toggleClass('deleted');
		// set appropriate value (true/false) to the hidden field
		this_slot.find(".hdn_deleted").attr('value', this_slot.hasClass('deleted'));
		return false;
	});

	$(".btn_fill_with_word").on("click", function () {
		$(this).closest(".pdg_slot").find("input.word[type='text']").each(function () {
			// overwrite any existing value
			$(this).val($("#current_word").text()).trigger("keyup");
			// console.log(".attr(value)=" + $(this).attr("value"));
			// console.log(".val()=" + $(this).val());
		});
		return false
	});

	$(".paradigm input[type='text']").on('keyup', function (evt) {
		if ($(this).attr('value') == $(this).val() && !$(this).hasClass('new')) {
			// slots marked as class=new should never be unhighlighted
			$(this).removeClass('changed')
		} else {
			$(this).addClass('changed')
		}

		// navigation across word/tag fields
		klass = null;
		if ($(this).hasClass('word')) {
			klass = '.word'
		} else if ($(this).hasClass('tag')) {
			klass = '.tag'
		}

//		console.log("Current input: " + klass)

		switch(evt.keyCode) {
		case 38:
//			console.log("Up arrow pressed")
			$(this).closest(".pdg_slot").prev(".pdg_slot").find("input[type='text']").filter(klass).focus()
			break;
		case 40:
//			console.log("Down arrow pressed")
			$(this).closest(".pdg_slot").next(".pdg_slot").find("input[type='text']").filter(klass).focus()
			break;
		}

	});

	$(".paradigm input[type='radio']").on('change', function () {
		target = $(this).parents(".radioset")
		if ($(this).is(":checked") && $(this).attr('checked') == 'checked') {
			target.removeClass('changed')
		} else {
			target.addClass('changed')
		}
	});

};

$(document).on('ready', function() {
	do_on_document_ready();
});

