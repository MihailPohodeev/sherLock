class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.references :advertisement
      t.string :image
      
      t.timestamps
    end
  end
end
