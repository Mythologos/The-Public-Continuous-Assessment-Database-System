Rails.application.routes.draw do
  root 'pages#home'

  get 'reports', to: 'pages#reports'
  post 'reports/download_standard',
       to: 'report_generators#download_standard_report'
  post 'reports/download_by_instructor',
       to: 'report_generators#download_instructor_report'

  get 'mapping_uploads', to: 'pages#upload_mappings'
  post 'mapping_uploads/upload', to: 'data_uploaders#upload_mp'

  get 'quiz_uploads', to: 'pages#upload_quizzes'
  post 'quiz_uploads/upload', to: 'data_uploaders#upload_qz'

  get 'roster_uploads', to: 'pages#upload_rosters'
  post 'roster_uploads/upload', to: 'data_uploaders#upload_rs'

  concern :uploadable do
    collection do
      get 'upload' => :upload_page
      post 'upload' => :upload
    end
  end

  resources :answers, concerns: [:uploadable]
  resources :course_sections, concerns: [:uploadable]
  resources :courses, concerns: [:uploadable]
  resources :enrollments, concerns: [:uploadable]
  resources :instructions, concerns: [:uploadable]
  resources :knowledge_topics, concerns: [:uploadable]
  resources :kt_slo_mappings, concerns: [:uploadable]
  resources :question_topic_mappings, concerns: [:uploadable]
  resources :rrk_questions, concerns: [:uploadable]
  resources :rrk_quizzes, concerns: [:uploadable]
  resources :student_learning_outcomes, concerns: [:uploadable]
  resources :students, concerns: [:uploadable]
  resources :taxonomies, concerns: [:uploadable]

  get 'answers/upload/id_mismatch', to: 'answers#id_mismatch_page'
end