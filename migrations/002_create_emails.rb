Sequel.migration do
  up do
    create_table(:posts) do
      primary_key :id

      String :title
      String :description
      Array :disc
      Date :date

      foreign_key :user_id
    end

    # Convert all user email data to email records

    alter_table(:users) do
      drop_column :post
    end
  end

  down do
    alter_table(:users) do
      add_column :post
    end

    # Convert all email records back to user email data

    drop_table(:posts)
  end
end