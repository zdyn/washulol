require_relative "migration_helper.rb"

Sequel.migration do
  change do
    alter_table(:articles) do
      add_foreign_key :user_id, :users, :on_delete=>:cascade
    end
  end
end