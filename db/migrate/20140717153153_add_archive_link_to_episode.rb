class AddArchiveLinkToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :archive, :string
  end
end
