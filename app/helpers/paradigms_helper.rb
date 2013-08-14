module ParadigmsHelper

  # generates code like this:
  # label_tag        :ready,            "Ready"
  # radio_button_tag 'pdg[nn][status]', "ready", checked=1
  # label_tag        :review,           "Review later"
  # radio_button_tag 'pdg[nn][status]', "review"
  #
  # NOTE:
  # in haml, use it as
  # != radio_button_for_status "nn"
  # where != tells haml not to sanitize the html code but render it literally
  #
  def radio_button_for_status pdg_type
    code = ""

    code << label_tag(:ready, "Ready")
    code << radio_button_tag("pdg[#{pdg_type}][status]", "ready", checked=1)

    code << label_tag(:review, "Review later")
    code << radio_button_tag("pdg[#{pdg_type}][status]", "review")

    code
  end

end
