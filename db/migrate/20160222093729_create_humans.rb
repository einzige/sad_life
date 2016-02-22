class CreateHumans < Framework::Migration
  use_database :default

  def up
    create_table :humans do |t|
      t.boolean :finished_school, default: false, null: false
    end
  end

  def down
    drop_table :humans
  end
end
