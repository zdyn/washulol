require_relative "migration_helper.rb"

Sequel.migration do
  change do
    create_table(:photo_previews) do
      primary_key :id
      DateTime :created_at
    end
    alter_table(:articles) do
      add_foreign_key :photo_preview_id, :photo_previews, :on_delete=>:cascade
    end
  end
end