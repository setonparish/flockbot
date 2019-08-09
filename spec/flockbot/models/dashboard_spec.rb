require "spec_helper"

RSpec.describe "Flockbot::Models::Dashboard", :vcr do

  let(:service) { Flockbot::Models::Dashboard.new(html_snippit) }

  let(:html_snippit) {
    <<-HTML
      <div class="network_around page page_network on" data-networkid="16999" data-unolytics="1"></div>
      <input type="file" class="change_network_photo upload_button" data-type="photo/group" data-itemid="19990" />
    HTML
  }

  describe "#network_id" do
    it "extracts the network id" do
      expect(service.network_id).to eq("16999")
    end
  end

  describe "#everyone_group_id" do
    it "extracts the network id" do
      expect(service.everyone_group_id).to eq("19990")
    end
  end
end
