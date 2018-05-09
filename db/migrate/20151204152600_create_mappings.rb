# Migration to create database tables
class CreateMappings < ActiveRecord::Migration
  def change
    create_table :mappings do |t|
      t.string :tag
      t.string :url

      t.timestamps null: false
      t.index :tag
      t.index :url
    end
  end
end
