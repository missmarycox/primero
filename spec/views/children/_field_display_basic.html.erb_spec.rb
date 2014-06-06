require 'spec_helper'

describe "children/_field_display_basic.html.erb" do
  it "It should display field label without ':' at the end" do
    text_field = Field.new :name => "child_name", :display_name => "Child Name Label", :type => 'text_field'
    child = Child.new
    child['child_name'] = "Child Name Value"

    render :partial => 'children/field_display_basic', :locals => { :field => text_field, :child => child }, :formats => [:html], :handlers => [:erb]

    #Test the exact content of the tags.
    rendered.should have_tag(".row .columns label.key[text()='Child Name Label']")
    rendered.should have_tag(".row .columns span.value[text()='Child Name Value']")
  end
end