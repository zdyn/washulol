require_relative "migration_helper.rb"

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, :null=>false
      String :username
      String :password
      String :salt
    end
    create_table(:articles) do
      primary_key :id
      String :title, :size=>100
      String :post, :size=>2000
      TrueClass :public
      DateTime :created_at
      DateTime :updated_at
    end
    create_table(:events) do
      primary_key :id
      String :location, :size=>100
      Date :start_date
      Date :end_date
      Time :start_time, :only_time=>true
      Time :end_time, :only_time=>true
    end
    alter_table(:articles) do
      add_foreign_key :event_id, :events, :on_delete=>:cascade
    end
  end
end