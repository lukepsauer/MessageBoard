Sequel.migration do
  up do
    create_table(:discs) do
      primary_key :id

      String :title
      String :message
      Date :date
      String :voted
      Integer :likes
      foreign_key :author_id
      foreign_key :post_id
    end

    # Convert all user email data to email records

    alter_table(:posts) do
      drop_column :disc
    end
  end

  down do
    alter_table(:posts) do
      add_column :disc
    end

    # Convert all email records back to user email data

    drop_table(:discs)
  end
end