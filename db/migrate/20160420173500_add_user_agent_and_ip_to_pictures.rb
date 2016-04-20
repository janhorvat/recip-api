class AddUserAgentAndIpToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :user_agent, :string
    add_column :pictures, :user_ip, :string
  end
end
