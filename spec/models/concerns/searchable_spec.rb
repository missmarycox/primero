require 'spec_helper'

describe "Searchable" do

  before :each do
    Sunspot.remove_all(Child)
  end

  before :all do
    form = FormSection.new(:name => "test_form", :parent_form => 'case')
    form.fields << Field.new(:name => "text_field1", :type => Field::TEXT_FIELD, :display_name => "Text Field 1")
    form.fields << Field.new(:name => "tick_field1", :type => Field::TICK_BOX, :display_name => "Tick Field 1")
    form.fields << Field.new(:name => "tick_field2", :type => Field::TICK_BOX, :display_name => "Tick Field 2")
    form.fields << Field.new(:name => "date_field1", :type => Field::DATE_FIELD, :display_name => "Date Field 1")
    form.save!
  end

  after :all do
    FormSection.all.all.each { |form| form.destroy }
  end

  describe "Text Query" do

    it "should return empty array for no match" do
      pending "Write this test!"
    end

    it "should return an exact match" do
      pending "Write this test!"
    end

    it "should return a match that starts with the query" do
      pending "Write this test!"
    end

    it "should return a fuzzy match" do
      pending "Fuzzy search isn't implemented yet"
    end

    it "should search by exact match for short id" do
      pending "Write this test!"
    end


    it "should match more than one word" do
      pending "Write this test!"
    end

    it "should match more than one word with fuzzy search" do
      pending "Fuzzy search isn't implemented yet"
    end

    it "should match more than one word with starts with" do
      pending "Are we even doing startswith searches for names?"
    end
  end

  describe "Filtering" do
  end


  describe "Solr schema" do

    it "should build with date search fields" do
      expect(Child.searchable_date_fields).to include("created_at", "last_updated_at", "registration_date", "date_field1")
    end

    it "should build with boolean search fields" do
      expect(Child.searchable_boolean_fields).to include(
        'duplicate', 'flag', 'has_photo', 'record_state', 
        'case_status_reopened', 'tick_field1', 'tick_field2'
      )
    end

  end

end



