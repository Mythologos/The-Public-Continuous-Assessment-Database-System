class DataUploadersController < ApplicationController
  # This method receives an XLSX file from the upload_mappings view and
  # utilizes it to insert or update data in the Knowledge Topic,
  # Student Learning Outcome, Taxonomy, KT-SLO Mapping, Course,
  # and Instruction relations.
  # params: a .xlsx file inside of the params object.
  def upload_mp
    xlsx_file = params[:xlsx_file]
    [KnowledgeTopic, StudentLearningOutcome, Taxonomy,
     KtSloMapping, Course, Instruction].each do |model|
      model.upload(xlsx_file)
    end
    redirect_to controller: :pages, action: :home
  end

  # This method receives an .xlsx file from the upload_quizzes view and
  # utilizes it to insert or update data in the RRK Quiz,
  # RRK Question, and QuestionTopicMapping relations.
  # params: a .xlsx file inside of the params object.
  def upload_qz
    xlsx_file = params[:xlsx_file]
    [RrkQuiz, RrkQuestion, QuestionTopicMapping].each do |model|
      model.upload(xlsx_file)
    end
    redirect_to controller: :pages, action: :home
  end

  # This method receives a .xlsx file from the upload_rosters view and
  # utilizes it to insert or update data in the Students
  # and Enrollments relations.
  # params: a .xlsx file inside of the params object.
  def upload_rs
    xlsx_file = params[:xlsx_student_file]
    [Student, Enrollment].each do |model|
      model.upload(xlsx_file)
    end
    redirect_to controller: :pages, action: :home
  end
end
