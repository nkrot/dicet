
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

/* 
   Pressing UP-ARROW when in word slot moves the focus to the PREVIOUS word slot.
   Pressing DOWN-ARROW when in word slot moves the focus to the NEXT word slot.
   The same logic works for the tag slot.
*/
function navigation_with_arrows(obj, evt) {

	klass = null;
	if ($(obj).hasClass('word')) {
		klass = '.word'
	} else if ($(obj).hasClass('tag')) {
		klass = '.tag'
	}

	switch (evt.keyCode) {
	case 38:
		// up-arrow pressed
		$(obj).closest(".pdg_slot").prev(".pdg_slot").find("input[type='text']").filter(klass).focus()
		break;
	case 40:
		// down-arrow pressed
		$(obj).closest(".pdg_slot").next(".pdg_slot").find("input[type='text']").filter(klass).focus()
		break;
	}
};

function do_on_document_ready() {

//	alert('document ready!');

	/*
	  NOTE: unbinding before binding using the following pattern does not work
	    xxx.off('click', function_name).on('click', function_name)
	  when do_on_document_ready() is run the second, third, so on times
	  Seems that function_name IDs have changed and .off() no longer recognizes the function
	 */

	$("a").on('click', function (ev) {
		if ( $(this).attr('disabled') == 'disabled' ) {
			ev.preventDefault();
			return false;
		}
	});

	$("#btn_generate_tasks").off('click').on('click', function () {
		$(this).addClass('disabled');
//		$(this).text('Wait...');
//		$(this).attr('value', 'Wait...'); // TODO: dangerous, the tokens_controller uses this value
		return true;
	});

	$(".btn_dismiss").off('click').on("click", function () {
		var section = $(this).attr("data-page-section-id");
		$("#" + section).remove();
		return false;
	});

	$(".btn_pdg_creator").off('click').on("click", function () {
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
	$(".click_to_copy").off('click').on('click', function () {
		$(this).closest(".paradigm").find("input.word[type='text']").each(function () {
			if ( ! $(this).val() ) {
				$(this).val($("#current_word").text());
			}
		}).trigger('keyup');
	});

	// this works incorrectly for tables with dinamically disappearing rows
//	$(".table_of_tasks tbody tr:odd").css('background-color', 'beige');

	$(".btn_add_pdg_slot").off("click").on("click", function () {
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

	$(".btn_convert").off('click').on("click", function () {
		var fields = $(this).closest("form").find("input[type='text']").filter(".word");
		var c_empty = fields.filter(function () { return this.value === '' }).length;

//		console.log(fields.length)
//		console.log(c_empty)

		if (c_empty == 0) {
			// all fields are filled in => no need to retrieve conversions
			alert('No conversions needed: all word slots are filled in')
/*
			var prev_bg_color = $(this).css('background-color');
			var prev_fg_color = $(this).css('color');
			console.log(prev_bg_color)
			console.log(prev_fg_color)
			$(this).parent().css('background-color', 'red');
			$(this).css('color', 'white');
			var ms = 3000;
			$(this).fadeOut(ms).fadeIn(ms).fadeOut(ms).fadeIn(ms).queue(function () {
				$(this).parent().css('background-color', prev_bg_color)
				$(this).css('color', prev_fg_color);
			}, 30000).dequeue();
*/
		} else if ( fields.length == c_empty ) {
			alert('Conversion impossible: not a sole base word given')

		} else {
			// submit the form
			var action = $(this).attr("href");
			$(this).closest("form").attr("action", action).submit();
		}
		return false;
	});

	$(".btn_search_word").off('click').on("click", function (e) {
		if (! $(this).attr("old-href")) {
			$(this).attr("old-href", $(this).attr("href"))
		}

		var word = $(this).closest(".pdg_slot").find("input.word[type='text']").val();
//		console.log("word='" + word + "'");

		$(this).attr("href", function () {
			var sep = "&";
			if ($(this).attr('old-href').indexOf('?') == -1) {
				sep = '?'
			}
			var newhref = $(this).attr('old-href') + sep + 'word=' + word;
			window.open(newhref, '_blank');
		});

		e.preventDefault; // but works w/o it
		return false;
	});

	$(".btn_search_all_words").off('click').on("click", function (e) {
		if (! $(this).attr("old-href")) {
			$(this).attr("old-href", $(this).attr("href"))
		}

		var word = $(this).closest(".paradigm")
			.find("input.word[type='text']").map(function () {
				return this.value === '' ? null : this.value
			}).get().join(' ');

		if (word === '') {
			alert('Nothing to search for: no word specified in this paradigm');
		} else {
			$(this).attr("href", function () {
				var sep = "&";
				if ($(this).attr('old-href').indexOf('?') == -1) {
					sep = '?'
				}
				var newhref = $(this).attr('old-href') + sep + 'word=' + word;
				window.open(newhref);
				return false;
			});
		}

		e.preventDefault; // but works w/o it
		return false;
	});

/*
	$("form").on("submit", function () {
		console.log("Form " + $(this).attr("id") + " submitted to action " + $(this).attr('action'));
	});
*/

	$(".btn_delete_pdg_slot").off("click").on("click", function () {
		// grey out the row
		this_slot = $(this).closest(".pdg_slot"); 
		this_slot.toggleClass('deleted');
		// set appropriate value (true/false) to the hidden field
		this_slot.find(".hdn_deleted").attr('value', this_slot.hasClass('deleted'));
		return false;
	});

	$(".btn_fill_with_word").off("click").on("click", function () {
		$(this).closest(".pdg_slot").find("input.word[type='text']").each(function () {
			// overwrite any existing value
			$(this).val($("#current_word").text()).trigger("keyup");
		});
		return false
	});

	$(".btn_fill_with_word").off("dblclick").on("dblclick", function (e) {
//		$(this).trigger("click"); // unnecessary as double click does not prevent single click
		$(this).closest(".paradigm").find(".btn_convert").trigger("click");
//		e.preventDefault() // has no effect?
	});

	// when text inputted in paradigm fields (tags or words) changes and is not
	// equal to the original text the element should be marked as 'changed'
	$(".paradigm input[type='text']").off('keyup').on('keyup', function (evt) {
		if (!$(this).hasClass('new')
			&& ($(this).attr('value') == $(this).val()
				|| !$(this).attr('value') && ! $(this).val()))
		{
			// slots marked as class=new should never be unhighlighted
			$(this).removeClass('changed')
		} else {
			$(this).addClass('changed')
		}
		navigation_with_arrows(this, evt);
	});

	// when a different button of the radiobutton is selected the element should
	// be marked as 'changed'
	$(".paradigm input[type='radio']").off('change').on('change', function () {
		target = $(this).parents(".radioset")
		if ($(this).is(":checked") && $(this).attr('checked') == 'checked') {
			target.removeClass('changed')
		} else {
			target.addClass('changed')
		}
	});

	$("#table_of_words .word a").off('click').on('click', function (e) {
		if (! $(this).attr("old-href")) {
			$(this).attr("old-href", $(this).attr("href"))
		}
		$(this).attr('href', function () {
			var cs = e.shiftKey ? "0" : "1"
			window.open($(this).attr('href') + "&casesensitive=" + cs, '_blank');
		});
		e.preventDefault;
		return false;
	});

	$("#table_of_words th a").off('click').on('click', function (e) {
		$(this).attr('href', function () {
			var newhref = $(this).attr('href');
			if ( $("#assigned").is(':checked') ) {
				newhref += "&assigned=1"
			}
			if ( $("#al").is(':checked') ) {
				newhref += "&al=1"
			}
			if ( $("#au").is(':checked') ) {
				newhref += "&au=1"
			}
			if ( $("#tc").is(':checked') ) {
				newhref += "&tc=1"
			}
//			console.log(newhref);
			return newhref;
		});
	});

	$("#chb_autoassign").off('change').on('change', function () {
		var btn = $('#btn_generate_tasks');
		if ($(this).is(":checked")) {
			/* TODO: update the link to include user id */
			var trg = "Take"
		} else {
			var trg = "Generate"
		}
//		btn.text(btn.text().replace(/^\S+/, trg)) // if <a>
		btn.attr('value', btn.attr('value').replace(/^\S+/, trg))
	})
};

$(document).on('ready', function() {
	do_on_document_ready();
});

