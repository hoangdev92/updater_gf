# frozen_string_literal: true

module Constants
  LIST_GEMS_ADD = [
    { name: 'ransack', version: '~> 4.2', condition: '>= 4.2.1' },
    { name: 'devise', version: '~> 4.9', condition: '>= 4.9.4' },
    { name: 'pagy', version: '~> 9.1' },
    { name: 'pundit', version: '~> 2.4' },
    { name: 'rack-cors', version: '~> 2.0', condition: '>= 2.0.1' },
    { name: 'redis', version: '~> 5.3' },
    { name: 'sidekiq', version: '~> 7.3', condition: '>= 7.3.2' },
    { name: 'draper', version: '~> 4.0', condition: '>= 4.0.2' },
    { name: 'paranoia', version: '~> 3.0' },
    { name: 'activeadmin', version: '~> 3.2', condition: '>= 3.2.5' }
  ].freeze

  LIST_GEMS_ADD_DEVELOP = [
    { name: 'pry' },
    { name: 'letter_opener', version: '~> 1.10' },
    { name: 'bullet', version: '~> 7.2' },
    { name: 'better_errors', version: '~> 2.10', condition: '>= 2.10.1' },
    { name: 'binding_of_caller', version: '~> 1.0', condition: '>= 1.0.1' }
  ].freeze
end
