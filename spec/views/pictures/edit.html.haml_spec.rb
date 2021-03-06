require 'rails_helper'

RSpec.describe "pictures/edit", type: :view do
  before(:each) do
    @picture = assign(:picture, Picture.create!(
      :listing => nil,
      :url => "MyString",
      :caption => "MyString"
    ))
  end

  it "renders the edit picture form" do
    render

    assert_select "form[action=?][method=?]", picture_path(@picture), "post" do

      assert_select "input#picture_listing_id[name=?]", "picture[listing_id]"

      assert_select "input#picture_url[name=?]", "picture[url]"

      assert_select "input#picture_caption[name=?]", "picture[caption]"
    end
  end
end
