require "spec_helper"

RSpec.describe "Flockbot::Models::Dashboard", :vcr do

  let(:service) { Flockbot::Models::Dashboard.new(html_snippit) }

  let(:html_snippit) {
    <<-HTML
      <div class="network_around page page_network on" data-networkid="16999" data-unolytics="1"></div>
      <input type="file" class="change_network_photo upload_button" data-type="photo/group" data-itemid="19990" />
      <div class="group_item group_item_group_id_452330 group_type_hidden" data-groupid="888889" data-shortname="BellChoir" data-shortnamesearch="bellchoir" data-parentgroup="777777">
        <div class="group_name">Bell Choir</div>
      </div>
      <div class="group_item group_item_group_id_452330 group_type_hidden" data-groupid="999999" data-shortname="Lunch" data-shortnamesearch="lunch" data-parentgroup="777777">
        <div class="group_name">Lunch</div>
      </div>
    HTML
  }

  describe "#everyone_group_id" do
    it "extracts the network id" do
      expect(service.everyone_group_id).to eq("19990")
    end
  end

  describe "#group_attributes" do
    it "extracts the group properties" do
      expect(service.group_attributes).to eq([
        {id: "888889", name: "Bell Choir", short_name: "BellChoir"},
        {id: "999999", name: "Lunch", short_name: "Lunch"},
      ])
    end
  end
end
