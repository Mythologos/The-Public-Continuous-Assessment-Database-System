class Taxonomy < ApplicationRecord
  self.primary_key = :taxonomic_id

  has_many :rrk_questions, foreign_key: :taxonomic_id

  @sheet_index = 6
  @taxonomic_id_column = 0
  @taxonomic_name_column = 1
  @taxonomic_description_column = 2

  # This method uses the Mapping file, a .xlsx file, to fill the Taxonomies
  # relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # The index starts at 1 in order to
    # avoid reading the header line of the file.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      # The following conditions differ only in whether
      # a taxonomic description exists for the data.
      Taxonomy.find_or_create_by!(attributes = { taxonomic_id: current_row[@taxonomic_id_column],
                                                 taxonomic_name: current_row[@taxonomic_name_column],
                                                 taxonomic_description: get_description(current_row[@taxonomic_description_column]) })
      index += 1
    end
  end

  private

  # This function returns a taxonomy's description if it is present.
  # Otherwise, it returns nil.
  # params: a cell of the .xlsx file containing the description--a string.
  # return: the description_cell's contents or nil.
  def self.get_description(description_cell)
    description_cell.present? ? description_cell : nil
  end
end