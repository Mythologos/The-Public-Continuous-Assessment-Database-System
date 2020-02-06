class KtSloMapping < ApplicationRecord
  self.primary_keys = :kt_id, :slo_id

  belongs_to :knowledge_topic, foreign_key: :kt_id

  belongs_to :student_learning_outcome, foreign_key: :slo_id

  @kt_id_column = 0
  @sheet_index = 1
  @slo_column_offset = 5

  # This method uses the Mapping file, a .xlsx file, to fill the KT-SLO Mappings
  # relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # This index starts at 1 to avoid the header line.
    index = 1
    # This index starts at 1 because there is no 0th SLO.
    # It serves to go through all SLOs in a row before
    # moving to the next row.

    slo_index = 1
    num_slos = StudentLearningOutcome.active.count
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      if current_row[slo_index + @slo_column_offset] == 'x'
        KtSloMapping.find_or_create_by!(attributes = { kt_id: current_row[@kt_id_column],
                                                       slo_id: slo_index })
      end
      slo_index += 1
      if slo_index > num_slos
        index += 1
        slo_index = 1
      end
    end
  end
end