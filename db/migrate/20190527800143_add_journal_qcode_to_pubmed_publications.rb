class AddJournalQcodeToPubmedPublications < ActiveRecord::Migration[7.0]
  def change
    add_column 'pubmed.publications', :journal_qcode, :string
  end
end
