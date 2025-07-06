# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin 'chartkick', to: 'chartkick.js'
pin 'Chart.bundle', to: 'Chart.bundle.js'

pin "theme_toggle", to: "theme_toggle.js"
pin "picmo" # @5.8.5
pin "@picmo/popup-picker", to: "@picmo--popup-picker.js" # @5.8.5
pin_all_from "app/javascript/controllers", under: "controllers"


pin "dropzone" # @6.0.0
pin "just-extend" # @5.1.1
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.0.200
