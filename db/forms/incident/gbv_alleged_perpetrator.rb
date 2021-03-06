alleged_perpetrator_subform_fields = [
  Field.new({"name" => "primary_perpetrator",
             "type" => "radio_button",
             "display_name_all" => "Is this the primary perpetrator?",
             "option_strings_text_all" => "Primary\nSecondary"
            }),
  Field.new({"name" => "perpetrator_sex",
             "type" => "radio_button",
             "display_name_all" => "Sex of Alleged Perpetrator",
             "option_strings_text_all" =>
                          ["Female",
                           "Male"].join("\n")
            }),
  Field.new({"name" => "former_perpetrator",
             "type" => "radio_button",
             "display_name_all" => "Past GBV by alledged perpetrator?",
             "option_strings_text_all" => "Yes\nNo"
            }),
  Field.new({"name" => "perpetrator_nationality",
             "type" => "select_box",
             "display_name_all" => "Nationality of alleged perpetrator",
             "option_strings_source" => "lookup Nationality"
            }),
  Field.new({"name" => "perpetrator_ethnicity",
             "type" => "select_box",
             "display_name_all" => "Clan or Ethnicity of alleged perpetrator",
             "option_strings_source" => "lookup Ethnicity"
            }),
  Field.new({"name" => "age_group",
             "type" => "select_box",
             "display_name_all" => "Age group of alleged perpetrator",
             "option_strings_text_all" =>
                          ["0-11",
                           "12-17",
                           "18-25",
                           "26-40",
                           "41-60",
                           "61+",
                           "Unknown"].join("\n")
            }),
  Field.new({"name" => "perpetrator_relationship",
             "type" => "select_box",
             "display_name_all" => "Alleged perpetrator relationship with survivor",
             "option_strings_text_all" =>
                          ["Intimate Partner / Former Partner",
                           "Primary Caregiver",
                           "Family other than spouse or caregiver",
                           "Supervisor / Employer",
                           "Schoolmate",
                           "Teacher / School Official",
                           "Service Provider",
                           "Cotenant / Housemate",
                           "Family Friend/Neighbor",
                           "Other refugee / IDP / Returnee",
                           "Other resident community member",
                           "Other",
                           "No relation",
                           "Unknown"].join("\n")
            }),
  Field.new({"name" => "perpetrator_occupation",
             "type" => "select_box",
             "display_name_all" => "Main occupation of alleged perpetrator (if known)",
             "option_strings_text_all" =>
                          ["Other",
                           "Unemployed",
                           "Unknown",
                           "Occupation 1",
                           "Occupation 2",
                           "Occupation 3",
                           "Occupation 4",
                           "Occupation 5"].join("\n")
            })
]

alleged_perpetrator_subform_section = FormSection.create_or_update_form_section({
  "visible" => false,
  "is_nested" => true,
  :order_form_group => 80,
  :order => 10,
  :order_subform => 1,
  :unique_id => "alleged_perpetrator",
  :parent_form=>"incident",
  "editable" => true,
  :fields => alleged_perpetrator_subform_fields,
  :initial_subforms => 1,
  "name_all" => "Nested Alleged Perpetrator Subform",
  "description_all" => "Nested Alleged Perpetrator Subform"
})

alleged_perpetrator_fields = [
  Field.new({"name" => "alleged_perpetrator",
             "type" => "subform", "editable" => true,
             "subform_section_id" => alleged_perpetrator_subform_section.unique_id,
             "display_name_all" => "Alleged Perpetrator"
            })
]

FormSection.create_or_update_form_section({
  :unique_id => "alleged_perpetrators_wrapper",
  :parent_form=>"incident",
  "visible" => true,
  :order_form_group => 80,
  :order => 10,
  :order_subform => 0,
  :form_group_name => "Alleged Perpetrator",
  "editable" => true,
  :fields => alleged_perpetrator_fields,
  "name_all" => "Alleged Perpetrator",
  "description_all" => "Alleged Perpetrator"
})
