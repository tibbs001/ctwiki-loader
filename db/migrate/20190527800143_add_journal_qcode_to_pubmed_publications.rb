class AddNameToPubmedPublications < ActiveRecord::Migration
  def change
    add_column 'pubmed.publications', :name, :string
  end
end
