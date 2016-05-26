class CreateStupidModel < ActiveRecord::Migration
  def change
    create_table :stupid_models do |t|
      t.timestamps
    end
  end
end
